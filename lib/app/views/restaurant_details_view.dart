import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/restaurant_details_controller.dart';
import '../controllers/cart_controller.dart';

class RestaurantDetailsView extends GetView<RestaurantDetailsController> {
  static const Color kPrimaryColor = Color(0xFFFF3008);
  final RxString selectedFilter = ''.obs;

  final List<String> chipLabels = const [
    'All',
    'Lunch',
    'Dinner',
    'Veg',
    'NonVeg'
  ];

  RestaurantDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Retrieve controllers
    final cartCtrl = Get.find<CartController>();
    final detailsCtrl = Get.find<RestaurantDetailsController>();

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Obx(() {
        final itemCount = cartCtrl.totalItemCount;
        final totalPrice = cartCtrl.totalPrice;
        if (itemCount == 0) {
          return const SizedBox.shrink();
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              Text(
                '$itemCount item(s)  ₹${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Get.toNamed('/cart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: kPrimaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'View Cart',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        );
      }),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        centerTitle: false,
        title: const Text(
          'Restaurant Details',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {},
          ),
        ],
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

        final restaurantName = detailsCtrl.restaurantName.value;
        final restaurantImageUrl = detailsCtrl.restaurantImageUrl.value;
        final rating = detailsCtrl.rating.value.toStringAsFixed(1);
        final allDishes = detailsCtrl.dishes;
        final servingTime = detailsCtrl.servingTime.value;

        if (allDishes.isEmpty) {
          return const Center(child: Text('No dishes available.'));
        }

