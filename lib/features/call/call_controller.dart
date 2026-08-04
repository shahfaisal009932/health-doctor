import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../core/exceptions/app_exception.dart';
import '../../core/exceptions/firebase_error_mapper.dart';
import '../../core/services/webrtc_service.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../data/repositories/appointment_repository.dart';
import '../../data/repositories/call_repository.dart';

class CallController extends GetxController {
  final WebRTCService _webRTCService;
  final CallRepository _repository;
  final AppointmentRepository _appointmentRepository;

  CallController(
    this._webRTCService,
    this._repository,
    this._appointmentRepository,
  );

  StreamSubscription<DocumentSnapshot>? _callSubscription;
  final List<StreamSubscription<QuerySnapshot>> _candidateSubscriptions = [];

  bool _remoteDescriptionSet = false;
  bool _initialized = false;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxnString _callId = RxnString();
  String? get callId => _callId.value;
  bool get hasActiveCall => _callId.value != null;

  // ---- Appointment-linked call metadata ----
  final RxnString _appointmentId = RxnString();
  String? get appointmentId => _appointmentId.value;
  final RxnString _role = RxnString();
  String? get role => _role.value;
  final RxnString _participantName = RxnString();
  String? get participantName => _participantName.value;
  String? _clientId;
  DateTime? _startedAt;

  final RxBool _micEnabled = true.obs;
  bool get micEnabled => _micEnabled.value;

  final RxBool _cameraEnabled = true.obs;
  bool get cameraEnabled => _cameraEnabled.value;

  final RxBool _speakerEnabled = true.obs;
  bool get speakerEnabled => _speakerEnabled.value;

  final List<RTCIceCandidate> _pendingIceCandidates = [];

  RTCVideoRenderer get localRenderer => _webRTCService.localRenderer;
  RTCVideoRenderer get remoteRenderer => _webRTCService.remoteRenderer;

  @override
  void onClose() {
    _cleanup();
    super.onClose();
  }

  /// Configure an appointment-linked call before joining/creating.
  void setupAppointmentCall({
    required String appointmentId,
    required String role,
    String? participantName,
    String? clientId,
    String? callId,
  }) {
    _appointmentId.value = appointmentId;
    _role.value = role;
    _participantName.value = participantName;
    _clientId = clientId;
    if (callId != null && callId.isNotEmpty) {
      _callId.value = callId;
    }
  }

