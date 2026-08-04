import 'package:get/get.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/client_repository.dart';
import '../../data/repositories/notification_repository.dart';
import 'client_controller.dart';
import 'client_tab_controller.dart';
import 'doctor_search_controller.dart';

class ClientBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ClientRepository>(ClientRepository(), permanent: true);
    Get.put<NotificationRepository>(NotificationRepository(), permanent: true);
    Get.put<ClientTabController>(ClientTabController(), permanent: true);
    // permanent: the controller (and its realtime Firestore streams) must
    // survive route disposal (e.g. Get.offAllNamed after booking) so the
    // client keeps receiving live appointment status updates. Repeated
    // ClientBinding attach is a no-op thanks to GetX's _insert guard, so the
    // same bound instance (and its active streams) is reused every time.
    Get.put<ClientController>(
      ClientController(
        Get.find(),
        Get.find(),
        Get.find<AuthRepository>(),
      ),
      permanent: true,
    );
    Get.lazyPut<DoctorSearchController>(
      () => DoctorSearchController(Get.find<ClientRepository>()),
    );
  }
}
