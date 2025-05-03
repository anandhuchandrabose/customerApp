import 'package:get/get.dart';
import '../data/repositories/auth_repository.dart';

class ProfileController extends GetxController {
  // Reactive variables for user data
  var userName = 'user'.obs;
  var email = ''.obs;
  var phoneNumber = ''.obs;
  var addresses = <Map<String, String>>[].obs;
  var notificationsEnabled = true.obs;

  // Repository for fetching user data
  final AuthRepository _authRepo = Get.find<AuthRepository>();

  @override
  void onInit() {
    super.onInit();
    // Fetch user data when the controller is initialized
    fetchUserData();
  }

  // Fetch user data from the repository
  Future<void> fetchUserData() async {
    try {
      // Assuming AuthRepository has a method to get user profile
      final userData = await _authRepo.getUserProfile();
      userName.value = userData['name'] ?? 'user';
      email.value = userData['email'] ?? '';
      phoneNumber.value = userData['phone'] ?? '';
      // Fetch addresses (assuming the repository provides this)
      addresses.value = (userData['addresses'] as List<dynamic>?)?.cast<Map<String, String>>() ?? [];
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data: $e');
    }
  }

  // Add a new address
  void addAddress() {
    // For simplicity, we'll add a dummy address; in a real app, show a form
    addresses.add({
      'title': 'Home',
      'details': '123 Main St, City, Country',
    });
    Get.snackbar('Success', 'Address added');
  }

  // Edit an existing address
  void editAddress(int index) {
    // For simplicity, update with dummy data; in a real app, show a form
    addresses[index] = {
      'title': 'Home (Updated)',
      'details': '456 Main St, City, Country',
    };
    Get.snackbar('Success', 'Address updated');
  }

  // Navigate to address management page
  void navigateToAddress() {
    Get.toNamed('/address'); // Assumes route exists
  }

  // Toggle notifications
  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    Get.snackbar('Notifications', value ? 'Enabled' : 'Disabled');
  }

  // Navigation methods for profile options
  void navigateToCoupons() {
    Get.toNamed('/coupons'); // Assumes route exists
  }

  void navigateToHelp() {
    Get.toNamed('/help'); // Assumes route exists
  }

  void navigateToPrivacy() {
    Get.toNamed('/privacy'); // Assumes route exists
  }

  void navigateToLegal() {
    Get.toNamed('/legal'); // Assumes route exists
  }

  void navigateToFAQ() {
    Get.toNamed('/faq'); // Assumes route exists
  }

  // Logout function
  void logout() async {
    try {
      await _authRepo.logout();
      // Navigate to login screen and remove previous routes
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Error', 'Logout failed: $e');
    }
  }
}