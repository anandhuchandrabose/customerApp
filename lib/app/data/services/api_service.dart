// lib/app/data/services/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import '../../controllers/network_controller.dart';

class ApiService {
  final String baseUrl;
  final GetStorage storage = GetStorage();

  ApiService({required this.baseUrl});

  Future<http.Response> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(url, headers: _headers());
      return response;
    } catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode(data),
      );
      return response;
    } catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Map<String, String> _headers() {
    final token = storage.read('token') ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  void _handleError(dynamic error) {
    final networkController = Get.find<NetworkController>();
    if (error is SocketException) {
      networkController.handleError(error);
    } else if (error is http.ClientException) {
      networkController.handleError(SocketException(error.message));
    } else {
      networkController.handleError(error);
    }
  }
}
