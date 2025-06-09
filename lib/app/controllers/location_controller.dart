import 'package:customerapp/app/views/design_system/colors.dart';
import 'package:get/get.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../data/repositories/location_repository.dart';
import '../routes/app_routes.dart';
import 'package:uuid/uuid.dart';

class LocationController extends GetxController {
  // Observables
  var currentLatitude = 0.0.obs;
  var currentLongitude = 0.0.obs;
  var isLoading = true.obs;
  var selectedLatitude = 0.0.obs;
  var selectedLongitude = 0.0.obs;
  var selectedAddress = ''.obs;
  var addresses = <Map<String, dynamic>>[].obs;

  GoogleMapController? mapController;
  final LocationRepository repository = Get.find<LocationRepository>();
  final Uuid _uuid = Uuid();

  // Define the GeoJSON polygon coordinates
  static const List<LatLng> kazhakootamPolygonPoints = [
    LatLng(8.593783616905327, 76.85565122175746),
    LatLng(8.583403273109397, 76.8337328656599),
    LatLng(8.533435849110546, 76.87390739237031),
    LatLng(8.536342760270198, 76.87805793322745),
    LatLng(8.51490877852696, 76.89586585161314),
    LatLng(8.524229118179374, 76.90931148785268),
    LatLng(8.535959392813886, 76.89279502159607),
    LatLng(8.548940916698314, 76.91681223486785),
    LatLng(8.593783616905327, 76.85565122175746), // Closing the polygon
  ];

