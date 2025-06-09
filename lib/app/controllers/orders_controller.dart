import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/api_service.dart';

class OrdersController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  var orders = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _api.post('/api/customer/get-customer-orders', {});
      
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      if (data['orders'] is List) {
        orders.value = List<Map<String, dynamic>>.from(data['orders']);
      } else {
        orders.clear();
      }
    } catch (e) {
      errorMessage.value = 'Failed to fetch orders: $e';
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelSubOrder(String subOrderId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _api.post(
        '/api/order/cancel-suborder',
        {'subOrderId': subOrderId}, // Fixed typo from 'subOrderIdd'
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Sub-order cancelled successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await fetchOrders();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to cancel sub-order');
      }
    } catch (e) {
      errorMessage.value = 'Failed to cancel sub-order: $e';
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitRating(String subOrderId, String vendorId, int rating, String comment) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _api.post(
        '/api/rating/add',
        {
          'subOrderId': subOrderId,
          'vendorId': vendorId,
          'rating': rating.toString(), // Convert int to string as per payload
          'comment': comment.isNotEmpty ? comment : null, // Send null if empty
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Rating submitted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await fetchOrders(); // Refresh orders to update isRated status
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to submit rating');
      }
    } catch (e) {
      errorMessage.value = 'Failed to submit rating: $e';
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}