// lib/app/views/restaurant_details_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/restaurant_details_controller.dart';

class RestaurantDetailsView extends GetView<RestaurantDetailsController> {
  /// Store the selected filter locally in an RxString
  /// (You could store this in the controller instead if you like).
  final RxString selectedFilter = ''.obs;

  RestaurantDetailsView({Key? key}) : super(key: key);

  /// Labels for our filtering chips
  final List<String> chipLabels = const ['Veg', 'Non-Veg', 'Lunch', 'Dinner'];

  @override
  Widget build(BuildContext context) {
    final detailsCtrl = Get.find<RestaurantDetailsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Details')),
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

        // We'll just show a circular avatar with a restaurant icon
        // since we don't have a restaurantImagePath:
        final allDishes = detailsCtrl.dishes;

        if (allDishes.isEmpty) {
          return const Center(child: Text('No dishes available.'));
        }

        // -------------------------------------------------------------
        // 1) Filter logic based on selectedFilter (Veg / Non-Veg / Lunch / Dinner)
        // -------------------------------------------------------------
        final filteredDishes = allDishes.where((dish) {
          if (selectedFilter.value.isEmpty) return true;

          // If filter is 'Veg', only show isVeg == true
          if (selectedFilter.value == 'Veg') {
            return (dish['isVeg'] == true);
          }
          // If filter is 'Non-Veg', only show isVeg == false
          if (selectedFilter.value == 'Non-Veg') {
            return (dish['isVeg'] == false);
          }
          // If filter is 'Lunch'
          if (selectedFilter.value == 'Lunch') {
            return (dish['mealType'] == 'lunch');
          }
          // If filter is 'Dinner'
          if (selectedFilter.value == 'Dinner') {
            return (dish['mealType'] == 'dinner');
          }
          return true;
        }).toList();

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // ========= Restaurant Icon / Circular Avatar (Fallback) =========
                const CircleAvatar(
                  radius: 60,
                  child: Icon(
                    Icons.restaurant,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),

                // ========= Filter Chips (Veg, Non-Veg, Lunch, Dinner) =========
                Obx(
                  () => Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: chipLabels.map((label) {
                      final isSelected = (selectedFilter.value == label);
                      return ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        selectedColor: Colors.green.shade200,
                        onSelected: (bool value) {
                          // If user unselects the chip, reset filter
                          selectedFilter.value = value ? label : '';
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // =============== List of Filtered Dishes ===============
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: filteredDishes.length,
                  itemBuilder: (context, index) {
                    final dish = filteredDishes[index];

                    final dishName = dish['name'] ?? 'Unnamed Dish';
                    final description = dish['description'] ?? '';
                    final price = dish['price'] ?? '0.00';
                    final vendorDishId = dish['vendorDishId'] ?? '';
                    final mealType = dish['mealType'] ?? 'lunch';
                    final imagePath = dish['imagePath'] != null
                        ? 'http://10.0.2.2:3000/${dish['imagePath']}'
                        : null;

                    return _buildDishCard(
                      context,
                      dishName: dishName,
                      description: description,
                      price: price,
                      mealType: mealType,
                      vendorDishId: vendorDishId,
                      imagePath: imagePath,
                      onAddToCart: () {
                        detailsCtrl.addItemToCart(
                          vendorDishId: vendorDishId,
                          quantity: 1,
                          mealType: mealType,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// A helper method that returns a more visually appealing card
  Widget _buildDishCard(
    BuildContext context, {
    required String dishName,
    required String description,
    required String price,
    required String mealType,
    required String vendorDishId,
    required VoidCallback onAddToCart,
    String? imagePath,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Row(
        children: [
          // ===== Left side: Dish Image =====
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(12)),
            child: imagePath != null
                ? Image.network(
                    imagePath,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey.shade300,
                        child:
                            const Icon(Icons.fastfood, color: Colors.white70),
                      );
                    },
                  )
                : Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.fastfood, color: Colors.white70),
                  ),
          ),

          // ===== Right side: Info + Cart button =====
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dish name + (mealType)
                  Text(
                    '$dishName (${mealType.toUpperCase()})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Description
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Price + Add to cart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹$price',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: onAddToCart,
                        icon: const Icon(Icons.add_shopping_cart, size: 16),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: Colors.orange.shade600,
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