  // Point-in-polygon algorithm (ray-casting)
  bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int i = 0; i < polygon.length - 1; i++) {
      final LatLng vertex1 = polygon[i];
      final LatLng vertex2 = polygon[(i + 1) % polygon.length];
      if ((vertex1.latitude > point.latitude) != (vertex2.latitude > point.latitude) &&
          point.longitude <
              (vertex2.longitude - vertex1.longitude) *
                  (point.latitude - vertex1.latitude) /
                  (vertex2.latitude - vertex1.latitude) +
                  vertex1.longitude) {
        intersectCount++;
      }
    }
    return (intersectCount % 2) == 1;
  }

  @override
  void onInit() {
    super.onInit();
    loadAddressesFromApi();
  }

  /// Fetch addresses from API
  Future<void> loadAddressesFromApi() async {
    try {
      isLoading.value = true;
      final apiAddresses = await repository.getAddresses();
      print('API Addresses: $apiAddresses');
      addresses.value = (apiAddresses as List<dynamic>).map((addr) {
        final mapAddr = (addr as Map<dynamic, dynamic>).cast<String, dynamic>();
        return <String, dynamic>{
          ...mapAddr,
          'addressId': mapAddr['id']?.toString() ?? _uuid.v4(),
          'addressType': mapAddr['category'] ?? mapAddr['addressType'] ?? 'other',
          'phoneNumber': mapAddr['receiverContact'] ?? '',
          'directions': mapAddr['directions'] ?? '',
          'createdAt': mapAddr['createdAt'] ?? '',
        };
      }).toList();
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
        String geocodedString = await _reverseGeocodeWithReturn(lat, lng);
        String finalAddress = selected['flatHouseNo'] ?? '';
        if (geocodedString.isNotEmpty) {
          finalAddress += ', $geocodedString';
        }
        selectedAddress.value = finalAddress;
      }
    } catch (e) {
      if (!Get.isSnackbarOpen) {
        Get.snackbar('Error', 'Failed to load addresses: $e');
      }
      addresses.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  /// Set an existing address as default
  Future<void> setDefaultAddress(String? addressId) async {
    if (addressId == null || addressId.isEmpty) {
      if (!Get.isSnackbarOpen) {
        Get.snackbar('Error', 'Invalid address ID');
      }
      return;
    }
    try {
      isLoading.value = true;
      final selected = addresses.firstWhere(
        (addr) => addr['addressId'] == addressId,
        orElse: () => <String, dynamic>{},
      );
      if (selected.isEmpty) {
        if (!Get.isSnackbarOpen) {
          Get.snackbar('Error', 'Address not found');
        }
        return;
      }
      addresses.forEach((addr) {
        addr['isSelected'] = addr['addressId'] == addressId;
      });
      currentLatitude.value = (selected['latitude'] ?? 0).toDouble();
      currentLongitude.value = (selected['longitude'] ?? 0).toDouble();
      selectedLatitude.value = currentLatitude.value;
      selectedLongitude.value = currentLongitude.value;
      selectedAddress.value = '${selected['addressName'] ?? ''}, ${selected['flatHouseNo'] ?? ''}';
      if (!Get.isSnackbarOpen) {
        Get.snackbar('Success', 'Default address updated: ${selectedAddress.value}');
      }
    } catch (e) {
      if (!Get.isSnackbarOpen) {
        Get.snackbar('Error', 'Failed to set default address: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Reverse geocode coordinates
  Future<String> _reverseGeocodeWithReturn(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) {
        return 'Unknown Address';
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
      return full.isEmpty ? 'Unknown Address' : full;
    } catch (e) {
      return 'Unknown Address';
    }
  }

  /// Save a new address
  Future<void> saveAddress({bool isNewAddress = false}) async {
    try {
      isLoading.value = true;
      // Validate if the selected point is inside the polygon
      final selectedPoint = LatLng(selectedLatitude.value, selectedLongitude.value);
      if (!isPointInPolygon(selectedPoint, kazhakootamPolygonPoints)) {
        if (!Get.isSnackbarOpen) {
          Get.snackbar(
            'Invalid Location',
            'Please select a location within the Kazhakootam polygon.',
            backgroundColor: AppColors.warning.withOpacity(0.9),
            colorText: AppColors.backgroundPrimary,
          );
        }
        return;
      }
      if (isNewAddress) {
        Get.toNamed(AppRoutes.addressForm, arguments: {
          'latitude': selectedLatitude.value,
          'longitude': selectedLongitude.value,
          'initialAddress': selectedAddress.value,
        });
      } else {
        if (!Get.isSnackbarOpen) {
          Get.snackbar('Error', 'Use setDefaultAddress for existing addresses.');
        }
      }
    } catch (e) {
      if (!Get.isSnackbarOpen) {
        Get.snackbar('Error', 'Failed to save address: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Save a new address from form
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
      if (flatHouseNo.isEmpty || addressName.isEmpty) {
        return {'success': false, 'message': 'Required fields cannot be empty'};
      }
      final newAddress = {
        'addressId': _uuid.v4(),
        'flatHouseNo': flatHouseNo,
        'addressName': addressName,
        'directions': directions,
        'category': addressType, // Map to API's 'category'
        'receiverContact': phoneNumber, // Map to API's 'receiverContact'
        'latitude': latitude,
        'longitude': longitude,
        'isSelected': addresses.isEmpty,
      };
      final response = await repository.addAddress(newAddress);
      if (response['message'] == 'Address added successfully.') {
        final apiAddress = (response['address'] as Map<dynamic, dynamic>).cast<String, dynamic>();
        addresses.add({
          'addressId': apiAddress['id']?.toString() ?? newAddress['addressId'],
          'flatHouseNo': apiAddress['flatHouseNo'] ?? newAddress['flatHouseNo'],
          'addressName': apiAddress['addressName'] ?? newAddress['addressName'],
          'directions': apiAddress['directions'] ?? newAddress['directions'],
          'addressType': apiAddress['category'] ?? newAddress['category'],
          'phoneNumber': apiAddress['receiverContact'] ?? newAddress['receiverContact'],
          'latitude': apiAddress['latitude'] ?? newAddress['latitude'],
          'longitude': apiAddress['longitude'] ?? newAddress['longitude'],
          'isSelected': apiAddress['isSelected'] ?? newAddress['isSelected'],
          'createdAt': apiAddress['createdAt'] ?? '',
        });
        if (apiAddress['isSelected'] == true) {
          currentLatitude.value = latitude;
          currentLongitude.value = longitude;
          selectedLatitude.value = latitude;
          selectedLongitude.value = longitude;
          selectedAddress.value = '$addressName, $flatHouseNo';
        }
        return {'success': true, 'message': 'Address saved successfully'};
      } else {
        return {'success': false, 'message': response['message'] ?? 'Failed to save address'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to save address: $e'};
    }
  }

  /// Handle camera movement
  void onCameraMove(CameraPosition position) {
    selectedLatitude.value = position.target.latitude;
    selectedLongitude.value = position.target.longitude;
  }

  /// Update address when camera stops
  Future<void> onCameraIdle() async {
    String geocoded = await _reverseGeocodeWithReturn(
      selectedLatitude.value,
      selectedLongitude.value,
    );
    selectedAddress.value = geocoded;
  }

  /// Handle map creation
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
}