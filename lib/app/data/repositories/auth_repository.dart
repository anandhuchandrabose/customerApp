// lib/app/data/repositories/auth_repository.dart

import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../services/api_service.dart';

class AuthRepository {
  final ApiService api;
  final GetStorage storage = GetStorage();

  AuthRepository({required this.api});

  // 🔐 Request OTP
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

  // 🔐 Verify OTP and cache profile info
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final response = await api.post('/api/auth/customer/verify-otp', {
      'mobileNumber': phone,
      'otp': otp,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final customer = data['customer'];

      if (token != null && customer != null) {
        storage.write('token', token);
        storage.write('customerId', customer['id']);
        storage.write('customerName', customer['name'] ?? 'user');
        storage.write('customerMobile', customer['mobileNumber']);
        storage.write('customerEmail', customer['email'] ?? '');
      }

      return data;
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // 👤 Complete signup (new user onboarding)
  Future<Map<String, dynamic>> completeSignup(
      String phone, String firstName, String lastName) async {
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

  // 👤 Get saved user profile for Profile screen
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      return {
        'name': storage.read('customerName') ?? 'user',
        'email': storage.read('customerEmail') ?? '',
        'phone': storage.read('customerMobile') ?? '',
        'addresses': [], // Optional — can extend later
      };
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // 🚪 Logout
  Future<void> logout() async {
    await storage.erase();
  }

  // (Optional) Save name update manually
  void saveName(String name) {
    storage.write('customerName', name);
  }
}