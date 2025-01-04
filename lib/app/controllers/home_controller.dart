// lib/app/controllers/home_controller.dart

import 'package:get/get.dart';
import '../data/repositories/home_repository.dart';

class HomeController extends GetxController {
  final HomeRepository _homeRepo = Get.find<HomeRepository>();

  var vendors = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  get kitchens => null;

  get categories => null;

  @override
  void onInit() {
    super.onInit();
    fetchVendors();
  }

  Future<void> fetchVendors() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = await _homeRepo.fetchVendors();
      // data is a List<Map<String, dynamic>>
      vendors.value = data;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
