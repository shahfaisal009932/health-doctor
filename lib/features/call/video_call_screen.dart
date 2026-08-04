import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/permission_helper.dart';
import '../../core/widgets/app_dialog.dart';
import 'call_controller.dart';
import 'widgets/call_badge.dart';
import 'widgets/call_controls.dart';
import 'widgets/create_join_panel.dart';
import 'widgets/join_retry_panel.dart';
import 'widgets/local_video_view.dart';
import 'widgets/permission_denied_view.dart';
import 'widgets/remote_video_view.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final TextEditingController _callIdController = TextEditingController();
  bool _permissionsGranted = false;
  bool _initializing = true;

  String? _appointmentId;
  String? _role;
  String? _participantName;
  String? _clientId;
  String? _joinError;

  CallController? _controller;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _callIdController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final controller = Get.find<CallController>();
    _controller = controller;

    // Parse navigation arguments.
    final argument = Get.arguments;
    if (argument is Map) {
      _appointmentId = argument['appointmentId']?.toString();
      _role = argument['role']?.toString();
      _participantName = argument['participantName']?.toString();
      _clientId = argument['clientId']?.toString();
      final callId = argument['callId']?.toString();
      if (callId != null && callId.isNotEmpty) {
        _callIdController.text = callId;
      }
    } else if (argument is String && argument.isNotEmpty) {
      _callIdController.text = argument;
    }

    final granted = await PermissionHelper.requestVideoCallPermissions();
    if (!mounted) return;

    if (!granted) {
      setState(() {
        _permissionsGranted = false;
        _initializing = false;
      });
      return;
    }

    setState(() {
      _permissionsGranted = true;
    });

    await controller.initialize();

    if (!mounted) return;
    setState(() {
      _initializing = false;
    });

    if (_appointmentId != null && _appointmentId!.isNotEmpty && _role != null) {
      controller.setupAppointmentCall(
        appointmentId: _appointmentId!,
        role: _role!,
        participantName: _participantName,
        clientId: _clientId,
        callId: _callIdController.text,
      );
      if (_role == 'doctor') {
        await controller.createCall();
      } else {
        await _tryJoin();
      }
    } else if (_callIdController.text.trim().isNotEmpty) {
      await controller.joinCall(_callIdController.text.trim());
    }
  }

  Future<void> _tryJoin() async {
    final controller = _controller;
    final appointmentId = _appointmentId;
    if (controller == null || appointmentId == null) return;

    setState(() => _joinError = null);
    final joined = await controller.joinAppointmentCall(appointmentId);
    if (!mounted) return;
    if (!joined) {
      setState(() {
        _joinError =
            'The doctor has not started the consultation yet.\nTap Retry in a moment to connect.';
      });
    }
  }

  Future<void> _retryPermissions() async {
    final granted = await PermissionHelper.requestVideoCallPermissions();
    if (!mounted) return;
    setState(() => _permissionsGranted = granted);
    if (granted) {
      await _controller?.initialize();
      if (mounted) setState(() => _initializing = false);
    }
  }

  Future<void> _onEndPressed(CallController controller) async {
    final isAppointmentCall = _appointmentId != null;
    await controller.endCall();

    if (!mounted) return;
    if (isAppointmentCall) {
      await showInfoDialog(
        title: 'Call Ended',
        message:
            'The consultation has ended and the appointment has been marked as completed.',
      );
    }
    if (mounted) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CallController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Video Consultation',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: !_permissionsGranted
          ? PermissionDeniedView(
              onOpenSettings: () => PermissionHelper.openSettings(),
              onRetry: _retryPermissions,
            )
          : Obx(
              () => Stack(
                children: [
                  CallBadge(
                    appointmentId: _appointmentId,
                    participantName: _participantName,
                    callId: controller.callId,
                  ),

                  RemoteVideoView(
                    renderer: controller.remoteRenderer,
                    initializing: _initializing,
                    isLoading: controller.isLoading,
                    role: _role,
                  ),

                  if (!controller.hasActiveCall &&
                      !_initializing &&
                      !controller.isLoading)
                    CreateJoinPanel(
                      callIdController: _callIdController,
                      isLoading: controller.isLoading,
                      onCreateCall: () => controller.createCall(),
                      onJoinCall: (id) => controller.joinCall(id),
                    ),

                  if (_joinError != null &&
                      !controller.hasActiveCall &&
                      !_initializing &&
                      !controller.isLoading)
                    JoinRetryPanel(
                      joinError: _joinError,
                      isLoading: controller.isLoading,
                      onRetry: _tryJoin,
                    ),

                  LocalVideoView(renderer: controller.localRenderer),

                  CallControls(
                    micEnabled: controller.micEnabled,
                    cameraEnabled: controller.cameraEnabled,
                    speakerEnabled: controller.speakerEnabled,
                    onToggleMic: controller.toggleMic,
                    onToggleCamera: controller.toggleCamera,
                    onToggleSpeaker: controller.toggleSpeaker,
                    onSwitchCamera: controller.switchCamera,
                    onEnd: () => _onEndPressed(controller),
                  ),
                ],
              ),
            ),
    );
  }
}
