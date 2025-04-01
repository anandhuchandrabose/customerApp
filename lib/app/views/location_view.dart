import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import '../controllers/location_controller.dart';
import 'dart:async'; // For debouncing
import '../routes/app_routes.dart';
import 'address_form_view.dart'; // New import for the address form
import 'design_system/typography.dart'; // Import AppTypography
import 'design_system/spacing.dart'; // Import AppSpacing
import 'design_system/icons.dart'; // Import AppIcons
import 'design_system/colors.dart'; // Import AppColors

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
        strokeColor: AppColors.primary,
        fillColor: AppColors.primary.withOpacity(0.1),
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
      backgroundColor: AppColors.backgroundPrimary, // Match HomeView background
      appBar: AppBar(
        title: Text(
          'Select Delivery Location',
          style: AppTypography.heading2.copyWith(color: AppColors.textHighestEmphasis), // Match HomeView heading style
        ),
        backgroundColor: AppColors.backgroundPrimary, // Match HomeView SliverAppBar
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.9),
                AppColors.primarySub.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: AppSpacing.paddingL, // Match HomeView padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(), // Reusing HomeView's search bar style
                AppSpacing.gapM,
                Obx(() => Container(
                      height: widget.suggestions.isNotEmpty ? 200.0 : 0.0,
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: widget.suggestions.length,
                        separatorBuilder: (context, index) => AppSpacing.gapS,
                        itemBuilder: (context, index) {
                          final prediction = widget.suggestions[index];
                          return _buildSuggestionCard(prediction, controller, args);
                        },
                      ),
                    )),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary, // Match HomeView refresh indicator
                  ),
                );
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
                    polygons: _polygons,
                    onCameraMove: (CameraPosition position) {
                      controller.selectedLatitude.value = position.target.latitude;
                      controller.selectedLongitude.value = position.target.longitude;
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
                    minMaxZoomPreference: const MinMaxZoomPreference(10.0, 18.0),
                  ),
                  Center(
                    child: AppIcons.locationPinIcon(
                      color: AppColors.primary,
                      size: 50,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: AppSpacing.paddingL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() {
              return Text(
                controller.selectedAddress.value.isNotEmpty
                    ? controller.selectedAddress.value
                    : 'No location selected',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMedEmphasis,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              );
            }),
            AppSpacing.gapM,
            ElevatedButton(
              onPressed: () {
                if (args['isNewAddress'] == true) {
                  Get.to(() => AddressFormView(
                        latitude: controller.selectedLatitude.value,
                        longitude: controller.selectedLongitude.value,
                        initialAddress: controller.selectedAddress.value,
                      ));
                } else {
                  controller.saveAddress();
                  Get.offAllNamed('/dashboard');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                elevation: 5,
                shadowColor: AppColors.textLowEmphasis.withOpacity(0.3),
              ),
              child: Text(
                'Confirm Location',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.backgroundPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.backgroundPrimary,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textLowEmphasis.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for a place in Kazhakootam...',
          hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMedEmphasis),
          prefixIcon: AppIcons.searchIcon(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.mic),
            color: AppColors.textMedEmphasis,
            onPressed: () {
              // Add voice search functionality if needed
            },
          ),
          filled: true,
          fillColor: AppColors.backgroundSecondary,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) async {
          if (value.isNotEmpty) {
            if (_debounce?.isActive ?? false) _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 500), () async {
              final response = await widget.places.autocomplete(
                value,
                location: Location(lat: 8.550, lng: 76.940),
                radius: 3000,
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
    );
  }

  Widget _buildSuggestionCard(Prediction prediction, LocationController controller, Map<String, dynamic> args) {
    return GestureDetector(
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
              backgroundColor: AppColors.primary.withOpacity(0.9),
              colorText: AppColors.backgroundPrimary,
            );
            widget.suggestions.clear();

            if (args['isNewAddress'] == true) {
              Get.to(() => AddressFormView(
                    latitude: latLng.latitude,
                    longitude: latLng.longitude,
                    initialAddress: controller.selectedAddress.value,
                  ));
            }
          } else {
            Get.snackbar(
              'Error',
              'Please select a location within Kazhakootam, Trivandrum.',
              backgroundColor: AppColors.warning.withOpacity(0.9),
              colorText: AppColors.backgroundPrimary,
            );
          }
        }
      },
      child: Container(
        padding: AppSpacing.paddingM,
        decoration: BoxDecoration(
          color: AppColors.backgroundPrimary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.textLowEmphasis.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.textLowEmphasis.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          prediction.description ?? '',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textHighestEmphasis,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}