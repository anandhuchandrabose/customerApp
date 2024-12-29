// lib/app/controllers/dashboard_controller.dart

import 'package:get/get.dart';

class DashboardController extends GetxController {
  // Currently selected tab index
  var selectedIndex = 0.obs;

  // Change the selected tab
  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }
}
