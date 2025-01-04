// lib/app/controllers/restaurant_details_controller.dart

import 'package:get/get.dart';
import '../data/repositories/restaurant_repository.dart';
import '../data/repositories/cart_repository.dart';

class RestaurantDetailsController extends GetxController {
  final RestaurantRepository _restaurantRepo = Get.find<RestaurantRepository>();
  final CartRepository _cartRepo = Get.find<CartRepository>();

  var vendorId = ''.obs;
  var dishes = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    vendorId.value = args['vendorId'] ?? '';
    print('Vendor ID received: ${vendorId.value}');

    if (vendorId.value.isEmpty) {
      errorMessage.value = 'No vendorId provided.';
      Get.snackbar('Error', 'Vendor ID not provided.');
    } else {
      fetchDishes();
    }
  }

  Future<void> fetchDishes() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = await _restaurantRepo.fetchDishes(vendorId.value);
      print('Fetch Dishes Response: $data');

      if (data['success'] == true) {
        final dishesData = data['data']?['dishes'] ?? [];
        print('Dishes Data: $dishesData');
        if (dishesData is List) {
          dishes.value = List<Map<String, dynamic>>.from(dishesData);
        }
        if (dishes.isEmpty && data['message'] != null) {
          errorMessage.value = data['message'];
        }
      } else {
        errorMessage.value = data['message'] ?? 'Failed to fetch dishes.';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', errorMessage.value);
      print('Error fetching dishes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addItemToCart({
    required String vendorDishId,
    required int quantity,
    required String mealType,
  }) async {
    try {
      isLoading.value = true;
      print(
          'Adding to cart: vendorDishId=$vendorDishId, quantity=$quantity, mealType=$mealType');

      final data = await _cartRepo.addItemToCart(
        vendorDishId: vendorDishId,
        quantity: quantity,
        mealType: mealType,
      );
      print('Add to Cart Response: $data');

      if (data['success'] == true ||
          data['message'] == 'Item added to cart successfully.') {
        // Show success snackbar
        Get.snackbar('Cart', data['message'] ?? 'Item added to cart');

        // Navigate to Cart screen
        Get.toNamed('/cart');
      } else {
        // Show error from response
        Get.snackbar('Error', data['message'] ?? 'Failed to add item');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
      print('Error adding to cart: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
