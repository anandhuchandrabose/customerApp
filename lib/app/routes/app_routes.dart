// lib/app/routes/app_routes.dart
abstract class AppRoutes {
  static const login = '/login';
  static const otp = '/otp';
  static const home = '/home';
  static const restaurantDetails = '/restaurant-details';
  static const notFound = '/not-found';
  static const cart = '/cart';
  static const profile = '/profile'; // Corrected from '/restaurants-by-category'
  static const addressInput = '/address-input'; // New route for Address Input Page
  static const locationPicker = '/location-picker'; // Route for Location Selection Page
  static const razorpayTest = '/razorpay-test';
  static const searchResults = '/search-results';
  static const categoryVendors = '/category-vendors';
  static const addressForm = '/address-form';
}