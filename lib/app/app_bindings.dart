import 'package:get/get.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/call_notification_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/call_repository.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/call/incoming_call_controller.dart';

/// Global dependency injection bindings.
class AppBindings implements Bindings {
  @override
  void dependencies() {
    // Services (singletons)
    Get.put<AuthService>(AuthService(), permanent: true);

    // Repositories (singletons)
    Get.put<AuthRepository>(AuthRepository(), permanent: true);
    Get.put<DashboardRepository>(DashboardRepository(), permanent: true);
    Get.put<CallRepository>(CallRepository(), permanent: true);

    // Incoming-call support (available from app boot so an incoming push can
    // be presented before the user ever visits a call screen).
    Get.put<CallNotificationService>(CallNotificationService(),
        permanent: true);
    Get.put<IncomingCallController>(
      IncomingCallController(Get.find(), Get.find()),
      permanent: true,
    );

    // Auth controller
    Get.lazyPut<AuthController>(
      () => AuthController(Get.find(), Get.find()),
    );
  }
}
