// lib/app/data/repositories/auth_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';



class AuthRepository {
  final ApiService api;

  AuthRepository({required this.api});

  Future<Map<String, dynamic>> requestOtp(String phone) async {
    final response = await api.post('/api/auth/customer/request-otp', {
      'mobileNumber': phone,
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final response = await api.post('/api/auth/customer/verify-otp', {
      'mobileNumber': phone,
      'otp': otp,
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<Map<String, dynamic>> completeSignup(
    String phone,
    String firstName,
    String lastName,
  ) async {
    final response = await api.post('/api/auth/customer/complete-signup', {
      'mobileNumber': phone,
      'firstName': firstName,
      'lastName': lastName,
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }
}
