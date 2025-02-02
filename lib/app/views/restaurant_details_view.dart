import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/restaurant_details_controller.dart';

class RestaurantDetailsView extends GetView<RestaurantDetailsController> {
  static const Color kPrimaryColor = Color(0xFFFF3008);
  final RxString selectedFilter = ''.obs;

  final List<String> chipLabels = const ['All', 'Lunch', 'Dinner', 'Veg', 'NonVeg'];

  RestaurantDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final detailsCtrl = Get.find<RestaurantDetailsController>();

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Obx(() {
        final itemCount = detailsCtrl.cartItemCount.value;
        final totalPrice = detailsCtrl.cartTotalPrice.value;
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
                '$itemCount item ₹${totalPrice.toStringAsFixed(2)}',
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('View Cart',
                    style: TextStyle(fontWeight: FontWeight.bold)),
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
          'Your order #5412',
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

        if (allDishes.isEmpty) {
          return const Center(child: Text('No dishes available.'));
        }

        // Filtering
        final filteredDishes = allDishes.where((dish) {
          if (selectedFilter.value.isEmpty || selectedFilter.value == 'All') return true;
          if (selectedFilter.value == 'Veg') return dish['nonveg'] == 0;
          if (selectedFilter.value == 'NonVeg') return dish['nonveg'] == 1;
          if (selectedFilter.value == 'Lunch') return dish['mealType'] == 'lunch';
          if (selectedFilter.value == 'Dinner') return dish['mealType'] == 'dinner';
          return true;
        }).toList();

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 8),
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade200,
                  child: ClipOval(
                    child: restaurantImageUrl.isNotEmpty
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
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
                const Text(
                  'Lunch serves between 12 PM to 2PM\nDinner serves between 8PM to 10PM',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Explore food Items',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.filter_list, color: Colors.grey),
                    ),
                  ],
                ),
                ListView.builder(
                  itemCount: filteredDishes.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final dish = filteredDishes[index];
                    final dishName = dish['name'] ?? '';
                    final dishDescription = dish['description'] ?? '';
                    final price = dish['price'] ?? '0.00';
                    final dishRating = '4.9'; 
                    final nonveg = dish['nonveg'] ?? 0; // 0=veg, 1=nonveg
                    final isVeg = (nonveg == 0);
                    final mealType = dish['mealType'] ?? 'lunch';
                    final vendorDishId = dish['vendorDishId'] ?? '';
                    final dishImageUrl = dish['image'] ?? '';

                    // Retrieve local quantity from the controller
                    final quantity = detailsCtrl.dishQuantity(vendorDishId);

                    return _buildDishTile(
                      dishName: dishName,
                      description: dishDescription,
                      rating: dishRating,
                      price: price.toString(),
                      isVeg: isVeg,
                      mealType: mealType,
                      quantity: quantity,
                      dishImageUrl: dishImageUrl,
                      onAdd: () {
                        // FIRST TIME => /add-item
                        detailsCtrl.addNewItemToCart(
                          vendorDishId: vendorDishId,
                          mealType: mealType,
                        );
                      },
                      onIncrement: () {
                        // SUBSEQUENT => /increase
                        detailsCtrl.increaseItemQuantity(
                          vendorDishId: vendorDishId,
                          mealType: mealType,
                        );
                      },
                      onDecrement: () {
                        // SUBSEQUENT => /decrease
                        detailsCtrl.decreaseItemQuantity(
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

  Widget _buildDishTile({
    required String dishName,
    required String description,
    required String rating,
    required String price,
    required bool isVeg,
    required String mealType,
    required int quantity,
    String? dishImageUrl,
    required VoidCallback onAdd,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _buildDishImage(dishImageUrl, isVeg),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dishName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.circle,
                        color: isVeg ? Colors.green : Colors.red,
                        size: 8,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Meal Type: $mealType',
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.orange),
                          const SizedBox(width: 2),
                          Text(
                            rating,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        '₹$price',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (quantity == 0)
              ElevatedButton(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: const Text('Add'),
              )
            else
              Row(
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
              )
          ],
        ),
      ),
    );
  }

  Widget _buildDishImage(String? dishImageUrl, bool isVeg) {
    if (dishImageUrl == null || dishImageUrl.isEmpty) {
      // Show placeholder
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.fastfood,
          color: isVeg ? Colors.green : Colors.red,
        ),
      );
    }

    // Check if it's base64
    if (dishImageUrl.startsWith('data:image')) {
      try {
        final base64Str = dishImageUrl.split(',').last;
        final imageBytes = base64Decode(base64Str);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            imageBytes,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 60,
              height: 60,
              color: Colors.grey.shade300,
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        );
      } catch (e) {
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      }
    } else {
      // Otherwise assume a direct network URL
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          dishImageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 60,
            height: 60,
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
