import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/services/call_notification_service.dart';
import '../../core/services/fcm_message_handler.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../data/repositories/call_repository.dart';
import 'call_controller.dart';
import 'call_state_listener.dart';

/// Immutable payload describing an unanswered, ringing consultation call.
class IncomingCallData {
  const IncomingCallData({
    required this.callId,
    required this.appointmentId,
    required this.doctorName,
  });

  final String callId;
  final String appointmentId;
  final String doctorName;
}

/// Drives the incoming video call presentation for the client.
///
/// A permanent singleton wired to [FcmMessageHandler] so it can present an
/// incoming call from any app state (foreground push, background tap, cold
/// start). Owns the ringtone, the 30s no-answer timeout and the call-document
/// listener that reacts to the doctor cancelling before the client answers.
class IncomingCallController extends GetxController {
  IncomingCallController(this._repository, this._notificationService);

  static const _answerTimeout = Duration(seconds: 30);

  final CallRepository _repository;
  final CallNotificationService _notificationService;
  late final CallStateListener _stateListener = CallStateListener(_repository);

  final Rxn<IncomingCallData> _incoming = Rxn<IncomingCallData>();
  IncomingCallData? get incoming => _incoming.value;
  bool get isRinging => _incoming.value != null;

  Timer? _timeoutTimer;
  bool _screenOpen = false;

  @override
  void onInit() {
    super.onInit();
    FcmMessageHandler.onIncomingCall = _onIncomingCall;

    // A cold start launched by tapping the notification can deliver the
    // payload before the app has booted (and while the splash route is still
    // deciding where to go). Buffer it until the app is on a real screen.
    final pending = FcmMessageHandler.takePendingIncomingCall();
    if (pending != null) {
      _presentWhenReady(pending);
    }
  }

  @override
  void onClose() {
    FcmMessageHandler.onIncomingCall = null;
    _teardown();
    _notificationService.stopRingtone();
    super.onClose();
  }

  /// Answer the call: join the consultation video call as the client.
  Future<void> accept() async {
    final call = _incoming.value;
    if (call == null) return;
    _stopRingingAndClear();
    _openVideoCall(call);
  }

  /// Decline the call: mark it rejected (which notifies the doctor) and
  /// close the incoming screen.
  Future<void> reject() async {
    final call = _incoming.value;
    if (call == null) return;
    _stopRingingAndClear();
    try {
      await _repository.markCallRejected(call.callId);
    } catch (_) {
      // Non-blocking: the local screen is closed regardless.
    }
    _closeIncomingScreen();
  }

  /// Handle a call payload routed by the FCM handler.
  void _onIncomingCall(Map<String, String> data) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;
    if (isRinging) return;
    if (Get.currentRoute == AppRoutes.videoCall) return;
    if (Get.isRegistered<CallController>() &&
        Get.find<CallController>().hasActiveCall) {
      return;
    }

    // The splash route wipes all routes when it routes to a dashboard, which
    // would tear down this screen. Wait for it to finish navigating.
    if (Get.currentRoute == AppRoutes.splash) {
      _presentWhenReady(data);
      return;
    }

    final appointmentId = data['appointmentId'];
    if (appointmentId == null || appointmentId.isEmpty) return;
    final rawCallId = data['callId'];

    final call = IncomingCallData(
      callId: (rawCallId == null || rawCallId.isEmpty)
          ? appointmentId
          : rawCallId,
      appointmentId: appointmentId,
      doctorName: data['doctorName'] ?? 'Doctor',
    );

    _incoming.value = call;
    _screenOpen = true;
    _notificationService.startRingtone();
    _startTimeout();
    _stateListener.onState = _handleState;
    _stateListener.listen(call.callId);

    Get.toNamed(AppRoutes.incomingCall, arguments: {
      'appointmentId': call.appointmentId,
      'callId': call.callId,
      'doctorName': call.doctorName,
    });
  }

  /// React to call-document changes while the client is still ringing.
  void _handleState(CallStateEvent event) {
    final call = _incoming.value;
    if (call == null) return;

    final status = event.status;
    if (status == CallStatus.active) {
      // Answered (e.g. another device accepted): join the consultation.
      _stopRingingAndClear();
      _openVideoCall(call);
    } else if (status == CallStatus.rejected ||
        status == CallStatus.missed) {
      // Closed elsewhere; nothing left to do.
      _stopRingingAndClear();
      _closeIncomingScreen();
    } else if (status == null) {
      // The doctor ended the call before the client answered.
      _stopRingingAndClear();
      _closeIncomingScreen();
      AppSnackbar.showInfo('The doctor ended the call.');
    }
  }

  /// The client did not answer within 30 seconds.
  void _onTimeout() {
    final call = _incoming.value;
    if (call == null) return;
    _stopRingingAndClear();
    _closeIncomingScreen();
    AppSnackbar.showInfo(
      'The call was missed.',
      title: 'Missed Call',
    );
    try {
      _repository.markCallMissed(call.callId);
    } catch (_) {
      // Non-blocking.
    }
  }

  void _startTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(_answerTimeout, _onTimeout);
  }

  /// Present [pending] once the app is past the splash route. The splash
  /// uses `Get.offAllNamed`, which would otherwise tear down the incoming
  /// screen mid-presentation.
  void _presentWhenReady(Map<String, String> pending) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isClosed) return;
      if (Get.currentRoute == AppRoutes.splash) {
        Timer(const Duration(milliseconds: 300), () {
          if (!isClosed) _presentWhenReady(pending);
        });
        return;
      }
      _onIncomingCall(pending);
    });
  }

  void _openVideoCall(IncomingCallData call) {
    Get.offNamed(AppRoutes.videoCall, arguments: {
      'appointmentId': call.appointmentId,
      'callId': call.callId,
      'role': 'client',
      'participantName': call.doctorName,
    });
  }

  void _stopRingingAndClear() {
    _notificationService.stopRingtone();
    _teardown();
    _incoming.value = null;
  }

  void _closeIncomingScreen() {
    if (_screenOpen && Get.currentRoute == AppRoutes.incomingCall) {
      Get.back();
    }
    _screenOpen = false;
  }

  void _teardown() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _stateListener.cancel();
  }
}
