import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Panel for creating a new call or joining an existing one by ID.
class CreateJoinPanel extends StatelessWidget {
  final TextEditingController callIdController;
  final bool isLoading;
  final VoidCallback onCreateCall;
  final ValueChanged<String> onJoinCall;

  const CreateJoinPanel({
    super.key,
    required this.callIdController,
    required this.isLoading,
    required this.onCreateCall,
    required this.onJoinCall,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 210,
      left: 20,
      right: 20,
      child: Column(
        children: [
          TextField(
            controller: callIdController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black54,
              hintText: 'Enter Call ID to join',
              hintStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_call),
                  onPressed: isLoading ? null : onCreateCall,
                  label: const Text('Create Call'),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                          final id = callIdController.text.trim();
                          if (id.isEmpty) {
                            Get.snackbar(
                              'Missing Call ID',
                              'Enter the Call ID to join.',
                            );
                            return;
                          }
                          onJoinCall(id);
                        },
                  label: const Text('Join Call'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
