// lib/app/controllers/location_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/services/api_service.dart';
import 'package:http/http.dart' as http;

class LocationController extends GetxController {
  // Observables for current location and loading status.
  var currentLatitude = 0.0.obs;
  var currentLongitude = 0.0.obs;
  var isLoading = true.obs;
  GoogleMapController? mapController;

  // Observables for the user-selected location (updated as the map moves).
  var selectedLatitude = 0.0.obs;
  var selectedLongitude = 0.0.obs;
  
  // Observable for the selected address string.
  var selectedAddress = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _getCurrentLocation();
  }

  /// Fetches the current location.
  Future<void> _getCurrentLocation() async {
    try {
      // Check and request location permissions.
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      currentLatitude.value = position.latitude;
      currentLongitude.value = position.longitude;
      selectedLatitude.value = position.latitude;
      selectedLongitude.value = position.longitude;
    } catch (e) {
      print("Error fetching location: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Callback for when the GoogleMap is created.
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  /// Updates the selected location when the camera moves.
  void onCameraMove(CameraPosition position) {
    selectedLatitude.value = position.target.latitude;
    selectedLongitude.value = position.target.longitude;
  }

  /// Saves the address using the provided [payload].
  ///
  /// The payload should be built (for example, from a form) with all the details.
  /// For example:
  /// {
  ///   "addressName": "Home",
  ///   "receiverName": "Manjula",
  ///   "receiverContact": "98480000",
  ///   "secondaryContact": "9424242",
  ///   "category": "home",
  ///   "flatHouseNo": "Devi Vihar",
  ///   "nearbyLocation": "",
  ///   "latitude": <selected latitude>,
  ///   "longitude": <selected longitude>,
  ///   "address": "Optional additional address info",
  ///   "isSelected": true
  /// }
  Future<void> saveAddress(Map<String, dynamic> payload) async {
    try {
      isLoading.value = true;
      // Instantiate the API service with your base URL.
      final apiService = ApiService(baseUrl: "https://yourapiurl.com");
      final http.Response response =
          await apiService.post('/api/customer/add-address', payload);

      // If the server returns success, show a snackbar and navigate back.
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data != null && data['message'] != null) {
          Get.snackbar("Success", data['message']);
          // Optionally update the global selected address.
          // For instance, using a formatted string from the payload.
          selectedAddress.value = "${payload['flatHouseNo']}, ${payload['addressName']}";
          Get.back();
        }
      } else {
        Get.snackbar("Error",
            "Failed to save address. Status: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to save address: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
