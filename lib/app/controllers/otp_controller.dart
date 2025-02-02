// lib/app/controllers/otp_controller.dart

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/repositories/auth_repository.dart';

class OtpController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final GetStorage storage = GetStorage();

  var phoneNumber = ''.obs;
  var otpCode = ''.obs;
  var isNewUser = false.obs;
  var isLoading = false.obs;

  // For development: store the OTP that comes from the backend
  var devOtp = ''.obs;

  @override
  void onInit() {
    final args = Get.arguments ?? {};
    phoneNumber.value = args['phone'] ?? '';
    isNewUser.value = args['isNewUser'] ?? false;
    devOtp.value = args['devOtp'] ?? ''; // <-- Retrieve the passed OTP
    super.onInit();
  }

  void updateOtp(String value) {
    otpCode.value = value;
  }

  Future<void> verifyOtp() async {
    if (otpCode.value.isEmpty) {
      Get.snackbar('Error', 'Please enter OTP');
      return;
    }

    try {
      isLoading.value = true;

      final data = await _authRepo.verifyOtp(phoneNumber.value, otpCode.value);

      if (isNewUser.value) {
        // Navigate to Complete Signup if new user
        Get.toNamed('/complete-signup',
            arguments: {'phone': phoneNumber.value});
      } else {
        // Store the token for existing users
        final token = data['token'];
        if (token != null) {
          storage.write('token', token);
          Get.snackbar('Success', 'Login successful!');
          Get.offAllNamed('/dashboard');
        } else {
          Get.snackbar('Error', 'Token not received');
        }
      }
    } catch (e) {
      Get.snackbar('OTP Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void resendOtp() {
    // Implement your resend logic here
  }
}
