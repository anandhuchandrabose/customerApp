// lib/app/views/location_picker_view.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

import '../data/repositories/location_repository.dart';

class LocationPickerView extends StatefulWidget {
  const LocationPickerView({Key? key}) : super(key: key);

  @override
  _LocationPickerViewState createState() => _LocationPickerViewState();
}

class _LocationPickerViewState extends State<LocationPickerView> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();

  // List for place suggestions from the autocomplete API.
  List<dynamic> _placeSuggestions = [];

  // List for saved addresses retrieved from the API.
  List<dynamic> _savedAddresses = [];

  // The current center of the map (updated as the camera moves).
  LatLng? _currentCenter;

  // Default location: Kazhakoottam, Trivandrum (approximate coordinates).
  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(8.5241, 76.9366),
    zoom: 14,
  );

  // Replace with your actual Google Places API key.
  final String _googleApiKey = 'AIzaSyDZZHgBbs6qxbJdG_709xnXw97wbOJefoQ';

  // Assume you have a LocationRepository instance available via GetX.
  late LocationRepository locationRepository;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    // Get the instance from GetX (make sure it was registered in your initial bindings).
    locationRepository = Get.find<LocationRepository>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Request location permission from the user (using permission_handler).
  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (!status.isGranted) {
      debugPrint('Location permission not granted.');
      // You might want to show a dialog or snackbar here, prompting the user.
    }
  }

  /// If permitted, fetch the device’s current location using geolocator.
  /// Then animate the map camera to that position and update _currentCenter.
  Future<void> _goToMyLocation() async {
    // 1) Check permission again in case user changed settings
    final status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) {
      Get.snackbar('Permission Denied', 'Location permission not granted.');
      return;
    }

    // 2) Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Error', 'Location services are disabled on this device.');
      return;
    }

    // 3) Retrieve current position
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final LatLng newLatLng = LatLng(position.latitude, position.longitude);

      // 4) Animate camera
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: newLatLng, zoom: 16),
        ),
      );

      // 5) Update _currentCenter
      setState(() {
        _currentCenter = newLatLng;
      });
    } catch (e) {
      debugPrint('Error getting current location: $e');
      Get.snackbar('Error', 'Unable to get current location.');
    }
  }

  /// Fetch place suggestions from the Google Places Autocomplete API.
  Future<void> _getPlaceSuggestions(String input) async {
  if (input.isEmpty) {
    setState(() {
      _placeSuggestions = [];
    });
    return;
  }
  final String encodedInput = Uri.encodeComponent(input);
  final String url =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$encodedInput&types=geocode&key=$_googleApiKey';
  debugPrint('Place suggestions URL: $url');
  try {
    final response = await http.get(Uri.parse(url));
    debugPrint('API response: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _placeSuggestions = data['predictions'] ?? [];
      });
    } else {
      debugPrint('Error fetching suggestions: ${response.body}');
    }
  } catch (e) {
    debugPrint('Exception fetching suggestions: $e');
  }
}

  /// When a suggestion is tapped, fetch its details and update the map.
  Future<void> _selectPlaceSuggestion(Map<String, dynamic> suggestion) async {
    final placeId = suggestion['place_id'];
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=$_googleApiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] != null && data['result']['geometry'] != null) {
          final location = data['result']['geometry']['location'];
          final double lat = location['lat'];
          final double lng = location['lng'];
          final LatLng selectedLocation = LatLng(lat, lng);

          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: selectedLocation, zoom: 16),
            ),
          );
          setState(() {
            _currentCenter = selectedLocation;
            _placeSuggestions = []; // Clear suggestions after selection.
            _searchController.text = suggestion['description'];
          });
        }
      } else {
        debugPrint('Error fetching place details: ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception fetching place details: $e');
    }
  }

  /// Show a dialog to collect address details from the user.
  Future<void> _showAddressFormDialog() async {
    // Create text controllers with default values.
    final addressNameController = TextEditingController(text: "Home");
    final receiverNameController = TextEditingController(text: "Name");
    final receiverContactController = TextEditingController(text: "0000000000");
    final secondaryContactController = TextEditingController(text: "121212");
    final categoryController = TextEditingController(text: "home");
    final flatHouseNoController = TextEditingController(text: "flat/house");
    final nearbyLocationController = TextEditingController(text: "");
    final addressController = TextEditingController(text: "");

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Address Details"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: addressNameController,
                  decoration: const InputDecoration(labelText: "Address Name"),
                ),
                TextField(
                  controller: receiverNameController,
                  decoration: const InputDecoration(labelText: "Receiver Name"),
                ),
                TextField(
                  controller: receiverContactController,
                  decoration:
                      const InputDecoration(labelText: "Receiver Contact"),
                ),
                TextField(
                  controller: secondaryContactController,
                  decoration:
                      const InputDecoration(labelText: "Secondary Contact"),
                ),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: "Category"),
                ),
                TextField(
                  controller: flatHouseNoController,
                  decoration:
                      const InputDecoration(labelText: "Flat/House No"),
                ),
                TextField(
                  controller: nearbyLocationController,
                  decoration:
                      const InputDecoration(labelText: "Nearby Location"),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Address"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog.
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // Construct the payload using the form values and the selected coordinates.
                final payload = {
                  "addressName": addressNameController.text,
                  "receiverName": receiverNameController.text,
                  "receiverContact": receiverContactController.text,
                  "secondaryContact": secondaryContactController.text,
                  "category": categoryController.text,
                  "flatHouseNo": flatHouseNoController.text,
                  "nearbyLocation": nearbyLocationController.text,
                  "latitude": _currentCenter?.latitude ?? 0,
                  "longitude": _currentCenter?.longitude ?? 0,
                  "address": addressController.text,
                  "isSelected": true
                };
                Navigator.of(context).pop(); // Close the dialog.
                _saveAddressWithPayload(payload);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  /// Save the address using the provided payload.
  Future<void> _saveAddressWithPayload(Map<String, dynamic> payload) async {
    try {
      await locationRepository.addAddress(payload);
      debugPrint('Address saved successfully.');
      Get.snackbar('Success', 'Address saved successfully.');
    } catch (e) {
      debugPrint('Error saving address: $e');
      Get.snackbar('Error', 'Failed to save address.');
    }
  }

  /// Fetch saved addresses via the repository.
  Future<void> _getSavedAddresses() async {
    try {
      final addresses = await locationRepository.getAddresses();
      setState(() {
        _savedAddresses = addresses;
      });
    } catch (e) {
      debugPrint('Error fetching addresses: $e');
    }
  }

  /// Display saved addresses in a bottom sheet.
  void _showSavedAddresses() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        if (_savedAddresses.isEmpty) {
          return const Center(child: Text('No saved addresses.'));
        }
        return ListView.builder(
          itemCount: _savedAddresses.length,
          itemBuilder: (context, index) {
            final address = _savedAddresses[index];
            return ListTile(
              title: Text(address['addressName'] ?? ''),
              subtitle: Text(
                '${address['flatHouseNo'] ?? ''}, ${address['receiverName'] ?? ''}',
              ),
            );
          },
        );
      },
    );
  }

  /// Pin the current location (save the current map center coordinates).
  void _pinCurrentLocation() {
    if (_currentCenter != null) {
      // Optionally, you can show a snackbar or dialog to confirm pinning.
      Get.snackbar('Location Pinned',
          'Current location pinned: ${_currentCenter!.latitude}, ${_currentCenter!.longitude}');
      setState(() {
        debugPrint(
            'Pinned location: ${_currentCenter!.latitude}, ${_currentCenter!.longitude}');
      });
      _showAddressFormDialog();
    } else {
      Get.snackbar(
          'Error', 'No location available to pin. Move the map or search first.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location', style: GoogleFonts.workSans()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // Google Map widget.
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            myLocationEnabled: false, // If you want the little blue dot
            myLocationButtonEnabled: false, // We'll handle our own button
            onMapCreated: (controller) {
              _mapController = controller;
              _currentCenter = _initialCameraPosition.target;
            },
            onCameraMove: (position) {
              _currentCenter = position.target;
            },
          ),
          // Fixed pin at the center of the map.
          const Center(
            child: Icon(
              Icons.location_pin,
              size: 50,
              color: Colors.red,
            ),
          ),
          // Search bar overlay.
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search location',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  _getPlaceSuggestions(value);
                },
              ),
            ),
          ),
          // Place suggestions overlay.
          if (_placeSuggestions.isNotEmpty)
            Positioned(
              top: 70,
              left: 16,
              right: 16,
              child: Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(8),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _placeSuggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _placeSuggestions[index];
                    return ListTile(
                      title: Text(suggestion['description']),
                      onTap: () {
                        _selectPlaceSuggestion(suggestion);
                      },
                    );
                  },
                ),
              ),
            ),
          // Confirm button overlay to show the address form dialog.
          Positioned(
            bottom: 80,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _pinCurrentLocation,
                  child: Text(
                    'Pin Location',
                    style: GoogleFonts.workSans(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: _showAddressFormDialog,
                  child: Text(
                    'Confirm & Save Address',
                    style: GoogleFonts.workSans(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // 1) This is your "Saved Addresses" button to open a list.
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 2) "My Location" button to recenter the map on the user’s current position.
          FloatingActionButton(
            heroTag: 'my_location_btn',
            onPressed: _goToMyLocation,
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 12),
          // 3) "Show Saved" button to show the bottom sheet of saved addresses.
          FloatingActionButton(
            heroTag: 'saved_addresses_btn',
            onPressed: () async {
              await _getSavedAddresses();
              _showSavedAddresses();
            },
            child: const Icon(Icons.list),
          ),
        ],
      ),
    );
  }
}