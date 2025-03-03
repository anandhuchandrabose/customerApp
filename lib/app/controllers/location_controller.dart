import 'dart:convert';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get_storage/get_storage.dart';
import '../routes/app_routes.dart';

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

  // Observable for the list of addresses (now using local storage or mock data)
  var addresses = <Map<String, dynamic>>[].obs;

  // Local storage instance.
  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    loadAddressesFromStorage();
  }

  /// Load addresses from local storage (mock or previously saved data)
  Future<void> loadAddressesFromStorage() async {
    try {
      isLoading.value = true;
      final storedAddresses = storage.read<List>('addresses') ?? [];
      addresses.value = List<Map<String, dynamic>>.from(storedAddresses);
      // Set the selected address if it exists
      final selected = addresses.firstWhere(
        (addr) => addr['isSelected'] == true,
        orElse: () => <String, dynamic>{},
      );
      if (selected.isNotEmpty) {
        final lat = (selected['latitude'] ?? 0).toDouble();
        final lng = (selected['longitude'] ?? 0).toDouble();
        currentLatitude.value = lat;
        currentLongitude.value = lng;
        selectedLatitude.value = lat;
        selectedLongitude.value = lng;

        // Await the Future<String> from _reverseGeocodeWithReturn
        String geocodedString = await _reverseGeocodeWithReturn(lat, lng);
        String finalAddress = selected['addressName'] ?? '';
        if (geocodedString.isNotEmpty) {
          finalAddress += ', $geocodedString';
        }
        selectedAddress.value = finalAddress;
        storage.write('userLocation', finalAddress);
      }
    } catch (e) {
      print("Error loading addresses from storage: $e");
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
  /// shows a snackbar, and navigates back for existing addresses.
  /// For new addresses, it navigates to the address form.
  Future<void> saveAddress({bool isNewAddress = false}) async {
    try {
      isLoading.value = true;
      if (isNewAddress) {
        // Navigate to the address form with the selected location
        Get.toNamed(AppRoutes.addressForm, arguments: {
          'latitude': selectedLatitude.value,
          'longitude': selectedLongitude.value,
          'initialAddress': selectedAddress.value,
        });
      } else {
        // Save existing address to local storage
        final newAddress = {
          'latitude': selectedLatitude.value,
          'longitude': selectedLongitude.value,
          'address': selectedAddress.value,
          'isSelected': true, // Mark as selected
          'addressName': selectedAddress.value.split(', ').firstOrNull ?? selectedAddress.value,
          'flatHouseNo': '', // Default empty for existing address
          'directions': '', // Default empty for existing address
          'addressType': 'Home', // Default type
          'phoneNumber': '', // Default empty for existing address
        };
        addresses.add(newAddress);
        addresses.forEach((addr) => addr['isSelected'] = addr == newAddress);
        storage.write('userLocation', selectedAddress.value);
        storage.write('addresses', addresses.toList());
        Get.snackbar("Location Saved", selectedAddress.value);
        Get.back();
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Save a new address locally (mocking API behavior)
  Future<Map<String, dynamic>> saveNewAddress({
    required String flatHouseNo,
    required String addressName,
    required String directions,
    required String addressType,
    required String phoneNumber,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final newAddress = {
        'flatHouseNo': flatHouseNo,
        'addressName': addressName,
        'directions': directions,
        'addressType': addressType,
        'phoneNumber': phoneNumber,
        'latitude': latitude,
        'longitude': longitude,
        'isSelected': addresses.isEmpty, // Set as selected if no other addresses exist
      };
      addresses.add(newAddress);
      if (newAddress['isSelected'] == true) {
        currentLatitude.value = latitude;
        currentLongitude.value = longitude;
        selectedLatitude.value = latitude;
        selectedLongitude.value = longitude;
        selectedAddress.value = '$addressName, $flatHouseNo';
        storage.write('userLocation', selectedAddress.value);
      }
      addresses.forEach((addr) => addr['isSelected'] = addr == newAddress);
      storage.write('addresses', addresses.toList());
      return {'success': true, 'message': 'Address saved locally'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Called when the map is created.
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
}