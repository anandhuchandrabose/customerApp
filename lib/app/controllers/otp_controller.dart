import 'dart:async';
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

  // Timer related properties
  var remainingTime = 0.obs;
  Timer? _timer;
  
  // Timer duration in seconds (e.g., 60 seconds)
  static const int timerDuration = 60;

  // Getter for otp (used by the view)
  RxString get otp => otpCode;

  @override
  void onInit() {
    final args = Get.arguments ?? {};
    phoneNumber.value = args['phone'] ?? '';
    isNewUser.value = args['isNewUser'] ?? false;
    devOtp.value = args['devOtp'] ?? ''; // <-- Retrieve the passed OTP
    
    // Start the timer when controller initializes
    startTimer();
    
    super.onInit();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
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
        // Navigate to Welcome Onboarding for new users
        Get.toNamed('/welcome-onboarding', arguments: {'phone': phoneNumber.value});
      } else {
        final token = data['token'];
        final customer = data['customer'];

        if (token != null && customer != null) {
          // Store token and customer data
          storage.write('token', token);
          storage.write('customerId', customer['id']);
          storage.write('customerName', customer['name']);
          storage.write('customerMobile', customer['mobileNumber']);

          // Get.snackbar('Success', 'Login successful!');
          Get.offAllNamed('/dashboard');
        } else {
          Get.snackbar('Error', 'Login data incomplete');
        }
      }
    } catch (e) {
      Get.snackbar('OTP Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (remainingTime.value > 0) {
      return; // Timer still running
    }

    try {
      isLoading.value = true;

      // Call your auth repository to resend OTP
      final data = await _authRepo.requestOtp(phoneNumber.value);
      
      // Update devOtp if returned from backend
      if (data['devOtp'] != null) {
        devOtp.value = data['devOtp'];
      }

      // Reset OTP field
      otpCode.value = '';

      // Start timer again
      startTimer();

      Get.snackbar('Success', 'OTP sent successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to resend OTP: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void startTimer() {
    remainingTime.value = timerDuration;
    _timer?.cancel();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.value > 0) {
        remainingTime.value--;
      } else {
        timer.cancel();
      }
    });
  }

  // Helper method to format time (optional)
  String get formattedTime {
    int minutes = remainingTime.value ~/ 60;
    int seconds = remainingTime.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}