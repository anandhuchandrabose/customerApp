// lib/app/controllers/complete_signup_controller.dart

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/repositories/auth_repository.dart';

class CompleteSignupController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final GetStorage storage = GetStorage();

  var firstName = ''.obs;
  var lastName = ''.obs;
  var phoneNumber = ''.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    final args = Get.arguments ?? {};
    phoneNumber.value = args['phone'] ?? '';
    super.onInit();
  }

  void updateFirstName(String value) {
    firstName.value = value;
  }

  void updateLastName(String value) {
    lastName.value = value;
  }

  Future<void> completeSignup() async {
    if (firstName.value.isEmpty || lastName.value.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    try {
      isLoading.value = true;

      final data = await _authRepo.completeSignup(
        phoneNumber.value,
        firstName.value,
        lastName.value,
      );

      // Store the token
      final token = data['token'];
      if (token != null) {
        // Save the token in GetStorage
        storage.write('token', token);

        // Navigate to Home
        Get.snackbar('Success', 'Signup successful!');
        Get.offAllNamed('/dashboard');
      } else {
        Get.snackbar('Error', 'Token not received');
      }
    } catch (e) {
      Get.snackbar('Signup Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
