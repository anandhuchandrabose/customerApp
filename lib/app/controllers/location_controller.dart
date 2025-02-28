import 'dart:convert';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get_storage/get_storage.dart';
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

  // Observable for the combined selected address string.
  var selectedAddress = ''.obs;

  // Observable for the list of addresses
  var addresses = <Map<String, dynamic>>[].obs;

  // Local storage instance.
  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    // Fetch all addresses from the API
    fetchAddresses();
  }

  /// Fetch all addresses from the API
  Future<void> fetchAddresses() async {
    try {
      isLoading.value = true;
      final apiService = ApiService(baseUrl: "https://www.fresmo.in");
      final http.Response response = await apiService.get('/api/customer/addresses');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['addresses'] != null) {
          addresses.value = List<Map<String, dynamic>>.from(data['addresses']);
          // Set the selected address if it exists
          final selected = addresses.firstWhere(
            (addr) => addr['isSelected'] == true,
            orElse: () => <String, dynamic>{},
          );
          if (selected != null) {
            final lat = (selected['latitude'] ?? 0).toDouble();
            final lng = (selected['longitude'] ?? 0).toDouble();
            currentLatitude.value = lat;
            currentLongitude.value = lng;
            selectedLatitude.value = lat;
            selectedLongitude.value = lng;
            String geocodedString = await _reverseGeocodeWithReturn(lat, lng);
            String finalAddress = selected['addressName'] ?? '';
            if (geocodedString.isNotEmpty) {
              finalAddress += ', $geocodedString';
            }
            selectedAddress.value = finalAddress;
            storage.write('userLocation', finalAddress);
          }
        }
      } else {
        throw Exception('Failed to load addresses');
      }
    } catch (e) {
      print("Error fetching addresses: $e");
      addresses.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  /// Public method to get the device's current location and reverse-geocode it.
  Future<void> getCurrentLocation() async {
    await _getCurrentLocation();
  }

  /// Get the device's current location and reverse-geocode it.
  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      currentLatitude.value = position.latitude;
      currentLongitude.value = position.longitude;
      selectedLatitude.value = position.latitude;
      selectedLongitude.value = position.longitude;

      String geocodedString = await _reverseGeocodeWithReturn(position.latitude, position.longitude);
      selectedAddress.value = geocodedString;
      storage.write('userLocation', geocodedString);
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  /// Reverse geocode and return a formatted address string.
  Future<String> _reverseGeocodeWithReturn(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) {
        return "($lat, $lng)";
      }
      Placemark place = placemarks.first;
      final placeName = place.name ?? '';
      final subLocality = place.subLocality ?? '';
      final locality = place.locality ?? '';
      final adminArea = place.administrativeArea ?? '';
      final country = place.country ?? '';

      final full = [placeName, subLocality, locality, adminArea, country]
          .where((segment) => segment.trim().isNotEmpty)
          .join(', ');
      return full.isEmpty ? "($lat, $lng)" : full;
    } catch (e) {
      print("Error in reverseGeocode: $e");
      return "($lat, $lng)";
    }
  }

  /// Called when the map's camera moves.
  void onCameraMove(CameraPosition position) {
    selectedLatitude.value = position.target.latitude;
    selectedLongitude.value = position.target.longitude;
  }

  /// Called when the camera stops moving.
  /// This updates the displayed address based on the current pin position.
  Future<void> onCameraIdle() async {
    String geocoded = await _reverseGeocodeWithReturn(
      selectedLatitude.value,
      selectedLongitude.value,
    );
    selectedAddress.value = geocoded;
  }

  /// Saves the currently selected location to local storage.
  ///
  /// This writes the current address from [selectedAddress] to storage,
  /// shows a snackbar, and navigates back.
  Future<void> saveAddress() async {
    try {
      isLoading.value = true;
      storage.write('userLocation', selectedAddress.value);
      Get.snackbar("Location Saved", selectedAddress.value);
      Get.back();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Called when the map is created.
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
}