// lib/app/bindings/initial_binding.dart

import 'package:get/get.dart';
import '../data/services/api_service.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/home_repository.dart';
import '../data/repositories/restaurant_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Register ApiService
    Get.put<ApiService>(ApiService(baseUrl: 'http://127.0.0.1:3000'),
        permanent: true);

    // Register Repositories
    Get.put<AuthRepository>(AuthRepository(api: Get.find<ApiService>()),
        permanent: true);
    Get.put<HomeRepository>(HomeRepository(api: Get.find<ApiService>()),
        permanent: true);
    Get.put<RestaurantRepository>(
        RestaurantRepository(api: Get.find<ApiService>()),
        permanent: true);
  }
}




//  'http://127.0.0.1:3000'),