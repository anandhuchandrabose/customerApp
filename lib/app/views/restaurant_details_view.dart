import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart'; // Import shimmer package
import '../controllers/restaurant_details_controller.dart';
import '../controllers/cart_controller.dart';
import 'cart_view.dart';
import 'design_system/typography.dart'; // Import AppTypography
import 'design_system/spacing.dart'; // Import AppSpacing
import 'design_system/icons.dart'; // Import AppIcons
import 'design_system/colors.dart'; // Import AppColors

/// Helper function to obtain an ImageProvider from a vendor image string.
ImageProvider getVendorImage(String imageString) {
  if (imageString.isEmpty) {
    return const AssetImage('assets/placeholder.png');
  } else if (imageString.startsWith('http')) {
    return NetworkImage(imageString);
  } else {
    try {
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
const String baseUrl = 'https://api.fresmo.in/';

class RestaurantDetailsView extends GetView<RestaurantDetailsController> {
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
    

    Future<void> _onRefresh() async {
      await detailsCtrl.fetchRestaurantAndDishes(); // Assuming this method exists in the controller
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary, // Use AppColors
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textHighestEmphasis), // Use AppColors
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Restaurant Details',
          style: AppTypography.heading3.copyWith(
            color: AppColors.textHighestEmphasis, // Use AppTypography and AppColors
          ),
        ),
        centerTitle: false,
      ),
      bottomNavigationBar: Obx(() {
        final int itemCount = cartCtrl.totalItemCount;
        if (itemCount == 0) return const SizedBox.shrink();
        return Padding(
          padding: AppSpacing.paddingL, // Use AppSpacing
          child: ElevatedButton(
            onPressed: () => Get.to(() => const CartView()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, // Use AppColors
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              elevation: 5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppIcons.cartIcon(color: AppColors.backgroundPrimary), // Use AppIcons
                Text(
                  'View Cart',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.backgroundPrimary, // Use AppTypography and AppColors
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$itemCount',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary, // Use AppTypography and AppColors
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      body: BouncyPage(
        child: Obx(() {
          if (detailsCtrl.isLoading.value) {
            return _buildSkeletonLoader(context); // Show skeleton loader while loading
          }
          if (detailsCtrl.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                detailsCtrl.errorMessage.value,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.warning), // Use AppTypography and AppColors
              ),
            );
          }

          final vendorImage = detailsCtrl.restaurantImageUrl.value;
          final vendorName = detailsCtrl.restaurantName.value;
          final description = detailsCtrl.restaurantDescription.value;
          final servingTime = detailsCtrl.servingTime.value;
          const ratingFixed = 4.3;
          final allDishes = detailsCtrl.dishes;
          if (allDishes.isEmpty) {
            return Center(
              child: Text(
                'No dishes available.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textMedEmphasis, // Use AppTypography and AppColors
                ),
              ),
            );
          }

          final filteredDishes = allDishes.where((dish) {
            final filter = selectedFilter.value;
            if (filter.isEmpty || filter == 'All') return true;
            if (filter == 'Veg') return (dish['nonveg'] == 0);
            if (filter == 'NonVeg') return (dish['nonveg'] == 1);
            if (filter == 'Lunch') {
              return (dish['mealType']?.toLowerCase() == 'lunch');
            }
            if (filter == 'Dinner') {
              return (dish['mealType']?.toLowerCase() == 'dinner');
            }
            return true;
          }).toList();

          bool showGrouped = (selectedFilter.value.isEmpty || selectedFilter.value == 'All');
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

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primary, // Use AppColors
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(
                    vendorImage: vendorImage,
                    vendorName: vendorName,
                    description: description.isNotEmpty ? description : servingTime,
                    rating: ratingFixed,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    height: 60,
                    padding: AppSpacing.paddingVerticalM, // Use AppSpacing
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: chipLabels.length,
                      itemBuilder: (context, index) {
                        final label = chipLabels[index];
                        final isSelected = (selectedFilter.value == label);

                        // Map labels to emojis
                        String emoji;
                        switch (label) {
                          case 'All':
                            emoji = '🌟'; // Star for "All"
                            break;
                          case 'Lunch':
                            emoji = '🍽️'; // Plate for "Lunch"
                            break;
                          case 'Dinner':
                            emoji = '🌙'; // Moon for "Dinner"
                            break;
                          case 'Veg':
                            emoji = '🥗'; // Salad for "Veg"
                            break;
                          case 'NonVeg':
                            emoji = '🍗'; // Chicken leg for "NonVeg"
                            break;
                          default:
                            emoji = '';
                        }

                        return Padding(
                          padding: const EdgeInsets.only(left: 10, right: 5),
                          child: GestureDetector(
                            onTap: () {
                              selectedFilter.value = isSelected ? '' : label;
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24, // Adjusted padding for full text visibility
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          AppColors.primary.withOpacity(0.7),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isSelected ? null : AppColors.backgroundPrimary, // Use AppColors
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.textLowEmphasis,
                                  width: 0.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: AppColors.textLowEmphasis.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  AppSpacing.gapS, // Use AppSpacing
                                  Text(
                                    label,
                                    style: AppTypography.labelSmall.copyWith(
                                      color: isSelected ? AppColors.backgroundPrimary : AppColors.textHighEmphasis, // Use AppTypography and AppColors
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: AppSpacing.paddingHorizontalL, // Use AppSpacing
                    child: ServingTimesWidget(),
                  ),
                ),
                if (showGrouped) ...[
                  if (lunchDishes.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: AppSpacing.paddingL, // Use AppSpacing
                        child: Text(
                          'Lunch',
                          style: AppTypography.heading3.copyWith(
                            color: AppColors.textHighestEmphasis, // Use AppTypography and AppColors
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
                              // Add divider only if this is not the last item
                              if (index < lunchDishes.length - 1)
                                Divider(
                                  height: 1,
                                  color: AppColors.textLowEmphasis, // Use AppColors
                                  indent: 16,
                                  endIndent: 16,
                                ),
                            ],
                          );
                        },
                        childCount: lunchDishes.length,
                      ),
                    ),
                  // Add the big divider between Lunch and Dinner sections
                  if (lunchDishes.isNotEmpty && dinnerDishes.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Divider(
                        height: 16,
                        thickness: 18,
                        color: AppColors.backgroundSecondary,
                      ),
                    ),
                  if (dinnerDishes.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: AppSpacing.paddingL, // Use AppSpacing
                        child: Text(
                          'Dinner',
                          style: AppTypography.heading3.copyWith(
                            color: AppColors.textHighestEmphasis, // Use AppTypography and AppColors
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
                              // Add divider only if this is not the last item
                              if (index < dinnerDishes.length - 1)
                                Divider(
                                  height: 1,
                                  color: AppColors.textLowEmphasis, // Use AppColors
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
                            // Add divider only if this is not the last item
                            if (index < filteredDishes.length - 1)
                              Divider(
                                height: 1,
                                color: AppColors.textLowEmphasis, // Use AppColors
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
            ),
          );
        }),
      ),
    );
  }

  // Skeleton loader widget
  Widget _buildSkeletonLoader(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Skeleton for header
        SliverToBoxAdapter(
          child: SizedBox(
            height: 260,
            child: Stack(
              children: [
                // Background image placeholder
                Shimmer.fromColors(
                  baseColor: AppColors.backgroundSecondary.withOpacity(0.5),
                  highlightColor: AppColors.backgroundSecondary.withOpacity(0.2),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    color: AppColors.backgroundSecondary,
                  ),
                ),
                // Circle avatar placeholder
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Shimmer.fromColors(
                      baseColor: AppColors.backgroundSecondary.withOpacity(0.5),
                      highlightColor: AppColors.backgroundSecondary.withOpacity(0.2),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.backgroundSecondary,
                      ),
                    ),
                  ),
                ),
                // Vendor name, rating, and description placeholders
                Positioned(
                  top: 200,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Shimmer.fromColors(
                        baseColor: AppColors.backgroundSecondary.withValues(alpha: 128),
                        highlightColor: AppColors.backgroundSecondary.withValues(alpha: 51), // 0.2 * 255 ≈ 51
                        child: Container(
                          width: 150,
                          height: 20,
                          color: AppColors.backgroundSecondary,
                        ),
                      ),
                      AppSpacing.gapS,
                      Shimmer.fromColors(
                        baseColor: AppColors.backgroundSecondary.withValues(alpha: 128),
                        highlightColor: AppColors.backgroundSecondary.withValues(alpha: 51), // 0.2 * 255 ≈ 51
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            5,
                            (index) => const Icon(
                              Icons.star_border,
                              color: AppColors.backgroundSecondary,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.gapS,
                      Shimmer.fromColors(
                        baseColor: AppColors.backgroundSecondary.withOpacity(0.5),
                        highlightColor: AppColors.backgroundSecondary.withOpacity(0.2),
                        child: Container(
                          width: 200,
                          height: 16,
                          color: AppColors.backgroundSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Skeleton for chips
        SliverToBoxAdapter(
          child: Container(
            height: 60,
            padding: AppSpacing.paddingVerticalM,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: chipLabels.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 10, right: 5),
                  child: Shimmer.fromColors(
                    baseColor: AppColors.backgroundSecondary.withOpacity(0.5),
                    highlightColor: AppColors.backgroundSecondary.withOpacity(0.2),
                    child: Container(
                      width: 80,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Skeleton for serving times
        SliverToBoxAdapter(
          child: Padding(
            padding: AppSpacing.paddingHorizontalL,
            child: Shimmer.fromColors(
              baseColor: AppColors.backgroundSecondary.withOpacity(0.5),
              highlightColor: AppColors.backgroundSecondary.withOpacity(0.2),
              child: Container(
                padding: AppSpacing.paddingM,
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      color: AppColors.backgroundSecondary,
                    ),
                    AppSpacing.gapM,
                    Container(
                      width: 150,
                      height: 16,
                      color: AppColors.backgroundSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Skeleton for dish tiles (show 3 placeholders)
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Padding(
                padding: AppSpacing.paddingL,
                child: Shimmer.fromColors(
                  baseColor: AppColors.backgroundSecondary.withOpacity(0.5),
                  highlightColor: AppColors.backgroundSecondary.withOpacity(0.2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSecondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      AppSpacing.gapM,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 20,
                              color: AppColors.backgroundSecondary,
                            ),
                            AppSpacing.gapS,
                            Row(
                              children: List.generate(
                                5,
                                (index) => const Icon(
                                  Icons.star_border,
                                  color: AppColors.backgroundSecondary,
                                  size: 16,
                                ),
                              ),
                            ),
                            AppSpacing.gapS,
                            Container(
                              width: double.infinity,
                              height: 16,
                              color: AppColors.backgroundSecondary,
                            ),
                            AppSpacing.gapS,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 50,
                                  height: 16,
                                  color: AppColors.backgroundSecondary,
                                ),
                                Container(
                                  width: 80,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundSecondary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            childCount: 3, // Show 3 skeleton dish tiles
          ),
        ),
      ],
    );
  }

  Widget _buildHeader({
    required String vendorImage,
    required String vendorName,
    required String description,
    required double rating,
  }) {
    return SizedBox(
      height: 300, // Reduced height since we're removing the bottom half
      child: Stack(
        children: [
          // Background image (top half only)
          Container(
            height: 150, // Only the top half for the background image
            width: double.infinity,
            decoration: BoxDecoration(
              image: vendorImage.isNotEmpty
                  ? DecorationImage(
                      image: getVendorImage(vendorImage),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: vendorImage.isEmpty ? AppColors.backgroundSecondary : null, // Use AppColors
            ),
          ),
          // Circle avatar for kitchen image
          Positioned(
            top: 100, // Position the avatar so it slightly overlaps the background image
            left: 0,
            right: 0,
            child: Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.backgroundSecondary, // Use AppColors
                backgroundImage: vendorImage.isNotEmpty ? getVendorImage(vendorImage) : null,
                child: vendorImage.isEmpty
                    ? const Icon(Icons.restaurant, size: 50)
                    : null,
              ),
            ),
          ),
          // Kitchen name, rating, and description
          Positioned(
            top: 200, // Adjusted position to place it below the avatar
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  vendorName,
                  style: AppTypography.heading3.copyWith(
                    color: AppColors.textHighestEmphasis, // Use AppTypography and AppColors
                  ),
                ),
                AppSpacing.gapS, // Use AppSpacing
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildRatingStars(rating),
                ),
                AppSpacing.gapS, // Use AppSpacing
                Padding(
                  padding: AppSpacing.paddingHorizontalL, // Use AppSpacing
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMedEmphasis, // Use AppTypography and AppColors
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishTileFromMap(Map dish) {
    final String dishName = dish['name'] ?? '';
    final String dishDescription = dish['description'] ?? '';
    final String price = dish['price'] ?? '0.00';

    bool isVeg;
    if (dish['nonveg'] is bool) {
      isVeg = dish['nonveg'] == false;
    } else if (dish['nonveg'] is int) {
      isVeg = (dish['nonveg'] == 0);
    } else {
      isVeg = true;
    }

    final String mealType = dish['mealType'] ?? 'lunch';
    final String vendorDishId = dish['vendorDishId'] ?? '';
final String rawImage = dish['image'] ?? '';
final String dishImageUrl = rawImage.startsWith('http')
    ? rawImage
    : '${RestaurantDetailsController.baseUrl}$rawImage';
    final double ratingValue = dish['rating'] is num ? (dish['rating'] as num).toDouble() : 3.9;
    final int ratingCount = dish['ratingCount'] is int ? dish['ratingCount'] : 0;
    final bool isBestseller = (ratingValue >= 4.0);

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
}) {
  final cartCtrl = Get.find<CartController>();
  final detailsCtrl = Get.find<RestaurantDetailsController>();

  return Container(
    margin: AppSpacing.paddingVerticalS, // Use AppSpacing
    padding: AppSpacing.paddingM, // Use AppSpacing
    color: AppColors.backgroundPrimary, // Use AppColors
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDishImage(dishImageUrl, isVeg),
        AppSpacing.gapM, // Use AppSpacing
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      dishName,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textHighestEmphasis, // Use AppTypography and AppColors
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AppSpacing.gapS, // Use AppSpacing
                  isVeg
                      ? AppIcons.vegIcon(size: 16) // Use AppIcons
                      : AppIcons.nonVegIcon(size: 16), // Use AppIcons
                ],
              ),
              AppSpacing.gapS, // Use AppSpacing
              Row(
                children: _buildRatingStars(ratingValue),
              ),
              AppSpacing.gapS, // Use AppSpacing
              _buildTruncatedDescription(description),
              AppSpacing.gapS, // Use AppSpacing
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹$price',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textHighestEmphasis, // Use AppTypography and AppColors
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300), // Smooth transition duration
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Obx(() {
                        final int quantity = cartCtrl.getDishQuantity(vendorDishId);
                        if (quantity == 0) {
                          return SizedBox(
                            key: const ValueKey(0),
                            height: 36,
                            child: ElevatedButton(
                              onPressed: () {
                                _onAddDish(
                                  cartCtrl,
                                  vendorDishId,
                                  mealType,
                                  detailsCtrl.vendorId.value,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary, // Use AppColors
                                foregroundColor: AppColors.backgroundPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 2, // Subtle shadow for depth
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              ),
                              child: Text(
                                'ADD',
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.backgroundPrimary, // Use AppTypography and AppColors
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
                                onTap: () {
                                  cartCtrl.decreaseItemQuantity(
                                    vendorDishId: vendorDishId,
                                    mealType: mealType,
                                  );
                                },
                              ),
                              Padding(
                                padding: AppSpacing.paddingHorizontalS, // Use AppSpacing
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200), // Smooth transition for quantity
                                  child: Text(
                                    quantity.toString(),
                                    style: AppTypography.labelMedium.copyWith(
                                      color: AppColors.textHighestEmphasis, // Use AppTypography and AppColors
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              _stepperButton(
                                iconData: Icons.add,
                                onTap: () {
                                  cartCtrl.increaseItemQuantity(
                                    vendorDishId: vendorDishId,
                                    mealType: mealType,
                                  );
                                },
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

  void _onAddDish(
    CartController cartCtrl,
    String vendorDishId,
    String mealType,
    String vendorId,
  ) async {
    final result = await cartCtrl.addItemToCart(
      vendorDishId: vendorDishId,
      mealType: mealType,
      vendorId: vendorId,
    );

    if (result.containsKey('vendorMismatch') && result['vendorMismatch'] == true) {
      Get.dialog(
        PopScope(
          canPop: true,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: EdgeInsets.zero,
            backgroundColor: AppColors.backgroundPrimary,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                // Title and message
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        "Clear Cart?",
                        style: AppTypography.heading3.copyWith(
                          color: AppColors.textHighestEmphasis,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "All items in the cart must be from the same vendor. Would you like to clear the cart and add this dish?",
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textMedEmphasis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Buttons
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.textLowEmphasis.withOpacity(0.12)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Get.back(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                              ),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.textMedEmphasis,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 56,
                        color: AppColors.textLowEmphasis.withOpacity(0.12),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            Get.back();
                            try {
                              await cartCtrl.clearEntireCart();
                              await cartCtrl.fetchCartItems();
                              await cartCtrl.addItemToCart(
                                vendorDishId: vendorDishId,
                                mealType: mealType,
                                vendorId: vendorId,
                              );
                            } catch (e) {
                              Get.snackbar('Error', 'Failed to add item to cart');
                            }
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                          ),
                          child: Text(
                            "Clear & Add",
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: true,
        barrierColor: Colors.black54,
      );
    }
  }

  Widget _buildDishImage(String? dishImageUrl, bool isVeg) {
    final borderRadius = BorderRadius.circular(12);
    if (dishImageUrl == null || dishImageUrl.isEmpty) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary, // Use AppColors
          borderRadius: borderRadius,
        ),
        child: Icon(
          Icons.fastfood,
          size: 50,
          color: isVeg ? AppColors.positive : AppColors.warning, // Use AppColors
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
              color: AppColors.backgroundSecondary, // Use AppColors
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        );
      } catch (e) {
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary, // Use AppColors
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
            color: AppColors.backgroundSecondary, // Use AppColors
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
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200), // Smooth transition for color/size changes
      width: 32, // Slightly larger for better touch area
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1), // Subtle background color
        border: Border.all(
          color: AppColors.primary.withOpacity(0.5), // Softer border
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16), // Fully rounded
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: AnimatedScale(
          duration: const Duration(milliseconds: 100), // Scale animation on tap
          scale: 1.0, // Default scale
          child: Icon(
            iconData,
            size: 18, // Slightly larger icon
            color: AppColors.primary, // Use AppColors
          ),
        ),
      ),
    ),
  );
}

  List<Widget> _buildRatingStars(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
    List<Widget> stars = [];
    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, color: AppColors.warning, size: 16)); // Use AppColors
    }
    if (hasHalfStar) {
      stars.add(const Icon(Icons.star_half, color: AppColors.warning, size: 16));
    }
    for (int i = 0; i < emptyStars; i++) {
      stars.add(const Icon(Icons.star_border, color: AppColors.warning, size: 16));
    }
    return stars;
  }

  Widget _buildTruncatedDescription(String description) {
    const maxChars = 50;
    if (description.length <= maxChars) {
      return Text(
        description,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textMedEmphasis, // Use AppTypography and AppColors
        ),
      );
    } else {
      final truncated = description.substring(0, maxChars).trim();
      return RichText(
        text: TextSpan(
          text: '$truncated... ',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textMedEmphasis, // Use AppTypography and AppColors
          ),
          children: [
            TextSpan(
              text: 'more',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary, // Use AppTypography and AppColors
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      );
    }
  }
}

class ServingTimesWidget extends StatefulWidget {
  const ServingTimesWidget({Key? key}) : super(key: key);

  @override
  State<ServingTimesWidget> createState() => _ServingTimesWidgetState();
}

class _ServingTimesWidgetState extends State<ServingTimesWidget> {
  final PageController _pageController = PageController();
  final List<Map<String, dynamic>> _servingTimes = [
    {
      'title': 'Lunch',
      'time': '12 PM - 2 PM',
      'icon': Icons.lunch_dining,
    },
    {
      'title': 'Dinner',
      'time': '8 PM - 10 PM',
      'icon': Icons.dinner_dining,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Set up infinite scroll
    _pageController.addListener(() {
      if (_pageController.position.pixels == _pageController.position.maxScrollExtent) {
        _pageController.jumpTo(0);
      } else if (_pageController.position.pixels == _pageController.position.minScrollExtent) {
        _pageController.jumpTo(_pageController.position.maxScrollExtent - 1);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25, // 1/4 of original height
      child: PageView.builder(
        controller: _pageController,
        itemBuilder: (context, index) {
          final actualIndex = index % _servingTimes.length;
          final item = _servingTimes[actualIndex];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item['icon'] as IconData,
                  size: 20, // Smaller icon size
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  item['title'],
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textHighestEmphasis,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  item['time'],
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMedEmphasis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class BouncyPage extends StatefulWidget {
  final Widget child;
  const BouncyPage({Key? key, required this.child}) : super(key: key);

  @override
  _BouncyPageState createState() => _BouncyPageState();
}

class _BouncyPageState extends State<BouncyPage> with SingleTickerProviderStateMixin {
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

class AnimatedDishTile extends StatefulWidget {
  final Widget child;
  final int delay;
  const AnimatedDishTile({Key? key, required this.child, this.delay = 0})
      : super(key: key);

  @override
  _AnimatedDishTileState createState() => _AnimatedDishTileState();
}

class _AnimatedDishTileState extends State<AnimatedDishTile> with SingleTickerProviderStateMixin {
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
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

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