// lib/app/controllers/login_controller.dart

import 'package:get/get.dart';
import '../data/repositories/auth_repository.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();

  var phoneNumber = ''.obs;
  var isLoading = false.obs;

  void updatePhoneNumber(String value) {
    phoneNumber.value = value;
  }

  Future<void> requestOtp() async {
    if (phoneNumber.value.isEmpty) {
      Get.snackbar('Error', 'Please enter phone number');
      return;
    }
    try {
      isLoading.value = true;

      final data = await _authRepo.requestOtp(phoneNumber.value);
      final bool isNewUser = data['isNewUser'] ?? false;
      final String devOtp = data['otp'] ?? '';

      Get.toNamed('/otp', arguments: {
        'phone': phoneNumber.value,
        'isNewUser': isNewUser,
        'devOtp': devOtp,
      });
    } catch (e) {
      Get.snackbar('OTP Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}