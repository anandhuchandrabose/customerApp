import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/home_controller.dart';
import '../controllers/cart_controller.dart';
// Import the location controller
import '../controllers/location_controller.dart';
import 'cart_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  static const Color kPrimaryColor = Color(0xFFFF3008);

  @override
  Widget build(BuildContext context) {
    final homeCtrl = Get.find<HomeController>();
    final cartCtrl = Get.find<CartController>();
    // Get the LocationController instance.
    final locationCtrl = Get.find<LocationController>();

    final placeholderOptions = [
      'Search for bakery...',
      'Discover sweets...',
      'Find breakfast options...',
      'Looking for lunch?',
      'Dinner ideas...',
      'Craving a snack...',
      'Hungry? Search here!',
    ];
    final randomPlaceholder =
        placeholderOptions[Random().nextInt(placeholderOptions.length)];

    // Dummy advertisement list for demonstration.
    final adList = [
      {
        'image': '/ads.png',
        'title': 'Special Offer!',
        'description':
            'Get up to 50% off on your first order. Hurry up, limited time offer!',
      },
      {
        'image': '',
        'title': 'New Deals!',
        'description': 'Check out our latest deals on your favorite items.',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (homeCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (homeCtrl.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              'Error: ${homeCtrl.errorMessage.value}',
              style: GoogleFonts.workSans(
                color: Colors.red,
                fontSize: 16,
              ),
            ),
          );
        }

        final vendors = homeCtrl.vendors;
        final categories = homeCtrl.categories;

        return ScrollConfiguration(
          behavior: NoScrollGlow(),
          child: CustomScrollView(
            slivers: [
              // ===== SliverAppBar with location & search =====
              SliverAppBar(
                pinned: true,
                expandedHeight: 150,
                backgroundColor: kPrimaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          kPrimaryColor,
                          Color.fromARGB(255, 240, 99, 71),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 36,
                          left: 16,
                          right: 16,
                        ),
                        child: Align(
                          alignment: Alignment.topCenter,
                         child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Row(
      children: [
        const Icon(
          Icons.location_pin,
          color: Colors.white,
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            // Navigate to the Location Picker screen (if you have one).
            Get.toNamed('/location-picker');
          },
          child: Obx(() {
            final address = locationCtrl.selectedAddress.value;
            // If the address is more than 10 characters, truncate it.
            final displayAddress = address.length > 10 ? address.substring(0, 25) + '...' : address;
            return Expanded(
              child: Text(
                displayAddress.isEmpty ? 'Select Location' : displayAddress,
                style: GoogleFonts.workSans(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
        ),
      ],
    ),
    IconButton(
      icon: const Icon(
        Icons.account_circle,
        color: Colors.white,
      ),
      onPressed: () {
        // Implement user profile or similar action
      },
    ),
  ],
),
                        ),
                      ),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(50),
                      child: TextField(
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: randomPlaceholder,
                          hintStyle: GoogleFonts.workSans(
                            color: Colors.grey,
                          ),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            Get.toNamed('/search-results',
                                arguments: {'searchKey': value.trim()});
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // ===== Categories Section =====
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categories',
                        style: GoogleFonts.workSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (categories.isEmpty)
                        Text(
                          'No categories found.',
                          style: GoogleFonts.workSans(),
                        )
                      else
                        SizedBox(
                          height: 90,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final cat = categories[index];
                              final catName = cat['name'] ?? 'No Name';
                              final catImage = cat['image'] ?? '';

                              return GestureDetector(
                                onTap: () {
                                  // Navigate to the new screen that lists vendors for this category.
                                  Get.toNamed(
                                    '/category-vendors',
                                    arguments: catName,
                                  );
                                },
                                child: _buildCategoryCard(catName, catImage),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ===== Advertisement / Offers Cards =====
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(right: 16),
                      itemCount: adList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final ad = adList[index];
                        return _buildAdCard(context, ad);
                      },
                    ),
                  ),
                ),
              ),

              // ===== Vendors Section =====
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nearby Kitchens',
                        style: GoogleFonts.workSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (vendors.isEmpty)
                        Center(
                          child: Text(
                            'No vendors found.',
                            style: GoogleFonts.workSans(),
                          ),
                        )
                      else
                        Column(
                          children: vendors.map((vendor) {
                            final vendorId = vendor['id'] ?? '';
                            final name = vendor['kitchenName'] ?? 'No Name';
                            final imageUrl =
                                vendor['profile']?['profileImage'] ?? '';
                            final rating =
                                vendor['rating']?.toString() ?? '4.5';
                            final isVeg = vendor['isVeg'] ?? false;

                            return _buildKitchenCard(
                              name,
                              imageUrl,
                              rating,
                              isVeg,
                              vendorId,
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
      // ===== Bottom Nav: View Cart popup if items in cart =====
      bottomNavigationBar: Obx(() {
        final int itemCount = cartCtrl.totalItemCount;
        if (itemCount == 0) return const SizedBox.shrink();
        return InkWell(
          onTap: () {
            // Navigates to the CartView
            Get.to(() => const CartView());
          },
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.shopping_cart, color: Colors.white, size: 24),
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
        );
      }),
    );
  }

  // ---------------------------
  // Category Card Widget
  // ---------------------------
  Widget _buildCategoryCard(String catName, String base64Image) {
    Uint8List? catImageBytes;
    try {
      if (base64Image.contains(',')) {
        base64Image = base64Image.split(',').last;
      }
      catImageBytes = base64Decode(base64Image);
    } catch (_) {
      catImageBytes = null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circle image (or icon placeholder)
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 60,
              height: 60,
              color: Colors.grey[200],
              child: catImageBytes != null
                  ? Image.memory(catImageBytes, fit: BoxFit.cover)
                  : const Icon(Icons.fastfood, size: 30, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 70),
            child: Text(
              catName,
              style: GoogleFonts.workSans(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------
  // Ad / Offers Card
  // ---------------------------
  Widget _buildAdCard(BuildContext context, Map<String, dynamic> ad) {
    final String imageUrl = ad['image'] as String;
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 180,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: imageUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.local_offer,
                        color: Colors.grey,
                        size: 40,
                      ),
                    );
                  },
                ),
              )
            : Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.local_offer,
                  color: Colors.grey,
                  size: 40,
                ),
              ),
      ),
    );
  }

  // ---------------------------
  // Kitchen Card (Vendor)
  // ---------------------------
  Widget _buildKitchenCard(
    String name,
    String base64Image,
    String rating,
    bool isVeg,
    String vendorId,
  ) {
    Uint8List? vendorImageBytes;
    try {
      if (base64Image.contains(',')) {
        base64Image = base64Image.split(',').last;
      }
      vendorImageBytes = base64Decode(base64Image);
    } catch (_) {
      vendorImageBytes = null;
    }

    return GestureDetector(
      onTap: () {
        // Navigate to vendor/restaurant details page
        Get.toNamed(
          '/restaurant-details',
          arguments: {
            'vendorId': vendorId,
            'kitchenName': name,
            'imageUrl': base64Image,
            'rating': rating,
            'isVeg': isVeg,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: vendorImageBytes != null
                    ? Image.memory(
                        vendorImageBytes,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, error, stack) => Container(
                          color: Colors.grey.shade300,
                          child: const Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade300,
                        child: const Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            // Bottom info row
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Kitchen name
                  Expanded(
                    child: Text(
                      name,
                      style: GoogleFonts.workSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Rating + Veg/NonVeg
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: GoogleFonts.workSans(fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Image.asset(
                        isVeg
                            ? 'assets/icons/veg.png'
                            : 'assets/icons/non-veg.png',
                        height: 18,
                        width: 18,
                        errorBuilder: (_, __, ___) => Icon(
                          isVeg ? Icons.eco : Icons.no_food,
                          size: 18,
                          color: isVeg ? Colors.green : Colors.red,
                        ),
                      )
                    ],
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

// Custom ScrollBehavior to remove overscroll glow
class NoScrollGlow extends ScrollBehavior {
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}