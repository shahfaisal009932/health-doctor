import 'package:get/get.dart';

/// Drives the selected tab in the client dashboard bottom navigation so
/// other screens (e.g. the home hero card) can switch tabs.
class ClientTabController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void switchTab(int index) {
    currentIndex.value = index;
  }
}
