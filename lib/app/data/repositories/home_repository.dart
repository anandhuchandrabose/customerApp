// lib/app/data/repositories/home_repository.dart

import 'dart:convert';
import '../services/api_service.dart';

class HomeRepository {
  final ApiService api;

  HomeRepository({required this.api});

  /// Fetch both vendors and categories from the API
  Future<Map<String, dynamic>> fetchHomeData() async {
    final response = await api.get('/api/customer/vendors-and-categories');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // Expecting something like:
      // {
      //   "vendors": [...],
      //   "categories": [...]
      // }
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to fetch data');
    }
  }

  /// Fetch vendors filtered by a specific category.
  ///
  /// Example payload: {"category": "Malabari"}
  /// Example response: [ {...}, {...} ]
  Future<List<dynamic>> fetchVendorsByCategory(String category) async {
    final payload = {
      "category": category,
    };

    final response = await api.post('/api/vendor/get-vendors-by-category', payload);

    if (response.statusCode == 200) {
      // Expecting a JSON array like:
      // [
      //   {
      //     "id": "...",
      //     "kitchenName": "...",
      //     "profile": {"profileImage": "...", ...},
      //     ...
      //   },
      //   ...
      // ]
      final data = jsonDecode(response.body);
      // Return the parsed list directly
      return data as List<dynamic>;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to fetch vendors by category');
    }
  }
}
