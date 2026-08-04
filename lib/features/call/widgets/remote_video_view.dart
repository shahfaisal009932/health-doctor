import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Full-screen remote participant video (or the waiting placeholder).
class RemoteVideoView extends StatelessWidget {
  final RTCVideoRenderer renderer;
  final bool initializing;
  final bool isLoading;
  final String? role;

  const RemoteVideoView({
    super.key,
    required this.renderer,
    required this.initializing,
    required this.isLoading,
    this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: renderer.srcObject == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (initializing || isLoading)
                    const CircularProgressIndicator(color: Colors.white)
                  else ...[
                    const Icon(
                      Icons.person_add,
                      size: 80,
                      color: Colors.white38,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      role == 'doctor'
                          ? 'Waiting for the patient to join...'
                          : 'Waiting for the doctor to start...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (role == 'doctor')
                      const Text(
                        'Once the call starts, the patient can join automatically.',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                  ],
                ],
              ),
            )
          : RTCVideoView(
              renderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
    );
  }
}
