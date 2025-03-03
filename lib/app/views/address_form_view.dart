import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/location_controller.dart';
import '../routes/app_routes.dart';

// Define your primary color.
const Color kPrimaryColor = Color(0xFFFF3008);

class AddressFormView extends GetView<LocationController> {
  final double latitude;
  final double longitude;
  final String initialAddress;

  const AddressFormView({
    required this.latitude,
    required this.longitude,
    required this.initialAddress,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Debug print to check if the controller is found
    final controller = Get.find<LocationController>();
    print('LocationController found: $controller');
    print('Latitude: $latitude, Longitude: $longitude, InitialAddress: $initialAddress');

    final houseFlatController = TextEditingController();
    final apartmentRoadController = TextEditingController(text: initialAddress);
    final directionsController = TextEditingController();
    final RxString selectedAddressType = 'Work'.obs; // Use RxString for reactive updates
    final phoneController = TextEditingController(text: '6238248775'); // Default phone number

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Add New Address',
          style: GoogleFonts.workSans(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0, // Remove shadow for a flat look
      ),
      backgroundColor: Colors.white, // Ensure background matches the image
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  kToolbarHeight - // AppBar height
                  16.0 * 2 - // Padding top and bottom
                  16.0, // Bottom navigation bar padding (approximate)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Use min to prevent unnecessary expansion
              children: [
                // Map preview (simplified, matching the image’s style)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!), // Lighter grey border
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Stack(
                    children: [
                      // Simulate a map background (you can replace with Google Maps or a real map image)
                      Container(
                        color: Colors.grey[200], // Light grey for map placeholder
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Center(
                        child: Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40, // Larger pin for visibility
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Text(
                          initialAddress,
                          style: GoogleFonts.workSans(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  initialAddress,
                  style: GoogleFonts.workSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: houseFlatController,
                  decoration: InputDecoration(
                    labelText: 'HOUSE / FLAT / BLOCK NO.',
                    labelStyle: GoogleFonts.workSans(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.grey[300]!), // Lighter grey border
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColor),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  style: GoogleFonts.workSans(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: apartmentRoadController,
                  decoration: InputDecoration(
                    labelText: 'APARTMENT / ROAD / AREA (RECOMMENDED)',
                    labelStyle: GoogleFonts.workSans(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColor),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  style: GoogleFonts.workSans(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: directionsController,
                  decoration: InputDecoration(
                    labelText: 'DIRECTIONS TO REACH (OPTIONAL)',
                    labelStyle: GoogleFonts.workSans(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0), // Rounded corners match image
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColor),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    hintText: 'e.g. Ring the bell on the red gate',
                    hintStyle: GoogleFonts.workSans(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  maxLength: 200,
                  maxLines: 3, // Allow multiple lines for directions
                  style: GoogleFonts.workSans(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Text(
                  'SAVE AS',
                  style: GoogleFonts.workSans(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                // Fix the Row with Flexible instead of Expanded to handle unbounded width
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Use min to prevent expansion
                    children: [
                      Flexible(
                        fit: FlexFit.loose, // Allow the button to size itself
                        child: Obx(() => OutlinedButton(
                          onPressed: () => selectedAddressType.value = 'Home',
                          style: OutlinedButton.styleFrom(
                            foregroundColor: selectedAddressType.value == 'Home' ? kPrimaryColor : Colors.grey[600],
                            side: BorderSide(color: selectedAddressType.value == 'Home' ? kPrimaryColor : Colors.grey[300]!),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.home, color: selectedAddressType.value == 'Home' ? kPrimaryColor : Colors.grey[600], size: 20),
                              const SizedBox(width: 8),
                              Text('Home', style: GoogleFonts.workSans(fontSize: 14)),
                            ],
                          ),
                        )),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        fit: FlexFit.loose, // Allow the button to size itself
                        child: Obx(() => ElevatedButton(
                          onPressed: () => selectedAddressType.value = 'Work',
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedAddressType.value == 'Work' ? kPrimaryColor : Colors.grey[200],
                            foregroundColor: selectedAddressType.value == 'Work' ? Colors.white : Colors.grey[600],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.work, color: selectedAddressType.value == 'Work' ? Colors.white : Colors.grey[600], size: 20),
                              const SizedBox(width: 8),
                              Text('Work', style: GoogleFonts.workSans(fontSize: 14)),
                            ],
                          ),
                        )),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        fit: FlexFit.loose, // Allow the button to size itself
                        child: Obx(() => OutlinedButton(
                          onPressed: () => selectedAddressType.value = 'Friends and Family',
                          style: OutlinedButton.styleFrom(
                            foregroundColor: selectedAddressType.value == 'Friends and Family' ? kPrimaryColor : Colors.grey[600],
                            side: BorderSide(color: selectedAddressType.value == 'Friends and Family' ? kPrimaryColor : Colors.grey[300]!),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people, color: selectedAddressType.value == 'Friends and Family' ? kPrimaryColor : Colors.grey[600], size: 20),
                              const SizedBox(width: 8),
                              Text('Friends and Family', style: GoogleFonts.workSans(fontSize: 14)),
                            ],
                          ),
                        )),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        fit: FlexFit.loose, // Allow the button to size itself
                        child: Obx(() => OutlinedButton(
                          onPressed: () => selectedAddressType.value = 'Other',
                          style: OutlinedButton.styleFrom(
                            foregroundColor: selectedAddressType.value == 'Other' ? kPrimaryColor : Colors.grey[600],
                            side: BorderSide(color: selectedAddressType.value == 'Other' ? kPrimaryColor : Colors.grey[300]!),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.pin_drop, color: selectedAddressType.value == 'Other' ? kPrimaryColor : Colors.grey[600], size: 20),
                              const SizedBox(width: 8),
                              Text('Other', style: GoogleFonts.workSans(fontSize: 14)),
                            ],
                          ),
                        )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: "RECEIVER'S PHONE NUMBER (OPTIONAL)",
                    labelStyle: GoogleFonts.workSans(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColor),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    prefixIcon: Icon(Icons.phone, color: Colors.grey[600], size: 20),
                  ),
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.workSans(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Text(
                  'We will call on ${phoneController.text}, if you are unavailable on this number.',
                  style: GoogleFonts.workSans(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final response = await controller.saveNewAddress(
                        flatHouseNo: houseFlatController.text,
                        addressName: apartmentRoadController.text,
                        directions: directionsController.text,
                        addressType: selectedAddressType.value,
                        phoneNumber: phoneController.text,
                        latitude: latitude,
                        longitude: longitude,
                      );
                      if (response['success'] == true) {
                        Get.snackbar('Success', 'Address saved successfully');
                        Get.offAllNamed('/dashboard'); // Navigate to dashboard after saving
                      } else {
                        Get.snackbar('Error', response['message'] ?? 'Failed to save address');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      'SAVE AND PROCEED',
                      style: GoogleFonts.workSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}