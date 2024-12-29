// lib/app/data/repositories/restaurant_repository.dart

import 'dart:convert';
import '../services/api_service.dart';

class RestaurantRepository {
  final ApiService api;

  RestaurantRepository({required this.api});

  // Fetch dishes for a specific vendor
  Future<Map<String, dynamic>> fetchDishes(String vendorId) async {
    final response = await api.post('/api/customer/vendor-dishes', {
      'vendorId': vendorId,
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to fetch dishes');
    }
  }
}
