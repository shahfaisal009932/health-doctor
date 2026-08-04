import 'package:get/get.dart';

import '../../core/services/webrtc_service.dart';
import '../../data/repositories/appointment_repository.dart';
import '../../data/repositories/call_repository.dart';
import 'call_controller.dart';

class CallBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<WebRTCService>(WebRTCService(), permanent: true);
    Get.put<CallRepository>(CallRepository(), permanent: true);
    Get.put<AppointmentRepository>(AppointmentRepository(), permanent: true);
    Get.lazyPut<CallController>(
      () => CallController(Get.find(), Get.find(), Get.find()),
    );
  }
}
