import 'dart:developer';
import 'package:get/get.dart';
import '../data/repositories/restaurant_repository.dart';
import '../controllers/cart_controller.dart';

class RestaurantDetailsController extends GetxController {
  final RestaurantRepository _restaurantRepo = Get.find<RestaurantRepository>();
  // If you need to call CartController here:
  final CartController cartCtrl = Get.find<CartController>();

  // Basic fields
  var vendorId = ''.obs;
  var dishes = <Map<String, dynamic>>[].obs;

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Restaurant display
  var restaurantName = 'Restaurant'.obs;
  var restaurantImageUrl = ''.obs;
  var rating = 0.0.obs;
  var servingTime = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    vendorId.value = args['vendorId'] ?? '';

    if (vendorId.value.isEmpty) {
      errorMessage.value = 'No vendorId provided.';
      Get.snackbar('Error', 'Vendor ID not provided.');
    } else {
      fetchRestaurantAndDishes();
    }
  }

  /// Use the existing `fetchDishes` method from your RestaurantRepository.
  /// (If your backend only returns dishes, you might not get restaurantName/image/etc.)
  /// Adapt as needed based on your real API response.
  Future<void> fetchRestaurantAndDishes() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = await _restaurantRepo.fetchDishes(vendorId.value);
      log('fetchDishes Response: $data');

      if (data['success'] == true) {
        // Suppose the response looks like:
        // { 
        //   "success": true,
        //   "data": {
        //       "restaurant": { "name": "...", "image": "...", "rating": 4.5, ... },
        //       "dishes": [ ... ]
        //   }
        // }

        // If your real API does not return restaurant data, skip these lines:
        final restaurantData = data['data']?['restaurant'] ?? {};
        restaurantName.value = restaurantData['name'] ?? 'Unknown';
        restaurantImageUrl.value = restaurantData['image'] ?? '';
        rating.value = double.tryParse(
          restaurantData['rating']?.toString() ?? '0'
        ) ?? 0.0;

        servingTime.value = restaurantData['servingTime'] ?? '12 PM - 2 PM';

        final dishesData = data['data']?['dishes'] ?? [];
        if (dishesData is List) {
          dishes.value = List<Map<String, dynamic>>.from(dishesData);
        }

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
