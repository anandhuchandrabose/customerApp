// lib/app/controllers/home_controller.dart

import 'package:get/get.dart';
import '../data/repositories/home_repository.dart';

class HomeController extends GetxController {
  final HomeRepository _homeRepo = Get.find<HomeRepository>();

  // Observables
  var vendors = <Map<String, dynamic>>[].obs;
  var categories = <Map<String, dynamic>>[].obs;

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeData(); 
  }

  Future<void> fetchHomeData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // 1) Get the entire map with {vendors: [...], categories: [...]}
      final data = await _homeRepo.fetchHomeData();

      // 2) Safely parse and assign vendors
      if (data['vendors'] is List) {
        vendors.value = (data['vendors'] as List)
            .map((v) => v as Map<String, dynamic>)
            .toList();
      } else {
        vendors.clear();
      }

      // 3) Safely parse and assign categories
      if (data['categories'] is List) {
        categories.value = (data['categories'] as List)
            .map((c) => c as Map<String, dynamic>)
            .toList();
      } else {
        categories.clear();
      }

    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
