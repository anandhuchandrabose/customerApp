// lib/app/data/repositories/home_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class HomeRepository {
  final ApiService api;

  HomeRepository({required this.api});

  /// Fetch list of vendors from the API
  Future<List<Map<String, dynamic>>> fetchVendors() async {
    final response = await api.get('/api/customer/vendors-and-categories');
    // or another endpoint, e.g. '/api/vendors'

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Suppose data is { "vendors": [...], "categories": [...] }
      if (data['vendors'] is List) {
        final List vendors = data['vendors'];
        return vendors.map((e) => e as Map<String, dynamic>).toList();
      } else {
        return [];
      }
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to fetch vendors');
    }
  }
}
