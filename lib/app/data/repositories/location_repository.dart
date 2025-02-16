// lib/app/data/repositories/location_repository.dart

import 'dart:convert';
import '../services/api_service.dart';

class LocationRepository {
  final ApiService api;

  LocationRepository({required this.api});

  /// Adds a new address by calling the API endpoint.
  ///
  /// The [payload] should contain details like:
  /// {
  ///   "addressName": "Home",
  ///   "receiverName": "Manjula",
  ///   "receiverContact": "98480000",
  ///   "secondaryContact": "9424242",
  ///   "category": "home",
  ///   "flatHouseNo": "Devi Vihar",
  ///   "nearbyLocation": "",
  ///   "latitude": 80,
  ///   "longitude": 23,
  ///   "address": "",
  ///   "isSelected": true
  /// }
  Future<Map<String, dynamic>> addAddress(Map<String, dynamic> payload) async {
    final response = await api.post('/api/customer/add-address', payload);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to add address');
    }
  }

  /// Retrieves saved addresses from the API.
  ///
  /// The expected response should be a JSON object like:
  /// {
  ///   "addresses": [ {...}, {...} ]
  /// }
  Future<List<dynamic>> getAddresses() async {
    final response = await api.get('/api/customer/addresses');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['addresses'] as List<dynamic>;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to fetch addresses');
    }
  }
}
