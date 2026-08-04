import 'package:get/get.dart';

import 'auth_controller.dart';

class AuthBinding implements Bindings {
  @override
  void dependencies() {
    // AppBindings already registers AuthRepository and AuthService.
    Get.lazyPut<AuthController>(() => AuthController(
          Get.find(),
          Get.find(),
        ));
  }
}
