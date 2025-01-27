// lib/app/views/restaurant_details_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/restaurant_details_controller.dart';

class RestaurantDetailsView extends GetView<RestaurantDetailsController> {
  // We keep your filter in an RxString
  final RxString selectedFilter = ''.obs;

  // Our new base color #FF3008
  static const Color kPrimaryColor = Color(0xFFFF3008);

  // Filter labels
  final List<String> chipLabels = const ['Lunch', 'Dinner', 'Veg', 'NonVeg'];

  RestaurantDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final detailsCtrl = Get.find<RestaurantDetailsController>();

    return Scaffold(
      backgroundColor: Colors.white,

      // A bottom bar that shows total items, total price, and a "View Cart" button
      bottomNavigationBar: Obx(() {
        final itemCount = detailsCtrl.cartItemCount.value;    // from controller
        final totalPrice = detailsCtrl.cartTotalPrice.value;  // from controller

        if (itemCount == 0) {
          return const SizedBox.shrink(); // Hide if no items in cart
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
                onPressed: () {
                  // Navigate to your cart page
                  Get.toNamed('/cart');
                },
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
          'Your order #5412',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // search logic
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {
              // user profile logic
            },
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

        // Grab these dynamic fields from the controller:
        final restaurantName = detailsCtrl.restaurantName.value;
        final restaurantImageUrl = detailsCtrl.restaurantImageUrl.value;
        final rating = detailsCtrl.rating.value.toStringAsFixed(1);
        final servingTime = detailsCtrl.servingTime.value;

        final allDishes = detailsCtrl.dishes;
        if (allDishes.isEmpty) {
          return const Center(child: Text('No dishes available.'));
        }

        // Filter logic
        final filteredDishes = allDishes.where((dish) {
          if (selectedFilter.value.isEmpty) return true;

          if (selectedFilter.value == 'Veg') {
            // If nonveg == 0 => Veg
            return dish['nonveg'] == 0;
          } else if (selectedFilter.value == 'NonVeg') {
            return dish['nonveg'] == 1;
          } else if (selectedFilter.value == 'Lunch') {
            return (dish['mealType'] == 'lunch');
          } else if (selectedFilter.value == 'Dinner') {
            return (dish['mealType'] == 'dinner');
          }
          return true;
        }).toList();

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 8),
                // A circle avatar for the restaurant
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
                            errorBuilder: (ctx, err, stack) =>
                                const Icon(Icons.restaurant, size: 50),
                          )
                        : const Icon(Icons.restaurant, size: 50),
                  ),
                ),
                const SizedBox(height: 12),

                // Restaurant Name & star rating
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
                    const Icon(
                      Icons.star,
                      color: Colors.orange,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Filter chips
                _buildFilterChips(),

                const SizedBox(height: 4),

                // Serving time
                Text(
                  'Serves Between $servingTime',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 16),

                // Title + filter icon row: "Explore food Items"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Explore food Items',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // sorting/filtering logic if needed
                      },
                      icon: const Icon(
                        Icons.filter_list,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),

                // List of filtered dishes
                ListView.builder(
                  itemCount: filteredDishes.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final dish = filteredDishes[index];
                    final dishName = dish['name'] ?? '';
                    final dishDescription = dish['description'] ?? '';
                    final price = dish['price'] ?? '0.00';
                    final rating = '4.9'; // or dish['rating'] if you have it
                    final nonveg = dish['nonveg'] ?? 0; // 0 => veg, 1 => nonveg
                    final isVeg = (nonveg == 0);
                    final mealType = dish['mealType'] ?? 'lunch';
                    final vendorDishId = dish['vendorDishId'] ?? '';

                    // If you have a real quantity, fetch from the controller
                    final quantity = detailsCtrl.dishQuantity(vendorDishId);

                    return _buildDishTile(
                      dishName: dishName,
                      description: dishDescription,
                      rating: rating,
                      price: price.toString(),
                      isVeg: isVeg,
                      mealType: mealType,
                      quantity: quantity,
                      onAdd: () {
                        detailsCtrl.addItemToCart(
                          vendorDishId: vendorDishId,
                          quantity: 1,
                          mealType: mealType,
                        );
                      },
                      onIncrement: () {
                        detailsCtrl.addItemToCart(
                          vendorDishId: vendorDishId,
                          quantity: 1,
                          mealType: mealType,
                        );
                      },
                      onDecrement: () {
                        detailsCtrl.removeItemFromCart(vendorDishId);
                      },
                    );
                  },
                ),

                const SizedBox(height: 80), // space above bottom bar
              ],
            ),
          ),
        );
      }),
    );
  }

  /// A row of filter chips: Lunch, Dinner, Veg, NonVeg
  Widget _buildFilterChips() {
    return Obx(
      () {
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
      },
    );
  }

  /// Each dish item row, showing name, desc, price, rating, and Add / + - stepper.
 /// Each dish item row, now with a leading photo
Widget _buildDishTile({
  required String dishName,
  required String description,
  required String rating,
  required String price,
  required bool isVeg,
  required String mealType,
  required int quantity,
  required VoidCallback onAdd,
  required VoidCallback onIncrement,
  required VoidCallback onDecrement,
  String? dishImageUrl, // Optional image field
}) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 6),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 3,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // ============ Left side: Dish Image ============
          _buildDishImage(dishImageUrl, isVeg),

          const SizedBox(width: 12),

          // ============ Middle: Name, desc, rating, price ============
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + (veg dot)
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

                // Description
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Rating + Price
                Row(
                  children: [
                    // rating
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
                    // Price
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

          // ============ Right side: "Add" or Stepper ============
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

/// Helper to build the dish image container
Widget _buildDishImage(String? dishImageUrl, bool isVeg) {
  // If you have base64, decode it with base64Decode and use Image.memory
  // If you have a partial path, prepend your domain
  // For now, assume a direct network URL
  if (dishImageUrl == null || dishImageUrl.isEmpty) {
    // Show a placeholder
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

  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.network(
      dishImageUrl,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 60,
          height: 60,
          color: Colors.grey.shade300,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      },
    ),
  );
}

/// A small circular button for increment/decrement
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