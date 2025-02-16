import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/repositories/location_repository.dart';

class LocationPickerController extends GetxController {
  // The repository used for making API calls.
  final LocationRepository locationRepository;

  // Observable for the current center of the map.
  final Rxn<LatLng> currentCenter = Rxn<LatLng>();

  // Observable list for place suggestions.
  final RxList<dynamic> placeSuggestions = <dynamic>[].obs;

  // Observable list for saved addresses.
  final RxList<dynamic> savedAddresses = <dynamic>[].obs;

  // Observable for the selected address string (to update the "Select Location" text dynamically).
  final RxString selectedAddress = ''.obs;

  LocationPickerController({required this.locationRepository});

  /// Call this method when the map's camera moves.
  void updateCurrentCenter(LatLng center) {
    currentCenter.value = center;
  }

  /// Update the place suggestions.
  void updatePlaceSuggestions(List<dynamic> suggestions) {
    placeSuggestions.assignAll(suggestions);
  }

  /// Update the selected address string.
  void updateSelectedAddress(String address) {
    selectedAddress.value = address;
  }

  /// Adds an address using the repository.
  /// The payload should follow your API schema.
  Future<void> addAddress(Map<String, dynamic> payload) async {
    try {
      await locationRepository.addAddress(payload);
      // Update the selectedAddress observable using a custom format.
      // For example, here we combine the address name and flat/house number.
      updateSelectedAddress("${payload["addressName"]}, ${payload["flatHouseNo"]}");
      await getSavedAddresses(); // Refresh the saved addresses list.
    } catch (e) {
      print('Error adding address: $e');
      // Optionally, you could notify the user via Get.snackbar or similar.
    }
  }

  /// Fetches saved addresses via the repository.
  Future<void> getSavedAddresses() async {
    try {
      final addresses = await locationRepository.getAddresses();
      savedAddresses.assignAll(addresses);
    } catch (e) {
      print('Error fetching addresses: $e');
    }
  }
}
