import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../data/repositories/cart_repository.dart';
import '../data/repositories/order_repository.dart';

class CartController extends GetxController {
  final CartRepository _cartRepo = Get.find<CartRepository>();
  final OrderRepository _orderRepo = Get.find<OrderRepository>();

  // The cart items array from the server
  var cartItems = <Map<String, dynamic>>[].obs;

  // Additional price fields
  var cartData = <String, dynamic>{}.obs;

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Razorpay instance (initialized from scratch)
  late Razorpay _razorpay;

  @override
  void onInit() {
    super.onInit();
    fetchCartItems();
    // Initialize Razorpay when we actually proceed to payment
  }

  @override
  void onClose() {
    // If Razorpay was initialized, clear it
    try {
      _razorpay.clear();
    } catch (_) {}
    super.onClose();
  }

  // 1) GET /api/customer-cart/get-cart
  Future<void> fetchCartItems() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = await _cartRepo.fetchCartItems();
      print("Fetched cart data: $data"); // Debugging

      final items = data['items'] ?? [];
      print("Number of items fetched: ${items.length}"); // Debugging

      if (items is List) {
        cartItems.value = items.map((e) => e as Map<String, dynamic>).toList();
        print("Cart items updated: ${cartItems.length}"); // Debugging
      } else {
        cartItems.clear();
      }

      cartData['subtotal'] = data['subtotal'] ?? 0;
      cartData['deliveryCharge'] = data['deliveryCharge'] ?? 0;
      cartData['tax'] = data['tax'] ?? 0;
      cartData['platformFees'] = data['platformFees'] ?? 0;
      cartData['total'] = data['total'] ?? 0;
    } catch (e) {
      errorMessage.value = e.toString();
      print("Error fetching cart items: $e"); // Debugging
    } finally {
      isLoading.value = false;
    }
  }

  // 2) Increase quantity => calls /api/customer-cart/increase
  Future<void> increaseItemQuantity(
    String vendorDishId,
    String mealType,
  ) async {
    try {
      isLoading.value = true;
      final data = await _cartRepo.increaseQuantity(
        vendorDishId: vendorDishId,
        mealType: mealType,
      );
      print("Increase quantity response: $data"); // Debugging
      final updatedItem = data['cartItem'] as Map<String, dynamic>?;
      if (updatedItem != null) {
        _updateLocalCartItem(updatedItem);
      }
      // Update price breakdown if returned
      _updateCartData(data);
    } catch (e) {
      errorMessage.value = e.toString();
      print("Error increasing item quantity: $e"); // Debugging
    } finally {
      isLoading.value = false;
    }
  }

  // 3) Decrease quantity => calls /api/customer-cart/decrease
  Future<void> decreaseItemQuantity(
    String vendorDishId,
    String mealType,
  ) async {
    try {
      isLoading.value = true;
      final data = await _cartRepo.decreaseQuantity(
        vendorDishId: vendorDishId,
        mealType: mealType,
      );
      print("Decrease quantity response: $data"); // Debugging
      final updatedItem = data['cartItem'] as Map<String, dynamic>?;
      if (updatedItem != null) {
        _updateLocalCartItem(updatedItem);
      }
      // Update price breakdown if returned
      _updateCartData(data);
    } catch (e) {
      errorMessage.value = e.toString();
      print("Error decreasing item quantity: $e"); // Debugging
    } finally {
      isLoading.value = false;
    }
  }

  // Merge the updated quantity into local cartItems
  void _updateLocalCartItem(Map<String, dynamic> newCartItem) {
    final itemId = newCartItem['id'];
    if (itemId == null) return;

    final index = cartItems.indexWhere((item) => item['id'] == itemId);
    if (index != -1) {
      cartItems[index] = {
        ...cartItems[index],
        'quantity': newCartItem['quantity'],
      };
      print("Updated item $itemId with quantity ${newCartItem['quantity']}");
    }
  }

  // Update cartData (subtotal, total, etc.) if the backend returns updated values
  void _updateCartData(Map<String, dynamic> data) {
    if (data['subtotal'] != null) cartData['subtotal'] = data['subtotal'];
    if (data['deliveryCharge'] != null) {
      cartData['deliveryCharge'] = data['deliveryCharge'];
    }
    if (data['tax'] != null) cartData['tax'] = data['tax'];
    if (data['platformFees'] != null) {
      cartData['platformFees'] = data['platformFees'];
    }
    if (data['total'] != null) cartData['total'] = data['total'];
  }

  // NEW: Initiate Razorpay from scratch
  Future<void> initiatePayment() async {
    // Typically, you might place the order first or fetch an order ID from your backend.
    // For demonstration, we’ll just open Razorpay with a test integration.

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Initialize Razorpay
      _razorpay = Razorpay();

      // Attach event listeners
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);

      // Example options (use actual values in production)
      var options = {
        'key':
            'rzp_test_fOAj9IBqaGPNY5', // Replace with your actual Razorpay key
        'amount': (cartData['total'] * 100), // In paise (e.g. ₹1 = 100 paise)
        'name': 'My Awesome App',
        'description': 'Payment for your order',
        'prefill': {
          'contact': '9999999999', // Replace with user's phone
          'email': 'user@example.com', // Replace with user's email
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      // Finally open Razorpay
      _razorpay.open(options);
    } catch (e, st) {
      errorMessage.value = 'Error initiating payment: $e';
      print("Error initiating payment: $e");
      print(st);
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Event handlers
  void handlePaymentSuccess(PaymentSuccessResponse response) {
    // Payment is successful. You can update the order status in your backend.
    print("Payment Success: ${response.paymentId}");
    Get.snackbar(
      'Payment Success',
      'Payment ID: ${response.paymentId}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void handlePaymentError(PaymentFailureResponse response) {
    // Payment failed. Log or notify the user.
    print("Payment Error: ${response.code} - ${response.message}");
    Get.snackbar(
      'Payment Failed',
      'Code: ${response.code}, Message: ${response.message}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    // User selected an external wallet like Paytm, etc.
    print("External Wallet: ${response.walletName}");
    Get.snackbar(
      'External Wallet',
      'Selected: ${response.walletName}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
