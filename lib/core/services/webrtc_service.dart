import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCService {
  WebRTCService();

  Function(RTCIceCandidate candidate)? onIceCandidate;

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  MediaStream? _localStream;
  RTCPeerConnection? peerConnection;

  bool micEnabled = true;
  bool cameraEnabled = true;
  bool speakerEnabled = true;

  bool _renderersInitialized = false;

  /// STUN / TURN servers for NAT traversal.
  final Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun.l.google.com:19302',
          'stun:stun1.l.google.com:19302',
        ],
      },
      {
        'urls': [
          'turn:openrelay.metered.ca:80',
          'turn:openrelay.metered.ca:443',
          'turn:openrelay.metered.ca:443?transport=tcp',
        ],
        'username': 'openrelayproject',
        'credential': 'openrelayproject',
      },
    ],
  };

  /// Initialize renderers.
  ///
  /// Idempotent: the renderers live for the app lifetime (the service is a
  /// singleton), so they are initialized only once and never re-created on
  /// every call. Disposing them per call breaks `srcObject` on the next
  /// call ("RTCVideoRenderer is disposed").
  Future<void> initialize() async {
    if (_renderersInitialized) return;
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    _renderersInitialized = true;
  }

  /// Open camera and microphone.
  Future<void> openUserMedia() async {
    final mediaConstraints = {
      'audio': true,
      'video': {'facingMode': 'user'},
    };

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    localRenderer.srcObject = _localStream;
  }

  /// Create the RTCPeerConnection and attach local tracks.
  Future<void> initializePeerConnection() async {
    peerConnection = await createPeerConnection(configuration);

    for (final track in _localStream!.getTracks()) {
      await peerConnection!.addTrack(track, _localStream!);
    }

    peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isEmpty) return;
      remoteRenderer.srcObject = event.streams.first;
      debugPrint('Remote stream received');
    };

    peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      debugPrint('ICE candidate generated');
      onIceCandidate?.call(candidate);
    };

    peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      debugPrint('Connection state: $state');
    };
  }

  /// Create an SDP offer (caller).
  Future<RTCSessionDescription> createOffer() async {
    final pc = _requirePeerConnection();
    final offer = await pc.createOffer();
    await pc.setLocalDescription(offer);
    debugPrint('Offer created');
    return offer;
  }

  /// Create an SDP answer (callee).
  Future<RTCSessionDescription> createAnswer() async {
    final pc = _requirePeerConnection();
    final answer = await pc.createAnswer();
    await pc.setLocalDescription(answer);
    debugPrint('Answer created');
    return answer;
  }

  /// Set the remote SDP description.
  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    if (peerConnection == null) return;
    await peerConnection!.setRemoteDescription(description);
    debugPrint('Remote description set');
  }

  /// Add a remote ICE candidate.
  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    if (peerConnection == null) return;
    await peerConnection!.addCandidate(candidate);
    debugPrint('ICE candidate added');
  }

  /// Toggle microphone.
  void toggleMicrophone() {
    if (_localStream == null) return;
    micEnabled = !micEnabled;
    for (final track in _localStream!.getAudioTracks()) {
      track.enabled = micEnabled;
    }
  }

  /// Toggle camera.
  void toggleCamera() {
    if (_localStream == null) return;
    cameraEnabled = !cameraEnabled;
    for (final track in _localStream!.getVideoTracks()) {
      track.enabled = cameraEnabled;
    }
  }

  /// Switch between front/back camera.
  Future<void> switchCamera() async {
    if (_localStream == null) return;
    final videoTrack = _localStream!.getVideoTracks().first;
    await Helper.switchCamera(videoTrack);
  }

  /// Toggle the speaker phone output (mobile only; no-op safe elsewhere).
  Future<void> toggleSpeaker() async {
    speakerEnabled = !speakerEnabled;
    final canControlSpeaker =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    if (canControlSpeaker) {
      try {
        await Helper.setSpeakerphoneOn(speakerEnabled);
      } catch (e) {
        debugPrint('setSpeakerphoneOn error: $e');
      }
    }
  }

  /// Close the peer connection and streams. Leaves the renderers alive so
  /// they can be reused by the next call.
  Future<void> closeCall() async {
    try {
      await peerConnection?.close();
      await _localStream?.dispose();
      localRenderer.srcObject = null;
      remoteRenderer.srcObject = null;
      peerConnection = null;
      _localStream = null;
    } catch (e) {
      debugPrint('closeCall error: $e');
    }
  }

  /// Full teardown of renderers and connections. Only call when the app is
  /// shutting down; the renderers cannot be reused afterwards.
  Future<void> disposeService() async {
    try {
      await closeCall();
      await localRenderer.dispose();
      await remoteRenderer.dispose();
      _renderersInitialized = false;
    } catch (e) {
      debugPrint('disposeService error: $e');
    }
  }

  RTCPeerConnection _requirePeerConnection() {
    if (peerConnection == null) {
      throw StateError('Peer connection not initialized');
    }
    return peerConnection!;
  }
}
