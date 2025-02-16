// lib/app/controllers/cart_controller.dart

import 'dart:developer';
import 'package:customerapp/app/views/payment_success_screen.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../data/repositories/cart_repository.dart';
import '../data/repositories/order_repository.dart';

class CartController extends GetxController {
  final CartRepository _cartRepo = Get.find<CartRepository>();
  final OrderRepository _orderRepo = Get.find<OrderRepository>();

  // The entire cart response from server.
  var cartItems = <Map<String, dynamic>>[].obs;
  var cartData = <String, dynamic>{}.obs;

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Payment
  late Razorpay _razorpay;

  @override
  void onInit() {
    super.onInit();
    fetchCartItems();
  }

  @override
  void onClose() {
    try {
      _razorpay.clear();
    } catch (_) {}
    super.onClose();
  }

  // ========================
  // 1) Fetch All Cart Items
  // ========================
 Future<void> fetchCartItems() async {
  try {
    isLoading.value = true;
    errorMessage.value = '';
    final data = await _cartRepo.fetchCartItems();
    _parseCartResponse(data);
    log('Cart fetched successfully.');
  } catch (e) {
    errorMessage.value = e.toString();
    log('Error fetching cart: $e');
    // Optionally clear the cart items if fetching fails.
    cartItems.clear();
  } finally {
    isLoading.value = false;
  }
}

