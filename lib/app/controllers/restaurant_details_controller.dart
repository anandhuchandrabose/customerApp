// lib/app/controllers/restaurant_details_controller.dart

import 'package:get/get.dart';
import '../data/repositories/restaurant_repository.dart';
import '../data/repositories/cart_repository.dart';

class RestaurantDetailsController extends GetxController {
  final RestaurantRepository _restaurantRepo = Get.find<RestaurantRepository>();
  final CartRepository _cartRepo = Get.find<CartRepository>();

  // Existing
  var vendorId = ''.obs;
  var dishes = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // -----------------
  // Added fields to avoid errors in the view
  // -----------------
  var restaurantName = 'Restuarent'.obs;      // For top display
  var restaurantImageUrl = ''.obs;                     // Could be a network or base64
  var rating = 5.0.obs;                                // 5.0 star rating
  var servingTime = '7 pm to 8 pm'.obs;                // “Serves Between 7 pm to 8 pm”

  // Cart summary fields (for sticky bottom bar)
  var cartItemCount = 0.obs;      // total items in cart
  var cartTotalPrice = 0.0.obs;   // total price for those items

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    vendorId.value = args['vendorId'] ?? '';
    print('Vendor ID received: ${vendorId.value}');

    // If you pass restaurant info via arguments, you could do:
    // restaurantName.value = args['kitchenName'] ?? 'Unknown';
    // rating.value = double.tryParse(args['rating']?.toString() ?? '0.0') ?? 0.0;
    // restaurantImageUrl.value = args['imageUrl'] ?? ''; 
    // servingTime.value = args['servingTime'] ?? '7 pm to 8 pm';

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
        // Optionally update your cart counters:
        cartItemCount.value += quantity;
        cartTotalPrice.value += double.tryParse(data['addedItemPrice']?.toString() ?? '0') ?? 0.0;
        // Show success
        Get.snackbar('Cart', data['message'] ?? 'Item added to cart');

        // Navigate to Cart screen if you want:
        // Get.toNamed('/cart');
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

  /// Example helper to get quantity of a dish from local cart data
  /// If you store a local cart or need more advanced logic, adapt here
  int dishQuantity(String vendorDishId) {
    // For demonstration, let's just return 0 to always show "Add" 
    // If you have a real cart, check if the dish is present and return actual quantity
    return 0;
  }

  /// Example: remove an item from the cart
  void removeItemFromCart(String vendorDishId) {
    // This might call an API or adjust local cart
    // For now, just a placeholder:
    if (cartItemCount.value > 0) cartItemCount.value -= 1;
    // You could also subtract from cartTotalPrice
  }
}
