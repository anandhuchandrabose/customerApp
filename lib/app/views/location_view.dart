import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import '../controllers/location_controller.dart';
import 'dart:async'; // For debouncing
import '../routes/app_routes.dart';
import 'address_form_view.dart'; // New import for the address form

// Define your primary color.
const Color kPrimaryColor = Color(0xFFFF3008);

// Define the bounds for Kazhakootam, Trivandrum (adjusted to be more inclusive)
final LatLngBounds kazhakootamBounds = LatLngBounds(
  southwest: LatLng(8.495, 76.890), // Further expanded southwest
  northeast: LatLng(8.605, 77.000), // Further expanded northeast
);

class LocationView extends GetView<LocationController> {
  LocationView({Key? key}) : super(key: key);

  // Initialize Google Maps Places API
  final GoogleMapsPlaces _places = GoogleMapsPlaces(
    apiKey: 'AIzaSyDZZHgBbs6qxbJdG_709xnXw97wbOJefoQ', // Replace with your API key
  );

  // Debouncer to limit frequent camera adjustments and API calls
  Timer? _debounce;

  // Observable list for place suggestions
  final RxList<Prediction> _suggestions = <Prediction>[].obs;

  @override
  Widget build(BuildContext context) {
    return _LocationViewStateful(_suggestions, _places, _debounce);
  }
}

class _LocationViewStateful extends StatefulWidget {
  final RxList<Prediction> suggestions;
  final GoogleMapsPlaces places;
  final Timer? debounce;

  const _LocationViewStateful(this.suggestions, this.places, this.debounce, {Key? key}) : super(key: key);

  @override
  __LocationViewStatefulState createState() => __LocationViewStatefulState();
}

class __LocationViewStatefulState extends State<_LocationViewStateful> {
  late Timer? _debounce;
  late Set<Polygon> _polygons;

  @override
  void initState() {
    super.initState();
    _debounce = widget.debounce;
    _polygons = {
      Polygon(
        polygonId: const PolygonId('kazhakootamBounds'),
        points: [
          kazhakootamBounds.southwest,
          LatLng(kazhakootamBounds.southwest.latitude, kazhakootamBounds.northeast.longitude),
          kazhakootamBounds.northeast,
          LatLng(kazhakootamBounds.northeast.latitude, kazhakootamBounds.southwest.longitude),
        ],
        strokeWidth: 2,
        strokeColor: Colors.red,
        fillColor: Colors.red.withOpacity(0.1),
      ),
    };
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LocationController controller = Get.find<LocationController>();
    final args = Get.arguments ?? {'isNewAddress': false};

    return Scaffold(
      appBar: AppBar(
        title: Text('Select delivery location', style: GoogleFonts.workSans(color: Colors.white)),
        backgroundColor: kPrimaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for a place in Kazhakootam...',
                    hintStyle: GoogleFonts.workSans(color: Colors.grey[600], fontSize: 16),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) async {
                    if (value.isNotEmpty) {
                      if (_debounce?.isActive ?? false) _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () async {
                        final response = await widget.places.autocomplete(
                          value, // Input query as String
                          location: Location(lat: 8.550, lng: 76.940), // Center of Kazhakootam
                          radius: 3000, // Reduced radius to 3 km for stricter constraint
                          types: ['address'],
                        );
                        if (response.isOkay) {
                          widget.suggestions.value = response.predictions;
                        } else {
                          widget.suggestions.clear();
                          Get.snackbar('Error', 'No suggestions found or API error: ${response.errorMessage}');
                        }
                      });
                    } else {
                      widget.suggestions.clear();
                    }
                  },
                ),
                Obx(() => Container(
                      height: widget.suggestions.isNotEmpty ? 200.0 : 0.0,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.suggestions.length,
                        itemBuilder: (context, index) {
                          final prediction = widget.suggestions[index];
                          return ListTile(
                            title: Text(prediction.description ?? ''),
                            onTap: () async {
                              final placeDetails = await widget.places.getDetailsByPlaceId(prediction.placeId!);
                              if (placeDetails.isOkay) {
                                final latLng = LatLng(placeDetails.result.geometry!.location.lat, placeDetails.result.geometry!.location.lng);
                                if (kazhakootamBounds.contains(latLng)) {
                                  controller.selectedLatitude.value = latLng.latitude;
                                  controller.selectedLongitude.value = latLng.longitude;
                                  if (controller.mapController != null) {
                                    controller.mapController!.animateCamera(CameraUpdate.newLatLng(latLng));
                                  }
                                  controller.selectedAddress.value = placeDetails.result.formattedAddress ?? 'No address';
                                  Get.snackbar(
                                    'Location Selected',
                                    'Address: ${controller.selectedAddress.value}',
                                    snackPosition: SnackPosition.BOTTOM,
                                    duration: const Duration(seconds: 2),
                                  );
                                  widget.suggestions.clear(); // Clear suggestions after selection

                                  // Navigate to address form if adding a new address
                                  if (args['isNewAddress'] == true) {
                                    Get.to(() => AddressFormView(
                                      latitude: latLng.latitude,
                                      longitude: latLng.longitude,
                                      initialAddress: controller.selectedAddress.value,
                                    ));
                                  }
                                } else {
                                  Get.snackbar('Error', 'Please select a location within Kazhakootam, Trivandrum. (Lat: ${latLng.latitude}, Lng: ${latLng.longitude})');
                                }
                              }
                            },
                          );
                        },
                      ),
                    )),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        controller.currentLatitude.value,
                        controller.currentLongitude.value,
                      ),
                      zoom: 15,
                    ),
                    onMapCreated: controller.onMapCreated,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    polygons: _polygons, // Add the boundary polygon
                    onCameraMove: (CameraPosition position) {
                      // Update selected position
                      controller.selectedLatitude.value = position.target.latitude;
                      controller.selectedLongitude.value = position.target.longitude;
                      // Debounce the clamping to avoid lag
                      if (_debounce?.isActive ?? false) _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 200), () {
                        if (!kazhakootamBounds.contains(position.target)) {
                          final clampedLat = position.target.latitude.clamp(
                            kazhakootamBounds.southwest.latitude,
                            kazhakootamBounds.northeast.latitude,
                          );
                          final clampedLng = position.target.longitude.clamp(
                            kazhakootamBounds.southwest.longitude,
                            kazhakootamBounds.northeast.longitude,
                          );
                          controller.mapController?.animateCamera(
                            CameraUpdate.newLatLng(LatLng(clampedLat, clampedLng)),
                          );
                        }
                      });
                    },
                    onCameraIdle: controller.onCameraIdle,
                    minMaxZoomPreference: const MinMaxZoomPreference(10.0, 18.0), // Limit zoom levels
                  ),
                  Center(
                    child: Icon(Icons.location_pin, color: Colors.red, size: 50),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              return Text(
                controller.selectedAddress.value.isNotEmpty
                    ? controller.selectedAddress.value
                    : 'No location selected',
                style: GoogleFonts.workSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              );
            }),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                if (args['isNewAddress'] == true) {
                  // Navigate to address form for new address
                  Get.to(() => AddressFormView(
                    latitude: controller.selectedLatitude.value,
                    longitude: controller.selectedLongitude.value,
                    initialAddress: controller.selectedAddress.value,
                  ));
                } else {
                  // Save and proceed for existing address
                  controller.saveAddress();
                  Get.offAllNamed('/dashboard'); // Changed from AppRoutes.home to dashboard
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
              child: Text(
                'CONFIRM LOCATION',
                style: GoogleFonts.workSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}