  // ============================
  // 2) Increase Item Quantity
  // ============================
 Future<void> increaseItemQuantity({
  required String vendorDishId,
  required String mealType,
}) async {
  try {
    isLoading.value = true;
    await _cartRepo.increaseQuantity(
      vendorDishId: vendorDishId,
      mealType: mealType,
    );
    await fetchCartItems();
  } catch (e) {
    final errMsg = e.toString().toLowerCase();
    
    if (errMsg.contains('cannot increase quantity beyond available capacity')) {
      // Show a snackbar with the capacity error message
      Get.snackbar(
        "Error",
        "Cannot increase quantity beyond available capacity.",
        snackPosition: SnackPosition.BOTTOM,
      );
      // Refresh the cart data to update UI
      await fetchCartItems();
      // Clear the error message so the CartView doesn't show the retry button
      errorMessage.value = "";
    } else if (errMsg.contains('not found')) {
      // For not found errors, just refresh the cart data
      await fetchCartItems();
      errorMessage.value = "";
    } else {
      // For any other error, set the error message and show a snackbar
      errorMessage.value = errMsg;
      Get.snackbar(
        "Error",
        errMsg,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  } finally {
    isLoading.value = false;
  }
}

  // ============================
  // 3) Decrease Item Quantity
  // ============================
  Future<void> decreaseItemQuantity({
    required String vendorDishId,
    required String mealType,
  }) async {
    try {
      isLoading.value = true;
      await _cartRepo.decreaseQuantity(
        vendorDishId: vendorDishId,
        mealType: mealType,
      );
      await fetchCartItems();
    } catch (e) {
      errorMessage.value = e.toString();
      if (errorMessage.value.toLowerCase().contains('not found')) {
        await fetchCartItems();
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ============================
  // 4) Add Item to Cart with Vendor Restriction
  // ============================
  Future<void> addItemToCart({
    required String vendorDishId,
    required String mealType,
    required String vendorId, // Vendor ID coming from the current restaurant
  }) async {
    // If the cart already has items, verify that they belong to the same vendor.
    if (cartItems.isNotEmpty) {
      // Retrieve the vendor id from the first cart item.
      // Use .toString() to compare string representations,
      // and treat an empty value as if no vendor is set.
      final existingVendorId =
          (cartItems.first['vendorDish']?['vendorId'] ?? '').toString();
      final currentVendorId = vendorId.toString();
      // Only enforce the check if an existing vendor id is set (non-empty)
      if (existingVendorId.isNotEmpty && existingVendorId != currentVendorId) {
        Get.snackbar(
          "Error",
          "You cannot add items from a different vendor. Please clear your cart first.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }
    try {
      isLoading.value = true;
      // Force a single quantity when adding a new item.
      await _cartRepo.addItemToCart(
        vendorDishId: vendorDishId,
        quantity: 1,
        mealType: mealType,
      );
      await fetchCartItems();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ============================
  // 5) Helpers for cart data
  // ============================
  void _parseCartResponse(Map<String, dynamic> data) {
    final items = data['items'] ?? [];
    if (items is List) {
      cartItems.value = items.map((e) => e as Map<String, dynamic>).toList();
    } else {
      cartItems.clear();
    }

    cartData['subtotal'] = data['subtotal'] ?? 0;
    cartData['deliveryCharge'] = data['deliveryCharge'] ?? 0;
    cartData['tax'] = data['tax'] ?? 0;
    cartData['platformFees'] = data['platformFees'] ?? 0;
    cartData['total'] = data['total'] ?? 0;
  }

  int get totalItemCount {
    var count = 0;
    for (final item in cartItems) {
      count += (item['quantity'] ?? 0) as int;
    }
    return count;
  }

  double get totalPrice {
    return double.tryParse(cartData['total']?.toString() ?? '0') ?? 0.0;
  }

  int getDishQuantity(String vendorDishId) {
    for (final item in cartItems) {
      final vendorDish = item['vendorDish'] ?? {};
      // Check if the vendor dish has either the key 'id' or 'vendorDishId'
      if ((vendorDish['id'] != null && vendorDish['id'] == vendorDishId) ||
          (vendorDish['vendorDishId'] != null &&
              vendorDish['vendorDishId'] == vendorDishId)) {
        return item['quantity'] ?? 0;
      }
    }
    return 0;
  }

  // ============================
  // 6) Payment Logic
  // ============================
  Future<void> initiatePayment() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      print("1) Calling placeOrder...");
      final placeOrderResponse = await _orderRepo.placeOrder(
        {'exampleKey': 'exampleValue'},
        paymentMethod: 'card',
      );
      print("2) placeOrderResponse: $placeOrderResponse");

      final razorpayOrder = placeOrderResponse['razorpayOrder'];
      if (razorpayOrder == null) {
        throw 'No razorpayOrder found in the placeOrder response.';
      }

      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);

      var options = {
        'key': 'rzp_test_fOAj9IBqaGPNY5', // Your Razorpay test/public key
        'order_id': razorpayOrder['id'], // e.g. "order_PrImk42XFGwCAy"
        'name': 'My Awesome App',
        'description': 'Payment for your order',
        'prefill': {
          'contact': '9999999999',
          'email': 'user@example.com',
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      print("3) Opening Razorpay with options: $options");
      _razorpay.open(options);
    } catch (e, st) {
      print("Error initiating payment: $e\nStack: $st");
      errorMessage.value = 'Error initiating payment: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Called when payment is successful in the Razorpay flow.
  void handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("Payment Success: ${response.paymentId}");
    await verifyPayment(
      razorpayOrderId: response.orderId ?? '',
      razorpayPaymentId: response.paymentId ?? '',
      razorpaySignature: response.signature ?? '',
    );
  }

  /// Called when there is an error in the Razorpay flow.
  void handlePaymentError(PaymentFailureResponse response) {
    print("Payment Error: ${response.code} - ${response.message}");
    Get.snackbar(
      'Payment Failed',
      'Code: ${response.code}, Message: ${response.message}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Called when an external wallet is selected, e.g. Paytm.
  void handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet: ${response.walletName}");
    Get.snackbar(
      'External Wallet',
      'Selected: ${response.walletName}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Verify payment on the server and refresh cart afterward.
  Future<void> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _orderRepo.verifyPayment(
        razorpayOrderId,
        razorpayPaymentId,
        razorpaySignature,
      );

      // Check if the response indicates a successful verification.
      if (response.containsKey('success')) {
        if (response['success'] == true) {
          print("Payment verification successful: $response");
          Get.snackbar(
            'Payment Verified',
            'Your payment has been successfully verified!',
            snackPosition: SnackPosition.BOTTOM,
          );
          // Refresh the cart after payment verification.
          await fetchCartItems();
          // Navigate to the success screen.
          Get.to(() => PaymentSuccessScreen(orderId: razorpayOrderId));
        } else {
          throw Exception(
              'Payment verification failed: ${response['message']}');
        }
      } else {
        // If there's no 'success' key, inspect the message.
        final message = (response['message'] as String?) ?? '';
        if (message.toLowerCase().contains('payment confirmed')) {
          print("Payment verification successful: $response");
          Get.snackbar(
            'Payment Verified',
            'Your payment has been successfully verified!',
            snackPosition: SnackPosition.BOTTOM,
          );
          // Refresh the cart after payment verification.
          await fetchCartItems();
          Get.to(() => PaymentSuccessScreen(orderId: razorpayOrderId));
        } else {
          throw Exception(
              'Payment verification failed: ${response['message']}');
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Verification Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
