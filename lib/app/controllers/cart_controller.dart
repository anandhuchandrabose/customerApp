import 'dart:developer';
import 'package:customerapp/app/views/payment_success_screen.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../data/repositories/cart_repository.dart';
import '../data/repositories/order_repository.dart';

class CartController extends GetxController {
  final CartRepository _cartRepo = Get.find<CartRepository>();
  final OrderRepository _orderRepo = Get.find<OrderRepository>();

  // The entire cart response from server
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
      errorMessage.value = e.toString();
      // If server returns an error like "item not found in cart", re-fetch
      if (errorMessage.value.toLowerCase().contains('not found')) {
        await fetchCartItems();
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
  // 4) Add Item to Cart
  // ============================
  Future<void> addItemToCart({
    required String vendorDishId,
    required int quantity,
    required String mealType,
  }) async {
    try {
      isLoading.value = true;
      await _cartRepo.addItemToCart(
        vendorDishId: vendorDishId,
        quantity: quantity,
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

    cartData['subtotal']       = data['subtotal']       ?? 0;
    cartData['deliveryCharge'] = data['deliveryCharge'] ?? 0;
    cartData['tax']            = data['tax']            ?? 0;
    cartData['platformFees']   = data['platformFees']   ?? 0;
    cartData['total']          = data['total']          ?? 0;
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
      if (vendorDish['id'] == vendorDishId) {
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
      // For debugging: see step-by-step
      print("1) Calling placeOrder...");

      // 1) Place order on the backend
      final placeOrderResponse = await _orderRepo.placeOrder(
        {'exampleKey': 'exampleValue'},
        paymentMethod: 'card',
      );

      print("2) placeOrderResponse: $placeOrderResponse");

      // 2) Check for 'razorpayOrder'
      final razorpayOrder = placeOrderResponse['razorpayOrder'];
      if (razorpayOrder == null) {
        throw 'No razorpayOrder found in the placeOrder response.';
      }

      // 3) Initialize Razorpay
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);

      // 4) Open the Razorpay checkout with the order_id from the backend
      var options = {
        'key': 'rzp_test_fOAj9IBqaGPNY5',   // Your Razorpay test/public key
        'order_id': razorpayOrder['id'],    // e.g. "order_PrImk42XFGwCAy"
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

  /// Called when payment is successful in the Razorpay flow
  void handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("Payment Success: ${response.paymentId}");
    await verifyPayment(
      razorpayOrderId: response.orderId ?? '',
      razorpayPaymentId: response.paymentId ?? '',
      razorpaySignature: response.signature ?? '',
    );
  }

  /// Called when there is an error in the Razorpay flow
  void handlePaymentError(PaymentFailureResponse response) {
    print("Payment Error: ${response.code} - ${response.message}");
    Get.snackbar(
      'Payment Failed',
      'Code: ${response.code}, Message: ${response.message}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Called when an external wallet is selected, e.g. Paytm
  void handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet: ${response.walletName}");
    Get.snackbar(
      'External Wallet',
      'Selected: ${response.walletName}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Verify payment on the server
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
        // Navigate to the success screen.
        // If your backend returns a separate order id, you can pass it here.
        Get.to(() => PaymentSuccessScreen(orderId: razorpayOrderId));
      } else {
        throw Exception('Payment verification failed: ${response['message']}');
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
        Get.to(() => PaymentSuccessScreen(orderId: razorpayOrderId));
      } else {
        throw Exception('Payment verification failed: ${response['message']}');
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
