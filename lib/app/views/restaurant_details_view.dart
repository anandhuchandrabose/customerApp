import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/dashboard_controller.dart';
import '../controllers/restaurant_details_controller.dart';
import '../controllers/cart_controller.dart';

/// Helper function to obtain an ImageProvider from a vendor image string.
/// If the string is not a URL, we assume it is a base64–encoded image.
ImageProvider getVendorImage(String imageString) {
  if (imageString.isEmpty) {
    return const AssetImage('assets/placeholder.png');
  } else if (imageString.startsWith('http')) {
    return NetworkImage(imageString);
  } else {
    try {
      // If the string does not contain the "data:image/..." header, we assume it is base64.
      return MemoryImage(
        base64Decode(
          imageString.contains(',') ? imageString.split(',').last : imageString,
        ),
      );
    } catch (e) {
      print("Error decoding vendor image: $e");
      return const AssetImage('assets/placeholder.png');
    }
  }
}

class RestaurantDetailsView extends GetView<RestaurantDetailsController> {
  static const Color kPrimaryColor = Color(0xFFFF3008);

  // For filtering dishes.
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
    final cartCtrl = Get.find<CartController>();
    final detailsCtrl = Get.find<RestaurantDetailsController>();

    return Scaffold(
      backgroundColor: Colors.white,
      // Bottom navigation bar: "View Cart" popup with fade up transition and bounce.
      bottomNavigationBar: Obx(() {
        final int itemCount = cartCtrl.totalItemCount;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) {
            // Use an elastic curve for a bounce effect.
            final curvedAnimation =
                CurvedAnimation(parent: animation, curve: Curves.elasticOut);
            return SlideTransition(
              position:
                  Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
                      .animate(curvedAnimation),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: itemCount == 0
              ? const SizedBox.shrink(key: ValueKey('empty'))
              : InkWell(
                  key: const ValueKey('cartPopup'),
                  onTap: () {
                    final dashboardCtrl = Get.find<DashboardController>();
                    dashboardCtrl.changeTabIndex(1); // Switch to Cart tab.
                    // Optionally, pop the current RestaurantDetailsView if needed:
                    Get.back();
                  },
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.shopping_cart,
                            color: Colors.white, size: 24),
                        Text(
                          'View Cart',
                          style: GoogleFonts.workSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$itemCount',
                          style: GoogleFonts.workSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      }),
      // Wrap the main content in a bounce animation.
      body: BouncyPage(
        child: Obx(() {
          if (detailsCtrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (detailsCtrl.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                detailsCtrl.errorMessage.value,
                style: GoogleFonts.workSans(color: Colors.red),
              ),
            );
          }

          // Get restaurant details from the controller.
          final vendorImage = detailsCtrl.restaurantImageUrl.value;
          print("Vendor image string: $vendorImage"); // Debug print

          final vendorName = detailsCtrl.restaurantName.value;
          final servingTime = detailsCtrl.servingTime.value;
          // For now, using a fixed rating.
          const ratingFixed = 4.3;
          final allDishes = detailsCtrl.dishes;
          if (allDishes.isEmpty) {
            return Center(
              child: Text(
                'No dishes available.',
                style: GoogleFonts.workSans(),
              ),
            );
          }

          // Filter dishes based on selected chip.
          final filteredDishes = allDishes.where((dish) {
            final filter = selectedFilter.value;
            if (filter.isEmpty || filter == 'All') return true;
            if (filter == 'Veg') return (dish['nonveg'] == 0);
            if (filter == 'NonVeg') return (dish['nonveg'] == 1);
            if (filter == 'Lunch')
              return (dish['mealType']?.toLowerCase() == 'lunch');
            if (filter == 'Dinner')
              return (dish['mealType']?.toLowerCase() == 'dinner');
            return true;
          }).toList();

          // Group dishes by meal type if no specific filter is selected.
          bool showGrouped =
              (selectedFilter.value.isEmpty || selectedFilter.value == 'All');
          List<dynamic> lunchDishes = [];
          List<dynamic> dinnerDishes = [];
          if (showGrouped) {
            lunchDishes = filteredDishes
                .where((dish) => (dish['mealType']?.toLowerCase() == 'lunch'))
                .toList();
            dinnerDishes = filteredDishes
                .where((dish) => (dish['mealType']?.toLowerCase() == 'dinner'))
                .toList();
          }

          return CustomScrollView(
            slivers: [
              // ----------------------------
              // Custom Header Section.
              // ----------------------------
              SliverToBoxAdapter(
                child: _buildHeader(
                  vendorImage: vendorImage,
                  vendorName: vendorName,
                  description: servingTime,
                  rating: ratingFixed,
                ),
              ),
              // ----------------------------
              // Filter Chips Section.
              // ----------------------------
              SliverToBoxAdapter(
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: chipLabels.length,
                    itemBuilder: (context, index) {
                      final label = chipLabels[index];
                      final isSelected = (selectedFilter.value == label);
                      return Padding(
                        padding: const EdgeInsets.only(left: 16, right: 8),
                        child: RawChip(
                          label: Text(
                            label,
                            style: GoogleFonts.workSans(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          avatar: Icon(
                            label == 'Lunch'
                                ? Icons.lunch_dining
                                : label == 'Dinner'
                                    ? Icons.dinner_dining
                                    : label == 'Veg'
                                        ? Icons.eco
                                        : label == 'NonVeg'
                                            ? Icons.no_food
                                            : Icons.all_inclusive,
                            color: isSelected ? Colors.white : Colors.black54,
                            size: 20,
                          ),
                          selected: isSelected,
                          selectedColor: kPrimaryColor,
                          backgroundColor: Colors.grey.shade200,
                          onSelected: (bool selected) {
                            selectedFilter.value = selected ? label : '';
                          },
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // ----------------------------
              // Serving Times Section.
              // ----------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Lunch serves between 12 PM to 2PM',
                        style: GoogleFonts.workSans(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dinner serves between 8PM to 10PM',
                        style: GoogleFonts.workSans(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ----------------------------
              // Dish List Section.
              // ----------------------------
              if (showGrouped) ...[
                if (lunchDishes.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Text(
                        'Lunch',
                        style: GoogleFonts.workSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                if (lunchDishes.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final dish = lunchDishes[index];
                        return Column(
                          children: [
                            AnimatedDishTile(
                              delay: index * 100,
                              child: _buildDishTileFromMap(dish),
                            ),
                            const Divider(
                              height: 1,
                              color: Colors.grey,
                              indent: 16,
                              endIndent: 16,
                            ),
                          ],
                        );
                      },
                      childCount: lunchDishes.length,
                    ),
                  ),
                if (dinnerDishes.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Text(
                        'Dinner',
                        style: GoogleFonts.workSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                if (dinnerDishes.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final dish = dinnerDishes[index];
                        return Column(
                          children: [
                            AnimatedDishTile(
                              delay: index * 100,
                              child: _buildDishTileFromMap(dish),
                            ),
                            const Divider(
                              height: 1,
                              color: Colors.grey,
                              indent: 16,
                              endIndent: 16,
                            ),
                          ],
                        );
                      },
                      childCount: dinnerDishes.length,
                    ),
                  ),
              ] else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final dish = filteredDishes[index];
                      return Column(
                        children: [
                          AnimatedDishTile(
                            delay: index * 100,
                            child: _buildDishTileFromMap(dish),
                          ),
                          const Divider(
                            height: 1,
                            color: Colors.grey,
                            indent: 16,
                            endIndent: 16,
                          ),
                        ],
                      );
                    },
                    childCount: filteredDishes.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        }),
      ),
    );
  }

  /// Custom header with a split background and centered circular avatar.
  Widget _buildHeader({
    required String vendorImage,
    required String vendorName,
    required String description,
    required double rating,
  }) {
    print("Building header with vendorImage: $vendorImage"); // Debug print

    return Container(
      height: 300,
      child: Stack(
        children: [
          // Background split into two halves.
          Column(
            children: [
              // Top half with vendor image as background.
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: vendorImage.isNotEmpty
                      ? DecorationImage(
                          image: getVendorImage(vendorImage),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: vendorImage.isEmpty ? Colors.grey.shade300 : null,
                ),
              ),
              // Bottom half with white background.
              Container(
                height: 150,
                width: double.infinity,
                color: Colors.white,
              ),
            ],
          ),
          // Centered circular avatar overlapping both halves.
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade200,
                backgroundImage:
                    vendorImage.isNotEmpty ? getVendorImage(vendorImage) : null,
                child: vendorImage.isEmpty
                    ? const Icon(Icons.restaurant, size: 50)
                    : null,
              ),
            ),
          ),
          // Vendor details below the avatar.
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  vendorName,
                  style: GoogleFonts.workSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildRatingStars(rating),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------
  // Dish Tile Builder
  // ---------------------------
  Widget _buildDishTileFromMap(Map dish) {
    final String dishName = dish['name'] ?? '';
    final String dishDescription = dish['description'] ?? '';
    final String price = dish['price'] ?? '0.00';

    // Correct handling of veg/nonveg:
    bool isVeg;
    if (dish['nonveg'] is bool) {
      isVeg = dish['nonveg'] == false;
    } else if (dish['nonveg'] is int) {
      isVeg = (dish['nonveg'] == 0);
    } else {
      isVeg = true;
    }

    final String mealType = dish['mealType'] ?? 'lunch';
    // Ensure that each dish has a unique vendorDishId.
    final String vendorDishId = dish['vendorDishId'] ?? '';
    final String dishImageUrl = dish['image'] ?? '';
    final double ratingValue =
        dish['rating'] is num ? (dish['rating'] as num).toDouble() : 3.9;
    final int ratingCount =
        dish['ratingCount'] is int ? dish['ratingCount'] : 0;
    final bool isBestseller = (ratingValue >= 4.0);
    final cartCtrl = Get.find<CartController>();

    return _buildDishTile(
      vendorDishId: vendorDishId,
      dishName: dishName,
      description: dishDescription,
      price: price,
      isVeg: isVeg,
      mealType: mealType,
      dishImageUrl: dishImageUrl,
      ratingValue: ratingValue,
      ratingCount: ratingCount,
      isBestseller: isBestseller,
      onAdd: () {
        // Pass current vendor id from RestaurantDetailsController to addItemToCart.
        final detailsCtrl = Get.find<RestaurantDetailsController>();
        cartCtrl.addItemToCart(
          vendorDishId: vendorDishId,
          mealType: mealType,
          vendorId: detailsCtrl.vendorId.value,
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
  }

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
    final cartCtrl = Get.find<CartController>();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDishImage(dishImageUrl, isVeg),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dish name and veg/nonveg indicator.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        dishName,
                        style: GoogleFonts.workSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Load the asset icon for veg/non-veg.
                    Image.asset(
                      isVeg ? 'assets/icons/veg.png' : 'assets/icons/non-veg.png',
                      width: 16,
                      height: 16,
                      errorBuilder: (_, __, ___) => Icon(
                        isVeg ? Icons.eco : Icons.no_food,
                        size: 16,
                        color: isVeg ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Rating stars.
                Row(
                  children: _buildRatingStars(ratingValue),
                ),
                const SizedBox(height: 6),
                _buildTruncatedDescription(description),
                const SizedBox(height: 6),
                // Price and ADD/Stepper controls.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹$price',
                      style: GoogleFonts.workSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: Obx(() {
                          final int quantity =
                              cartCtrl.getDishQuantity(vendorDishId);
                          if (quantity == 0) {
                            return SizedBox(
                              key: const ValueKey(0),
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
                                child: Text(
                                  'ADD',
                                  style: GoogleFonts.workSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Row(
                              key: ValueKey(quantity),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _stepperButton(
                                  iconData: Icons.remove,
                                  onTap: onDecrement,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    quantity.toString(),
                                    style: GoogleFonts.workSans(fontSize: 16),
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
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishImage(String? dishImageUrl, bool isVeg) {
    final borderRadius = BorderRadius.circular(12);
    if (dishImageUrl == null || dishImageUrl.isEmpty) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: borderRadius,
        ),
        child: Icon(
          Icons.fastfood,
          size: 50,
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
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 100,
              height: 100,
              color: Colors.grey.shade300,
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        );
      } catch (e) {
        return Container(
          width: 100,
          height: 100,
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
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 100,
            height: 100,
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

  List<Widget> _buildRatingStars(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
    List<Widget> stars = [];
    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, color: Colors.orange, size: 16));
    }
    if (hasHalfStar) {
      stars.add(const Icon(Icons.star_half, color: Colors.orange, size: 16));
    }
    for (int i = 0; i < emptyStars; i++) {
      stars.add(const Icon(Icons.star_border, color: Colors.orange, size: 16));
    }
    return stars;
  }

  Widget _buildTruncatedDescription(String description) {
    const maxChars = 50;
    if (description.length <= maxChars) {
      return Text(
        description,
        style: GoogleFonts.workSans(
          fontSize: 13,
          color: Colors.grey.shade800,
        ),
      );
    } else {
      final truncated = description.substring(0, maxChars).trim();
      return RichText(
        text: TextSpan(
          text: '$truncated... ',
          style: GoogleFonts.workSans(
            fontSize: 13,
            color: Colors.grey.shade800,
          ),
          children: [
            TextSpan(
              text: 'more',
              style: GoogleFonts.workSans(
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
}

/// A wrapper widget that applies a bounce/elastic scale animation when its child appears.
class BouncyPage extends StatefulWidget {
  final Widget child;
  const BouncyPage({Key? key, required this.child}) : super(key: key);

  @override
  _BouncyPageState createState() => _BouncyPageState();
}

class _BouncyPageState extends State<BouncyPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

/// A widget that animates its child by fading and sliding it in with a delay.
class AnimatedDishTile extends StatefulWidget {
  final Widget child;
  final int delay; // Delay in milliseconds
  const AnimatedDishTile({Key? key, required this.child, this.delay = 0})
      : super(key: key);

  @override
  _AnimatedDishTileState createState() => _AnimatedDishTileState();
}

class _AnimatedDishTileState extends State<AnimatedDishTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _offsetAnimation = Tween<Offset>(
            begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Start the animation after a delay.
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _offsetAnimation,
        child: widget.child,
      ),
    );
  }
}
