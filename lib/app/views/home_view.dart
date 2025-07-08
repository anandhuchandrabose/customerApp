import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/home_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/location_controller.dart';
import 'cart_view.dart';
import 'dart:ui';
import 'design_system/typography.dart';
import 'design_system/spacing.dart';
import 'design_system/icons.dart';
import 'design_system/colors.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeCtrl = Get.find<HomeController>();
    final cartCtrl = Get.find<CartController>();
    final locationCtrl = Get.find<LocationController>();

    final placeholderOptions = [
      'Search for Pizza...',
      'Discover Burgers...',
      'Find Shawarma...',
      'Craving Sandwiches?',
      'Explore Parotta...',
      'Snack time?',
      'Explore now!',
    ];
    final randomPlaceholder =
        placeholderOptions[Random().nextInt(placeholderOptions.length)];

    // Simulate API response for ad cards
    final adList = [
      {
        'image': 'img/card.jpg',
        'title': 'Special Offer!',
        'description': 'Up to 50% off your first order – limited time!',
        'isNew': true,
      },
      {
        'image': '',
        'title': 'New Deals!',
        'description': 'Fresh deals on your favorites await.',
        'isNew': false,
      },
      {
        'image': '',
        'title': 'Weekend Special!',
        'description': 'Get 20% off on all orders this weekend.',
        'isNew': true,
      },
      {
        'image': '',
        'title': 'Free Delivery!',
        'description': 'Order now and get free delivery on your first order.',
        'isNew': false,
      },
    ];

    final ScrollController scrollController = ScrollController();

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: () async {
            await homeCtrl.fetchHomeData();
          },
          color: AppColors.primary,
          child: ScrollConfiguration(
            behavior: NoScrollGlow(),
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                // Modern App Bar
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  expandedHeight: 160,
                  backgroundColor: AppColors.backgroundPrimary,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: SafeArea(
                      child: Padding(
                        padding: AppSpacing.paddingL,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Get.toNamed('/address-input');
                                  },
                                  child: Row(
                                    children: [
                                      AppIcons.homeIcon(
                                          color: AppColors.primary, size: 30),
                                      AppSpacing.gapS,
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Home',
                                            style: AppTypography.heading2
                                                .copyWith(
                                                    color: AppColors
                                                        .textHighestEmphasis),
                                          ),
                                          Obx(() {
                                            final flatHouseNo = locationCtrl.addresses
    .firstWhereOrNull((addr) => addr['isSelected'] == true)?['flatHouseNo'] ?? '';
return Text(
  flatHouseNo.isNotEmpty ? flatHouseNo : 'Select a location',
  style: AppTypography.bodySmall.copyWith(color: AppColors.textMedEmphasis),
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
);
                                          }),
                                        ],
                                      ),
                                      AppSpacing.gapS,
                                      // Icon(Icons.keyboard_arrow_down,
                                      //     color: AppColors.textMedEmphasis),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: AppIcons.profileIcon(),
                                  iconSize: 36,
                                  padding: const EdgeInsets.all(12),
                                  onPressed: () {
                                    Get.toNamed('/profile');
                                  },
                                ),
                              ],
                            ),
                            AppSpacing.gapL,
                            _buildSearchBar(randomPlaceholder),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Categories Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: AppSpacing.paddingL,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "What's on your mind?",
                          style: AppTypography.heading3.copyWith(
                              color: AppColors.textHighestEmphasis),
                        ),
                        AppSpacing.gapM,
                        homeCtrl.isLoading.value
                            ? _buildCategorySkeleton()
                            : homeCtrl.categories.isEmpty
                                ? _buildEmptyState('No categories available.')
                                : SizedBox(
                                    height: 100,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: homeCtrl.categories.length,
                                      separatorBuilder: (_, __) =>
                                          AppSpacing.gapM,
                                      itemBuilder: (_, index) {
                                        final cat = homeCtrl.categories[index];
                                        final catName = cat['name'] ?? 'Unnamed';
                                        final catImage = cat['image'] ?? '';
                                        return _buildCategoryCard(
                                            catName, catImage, index);
                                      },
                                    ),
                                  ),
                      ],
                    ),
                  ),
                ),
                // Ads Section with Auto-Scrolling
                SliverToBoxAdapter(
                  child: Padding(
                    padding: AppSpacing.paddingHorizontalL,
                    child: SizedBox(
                      height: 180,
                      child: _buildAdCarousel(context, adList),
                    ),
                  ),
                ),
                // Nearby Kitchens Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: AppSpacing.paddingL,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Nearby Kitchens',
                              style: AppTypography.heading3.copyWith(
                                  color: AppColors.textHighestEmphasis),
                            ),
                            // Row(
                            //   children: [
                            //     IconButton(
                            //       icon: const Icon(Icons.filter_list),
                            //       onPressed: () {
                            //         // Add filter functionality
                            //       },
                            //     ),
                            //     IconButton(
                            //       icon: const Icon(Icons.sort),
                            //       onPressed: () {
                            //         // Add sort functionality
                            //       },
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                        AppSpacing.gapM,
                        homeCtrl.isLoading.value
                            ? _buildKitchenSkeleton()
                            : homeCtrl.vendors.isEmpty
                                ? _buildEmptyState('No kitchens nearby.')
                                : Column(
                                    children: homeCtrl.vendors
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      final index = entry.key;
                                      final vendor = entry.value;
                                      final vendorId = vendor['id'] ?? '';
                                      final name =
                                          vendor['kitchenName'] ?? 'Unnamed';
                                      final imageUrl =
                                          vendor['profile']?['profileImage'] ??
                                              '';
                                      final rating =
                                          vendor['rating']?.toString() ?? '4.5';
                                      final isVeg = vendor['isVeg'] ?? false;
                                      final isFeatured = index % 2 == 0;
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: _buildKitchenCard(
                                            name, imageUrl, rating, isVeg, vendorId, index, isFeatured),
                                      );
                                    }).toList(),
                                  ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final int itemCount = cartCtrl.totalItemCount;
        if (itemCount == 0) return const SizedBox.shrink();
        return Padding(
          padding: AppSpacing.paddingL,
          child: ElevatedButton(
            onPressed: () => Get.to(() => const CartView()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              elevation: 5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppIcons.cartIcon(color: AppColors.backgroundPrimary),
                Text(
                  'View Cart',
                  style: AppTypography.labelLarge
                      .copyWith(color: AppColors.backgroundPrimary),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$itemCount',
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSearchBar(String placeholder) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.backgroundPrimary,
          width: 1.5,
        ),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMedEmphasis),
          prefixIcon: AppIcons.searchIcon(),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            // children: [
            //   IconButton(
            //     icon: const Icon(Icons.mic),
            //     onPressed: () {
            //       // Add voice search functionality
            //     },
            //   ),
            //   Padding(
            //     padding: const EdgeInsets.only(right: 8),
            //     child: Container(
            //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            //       decoration: BoxDecoration(
            //         color: AppColors.positive.withOpacity(0.1),
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //       child: Row(
            //         children: [
            //           AppIcons.vegIcon(size: 16),
            //           AppSpacing.gapXS,
            //           Text(
            //             'VEG',
            //             style: AppTypography.labelSmall.copyWith(color: AppColors.positive),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ],
          ),
          filled: true,
          fillColor: AppColors.backgroundSecondary,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            Get.toNamed('/search-results', arguments: {'searchKey': value.trim()});
          }
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: AppSpacing.paddingL,
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.textLowEmphasis.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message,
        style: AppTypography.bodyMedium
            .copyWith(color: AppColors.textMedEmphasis),
      ),
    );
  }

  Widget _buildCategorySkeleton() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (_, __) => AppSpacing.gapM,
        itemBuilder: (_, __) {
          return Shimmer.fromColors(
            baseColor: AppColors.textLowEmphasis,
            highlightColor: AppColors.backgroundPrimary,
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                AppSpacing.gapS,
                Container(
                  width: 50,
                  height: 10,
                  color: Colors.white,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(String catName, String base64Image, int index) {
    Uint8List? catImageBytes;
    try {
      if (base64Image.contains(',')) base64Image = base64Image.split(',').last;
      catImageBytes = base64Decode(base64Image);
    } catch (_) {
      catImageBytes = null;
    }

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + (index * 100)),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => Get.toNamed('/category-vendors', arguments: catName),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.backgroundPrimary,
                boxShadow: [],
              ),
              child: ClipOval(
                child: catImageBytes != null
                    ? Image.memory(catImageBytes, fit: BoxFit.cover)
                    : Icon(Icons.fastfood,
                        color: AppColors.textMedEmphasis, size: 30),
              ),
            ),
            AppSpacing.gapS,
            SizedBox(
              width: 70,
              child: Text(
                catName,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textHighEmphasis),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdCarousel(BuildContext context, List<Map<String, dynamic>> adList) {
    final PageController pageController = PageController(viewportFraction: 0.85);
    Timer? timer;

    void startAutoScroll() {
      timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
        if (pageController.hasClients) {
          int nextPage = (pageController.page?.round() ?? 1) + 1;
          if (nextPage >= adList.length) {
            nextPage = 0;
          }
          pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      startAutoScroll();
    });

    void dispose() {
      timer?.cancel();
      pageController.dispose();
    }

    return PageView.builder(
      controller: pageController,
      itemCount: adList.length,
      itemBuilder: (context, index) {
        return _buildAdCard(context, adList[index], index);
      },
      onPageChanged: (index) {},
    );
  }

 Widget _buildAdCard(BuildContext context, Map<String, dynamic> ad, int index) {
  final String imageUrl = ad['image'] as String;
  final bool isNew = ad['isNew'] as bool;

  // Remove leading '/' from imageUrl to match asset path
  final String assetPath = imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;

  return TweenAnimationBuilder(
    tween: Tween<double>(begin: 0, end: 1),
    duration: Duration(milliseconds: 500 + (index * 100)),
    builder: (context, double value, child) {
      return Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset((1 - value) * 20, 0),
          child: child,
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.2),
            AppColors.primarySub.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.backgroundPrimary.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textLowEmphasis.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: assetPath.isNotEmpty
                ? Image.asset(
                    'assets/$assetPath', // Load image from assets
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black.withOpacity(0.3),
                    colorBlendMode: BlendMode.darken,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if the image fails to load
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.textLowEmphasis,
                              AppColors.textMedEmphasis,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.local_offer,
                            color: AppColors.backgroundPrimary.withOpacity(0.7),
                            size: 50,
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.textLowEmphasis,
                          AppColors.textMedEmphasis,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.local_offer,
                        color: AppColors.backgroundPrimary.withOpacity(0.7),
                        size: 50,
                      ),
                    ),
                  ),
          ),
          if (isNew)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'New',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.backgroundPrimary,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: AppSpacing.paddingM,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ad['title'] ?? '',
                    style: AppTypography.heading3.copyWith(
                      color: AppColors.backgroundPrimary,
                      shadows: [
                        Shadow(
                          color: AppColors.textHighestEmphasis.withOpacity(0.5),
                          offset: const Offset(1, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.gapXS,
                  Text(
                    ad['description'] ?? '',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.backgroundPrimary.withOpacity(0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildKitchenSkeleton() {
    return Column(
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: AppColors.textLowEmphasis,
            highlightColor: AppColors.backgroundPrimary,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.backgroundPrimary,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKitchenCard(String name, String base64Image, String rating,
      bool isVeg, String vendorId, int index, bool isFeatured) {
    Uint8List? vendorImageBytes;
    try {
      if (base64Image.contains(',')) base64Image = base64Image.split(',').last;
      vendorImageBytes = base64Decode(base64Image);
    } catch (_) {
      vendorImageBytes = null;
    }

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + (index * 100)),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => Get.toNamed('/restaurant-details', arguments: {
          'vendorId': vendorId,
          'kitchenName': name,
          'imageUrl': base64Image,
          'rating': rating,
          'isVeg': isVeg,
        }),
        child: Column(
          children: [
            // Main Card (Image and Overlay)
            Container(
              height: 180, // Reduced height to make space for the footer
              decoration: BoxDecoration(
                color: AppColors.backgroundPrimary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.textLowEmphasis.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textLowEmphasis.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: vendorImageBytes != null
                          ? Image.memory(
                              vendorImageBytes,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.textLowEmphasis,
                                child: Icon(
                                  Icons.store,
                                  color: AppColors.textMedEmphasis,
                                  size: 50,
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.textLowEmphasis,
                              child: Icon(
                                Icons.store,
                                color: AppColors.textMedEmphasis,
                                size: 50,
                              ),
                            ),
                    ),
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.textHighestEmphasis.withOpacity(0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Featured Badge
                  if (isFeatured)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Featured',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.backgroundPrimary,
                          ),
                        ),
                      ),
                    ),
                  // Favorite Icon
                  // Positioned(
                  //   top: 12,
                  //   right: 12,
                  //   child: Container(
                  //     padding: const EdgeInsets.all(8),
                  //     decoration: BoxDecoration(
                  //       color: AppColors.backgroundPrimary.withOpacity(0.9),
                  //       shape: BoxShape.circle,
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: AppColors.textLowEmphasis.withOpacity(0.2),
                  //           blurRadius: 4,
                  //           offset: const Offset(0, 2),
                  //         ),
                  //       ],
                  //     ),
                  //     child: AppIcons.favoriteIcon(
                  //       color: AppColors.primary,
                  //       size: 20,
                  //     ),
                  //   ),
                  // ),
                  // Veg/Non-Veg Indicator
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundPrimary.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.textLowEmphasis.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isVeg
                          ? AppIcons.vegIcon(size: 20)
                          : AppIcons.nonVegIcon(size: 20),
                    ),
                  ),
                ],
              ),
            ),
            // White Background Extension (Footer)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.backgroundPrimary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(
                  color: AppColors.textLowEmphasis.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textLowEmphasis.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Restaurant Name (Left)
                  Expanded(
                    child: Text(
                      name,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textHighestEmphasis,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Rating (Right)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star,
                          color: AppColors.warning,
                          size: 16,
                        ),
                        AppSpacing.gapXS,
                        Text(
                          rating,
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.textHighestEmphasis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoScrollGlow extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}