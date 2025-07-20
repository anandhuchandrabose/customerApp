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
  if (firstName.value.isEmpty || lastName.value.isEmpty) {
    Get.snackbar('Error', 'Please fill all fields');
    return;
  }

  try {
    isLoading.value = true;

    // Send request
    final data = await _authRepo.completeSignup(
      phoneNumber.value,
      firstName.value,
      lastName.value,
    );

    print('API response: $data');

    final token = data['token'];

    if (token != null) {
      // Store token and user info you already have locally
      storage.write('token', token);
      storage.write('customerName', '${firstName.value} ${lastName.value}');
      storage.write('customerMobile', phoneNumber.value);

      // Get.snackbar('Success', 'Signup completed successfully!');
      Get.offAllNamed('/dashboard');
    } else {
      Get.snackbar('Error', 'Token not received from server');
    }
  } catch (e) {
    Get.snackbar('Signup Error', e.toString());
  } finally {
    isLoading.value = false;
  }
}
}