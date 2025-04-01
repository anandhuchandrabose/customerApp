// lib/app/bindings/initial_binding.dart
import 'package:customerapp/app/controllers/cart_controller.dart';
import 'package:customerapp/app/controllers/dashboard_controller.dart';
import 'package:customerapp/app/controllers/profile_controller.dart';
import 'package:customerapp/app/controllers/home_controller.dart';
import 'package:customerapp/app/controllers/orders_controller.dart'; // Import the OrdersController
import 'package:customerapp/app/data/repositories/order_repository.dart';
import 'package:get/get.dart';
// import '../controllers/location_picker_controller.dart';
import '../controllers/location_controller.dart';
import '../data/repositories/location_repository.dart';
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
      // () => ApiService(baseUrl: 'http://127.0.0.1:3000'),
      () => ApiService(baseUrl: 'https://api.fresmo.in'),
      fenix: true,
    );

    // Register LocationRepository so that it can be found by Get.find<LocationRepository>()
    Get.lazyPut<LocationRepository>(
      () => LocationRepository(api: Get.find<ApiService>()),
      fenix: true,
    );

    Get.lazyPut<LocationController>(() => LocationController(), fenix: true);

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

    // Register CartController
    Get.lazyPut<CartController>(() => CartController(), fenix: true);

    // Register OrderRepository permanently
    Get.put<OrderRepository>(
      OrderRepository(api: Get.find<ApiService>()),
      permanent: true,
    );

    // 3) Register Controllers
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    Get.lazyPut<OrdersController>(() => OrdersController(), fenix: true);
  }
}
