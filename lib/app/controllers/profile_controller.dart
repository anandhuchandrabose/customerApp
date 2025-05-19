import 'package:get/get.dart';
import '../data/repositories/auth_repository.dart';

class ProfileController extends GetxController {
  var userName = 'user'.obs;
  var email = ''.obs;
  var phoneNumber = ''.obs;
  var addresses = <Map<String, String>>[].obs;
  var notificationsEnabled = true.obs;

  final AuthRepository _authRepo = Get.find<AuthRepository>();

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final userData = await _authRepo.getUserProfile();
      userName.value = userData['name'] ?? 'user';
      email.value = userData['email'] ?? '';
      phoneNumber.value = userData['phone'] ?? '';
      addresses.value =
          (userData['addresses'] as List<dynamic>?)?.cast<Map<String, String>>() ?? [];
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data: $e');
    }
  }

  void addAddress() {
    addresses.add({
      'title': 'Home',
      'details': '123 Main St, City, Country',
    });
    Get.snackbar('Success', 'Address added');
  }

  void editAddress(int index) {
    addresses[index] = {
      'title': 'Home (Updated)',
      'details': '456 Main St, City, Country',
    };
    Get.snackbar('Success', 'Address updated');
  }

  void navigateToAddress() {
    Get.toNamed('/address');
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    Get.snackbar('Notifications', value ? 'Enabled' : 'Disabled');
  }

  void navigateToCoupons() => Get.toNamed('/coupons');
  void navigateToHelp() => Get.toNamed('/help');
  void navigateToPrivacy() => Get.toNamed('/privacy');
  void navigateToLegal() => Get.toNamed('/legal');
  void navigateToFAQ() => Get.toNamed('/faq');

  void logout() async {
    try {
      await _authRepo.logout();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Error', 'Logout failed: $e');
    }
  }
}