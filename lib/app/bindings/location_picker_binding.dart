import 'package:get/get.dart';
import '../controllers/location_picker_controller.dart';
import '../data/repositories/location_repository.dart';

class LocationPickerBinding extends Bindings {
  @override
  void dependencies() {
    // Make sure that LocationRepository is already registered (for example, in your initial bindings).
    Get.lazyPut<LocationPickerController>(
      () => LocationPickerController(locationRepository: Get.find<LocationRepository>()),
    );
  }
}
