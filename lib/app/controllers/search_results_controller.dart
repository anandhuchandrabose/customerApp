import 'dart:convert';
import 'package:get/get.dart';
import '../data/services/api_service.dart';

class SearchResultsController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var searchResults = <Map<String, dynamic>>[].obs;

  Future<void> searchDishes(String searchKey) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      // Send a POST request with the payload {"searchKey": searchKey}
      final response = await _api.post('/api/customer/search-dishes', {"searchKey": searchKey});
      final data = jsonDecode(response.body);
      if (data is List) {
        searchResults.value = List<Map<String, dynamic>>.from(data);
      } else {
        searchResults.clear();
      }
    } catch (e) {
      errorMessage.value = e.toString();
      searchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
