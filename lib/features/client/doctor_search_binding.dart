import 'package:get/get.dart';

import '../../data/repositories/client_repository.dart';
import 'doctor_search_controller.dart';

class DoctorSearchBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorSearchController>(
      () => DoctorSearchController(Get.find<ClientRepository>()),
    );
  }
}
