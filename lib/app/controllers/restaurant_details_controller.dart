import 'dart:developer';
import 'package:get/get.dart';
import '../data/repositories/restaurant_repository.dart';
import '../data/repositories/cart_repository.dart';

class RestaurantDetailsController extends GetxController {
  final RestaurantRepository _restaurantRepo = Get.find<RestaurantRepository>();
  final CartRepository _cartRepo = Get.find<CartRepository>();

  // Basic fields
  var vendorId = ''.obs;
  var dishes = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Restaurant display
  var restaurantName = 'Restaurant'.obs;
  var restaurantImageUrl = ''.obs;
  var rating = 5.0.obs;
  var servingTime = '7 pm to 8 pm'.obs;

  // Cart summary
  var cartItemCount = 0.obs;
  var cartTotalPrice = 0.0.obs;

  /// Reactive map for dish quantities: vendorDishId -> quantity
  final RxMap<String, int> cartQuantities = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    vendorId.value = args['vendorId'] ?? '';

    if (vendorId.value.isEmpty) {
      errorMessage.value = 'No vendorId provided.';
      Get.snackbar('Error', 'Vendor ID not provided.');
    } else {
      // 1) Fetch the restaurant's dishes
      fetchDishes();

      // 2) Fetch the user's existing cart
      fetchCart();
    }
  }

  /// Fetches the restaurant's dishes
  Future<void> fetchDishes() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = await _restaurantRepo.fetchDishes(vendorId.value);
      log('Fetch Dishes Response: $data');

      if (data['success'] == true) {
        final dishesData = data['data']?['dishes'] ?? [];
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
      log('Error fetching dishes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetches the existing cart from /api/customer-cart/get-cart
  /// and populates [cartQuantities] + summary counts.
  Future<void> fetchCart() async {
    try {
      final cartData = await _cartRepo.fetchCartItems();
      log('Fetch Cart Response: $cartData');

      final items = cartData['items'] ?? [];
      // Clear before re-populating
      cartQuantities.clear();

      double totalPrice = 0;
      int itemCount = 0;

      for (final item in items) {
        // Suppose each 'item' has: vendorDishId, quantity, mealType, price, etc.
        final dishId = item['vendorDishId'] ?? '';
        if (dishId.isEmpty) continue;

        // -------------- KEY FIX: Safely parse quantity as int --------------
        final dynamic rawQty = item['quantity'] ?? 0;
        final int qty = (rawQty is num) ? rawQty.toInt() : 0;

        // Put in our reactive map
        cartQuantities[dishId] = qty;

        // Build up totals
        itemCount += qty;

        // Either read the dish price from the local 'dishes' array or from item['price']
        double localDishPrice = _getDishPrice(dishId);
        if (localDishPrice == 0 && item['price'] != null) {
          localDishPrice =
              double.tryParse(item['price'].toString()) ?? 0.0;
        }
        totalPrice += qty * localDishPrice;
      }

      // Update reactive summary
      cartItemCount.value = itemCount;
      cartTotalPrice.value = totalPrice;
    } catch (e) {
      log('Error fetching cart: $e');
      // Optionally show a snackbar
      Get.snackbar('Error', e.toString());
    }
  }

  /// Returns local quantity from [cartQuantities]
  int dishQuantity(String vendorDishId) {
    return cartQuantities[vendorDishId] ?? 0;
  }

  /// First time => /api/customer-cart/add-item
  Future<void> addNewItemToCart({
    required String vendorDishId,
    required String mealType,
  }) async {
    try {
      isLoading.value = true;
      final response = await _cartRepo.addItemToCart(
        vendorDishId: vendorDishId,
        quantity: 1,
        mealType: mealType,
      );
      log('Add item response: $response');

      if (response['message'] == 'Item added to cart successfully.' ||
          response['success'] == true) {
        cartQuantities[vendorDishId] = 1;

        cartItemCount.value += 1;
        cartTotalPrice.value += _getDishPrice(vendorDishId);

        Get.snackbar('Cart', response['message'] ?? 'Item added to cart');
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to add item');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
      log('Error adding item to cart: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Subsequent plus => /api/customer-cart/increase
  Future<void> increaseItemQuantity({
    required String vendorDishId,
    required String mealType,
  }) async {
    try {
      isLoading.value = true;

      final response = await _cartRepo.increaseQuantity(
        vendorDishId: vendorDishId,
        mealType: mealType,
      );
      log('Increase item response: $response');

      if (response['message'] == 'Item quantity increased.' ||
          response['success'] == true) {
        final newQty = dishQuantity(vendorDishId) + 1;
        cartQuantities[vendorDishId] = newQty;

        cartItemCount.value += 1;
        cartTotalPrice.value += _getDishPrice(vendorDishId);
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to increase item');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
      log('Error increasing item: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Subsequent minus => /api/customer-cart/decrease
  Future<void> decreaseItemQuantity({
    required String vendorDishId,
    required String mealType,
  }) async {
    final currentQty = dishQuantity(vendorDishId);
    if (currentQty == 0) return;

    try {
      isLoading.value = true;

      final response = await _cartRepo.decreaseQuantity(
        vendorDishId: vendorDishId,
        mealType: mealType,
      );
      log('Decrease item response: $response');

      if (response['message'] == 'Item quantity decreased.' ||
          response['success'] == true) {
        final newQty = currentQty - 1;
        cartQuantities[vendorDishId] = newQty;

        cartItemCount.value -= 1;
        cartTotalPrice.value -= _getDishPrice(vendorDishId);

        if (newQty == 0) {
          cartQuantities.remove(vendorDishId);
        }
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to decrease item');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
      log('Error decreasing item: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Looks up the dish price from the local [dishes] list 
  double _getDishPrice(String vendorDishId) {
    try {
      final dish = dishes.firstWhere(
        (d) => d['vendorDishId'] == vendorDishId,
        orElse: () => {},
      );
      if (dish.isNotEmpty) {
        return double.tryParse(dish['price']?.toString() ?? '0') ?? 0;
      }
    } catch (_) {}
    return 0;
  }
}
