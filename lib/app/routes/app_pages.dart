// lib/app/routes/app_pages.dart

import 'package:get/get.dart';
import 'package:vendorapp/app/controllers/complete_signup_controller.dart';
import 'package:vendorapp/app/controllers/dashboard_controller.dart';
import 'package:vendorapp/app/controllers/restaurant_details_controller.dart';
import 'package:vendorapp/app/views/complete_signup_view.dart';
import 'package:vendorapp/app/views/dashboard_view.dart';
import '../controllers/login_controller.dart';
import '../controllers/otp_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/restaurant_details_controller.dart';
import '../views/login_view.dart';
import '../views/otp_view.dart';
import '../views/home_view.dart';
import '../views/restaurant_details_view.dart';
// import '../views/not_found_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.login;

  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LoginController>(() => LoginController());
      }),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OtpController>(() => OtpController());
      }),
    ),

    GetPage(
      name: '/home',
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),

    GetPage(
      name: '/restaurant-details',
      page: () => const RestaurantDetailsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<RestaurantDetailsController>(
            () => RestaurantDetailsController());
      }),
    ),

    // lib/app/routes/app_pages.dart

    GetPage(
      name: '/complete-signup',
      page: () => const CompleteSignupView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CompleteSignupController>(() => CompleteSignupController());
      }),
    ),

    // lib/app/routes/app_pages.dart

    GetPage(
      name: '/dashboard',
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DashboardController>(() => DashboardController());
        Get.lazyPut<HomeController>(() => HomeController());
        // Get.lazyPut<CartController>(() => CartController());
        // Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),

    GetPage(
      name: '/restaurant-details',
      page: () => const RestaurantDetailsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<RestaurantDetailsController>(
            () => RestaurantDetailsController());
      }),
    ),
  ];
}
