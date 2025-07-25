// restaurant_details_controller.dart
import 'dart:developer';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/repositories/restaurant_repository.dart';
import 'cart_controller.dart';
import 'network_controller.dart';

class RestaurantDetailsController extends GetxController {
  final RestaurantRepository _restaurantRepo = Get.find<RestaurantRepository>();
  final CartController cartCtrl = Get.find<CartController>();

  // Basic fields
  static const String baseUrl =
      'https://api.fresmo.in/'; // Include trailing slash
  var vendorId = ''.obs;
  var dishes = <Map<String, dynamic>>[].obs;

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Restaurant display
  var restaurantName = 'Restaurant'.obs;
  var restaurantImageUrl = ''.obs;
  var restaurantDescription = ''.obs; // Added description
  var rating = 0.0.obs;
  var servingTime = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    final storage = GetStorage();
    vendorId.value = args['vendorId'] ?? storage.read('vendorId') ?? '';

    if (vendorId.value.isEmpty) {
      errorMessage.value = 'No vendorId provided.';
      Get.snackbar('Error', 'Vendor ID not provided.');
    } else {
      fetchRestaurantAndDishes();
    }
  }

  Future<void> fetchRestaurantAndDishes() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = await _restaurantRepo.fetchDishes(vendorId.value);
      log('fetchDishes Response: $data');

      if (data['success'] == true) {
        final restaurantData = data['data'] ?? {};

        restaurantName.value = restaurantData['vendorName'] ?? 'Unknown';
        final imagePath =
            restaurantData['vendorImage'] ?? restaurantData['image'] ?? '';
        restaurantImageUrl.value = imagePath.startsWith('http')
            ? imagePath
            : 'https://api.fresmo.in/$imagePath';
        restaurantDescription.value = restaurantData['description'] ??
            'description'; // Handle description
        rating.value =
            double.tryParse(restaurantData['rating']?.toString() ?? '0') ?? 0.0;
        log('Using image URL: ${restaurantImageUrl.value}');

        final dishesData = restaurantData['dishes'] ?? [];
        if (dishesData is List) {
          dishes.value = List<Map<String, dynamic>>.from(dishesData);
        }
        if (dishes.isEmpty && data['message'] != null) {
          errorMessage.value = data['message'];
        }
      } else {
        errorMessage.value = data['message'] ?? 'Failed to load data.';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      log('Error fetching restaurant data: $e');
      final networkController = Get.find<NetworkController>();
      networkController.handleError(e);
    } finally {
      isLoading.value = false;
    }
  }
}
