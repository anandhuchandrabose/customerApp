// lib/app/views/restaurant_details_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/restaurant_details_controller.dart';

class RestaurantDetailsView extends GetView<RestaurantDetailsController> {
  const RestaurantDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final detailsCtrl = Get.find<RestaurantDetailsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Details'),
      ),
      body: Obx(() {
        if (detailsCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (detailsCtrl.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              detailsCtrl.errorMessage.value,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (detailsCtrl.dishes.isEmpty) {
          return const Center(
            child: Text('No dishes available.'),
          );
        }

        return ListView.builder(
          itemCount: detailsCtrl.dishes.length,
          itemBuilder: (_, index) {
            final dish = detailsCtrl.dishes[index];
            return ListTile(
              title: Text(dish['name'] ?? 'Unknown Dish'),
              subtitle: Text(dish['description'] ?? ''),
              trailing: Text('₹${dish['price'] ?? 0}'),
            );
          },
        );
      }),
    );
  }
}
