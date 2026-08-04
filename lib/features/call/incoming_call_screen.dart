import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'incoming_call_controller.dart';
import 'widgets/incoming_call_view.dart';

/// Route shown when the client receives an incoming consultation call.
class IncomingCallScreen extends StatelessWidget {
  const IncomingCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IncomingCallController>();
    final call = controller.incoming;

    // The controller nulls `incoming` while tearing down; render an empty
    // frame until the route is popped by the controller.
    if (call == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.shrink(),
      );
    }

    return IncomingCallView(
      doctorName: call.doctorName,
      onAccept: controller.accept,
      onReject: controller.reject,
    );
  }
}
