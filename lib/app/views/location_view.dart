import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import '../controllers/location_controller.dart';
import 'dart:async';
import '../routes/app_routes.dart';
import 'address_form_view.dart';
import 'design_system/typography.dart';
import 'design_system/spacing.dart';
import 'design_system/icons.dart';
import 'design_system/colors.dart';
import '../../config.dart';

// Define the GeoJSON coordinates as a static list
final List<LatLng> kazhakootamPolygonPoints = [
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

// Compute LatLngBounds from the polygon points
LatLngBounds computeBounds(List<LatLng> points) {
  double minLat = points[0].latitude;
  double maxLat = points[0].latitude;
  double minLng = points[0].longitude;
  double maxLng = points[0].longitude;

  for (var point in points) {
    if (point.latitude < minLat) minLat = point.latitude;
    if (point.latitude > maxLat) maxLat = point.latitude;
    if (point.longitude < minLng) minLng = point.longitude;
    if (point.longitude > maxLng) maxLng = point.longitude;
  }

  return LatLngBounds(
    southwest: LatLng(minLat, minLng),
    northeast: LatLng(maxLat, maxLng),
  );
}

final LatLngBounds kazhakootamBounds = computeBounds(kazhakootamPolygonPoints);

// Compute the centroid for search center
LatLng computeCentroid(List<LatLng> points) {
  double latSum = 0;
  double lngSum = 0;
  for (var point in points) {
    latSum += point.latitude;
    lngSum += point.longitude;
  }
  return LatLng(latSum / points.length, lngSum / points.length);
}

final LatLng kazhakootamCenter = computeCentroid(kazhakootamPolygonPoints);

class LocationView extends GetView<LocationController> {
  LocationView({Key? key}) : super(key: key);

  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: AppConfig.googleMapsApiKey);
  final RxList<Prediction> _suggestions = <Prediction>[].obs;

  @override
  Widget build(BuildContext context) {
    return _LocationViewStateful(_suggestions, _places);
  }
}

class _LocationViewStateful extends StatefulWidget {
  final RxList<Prediction> suggestions;
  final GoogleMapsPlaces places;

  const _LocationViewStateful(this.suggestions, this.places, {Key? key}) : super(key: key);

  @override
  __LocationViewStatefulState createState() => __LocationViewStatefulState();
}

class __LocationViewStatefulState extends State<_LocationViewStateful> {
  Timer? _debounce;
  late Set<Polygon> _polygons;

  @override
  void initState() {
    super.initState();
    _polygons = {
      Polygon(
        polygonId: const PolygonId('kazhakootamBounds'),
        points: kazhakootamPolygonPoints,
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
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Text(
          'Select Delivery Location',
          style: AppTypography.heading2.copyWith(color: AppColors.textHighestEmphasis),
        ),
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        leading: IconButton(
          icon: AppIcons.backIcon(),
          onPressed: () => Get.back(),
        ),
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: AppSpacing.paddingL,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(controller),
                  AppSpacing.gapM,
                  Obx(() => AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        height: widget.suggestions.isNotEmpty ? 150.0 : 0.0,
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
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                return Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          controller.currentLatitude.value != 0.0
                              ? controller.currentLatitude.value
                              : kazhakootamCenter.latitude,
                          controller.currentLongitude.value != 0.0
                              ? controller.currentLongitude.value
                              : kazhakootamCenter.longitude,
                        ),
                        zoom: 15,
                      ),
                      onMapCreated: controller.onMapCreated,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      polygons: _polygons,
                      onCameraMove: controller.onCameraMove,
                      onCameraIdle: controller.onCameraIdle,
                      minMaxZoomPreference: MinMaxZoomPreference(10.0, 18.0),
                      onCameraMoveStarted: () {
                        if (_debounce?.isActive ?? false) _debounce?.cancel();
                        _debounce = Timer(Duration(milliseconds: 100), () async {
                          final visibleRegion = await controller.mapController?.getVisibleRegion();
                          if (visibleRegion != null) {
                            final centerLat = (visibleRegion.southwest.latitude + visibleRegion.northeast.latitude) / 2;
                            final centerLng = (visibleRegion.southwest.longitude + visibleRegion.northeast.longitude) / 2;
                            final center = LatLng(centerLat, centerLng);
                            if (!kazhakootamBounds.contains(center)) {
                              Get.snackbar('Restricted Area', 'Please select a location within Kazhakootam.');
                              final clampedLat = controller.selectedLatitude.value.clamp(
                                kazhakootamBounds.southwest.latitude,
                                kazhakootamBounds.northeast.latitude,
                              );
                              final clampedLng = controller.selectedLongitude.value.clamp(
                                kazhakootamBounds.southwest.longitude,
                                kazhakootamBounds.northeast.longitude,
                              );
                              controller.mapController?.animateCamera(
                                CameraUpdate.newLatLng(LatLng(clampedLat, clampedLng)),
                              );
                            }
                          }
                        });
                      },
                    ),
                    Center(
                      child: AppIcons.locationPinIcon(color: AppColors.primary, size: 50),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundPrimary,
          boxShadow: [
            BoxShadow(
              color: AppColors.textLowEmphasis.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        padding: AppSpacing.paddingL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() => Text(
                  controller.selectedAddress.value.isNotEmpty
                      ? controller.selectedAddress.value
                      : 'No location selected',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMedEmphasis),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )),
            AppSpacing.gapM,
            ElevatedButton(
              onPressed: () => controller.saveAddress(isNewAddress: args['isNewAddress']),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 5,
              ),
              child: Text(
                'Confirm Location',
                style: AppTypography.labelLarge.copyWith(color: AppColors.backgroundPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(LocationController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.textLowEmphasis.withOpacity(0.15),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for a place in Kazhakootam...',
          hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMedEmphasis),
          prefixIcon: AppIcons.searchIcon(),
          suffixIcon: Obx(() => controller.isLoading.value
              ? Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                )
              : IconButton(
                  icon: AppIcons.micIcon(),
                  onPressed: () {
                    // Implement voice search if needed
                  },
                )),
          filled: true,
          fillColor: AppColors.backgroundSecondary,
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) async {
          widget.suggestions.clear();
          if (value.isNotEmpty) {
            controller.isLoading.value = true;
            _debounce?.cancel();
            _debounce = Timer(Duration(milliseconds: 300), () async {
              final response = await widget.places.autocomplete(
                value,
                location: Location(lat: kazhakootamCenter.latitude, lng: kazhakootamCenter.longitude),
                radius: 3000,
                types: ['address'],
              );
              controller.isLoading.value = false;
              if (response.isOkay) {
                widget.suggestions.value = response.predictions;
              } else {
                Get.snackbar('Error', 'No suggestions found: ${response.errorMessage}');
              }
            });
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
            controller.mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
            controller.selectedAddress.value = placeDetails.result.formattedAddress ?? 'Unknown Address';
            Get.snackbar(
              'Location Selected',
              controller.selectedAddress.value,
              snackPosition: SnackPosition.BOTTOM,
              duration: Duration(seconds: 2),
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
              'Please select a location within Kazhakootam.',
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
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.textLowEmphasis.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.textLowEmphasis.withOpacity(0.2),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          prediction.description ?? 'Unknown Place',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textHighestEmphasis),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}