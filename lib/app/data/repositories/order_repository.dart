import 'dart:convert';
import '../services/api_service.dart';

class OrderRepository {
  final ApiService api;

  OrderRepository({required this.api});

  /// POST /api/customer/place-order
  Future<Map<String, dynamic>> placeOrder(
    Map<String, dynamic> payload,
    {required String paymentMethod}
  ) async {
    try {
      final response = await api.post(
        '/api/order/place-order',
        {
          ...payload, // Includes addressId
          'paymentMethod': paymentMethod,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to place order');
      }
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }

  /// POST /api/customer/verify-payment
  Future<Map<String, dynamic>> verifyPayment(
    String razorpayOrderId,
    String razorpayPaymentId,
    String razorpaySignature,
  ) async {
    try {
      final response = await api.post(
        '/api/order/verify-payment',
        {
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature, 
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to verify payment');
      }
    } catch (e) {
      throw Exception('Failed to verify payment: $e');
    }
  }
}