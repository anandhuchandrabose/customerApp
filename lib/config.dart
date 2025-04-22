import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppConfig {
  static const String googleMapsApiKey = 'AIzaSyDZZHgBbs6qxbJdG_709xnXw97wbOJefoQ'; 
  static final LatLngBounds kazhakootamBounds = LatLngBounds(
    southwest: LatLng(8.495, 76.890),
    northeast: LatLng(8.605, 77.000),
  );
  static const LatLng kazhakootamCenter = LatLng(8.550, 76.940);
}