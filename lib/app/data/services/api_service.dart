// lib/app/data/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  final storage = GetStorage();

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url, headers: _headers());
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      url,
      headers: _headers(),
      body: jsonEncode(data),
    );
  }

  Map<String, String> _headers() {
    final token = storage.read('token') ?? ''; // Read the token from storage
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty)
        'Authorization': 'Bearer $token', // Add token if available
    };
  }
}
