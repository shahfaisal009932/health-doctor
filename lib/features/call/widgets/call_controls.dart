import 'package:flutter/material.dart';

/// Bottom call control bar: mute, camera, speaker, switch, end.
class CallControls extends StatelessWidget {
  final bool micEnabled;
  final bool cameraEnabled;
  final bool speakerEnabled;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCamera;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onSwitchCamera;
  final VoidCallback onEnd;

  const CallControls({
    super.key,
    required this.micEnabled,
    required this.cameraEnabled,
    required this.speakerEnabled,
    required this.onToggleMic,
    required this.onToggleCamera,
    required this.onToggleSpeaker,
    required this.onSwitchCamera,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        color: Colors.black54,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _controlButton(
              icon: micEnabled ? Icons.mic : Icons.mic_off,
              backgroundColor: micEnabled ? Colors.white : Colors.red,
              iconColor: micEnabled ? Colors.black : Colors.white,
              onTap: onToggleMic,
              label: micEnabled ? 'Mute' : 'Unmute',
            ),
            _controlButton(
              icon: cameraEnabled ? Icons.videocam : Icons.videocam_off,
              backgroundColor: cameraEnabled ? Colors.white : Colors.red,
              iconColor: cameraEnabled ? Colors.black : Colors.white,
              onTap: onToggleCamera,
              label: cameraEnabled ? 'Cam Off' : 'Cam On',
            ),
            _controlButton(
              icon: speakerEnabled ? Icons.volume_up : Icons.volume_off,
              backgroundColor: Colors.white,
              iconColor: Colors.black,
              onTap: onToggleSpeaker,
              label: speakerEnabled ? 'Speaker' : 'Muted',
            ),
            _controlButton(
              icon: Icons.cameraswitch,
              backgroundColor: Colors.white,
              iconColor: Colors.black,
              onTap: onSwitchCamera,
              label: 'Switch',
            ),
            _controlButton(
              icon: Icons.call_end,
              backgroundColor: Colors.red,
              iconColor: Colors.white,
              onTap: onEnd,
              label: 'End',
              radius: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
    required String label,
    double radius = 28,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor,
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: iconColor),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
