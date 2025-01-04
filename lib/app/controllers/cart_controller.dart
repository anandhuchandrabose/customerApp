// lib/app/controllers/cart_controller.dart

import 'package:get/get.dart';
import '../data/repositories/cart_repository.dart';

class CartController extends GetxController {
  final CartRepository _cartRepo = Get.find<CartRepository>();

  // The cart items array from the server
  var cartItems = <Map<String, dynamic>>[].obs;

  // Additional price fields from the server response:
  // e.g. "subtotal", "deliveryCharge", "tax", "platformFees", "total"
  var cartData = <String, dynamic>{}.obs;

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCartItems();
  }

  // Fetch items + price breakups from /get-cart
  Future<void> fetchCartItems() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Example server response:
      // {
      //   "items": [...],
      //   "subtotal": 40,
      //   "deliveryCharge": 25,
      //   "tax": 2,
      //   "platformFees": 8,
      //   "total": 75
      // }
      final data = await _cartRepo.fetchCartItems();

      // 1) Items array
      final items = data['items'] ?? [];
      if (items is List) {
        cartItems.value = items.map((e) => e as Map<String, dynamic>).toList();
      } else {
        cartItems.clear();
      }

      // 2) Price fields
      cartData['subtotal'] = data['subtotal'] ?? 0;
      cartData['deliveryCharge'] = data['deliveryCharge'] ?? 0;
      cartData['tax'] = data['tax'] ?? 0;
      cartData['platformFees'] = data['platformFees'] ?? 0;
      cartData['total'] = data['total'] ?? 0;

    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Increase quantity by calling /api/customer-cart/increase
  Future<void> increaseItemQuantity(String vendorDishId, String mealType) async {
    try {
      isLoading.value = true;
      final data = await _cartRepo.increaseQuantity(
        vendorDishId: vendorDishId,
        mealType: mealType,
      );
      final updatedItem = data['cartItem'] as Map<String, dynamic>?;
      if (updatedItem != null) {
        _updateLocalCartItem(updatedItem);
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Decrease quantity by calling /api/customer-cart/decrease
  Future<void> decreaseItemQuantity(String vendorDishId, String mealType) async {
    try {
      isLoading.value = true;
      final data = await _cartRepo.decreaseQuantity(
        vendorDishId: vendorDishId,
        mealType: mealType,
      );
      final updatedItem = data['cartItem'] as Map<String, dynamic>?;
      if (updatedItem != null) {
        _updateLocalCartItem(updatedItem);
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Update the local cartItems list with the new quantity from the server
  void _updateLocalCartItem(Map<String, dynamic> newCartItem) {
    final itemId = newCartItem['id'];
    if (itemId == null) return;

    int index = cartItems.indexWhere((item) => item['id'] == itemId);
    if (index != -1) {
      // Merge new fields (like quantity)
      cartItems[index] = {
        ...cartItems[index],
        'quantity': newCartItem['quantity'],
      };
    }
  }

  // Called by the Slide-to-Pay button
  Future<void> checkoutCart() async {
    // You can do your payment logic here
    // e.g. _cartRepo.checkout() or do other steps
    // For demonstration, we just show a success message
    Get.snackbar('Payment', 'Checkout successful!');
  }
}
