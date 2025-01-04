// lib/app/controllers/profile_controller.dart

import 'package:get/get.dart';

class ProfileController extends GetxController {
  // Dummy data: userName
  var userName = 'John Doe'.obs;

  @override
  void onInit() {
    super.onInit();
    // If you want to do any initialization or fetch real data, do it here.
    // For now, we'll just rely on the dummy value 'John Doe'.
  }
}
