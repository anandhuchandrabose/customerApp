import 'dart:convert';
import '../services/api_service.dart';

class LocationRepository {
  final ApiService api;

  LocationRepository({required this.api});

  /// Add a new address via API
  Future<Map<String, dynamic>> addAddress(Map<String, dynamic> payload) async {
    try {
      final response = await api.post('/api/customer/add-address', payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        print('Add Address Response: $result');
        return result;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to add address');
      }
    } catch (e) {
      throw Exception('Failed to add address: $e');
    }
  }

  /// Retrieve saved addresses from API
  Future<List<dynamic>> getAddresses() async {
    try {
      final response = await api.get('/api/customer/addresses');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Get Addresses Response: $data');
        return data['addresses'] as List<dynamic>;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch addresses');
      }
    } catch (e) {
      throw Exception('Failed to fetch addresses: $e');
    }
  }
}