  /// Initialize WebRTC with camera + microphone.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _isLoading.value = true;
    try {
      await _webRTCService.initialize();
      await _webRTCService.openUserMedia();
      await _webRTCService.initializePeerConnection();
    } catch (e) {
      AppSnackbar.showError('Failed to start camera/microphone. $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Create a new call (caller). Creates an appointment-linked call when an
  /// appointment is configured, otherwise a standalone adhoc call.
  Future<void> createCall() async {
    _isLoading.value = true;
    try {
      _startedAt ??= DateTime.now();

      // Buffer local ICE candidates until the call document is committed
      // server-side. Candidates produced before the doc exists are denied by
      // the rules' participant checks (the doc cannot be read yet), which
      // would poison the write stream and kill the call doc + offer writes.
      _webRTCService.onIceCandidate = (RTCIceCandidate candidate) {
        _pendingIceCandidates.add(candidate);
      };

      // 1. Create the SDP offer first (starts ICE gathering into the buffer).
      final RTCSessionDescription offer = await _webRTCService.createOffer();

      // 2. Create the call WITH the offer in one atomic write.
      _callId.value = await _repository.createCall(
        appointmentId: _appointmentId.value,
        doctorId: FirebaseAuth.instance.currentUser?.uid,
        clientId: _clientId,
        offer: offer,
      );

      // 3. Link the appointment to the call (non-fatal if it races teardown).
      await _linkAppointmentCallId();

      // 4. Wait until the call doc is visible to the rules engine server-side.
      await _waitForCallDocServer(_callId.value!);

      // 5. Stream candidates live now that the doc exists, then upload the
      // candidates buffered while the doc was still being committed.
      _webRTCService.onIceCandidate = (RTCIceCandidate candidate) async {
        try {
          await _repository.addCallerCandidate(
            callId: _callId.value!,
            candidate: candidate,
          );
        } catch (e) {
          debugPrint('ICE candidate upload error: $e');
        }
      };
      await _flushBufferedIceCandidates();

      await _listenCallUpdates();
      _listenIceCandidates(isCaller: true);

      AppSnackbar.showInfo(
        _appointmentId.value != null
            ? 'Consultation call started. Waiting for the patient to join.'
            : 'Call ID: ${_callId.value} - Share it with the patient',
        title: 'Call Created',
      );
    } on AppException catch (e) {
      AppSnackbar.showError(e.message);
    } catch (e) {
      AppSnackbar.showError(FirebaseErrorMapper.map(e).message);
    } finally {
      _isLoading.value = false;
    }
  }

  /// Link the appointment to the newly created call. Non-fatal: the link may
  /// already exist or the update may race with the call teardown.
  Future<void> _linkAppointmentCallId() async {
    final appointmentId = _appointmentId.value;
    final callId = _callId.value;
    if (appointmentId == null || appointmentId.isEmpty || callId == null) {
      return;
    }
    try {
      await _appointmentRepository.updateAppointmentCallId(
        appointmentId: appointmentId,
        callId: callId,
      );
    } catch (e) {
      debugPrint('linkAppointmentCallId error (ignored): $e');
    }
  }

  /// Poll the server until the call document is visible to the rules engine.
  Future<void> _waitForCallDocServer(String callId) async {
    for (var i = 0; i < 20; i++) {
      if (await _repository.callDocExistsOnServer(callId)) return;
      await Future.delayed(const Duration(milliseconds: 250));
    }
    debugPrint('Call doc not visible server-side after polling: $callId');
  }

  /// Upload the local candidates buffered while the call doc did not exist.
  Future<void> _flushBufferedIceCandidates() async {
    final buffered = List<RTCIceCandidate>.from(_pendingIceCandidates);
    _pendingIceCandidates.clear();
    for (final candidate in buffered) {
      try {
        await _repository.addCallerCandidate(
          callId: _callId.value!,
          candidate: candidate,
        );
      } catch (e) {
        debugPrint('Buffered ICE candidate upload error: $e');
      }
    }
  }

  /// Join an appointment-linked call (client side). Verifies access and
  /// waits for the doctor to start the consultation. Returns true if the
  /// call was successfully joined.
  Future<bool> joinAppointmentCall(String appointmentId) async {
    _isLoading.value = true;
    try {
      await _repository.verifyAccessForAppointment(appointmentId);

      final doc = await _repository.getCallById(appointmentId);
      if (doc == null) {
        throw const AppException(
          'The doctor has not started the consultation yet. Please try again in a moment.',
        );
      }

      final data = doc.data() as Map<String, dynamic>;
      final offer = data['offer'];
      if (offer == null) {
        throw const AppException(
          'The doctor has not started the consultation yet. Please try again in a moment.',
        );
      }

      _callId.value = appointmentId;
      _startedAt ??= DateTime.now();

      final RTCSessionDescription remoteOffer = RTCSessionDescription(
        offer['sdp'],
        offer['type'],
      );

      await _webRTCService.setRemoteDescription(remoteOffer);
      _remoteDescriptionSet = true;

      final RTCSessionDescription answer = await _webRTCService.createAnswer();
      await _repository.saveAnswer(callId: appointmentId, answer: answer);

      _webRTCService.onIceCandidate = (RTCIceCandidate candidate) async {
        await _repository.addCalleeCandidate(
          callId: appointmentId,
          candidate: candidate,
        );
      };

      await _listenCallUpdates();
      _listenIceCandidates(isCaller: false);
      return true;
    } on AppException catch (e) {
      AppSnackbar.showError(e.message);
      return false;
    } catch (e) {
      AppSnackbar.showError(FirebaseErrorMapper.map(e).message);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Join an existing adhoc call by ID (callee).
  Future<void> joinCall(String callId) async {
    _isLoading.value = true;
    try {
      final doc = await _repository.getCallById(callId);
      if (doc == null) {
        throw const AppException(
          'Call not found. Check the Call ID and try again.',
        );
      }

      final data = doc.data() as Map<String, dynamic>;
      final offer = data['offer'];
      if (offer == null) {
        throw const AppException(
          'This call has not started yet. Ask the caller to create the call first.',
        );
      }

      _callId.value = callId;
      _startedAt ??= DateTime.now();

      final RTCSessionDescription remoteOffer = RTCSessionDescription(
        offer['sdp'],
        offer['type'],
      );

      await _webRTCService.setRemoteDescription(remoteOffer);
      _remoteDescriptionSet = true;

      final RTCSessionDescription answer = await _webRTCService.createAnswer();
      await _repository.saveAnswer(callId: callId, answer: answer);

      _webRTCService.onIceCandidate = (RTCIceCandidate candidate) async {
        await _repository.addCalleeCandidate(
          callId: callId,
          candidate: candidate,
        );
      };

      await _listenCallUpdates();
      _listenIceCandidates(isCaller: false);
    } on AppException catch (e) {
      AppSnackbar.showError(e.message);
    } catch (e) {
      AppSnackbar.showError(FirebaseErrorMapper.map(e).message);
    } finally {
      _isLoading.value = false;
    }
  }

  /// End and clean up the current call. For appointment-linked calls this
  /// saves the call history and marks the appointment as Completed.
  Future<void> endCall() async {
    final id = _callId.value;
    final appointmentId = _appointmentId.value;
    final role = _role.value;

    try {
      if (id != null && appointmentId != null && appointmentId.isNotEmpty) {
        final doc = await _repository.getCallById(id);
        final data = doc?.data() as Map<String, dynamic>? ?? {};
        final doctorId = data['doctorId']?.toString() ?? '';
        final clientId = data['clientId']?.toString() ?? '';
        final startedAt = _startedAt ?? DateTime.now();

        try {
          await _repository.saveCallHistory(
            callId: id,
            appointmentId: appointmentId,
            doctorId: doctorId,
            clientId: clientId,
            startedAt: startedAt,
            endedAt: DateTime.now(),
          );
          // Mark the consultation as completed (idempotent on both sides).
          await _repository.completeAppointment(appointmentId);
        } catch (e) {
          debugPrint('endCall history/complete error: $e');
        }
      }

      if (id != null) {
        await _callSubscription?.cancel();
        for (final sub in _candidateSubscriptions) {
          await sub.cancel();
        }
        _candidateSubscriptions.clear();
        _callSubscription = null;
        await _repository.clearCall(id);
      }
      await _webRTCService.closeCall();

      if (appointmentId != null && role != null) {
        AppSnackbar.showInfo('Call ended. Consultation marked as completed.');
      }
    } catch (e) {
      debugPrint('endCall error: $e');
    } finally {
      _callId.value = null;
      _appointmentId.value = null;
      _role.value = null;
      _remoteDescriptionSet = false;
      _pendingIceCandidates.clear();
    }
  }

  /// Toggle microphone.
  void toggleMic() {
    _webRTCService.toggleMicrophone();
    _micEnabled.value = !_micEnabled.value;
  }

  /// Toggle camera.
  void toggleCamera() {
    _webRTCService.toggleCamera();
    _cameraEnabled.value = !_cameraEnabled.value;
  }

  /// Toggle the speaker phone output.
  Future<void> toggleSpeaker() async {
    await _webRTCService.toggleSpeaker();
    _speakerEnabled.value = _webRTCService.speakerEnabled;
  }

  /// Switch between front/back camera.
  Future<void> switchCamera() async {
    await _webRTCService.switchCamera();
  }

  Future<void> _listenCallUpdates() async {
    final id = _callId.value;
    if (id == null) return;

    await _callSubscription?.cancel();
    _callSubscription = _repository
        .listenCall(id)
        .listen(
          (event) async {
            if (!event.exists) {
              // The call document was removed by the remote participant.
              if (_callId.value != null) {
                debugPrint('Call ended by remote user (doc removed)');
                await _webRTCService.closeCall();
                _callId.value = null;
                _remoteDescriptionSet = false;
                _pendingIceCandidates.clear();
                AppSnackbar.showInfo('The consultation call has ended.');
              }
              return;
            }

            final data = event.data() as Map<String, dynamic>;

            if (data['answer'] != null && !_remoteDescriptionSet) {
              final answer = RTCSessionDescription(
                data['answer']['sdp'],
                data['answer']['type'],
              );

              await _webRTCService.setRemoteDescription(answer);
              _remoteDescriptionSet = true;

              debugPrint(
                'Answer received, flushing ${_pendingIceCandidates.length} pending candidates',
              );
              await _flushPendingIceCandidates();
            }
          },
          onError: (Object error) {
            // Stream teardown race: the call doc can be removed while this
            // listener is still attached. Never let a stream error crash the app.
            debugPrint('Call document listen error: $error');
            AppSnackbar.showError(
              'Call connection interrupted. ${FirebaseErrorMapper.map(error).message}',
            );
          },
        );
  }

  void _listenIceCandidates({required bool isCaller}) {
    final id = _callId.value;
    if (id == null) return;

    final stream = isCaller
        ? _repository.calleeCandidates(id)
        : _repository.callerCandidates(id);

    final sub = stream.listen(
      (snapshot) async {
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final candidate = RTCIceCandidate(
            data['candidate'],
            data['sdpMid'],
            data['sdpMLineIndex'],
          );
          await _addIceCandidate(candidate);
        }
      },
      onError: (Object error) {
        debugPrint('ICE candidate listen error: $error');
      },
    );

    _candidateSubscriptions.add(sub);
  }

  Future<void> _addIceCandidate(RTCIceCandidate candidate) async {
    if (_remoteDescriptionSet) {
      await _webRTCService.addIceCandidate(candidate);
    } else {
      _pendingIceCandidates.add(candidate);
    }
  }

  Future<void> _flushPendingIceCandidates() async {
    final pending = List<RTCIceCandidate>.from(_pendingIceCandidates);
    _pendingIceCandidates.clear();

    for (final candidate in pending) {
      await _webRTCService.addIceCandidate(candidate);
    }
  }

  Future<void> _cleanup() async {
    await _callSubscription?.cancel();
    for (final sub in _candidateSubscriptions) {
      await sub.cancel();
    }
    _candidateSubscriptions.clear();
    _callSubscription = null;
    // Close the peer connection and streams, but keep the shared renderers
    // alive so the next call can start without "RTCVideoRenderer is disposed".
    await _webRTCService.closeCall();
    _callId.value = null;
    _appointmentId.value = null;
    _role.value = null;
    _participantName.value = null;
    _initialized = false;
    _remoteDescriptionSet = false;
    _pendingIceCandidates.clear();
  }
}
