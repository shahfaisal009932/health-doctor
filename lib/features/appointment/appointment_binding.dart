import 'package:get/get.dart';

import '../../data/repositories/appointment_repository.dart';
import 'appointment_controller.dart';

class AppointmentBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<AppointmentRepository>(AppointmentRepository(), permanent: true);
    Get.lazyPut<AppointmentController>(
      () => AppointmentController(Get.find()),
    );
  }
}
