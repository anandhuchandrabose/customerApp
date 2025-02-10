// lib/app/controllers/category_vendors_controller.dart

import 'package:get/get.dart';
import '../data/repositories/home_repository.dart';

class CategoryVendorsController extends GetxController {
  final HomeRepository _homeRepo = Get.find<HomeRepository>();

  var vendors = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // The category name is passed in as Get.arguments
    final String? catName = Get.arguments as String?;
    if (catName != null && catName.isNotEmpty) {
      fetchVendorsByCategory(catName);
    }
  }

  Future<void> fetchVendorsByCategory(String category) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final list = await _homeRepo.fetchVendorsByCategory(category);
      // e.g. fetchVendorsByCategory returns List of Map
      vendors.value = list.cast<Map<String, dynamic>>();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
