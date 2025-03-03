import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/location_controller.dart';
import '../routes/app_routes.dart';

// Define your primary color.
const Color kPrimaryColor = Color(0xFFFF3008);

class AddressInputView extends GetView<LocationController> {
  const AddressInputView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Location',
          style: GoogleFonts.workSans(color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Try Kazhakkootam, Kulathur etc...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                // Handle search or input changes if needed
              },
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                await controller.getCurrentLocation();
                Get.toNamed(AppRoutes.locationPicker, arguments: {'isNewAddress': true});
              },
              child: Row(
                children: [
                  Icon(Icons.location_on, color: kPrimaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Use my current location',
                    style: GoogleFonts.workSans(
                      fontSize: 16,
                      color: kPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.locationPicker, arguments: {'isNewAddress': true});
              },
              child: Row(
                children: [
                  Icon(Icons.add, color: kPrimaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Add new address',
                    style: GoogleFonts.workSans(
                      fontSize: 16,
                      color: kPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Saved Addresses',
              style: GoogleFonts.workSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
              }
              final addresses = controller.addresses;
              if (addresses.isEmpty) {
                return Text(
                  'No saved addresses found.',
                  style: GoogleFonts.workSans(color: Colors.grey[600], fontSize: 14),
                );
              }
              return Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    final isSelected = address['isSelected'] ?? false;
                    return ListTile(
                      leading: Icon(
                        isSelected ? Icons.location_on : Icons.location_off,
                        color: isSelected ? kPrimaryColor : Colors.grey,
                      ),
                      title: Text(
                        address['addressName'] ?? 'Unnamed Address',
                        style: GoogleFonts.workSans(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        '${address['flatHouseNo'] ?? ''}, Lat: ${address['latitude']}, Long: ${address['longitude']}',
                        style: GoogleFonts.workSans(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: kPrimaryColor)
                          : null,
                      onTap: () async {
                        controller.currentLatitude.value = (address['latitude'] ?? 0).toDouble();
                        controller.currentLongitude.value = (address['longitude'] ?? 0).toDouble();
                        controller.selectedLatitude.value = (address['latitude'] ?? 0).toDouble();
                        controller.selectedLongitude.value = (address['longitude'] ?? 0).toDouble();
                        controller.selectedAddress.value = '${address['addressName'] ?? ''}, ${address['flatHouseNo'] ?? ''}';
                        Get.toNamed(AppRoutes.locationPicker, arguments: {'isNewAddress': false});
                      },
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}