// lib/app/data/repositories/order_repository.dart

import 'dart:convert';
import '../services/api_service.dart';

class OrderRepository {
  final ApiService api; 

  OrderRepository({required this.api});

  Future<Map<String, dynamic>> placeOrder({required String paymentMethod}) async {
    final response = await api.post('/api/order/place-order', {
      'paymentMethod': paymentMethod,
    });

    print("POST /place-order status: ${response.statusCode}");
    print("POST /place-order response: ${response.body}");

    // Accept only 200 as success
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to place order');
    }
  }

  /// POST /api/order/verify-payment
  Future<Map<String, dynamic>> verifyPayment(String paymentId, String orderId, String signature) async {
    final response = await api.post(
      '/api/order/verify-payment',
      {
        'paymentId': paymentId,
        'orderId': orderId,
        'signature': signature,
      },
    );

    print("POST /verify-payment status: ${response.statusCode}");
    print("POST /verify-payment response: ${response.body}"); 

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to verify payment');
    }
  }
}
