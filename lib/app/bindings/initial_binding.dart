// lib/app/bindings/initial_binding.dart

import 'package:get/get.dart';
import 'package:vendorapp/app/controllers/profile_controller.dart';
// import '../controllers/profile_controller.dart';
import '../controllers/cart_controller.dart';
// ... other imports

import '../data/services/api_service.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/restaurant_repository.dart';
import '../data/repositories/cart_repository.dart';
import '../data/repositories/home_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 1) Register ApiService
    Get.lazyPut<ApiService>(
      () => ApiService(
          baseUrl: 'http://127.0.0.1:3000'), 
      fenix: true,
    );

    // 2) Register Repositories
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(api: Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<RestaurantRepository>(
      () => RestaurantRepository(api: Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<CartRepository>(
      () => CartRepository(api: Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<HomeRepository>(
      () => HomeRepository(api: Get.find<ApiService>()),
      fenix: true,
    );
    // Ensure CartRepository is available
    Get.lazyPut<CartRepository>(
        () => CartRepository(api: Get.find<ApiService>()),
        fenix: true);
    // Then register CartController
    Get.lazyPut<CartController>(() => CartController(), fenix: true);

    // 3) Register Controllers
    Get.lazyPut<ProfileController>(() => ProfileController());
    // Get.lazyPut<CartController>(() => CartController());
    // Register other controllers as needed
  }
}




//  'http://127.0.0.1:3000'),