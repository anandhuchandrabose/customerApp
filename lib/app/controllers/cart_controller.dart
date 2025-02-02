import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../data/repositories/cart_repository.dart';
import '../data/repositories/order_repository.dart';

class CartController extends GetxController {
  final CartRepository _cartRepo = Get.find<CartRepository>();
  final OrderRepository _orderRepo = Get.find<OrderRepository>();

  var cartItems = <Map<String, dynamic>>[].obs;
  var cartData = <String, dynamic>{}.obs;

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  late Razorpay _razorpay;

  @override
  void onInit() {
    super.onInit();
    fetchCartItems();
  }

  @override
  void onClose() {
    // Clear Razorpay resources
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
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ============================
  // 2) Increase Item Quantity
  // ============================
  Future<void> increaseItemQuantity(String vendorDishId, String mealType) async {
    try {
      isLoading.value = true;

      // Make the API call to increase quantity
      await _cartRepo.increaseQuantity(
        vendorDishId: vendorDishId,
        mealType: mealType,
      );

      // Refetch the entire cart to ensure totals (subtotal, total) are updated
      await fetchCartItems();
    } catch (e) {
      // If server says "item not found on cart", re-fetch the cart to sync
      errorMessage.value = e.toString();
      if (errorMessage.value.toLowerCase().contains('not found on cart')) {
        await fetchCartItems();
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ============================
  // 3) Decrease Item Quantity
  // ============================
  Future<void> decreaseItemQuantity(String vendorDishId, String mealType) async {
    try {
      isLoading.value = true;

      // Make the API call to decrease quantity
      await _cartRepo.decreaseQuantity(
        vendorDishId: vendorDishId,
        mealType: mealType,
      );

      // Refetch the entire cart to ensure totals are updated
      await fetchCartItems();
    } catch (e) {
      // If server says "item not found on cart", re-fetch the cart to sync
      errorMessage.value = e.toString();
      if (errorMessage.value.toLowerCase().contains('not found on cart')) {
        await fetchCartItems();
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ============================
  // 4) Add Item to Cart (If used)
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
      // After adding item, refetch so the UI is up to date
      await fetchCartItems();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ============================
  // Helpers to parse cart data
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

  // ============================
  // 5) Payment Logic
  // ============================
  Future<void> initiatePayment() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);

      var options = {
        'key': 'rzp_test_fOAj9IBqaGPNY5', // Replace with your test/public key
        'amount': (cartData['total'] * 100),
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

      _razorpay.open(options);
    } catch (e) {
      errorMessage.value = 'Error initiating payment: $e';
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("Payment Success: ${response.paymentId}");
    await verifyPayment(
      razorpayOrderId: response.orderId!,
      razorpayPaymentId: response.paymentId!,
      razorpaySignature: response.signature!,
    );
  }

  void handlePaymentError(PaymentFailureResponse response) {
    print("Payment Error: ${response.code} - ${response.message}");
    Get.snackbar(
      'Payment Failed',
      'Code: ${response.code}, Message: ${response.message}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet: ${response.walletName}");
    Get.snackbar(
      'External Wallet',
      'Selected: ${response.walletName}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

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

      if (response['success'] == true) {
        print("Payment verification successful: $response");
        Get.snackbar(
          'Payment Verified',
          'Your payment has been successfully verified!',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception('Payment verification failed: ${response['message']}');
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
