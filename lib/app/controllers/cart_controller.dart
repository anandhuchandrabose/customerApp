import 'dart:developer';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../data/repositories/cart_repository.dart';
import '../data/repositories/order_repository.dart';
import '../controllers/location_controller.dart';
import 'package:customerapp/app/views/payment_success_screen.dart';

class CartController extends GetxController {
  final CartRepository _cartRepo = Get.find<CartRepository>();
  final OrderRepository _orderRepo = Get.find<OrderRepository>();
  final LocationController _locationController = Get.find<LocationController>();

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
      cartItems.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // ============================
  // 2) Add Item to Cart
  // ============================
  Future<Map<String, dynamic>> addItemToCart({
    required String vendorDishId,
    required String mealType,
    required String vendorId,
  }) async {
    try {
      isLoading.value = true;
      final result = await _cartRepo.addItemToCart(
        vendorDishId: vendorDishId,
        quantity: 1,
        mealType: mealType,
      );
      await fetchCartItems();
      return result;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar("Error", errorMessage.value);
      return {'error': errorMessage.value};
    } finally {
      isLoading.value = false;
    }
  }

  // ============================
  // 3) Increase/Decrease Quantity
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
        Get.snackbar("Error", "Cannot increase quantity beyond capacity.");
        await fetchCartItems();
        errorMessage.value = "";
      } else if (errMsg.contains('not found')) {
        await fetchCartItems();
        errorMessage.value = "";
      } else {
        errorMessage.value = errMsg;
        Get.snackbar("Error", errMsg);
      }
    } finally {
      isLoading.value = false;
    }
  }

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
  // 4) Clear Entire Cart
  // ============================
  Future<void> clearEntireCart() async {
    isLoading.value = true;
    errorMessage.value = "";
    try {
      await _cartRepo.clearCart();
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================
  // 5) Helpers
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
      final String? itemId = vendorDish['id']?.toString();
      final String? itemDishId = vendorDish['vendorDishId']?.toString();
      if (itemId == vendorDishId || itemDishId == vendorDishId) {
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
      // Find the selected address
      final selectedAddress = _locationController.addresses.firstWhere(
        (address) => address['isSelected'] == true,
        orElse: () => <String, dynamic>{},
      );

      if (selectedAddress.isEmpty || selectedAddress['addressId'] == null) {
        Get.snackbar(
          'Error',
          'No address selected. Please select a delivery address.',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.toNamed('/address-input');
        return;
      }

      final addressId = selectedAddress['addressId'].toString();

      print("1) Calling placeOrder with addressId: $addressId...");
      final placeOrderResponse = await _orderRepo.placeOrder(
        {
          'addressId': addressId,
        },
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
        'key': 'rzp_test_fOAj9IBqaGPNY5',
        'order_id': razorpayOrder['id'],
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

  void handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("Payment Success: ${response.paymentId}");
    await verifyPayment(
      razorpayOrderId: response.orderId ?? '',
      razorpayPaymentId: response.paymentId ?? '',
      razorpaySignature: response.signature ?? '',
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

      if (response.containsKey('success')) {
        if (response['success'] == true) {
          print("Payment verification successful: $response");
          Get.snackbar(
            'Payment Verified',
            'Your payment has been successfully verified!',
            snackPosition: SnackPosition.BOTTOM,
          );
          await fetchCartItems();
          Get.to(() => PaymentSuccessScreen(orderId: razorpayOrderId));
        } else {
          throw Exception('Payment verification failed: ${response['message']}');
        }
      } else {
        final message = (response['message'] as String?) ?? '';
        if (message.toLowerCase().contains('payment confirmed')) {
          print("Payment verification successful: $response");
          Get.snackbar(
            'Payment Verified',
            'Your payment has been successfully verified!',
            snackPosition: SnackPosition.BOTTOM,
          );
          await fetchCartItems();
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