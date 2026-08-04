import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Small mirrored preview of the local camera feed.
class LocalVideoView extends StatelessWidget {
  final RTCVideoRenderer renderer;

  const LocalVideoView({
    super.key,
    required this.renderer,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      top: 70,
      width: 120,
      height: 170,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white38, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: RTCVideoView(renderer, mirror: true),
        ),
      ),
    );
  }
}
