// lib/app/routes/app_pages.dart

import 'package:customerapp/app/controllers/cart_controller.dart';
import 'package:customerapp/app/controllers/complete_signup_controller.dart';
import 'package:customerapp/app/controllers/dashboard_controller.dart';
import 'package:customerapp/app/controllers/profile_controller.dart';
import 'package:customerapp/app/controllers/restaurant_details_controller.dart';
import 'package:customerapp/app/views/cart_view.dart';
import 'package:customerapp/app/views/complete_signup_view.dart';
import 'package:customerapp/app/views/dashboard_view.dart';
import 'package:customerapp/app/views/profile_view.dart';
import 'package:customerapp/app/views/razorpay_test_view.dart';
import 'package:get/get.dart';
import '../bindings/location_picker_binding.dart';
import '../controllers/category_vendors_controller.dart';
import '../controllers/location_controller.dart';
import '../controllers/login_controller.dart';
import '../controllers/otp_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/search_results_controller.dart';
import '../views/category_vendors_view.dart';
import '../views/location_picker_view.dart';
import '../views/login_view.dart';
import '../views/otp_view.dart';
import '../views/home_view.dart';
import '../views/restaurant_details_view.dart';
import '../views/search_results_view.dart';
import 'app_routes.dart';

class AppPages {
  // Set the initial route; here we use the login screen.
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

    // GetPage(
    //   name: '/location-picker',
    //   page: () => const LocationView(),
    //   binding: BindingsBuilder(() {
    //     Get.put(LocationController());
    //   }),
    // ),
    // Home route (if needed standalone)

    GetPage(
      name: '/location-picker',
      page: () => const LocationPickerView(),
      binding: LocationPickerBinding(), // Now this class is defined.
    ),

    GetPage(
      name: '/home',
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
        Get.lazyPut<LocationController>(() => LocationController());
      }),
    ),
    // Restaurant Details
    GetPage(
      name: '/restaurant-details',
      page: () => RestaurantDetailsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<RestaurantDetailsController>(
            () => RestaurantDetailsController());
      }),
    ),
    // Complete Signup
    GetPage(
      name: '/complete-signup',
      page: () => const CompleteSignupView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CompleteSignupController>(() => CompleteSignupController());
      }),
    ),
    // Dashboard: The main container that includes the persistent bottom navbar.
    GetPage(
      name: '/dashboard',
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DashboardController>(() => DashboardController());
        // Bind controllers for the individual tabs used within the Dashboard.
        Get.lazyPut<HomeController>(() => HomeController());
        Get.lazyPut<CartController>(() => CartController());
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    // Cart route (if you ever need to navigate to it separately; note that it won't have the dashboard's bottom nav)
    GetPage(
      name: '/cart',
      page: () => CartView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CartController>(() => CartController());
      }),
    ),
    // Profile route (if needed standalone)
    GetPage(
      name: '/profile',
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(
      name: '/razorpay-test',
      page: () => const RazorpayTestView(),
    ),

    GetPage(
      name: '/search-results',
      page: () => const SearchResultsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SearchResultsController>(() => SearchResultsController());
      }),
    ),
    GetPage(
      name: '/category-vendors',
      page: () => const CategoryVendorsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CategoryVendorsController>(
          () => CategoryVendorsController(),
        );
      }),
    ),
  ];
}
