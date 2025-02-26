// lib/app/views/location_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/location_controller.dart';

// Define your primary color.
const Color kPrimaryColor = Color(0xFFFF3008);

class LocationView extends GetView<LocationController> {
  const LocationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Scaffold with an AppBar and a GoogleMap widget.
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location', style: GoogleFonts.workSans(color: Colors.white)),
        backgroundColor: kPrimaryColor,
      ),
      body: Obx(() {
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
              onCameraMove: controller.onCameraMove,
              onCameraIdle: controller.onCameraIdle,
            ),
            // A centered marker to indicate the current pin position.
            Center(
              child: Icon(Icons.location_pin, color: Colors.red, size: 50),
            ),
          ],
        );
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(26.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show the dynamically updated address (based on the pin).
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
              onPressed: () async {
                await controller.saveAddress();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16 , horizontal: 32),
              ),
              child: Text(
                'Save Location',
                style: GoogleFonts.workSans(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}