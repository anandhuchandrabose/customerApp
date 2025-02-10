// lib/app/controllers/restaurant_details_controller.dart

import 'dart:developer';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/repositories/restaurant_repository.dart';
import '../controllers/cart_controller.dart';

class RestaurantDetailsController extends GetxController {
  final RestaurantRepository _restaurantRepo = Get.find<RestaurantRepository>();
  final CartController cartCtrl = Get.find<CartController>();

  // Basic fields
  var vendorId = ''.obs;
  var dishes = <Map<String, dynamic>>[].obs;

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Restaurant display
  var restaurantName = 'Restaurant'.obs;
  // Modified: Check for "vendorImage" first then "image"
  var restaurantImageUrl = ''.obs;
  var rating = 0.0.obs;
  var servingTime = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    final storage = GetStorage();
    // Try to get vendorId from navigation arguments, otherwise from persistent storage.
    vendorId.value = args['vendorId'] ?? storage.read('vendorId') ?? '';

    if (vendorId.value.isEmpty) {
      errorMessage.value = 'No vendorId provided.';
      Get.snackbar('Error', 'Vendor ID not provided.');
    } else {
      fetchRestaurantAndDishes();
    }
  }

  Future<void> fetchRestaurantAndDishes() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = await _restaurantRepo.fetchDishes(vendorId.value);
      log('fetchDishes Response: $data');

      if (data['success'] == true) {
        // Assume the API returns restaurant details directly inside "data"
        final restaurantData = data['data'] ?? {};

        // Use "vendorName" for the restaurant (vendor) name.
        restaurantName.value = restaurantData['vendorName'] ?? 'Unknown';
        // Check for "vendorImage" first; if not provided, fallback to "image"
        restaurantImageUrl.value = restaurantData['vendorImage'] ?? restaurantData['image'] ?? '';
        rating.value = double.tryParse(restaurantData['rating']?.toString() ?? '0') ?? 0.0;
        // Set servingTime; you can adjust this default as needed.
        // servingTime.value = restaurantData['servingTime'] ?? 'Lunch serves between 12 PM to 2PM';

        final dishesData = restaurantData['dishes'] ?? [];
        if (dishesData is List) {
          dishes.value = List<Map<String, dynamic>>.from(dishesData);
        }
        // Optionally set an error message if no dishes are available.
        if (dishes.isEmpty && data['message'] != null) {
          errorMessage.value = data['message'];
        }
      } else {
        errorMessage.value = data['message'] ?? 'Failed to load data.';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', errorMessage.value);
      log('Error fetching restaurant data: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
