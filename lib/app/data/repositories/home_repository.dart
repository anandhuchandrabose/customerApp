// lib/app/data/repositories/home_repository.dart

import 'dart:convert';
import '../services/api_service.dart';

class HomeRepository {
  final ApiService api;

  HomeRepository({required this.api});

  Future<Map<String, dynamic>> getVendorsAndCategories() async {
    final response = await api.get('/api/customer/vendors-and-categories');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to fetch data');
    }
  }
}
