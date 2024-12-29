// lib/app/controllers/home_controller.dart

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/repositories/home_repository.dart';

class HomeController extends GetxController {
  final HomeRepository _homeRepo = Get.find<HomeRepository>();
  final GetStorage storage = GetStorage();

  var vendors = <Map<String, dynamic>>[].obs;
  var categories = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Check if token exists
    final token = storage.read('token');
    if (token == null || token.isEmpty) {
      Get.offAllNamed('/login'); // Redirect to login if no token is found
    } else {
      fetchVendorsAndCategories();
    }
  }

  Future<void> fetchVendorsAndCategories() async {
    try {
      isLoading.value = true;

      // Call the API
      final data = await _homeRepo.getVendorsAndCategories();

      // Parse the response
      vendors.value = List<Map<String, dynamic>>.from(data['vendors'] ?? []);
      categories.value =
          List<Map<String, dynamic>>.from(data['categories'] ?? []);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
