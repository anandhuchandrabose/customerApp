import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/home_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/location_controller.dart';
import 'cart_view.dart';
import 'dart:ui';

class HomeView extends GetView<HomeController> {
  // ignore: use_super_parameters
  const HomeView({Key? key}) : super(key: key);

  static const Color kPrimaryColor = Color(0xFFFF3008);

  @override
  Widget build(BuildContext context) {
    final homeCtrl = Get.find<HomeController>();
    final cartCtrl = Get.find<CartController>();
    final locationCtrl = Get.find<LocationController>();

    final placeholderOptions = [
      'Search for bakery...',
      'Discover sweets...',
      'Find breakfast...',
      'Craving lunch?',
      'Dinner ideas...',
      'Snack time?',
      'Explore now!',
    ];
    final randomPlaceholder =
        placeholderOptions[Random().nextInt(placeholderOptions.length)];

    final adList = [
      {
        'image': '',
        'title': 'Special Offer!',
        'description': 'Up to 50% off your first order – limited time!',
      },
      {
        'image': '',
        'title': 'New Deals!',
        'description': 'Fresh deals on your favorites await.',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Obx(() {
        if (homeCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
        }
        if (homeCtrl.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              'Error: ${homeCtrl.errorMessage.value}',
              style: GoogleFonts.workSans(
                color: Colors.redAccent,
                fontSize: 16,
                fontWeight: FontWeight.w500,
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
              // ===== Updated SliverAppBar to show Kazhakootam with truncated address =====
              SliverAppBar(
                pinned: true,
                floating: false,
                expandedHeight: 140,
                backgroundColor: kPrimaryColor,
                automaticallyImplyLeading: false, // Removes the back arrow
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.9)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    // Navigate to AddressInputView
                                    Get.toNamed('/address-input');
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_pin, color: Colors.white, size: 20),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Kazhakootam', // Always show Kazhakootam
                                            style: GoogleFonts.workSans(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Obx(() {
                                            final address = locationCtrl.selectedAddress.value;
                                            final truncatedAddress = address.isNotEmpty
                                                ? (address.length > 25
                                                    ? '${address.substring(0, 25)}...'
                                                    : address)
                                                : 'Select a location';
                                            return Text(
                                              truncatedAddress,
                                              style: GoogleFonts.workSans(
                                                color: Colors.white70,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            );
                                          }),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 28),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSearchBar(randomPlaceholder),
                          ],
                        ),
                      ),
                    ),
                  ),
                  title: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Fresmo',
                      style: GoogleFonts.workSans(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  centerTitle: true,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categories',
                        style: GoogleFonts.workSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      categories.isEmpty
                          ? _buildEmptyState('No categories available.')
                          : SizedBox(
                              height: 100,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: categories.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 12),
                                itemBuilder: (_, index) {
                                  final cat = categories[index];
                                  final catName = cat['name'] ?? 'Unnamed';
                                  final catImage = cat['image'] ?? '';
                                  return GestureDetector(
                                    onTap: () => Get.toNamed('/category-vendors', arguments: catName),
                                    child: _buildCategoryCard(catName, catImage),
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: adList.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, index) => _buildAdCard(context, adList[index]),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nearby Kitchens',
                        style: GoogleFonts.workSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      vendors.isEmpty
                          ? _buildEmptyState('No kitchens nearby.')
                          : Column(
                              children: vendors.map((vendor) {
                                final vendorId = vendor['id'] ?? '';
                                final name = vendor['kitchenName'] ?? 'Unnamed';
                                final imageUrl = vendor['profile']?['profileImage'] ?? '';
                                final rating = vendor['rating']?.toString() ?? '4.5';
                                final isVeg = vendor['isVeg'] ?? false;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildKitchenCard(name, imageUrl, rating, isVeg, vendorId),
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
      bottomNavigationBar: Obx(() {
        final int itemCount = cartCtrl.totalItemCount;
        if (itemCount == 0) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => Get.to(() => const CartView()),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              elevation: 5,
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$itemCount',
                    style: GoogleFonts.workSans(
                      color: kPrimaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
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
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: GoogleFonts.workSans(color: Colors.grey[600], fontSize: 16),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: GoogleFonts.workSans(color: Colors.grey[600], fontSize: 14),
      ),
    );
  }

  Widget _buildCategoryCard(String catName, String base64Image) {
    Uint8List? catImageBytes;
    try {
      if (base64Image.contains(',')) base64Image = base64Image.split(',').last;
      catImageBytes = base64Decode(base64Image);
    } catch (_) {
      catImageBytes = null;
    }

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8)],
          ),
          child: ClipOval(
            child: catImageBytes != null
                ? Image.memory(catImageBytes, fit: BoxFit.cover)
                : Icon(Icons.fastfood, color: Colors.grey[400], size: 30),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 70,
          child: Text(
            catName,
            style: GoogleFonts.workSans(fontSize: 13, color: Colors.black87),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAdCard(BuildContext context, Map<String, dynamic> ad) {
    final String imageUrl = ad['image'] as String;
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            imageUrl.isNotEmpty
                ? Image.asset(imageUrl, fit: BoxFit.cover, width: double.infinity, height: 160)
                : Container(color: Colors.grey[200], height: 160),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad['title'] ?? '',
                      style: GoogleFonts.workSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ad['description'] ?? '',
                      style: GoogleFonts.workSans(color: Colors.white70, fontSize: 12),
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

  Widget _buildKitchenCard(String name, String base64Image, String rating, bool isVeg, String vendorId) {
    Uint8List? vendorImageBytes;
    try {
      if (base64Image.contains(',')) base64Image = base64Image.split(',').last;
      vendorImageBytes = base64Decode(base64Image);
    } catch (_) {
      vendorImageBytes = null;
    }

    return GestureDetector(
      onTap: () => Get.toNamed('/restaurant-details', arguments: {
        'vendorId': vendorId,
        'kitchenName': name,
        'imageUrl': base64Image,
        'rating': rating,
        'isVeg': isVeg,
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: vendorImageBytes != null
                    ? Image.memory(
                        vendorImageBytes,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.store, color: Colors.grey[400], size: 50),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.store, color: Colors.grey[400], size: 50),
                      ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            name,
                            style: GoogleFonts.workSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                rating,
                                style: GoogleFonts.workSans(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isVeg ? Icons.eco : Icons.local_dining,
                            color: isVeg ? Colors.green : Colors.red,
                            size: 18,
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
      ),
    );
  }
}

class NoScrollGlow extends ScrollBehavior {
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}