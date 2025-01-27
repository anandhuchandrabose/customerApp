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
      // Full JSON response, e.g.:
      // {
      //   "vendors": [...],
      //   "categories": [...]
      // }
      final data = jsonDecode(response.body);
      return data;
    } else {
      // Parse error
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to fetch data');
    }
  }
}
