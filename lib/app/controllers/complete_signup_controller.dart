// lib/app/controllers/complete_signup_controller.dart

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/repositories/auth_repository.dart';
import '../views/dashboard_view.dart';

class CompleteSignupController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final GetStorage storage = GetStorage();

  // Observable fields for signup data.
  var firstName = ''.obs;
  var lastName = ''.obs;
  var phoneNumber = ''.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    // Retrieve phone number from the passed arguments.
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
    // Validate that the required fields are filled.
    if (firstName.value.isEmpty || lastName.value.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    try {
      isLoading.value = true;

      // Call the completeSignup API.
      final data = await _authRepo.completeSignup(
        phoneNumber.value,
        firstName.value,
        lastName.value,
      );

      // Retrieve the token from the response.
      final token = data['token'];
      if (token != null) {
        // Save the token in persistent storage.
        storage.write('token', token);
        Get.snackbar('Success', 'Signup completed successfully!');

        // Navigate to the dashboard using a fade transition.
        Get.offAll(
          () => DashboardView(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
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
