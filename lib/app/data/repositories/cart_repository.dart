import 'dart:convert';
import '../services/api_service.dart';

class CartRepository {
  final ApiService api;

  CartRepository({required this.api});

  /// POST /api/customer-cart/get-cart
  Future<Map<String, dynamic>> fetchCartItems() async {
    final response = await api.post('/api/customer-cart/get-cart', {});
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to fetch cart items');
    }
  }

  /// POST /api/customer-cart/add-item
  /// If the API returns a 400 error (vendor mismatch), this method returns a map with a
  /// vendorMismatch flag instead of throwing an exception.
  Future<Map<String, dynamic>> addItemToCart({
    required String vendorDishId,
    required int quantity,
    required String mealType,
  }) async {
    final response = await api.post(
      '/api/customer-cart/add-item',
      {
        'vendorDishId': vendorDishId,
        'quantity': quantity,
        'mealType': mealType,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 406) {
      // If status is 400, return a map with vendorMismatch flag.
      final error = jsonDecode(response.body);
      return {
        'vendorMismatch': true,
        'message': error['message'] ?? 'Vendor mismatch error',
      };
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to add item to cart');
    }
  }

  /// POST /api/customer-cart/increase
  Future<Map<String, dynamic>> increaseQuantity({
    required String vendorDishId,
    required String mealType,
  }) async {
    final response = await api.post(
      '/api/customer-cart/increase',
      {
        'vendorDishId': vendorDishId,
        'mealType': mealType,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to increase item quantity');
    }
  }

  /// POST /api/customer-cart/decrease
  Future<Map<String, dynamic>> decreaseQuantity({
    required String vendorDishId,
    required String mealType,
  }) async {
    final response = await api.post(
      '/api/customer-cart/decrease',
      {
        'vendorDishId': vendorDishId,
        'mealType': mealType,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to decrease item quantity');
    }
  }

  /// POST /api/customer-cart/clear-cart
  Future<Map<String, dynamic>> clearCart() async {
    final response = await api.post(
      '/api/customer-cart/clear-cart',
      {},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to clear cart');
    }
  }
}