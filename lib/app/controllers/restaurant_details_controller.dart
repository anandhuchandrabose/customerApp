// lib/app/controllers/restaurant_details_controller.dart

import 'package:get/get.dart';
import '../data/repositories/restaurant_repository.dart';

class RestaurantDetailsController extends GetxController {
  final RestaurantRepository _restaurantRepo = Get.find<RestaurantRepository>();

  var vendorId = ''.obs;
  var dishes = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Read vendorId from navigation arguments
    final args = Get.arguments ?? {};
    vendorId.value = args['vendorId'] ?? '';

    // Fetch dishes for the vendor
    fetchDishes();
  }

  Future<void> fetchDishes() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = await _restaurantRepo.fetchDishes(vendorId.value);

      if (data['dishes'] != null && data['dishes'] is List) {
        dishes.value = List<Map<String, dynamic>>.from(data['dishes']);
      } else {
        dishes.value = [];
        errorMessage.value = data['message'] ?? 'No dishes available.';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
