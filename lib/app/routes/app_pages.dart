// lib/app/routes/app_pages.dart
import 'package:customerapp/app/controllers/cart_controller.dart';
import 'package:customerapp/app/controllers/complete_signup_controller.dart';
import 'package:customerapp/app/controllers/dashboard_controller.dart';
import 'package:customerapp/app/controllers/network_controller.dart';
import 'package:customerapp/app/controllers/profile_controller.dart';
import 'package:customerapp/app/controllers/restaurant_details_controller.dart';
import 'package:customerapp/app/views/cart_view.dart';
import 'package:customerapp/app/views/complete_signup_view.dart';
import 'package:customerapp/app/views/dashboard_view.dart';
import 'package:customerapp/app/views/address_input_view.dart'; // New import
import 'package:customerapp/app/views/location_view.dart'; // Updated import
import 'package:customerapp/app/views/profile_view.dart';
import 'package:customerapp/app/views/razorpay_test_view.dart';
import 'package:customerapp/app/views/welcome-onboarding.dart'; // Add this import
import 'package:get/get.dart';
import '../controllers/category_vendors_controller.dart';
import '../controllers/location_controller.dart';
import '../controllers/login_controller.dart';
import '../controllers/otp_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/search_results_controller.dart';
import '../views/address_form_view.dart';
import '../views/category_vendors_view.dart';
import '../views/login_view.dart';
import '../views/otp_view.dart';
import '../views/home_view.dart';
import '../views/restaurant_details_view.dart';
import '../views/network_view.dart';
import '../views/search_results_view.dart';
import 'app_routes.dart';

class AppPages {
  // Set the initial route; here we use the login screen.
  static const initial = AppRoutes.login;

  static final routes = [
    GetPage(
      name: AppRoutes.network,
      page: () => const NetworkView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<NetworkController>(() => NetworkController());
      }),
    ),
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
    // Welcome Onboarding for new users
    GetPage(
      name: '/welcome-onboarding',
      page: () => const WelcomeOnboardingView(),
    ),
    // Address Input Page
    GetPage(
      name: AppRoutes.addressInput,
      page: () => const AddressInputView(),
      binding: BindingsBuilder(() {
        Get.put(LocationController()); // Ensure LocationController is available
      }),
    ),
    // Location Picker Page (Map-based selection)
    GetPage(
      name: AppRoutes.locationPicker,
      page: () =>  LocationView(),
      binding: BindingsBuilder(() {
        Get.put(LocationController()); // Reuse the same controller instance
      }),
    ),
    // Home route
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
        Get.lazyPut<LocationController>(() => LocationController());
      }),
    ),
    // Restaurant Details
    GetPage(
      name: AppRoutes.restaurantDetails,
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
    // Dashboard
    GetPage(
      name: '/dashboard',
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DashboardController>(() => DashboardController());
        Get.lazyPut<HomeController>(() => HomeController());
        Get.lazyPut<CartController>(() => CartController());
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    // Cart route
    GetPage(
      name: AppRoutes.cart,
      page: () => CartView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CartController>(() => CartController());
      }),
    ),
    // Profile route
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.razorpayTest,
      page: () => const RazorpayTestView(),
    ),
    GetPage(
      name: AppRoutes.searchResults,
      page: () => const SearchResultsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SearchResultsController>(() => SearchResultsController());
      }),
    ),
    GetPage(
      name: AppRoutes.categoryVendors,
      page: () => const CategoryVendorsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CategoryVendorsController>(
          () => CategoryVendorsController(),
        );
      }),
    ),

    GetPage(
  name: AppRoutes.addressForm,
  page: () => AddressFormView(
    latitude: Get.arguments['latitude'] ?? 0.0,
    longitude: Get.arguments['longitude'] ?? 0.0,
    initialAddress: Get.arguments['initialAddress'] ?? '',
  ),
  binding: BindingsBuilder(() {
    Get.put(LocationController()); // Ensure LocationController is available
  }),
),
  ];
}