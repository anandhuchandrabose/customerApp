// lib/app/data/repositories/cart_repository.dart

import 'dart:convert';
import '../services/api_service.dart';

class CartRepository {
  final ApiService api;

  CartRepository({required this.api});

  /// GET /api/customer-cart/get-cart
  /// Returns JSON like: { "items": [ ... ] }
  Future<Map<String, dynamic>> fetchCartItems() async {
    final response = await api.get('/api/customer-cart/get-cart');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to fetch cart items');
    }
  }

  /// POST /api/customer-cart/add-item
  /// Body: { "vendorDishId": "...", "quantity": 1, "mealType": "..." }
  /// On success: e.g. { "message": "Item added to cart successfully." }
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
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to add item to cart');
    }
  }

  /// POST /api/customer-cart/increase
  /// Body: { "vendorDishId": "...", "mealType": "..." }
  /// On success: { "message": "Item quantity increased.", "cartItem": { "quantity": x, ... } }
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
  /// Body: { "vendorDishId": "...", "mealType": "..." }
  /// On success: { "message": "Item quantity decreased.", "cartItem": { "quantity": x, ... } }
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
}