        // Filter the dishes based on the selected chip label.
        final filteredDishes = allDishes.where((dish) {
          final filter = selectedFilter.value;
          if (filter.isEmpty || filter == 'All') return true;
          if (filter == 'Veg') return (dish['nonveg'] == 0);
          if (filter == 'NonVeg') return (dish['nonveg'] == 1);
          if (filter == 'Lunch') return (dish['mealType'] == 'lunch');
          if (filter == 'Dinner') return (dish['mealType'] == 'dinner');
          return true;
        }).toList();

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 8),
                // Restaurant header area
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade200,
                  child: ClipOval(
                    child: (restaurantImageUrl.isNotEmpty)
                        ? Image.network(
                            restaurantImageUrl,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.restaurant, size: 50),
                          )
                        : const Icon(Icons.restaurant, size: 50),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  restaurantName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      rating,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                  ],
                ),
                const SizedBox(height: 8),
                _buildFilterChips(),
                const SizedBox(height: 8),
                Text(
                  servingTime.isNotEmpty
                      ? servingTime
                      : 'Lunch: 12 PM to 2 PM  |  Dinner: 8 PM to 10 PM',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                // Heading: "Recommended (X)"
                Row(
                  children: [
                    Text(
                      'Recommended (${filteredDishes.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // List of dish items
                ListView.builder(
                  itemCount: filteredDishes.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final dish = filteredDishes[index];
                    final dishName = dish['name'] ?? '';
                    final dishDescription = dish['description'] ?? '';
                    final price = dish['price'] ?? '0.00';
                    final nonveg = dish['nonveg'] ?? 0; // 0=veg, 1=nonveg
                    final isVeg = (nonveg == 0);
                    final mealType = dish['mealType'] ?? 'lunch';
                    final vendorDishId = dish['vendorDishId'] ?? '';
                    final dishImageUrl = dish['image'] ?? '';
                    final ratingValue = dish['rating'] ?? 3.9;
                    final ratingCount = dish['ratingCount'] ?? 0;
                    final isBestseller = (ratingValue >= 4.0);

                    return _buildDishTile(
                      vendorDishId: vendorDishId,
                      dishName: dishName,
                      description: dishDescription,
                      price: price.toString(),
                      isVeg: isVeg,
                      mealType: mealType,
                      dishImageUrl: dishImageUrl,
                      ratingValue: ratingValue,
                      ratingCount: ratingCount,
                      isBestseller: isBestseller,
                      onAdd: () {
                        // Call addItemToCart without sending a quantity.
                        cartCtrl.addItemToCart(
                          vendorDishId: vendorDishId,
                          mealType: mealType,
                        );
                      },
                      onIncrement: () {
                        cartCtrl.increaseItemQuantity(
                          vendorDishId: vendorDishId,
                          mealType: mealType,
                        );
                      },
                      onDecrement: () {
                        cartCtrl.decreaseItemQuantity(
                          vendorDishId: vendorDishId,
                          mealType: mealType,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFilterChips() {
    return Obx(() {
      return Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        alignment: WrapAlignment.center,
        children: chipLabels.map((label) {
          final isSelected = (selectedFilter.value == label);
          return ChoiceChip(
            label: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            selected: isSelected,
            selectedColor: kPrimaryColor,
            backgroundColor: Colors.grey.shade200,
            onSelected: (bool value) {
              selectedFilter.value = value ? label : '';
            },
          );
        }).toList(),
      );
    });
  }

  // Updated dish tile widget that rebuilds its quantity display reactively.
  Widget _buildDishTile({
    required String vendorDishId,
    required String dishName,
    required String description,
    required String price,
    required bool isVeg,
    required String mealType,
    required String? dishImageUrl,
    required double ratingValue,
    required int ratingCount,
    required bool isBestseller,
    required VoidCallback onAdd,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    // Retrieve the CartController instance
    final cartCtrl = Get.find<CartController>();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT side: Dish details and description.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bestseller tag.
                if (isBestseller)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Bestseller',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                // Dish name and price.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        dishName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₹$price',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Rating row (e.g. 3.7 (36)).
                Row(
                  children: [
                    Text(
                      ratingValue.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, size: 14, color: Colors.orange),
                    const SizedBox(width: 6),
                    Text(
                      '($ratingCount)',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Truncated description with "more".
                _buildTruncatedDescription(description),
                // Display price below description.
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '₹$price',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // RIGHT side: Dish image and the ADD / stepper controls.
          Column(
            children: [
              _buildDishImage(dishImageUrl, isVeg),
              const SizedBox(height: 8),
              // Use Obx to rebuild the button area whenever the dish quantity changes.
              Obx(() {
                final int quantity = cartCtrl.getDishQuantity(vendorDishId);
                if (quantity == 0) {
                  return SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: onAdd,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('ADD'),
                    ),
                  );
                } else {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _stepperButton(
                        iconData: Icons.remove,
                        onTap: onDecrement,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          quantity.toString(),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      _stepperButton(
                        iconData: Icons.add,
                        onTap: onIncrement,
                      ),
                    ],
                  );
                }
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTruncatedDescription(String description) {
    const maxChars = 50;
    if (description.length <= maxChars) {
      return Text(
        description,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
      );
    } else {
      final truncated = description.substring(0, maxChars).trim();
      return RichText(
        text: TextSpan(
          text: '$truncated... ',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
          children: [
            TextSpan(
              text: 'more',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDishImage(String? dishImageUrl, bool isVeg) {
    final borderRadius = BorderRadius.circular(12);
    if (dishImageUrl == null || dishImageUrl.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: borderRadius,
        ),
        child: Icon(
          Icons.fastfood,
          size: 36,
          color: isVeg ? Colors.green : Colors.red,
        ),
      );
    }
    if (dishImageUrl.startsWith('data:image')) {
      try {
        final base64Str = dishImageUrl.split(',').last;
        final imageBytes = base64Decode(base64Str);
        return ClipRRect(
          borderRadius: borderRadius,
          child: Image.memory(
            imageBytes,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 80,
              height: 80,
              color: Colors.grey.shade300,
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        );
      } catch (e) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: borderRadius,
          ),
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      }
    } else {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.network(
          dishImageUrl,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 80,
            height: 80,
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      );
    }
  }

  Widget _stepperButton({
    required IconData iconData,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(iconData, size: 16, color: kPrimaryColor),
      ),
    );
  }
}
