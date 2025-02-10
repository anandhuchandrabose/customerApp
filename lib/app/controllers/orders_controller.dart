// lib/app/controllers/orders_controller.dart
import 'dart:convert';
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
      
      // Since it's a POST request without a payload, pass an empty map.
      final response = await _api.post('/api/customer/get-customer-orders', {});
      
      // Decode the response body from JSON.
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      // Check if the response contains an 'orders' list.
      if (data['orders'] is List) {
        orders.value = List<Map<String, dynamic>>.from(data['orders']);
      } else {
        orders.clear();
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
