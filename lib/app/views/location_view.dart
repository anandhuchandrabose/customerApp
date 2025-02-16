// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import '../controllers/location_controller.dart';

// // Define your primary color.
// const Color kPrimaryColor = Color(0xFFFF3008);

// class LocationView extends GetView<LocationController> {
//   const LocationView({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Scaffold with an AppBar and a GoogleMap widget.
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Select Location', style: GoogleFonts.workSans()),
//         backgroundColor: kPrimaryColor,
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         return Stack(
//           children: [
//             GoogleMap(
//               initialCameraPosition: CameraPosition(
//                 target: LatLng(
//                   controller.currentLatitude.value,
//                   controller.currentLongitude.value,
//                 ),
//                 zoom: 15,
//               ),
//               onMapCreated: controller.onMapCreated,
//               myLocationEnabled: true,
//               myLocationButtonEnabled: true,
//               onCameraMove: controller.onCameraMove,
//             ),
//             // A centered marker to indicate the selected location.
//             Center(
//               child: Icon(Icons.location_pin, color: Colors.red, size: 50),
//             ),
//           ],
//         );
//       }),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ElevatedButton(
//           onPressed: () async {
//             await controller.saveAddress();
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: kPrimaryColor,
//             padding: const EdgeInsets.symmetric(vertical: 16),
//           ),
//           child: Text(
//             'Save Location',
//             style: GoogleFonts.workSans(fontSize: 16),
//           ),
//         ),
//       ),
//     );
//   }
// }
