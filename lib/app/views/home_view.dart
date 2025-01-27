// lib/app/views/home_view.dart

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeCtrl = Get.find<HomeController>();

    final placeholderOptions = [
      'Search for bakery...',
      'Search for sweets...',
      'Search for breakfast...',
      'Search for lunch...',
      'Search for dinner...',
    ];
    final randomPlaceholder =
        placeholderOptions[Random().nextInt(placeholderOptions.length)];

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
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        }

        final vendors = homeCtrl.vendors;       // from controller
        final categories = homeCtrl.categories; // from controller

        return SingleChildScrollView(
          child: Column(
            children: [
              // =======================================
              // Banner & Search Section (unchanged)
              // =======================================
              Stack(
                children: [
                  // Banner with gradient
                  Container(
                    height: MediaQuery.of(context).size.height * 0.35,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF00BCD4), Color(0xFF00838F)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Location Selector
                  Positioned(
                    top: kToolbarHeight - 10,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_pin, color: Colors.white),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                // Trigger location selection logic
                              },
                              child: const Text(
                                'Select Location',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.account_circle,
                              color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  // Search Bar
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.23,
                    left: 16,
                    right: 16,
                    child: Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(12),
                      child: TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: randomPlaceholder,
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // =======================================
              // Categories Section
              // =======================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Explore Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // If no categories, show a fallback
                    if (categories.isEmpty)
                      const Text('No categories found.')
                    else
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            final catName = cat['name'] ?? 'No Name';
                            // We might have "data:image/png;base64,..."
                            final catImage = cat['image'] ?? '';

                            return _buildCategoryCard(catName, catImage);
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // =======================================
              // Vendor Section
              // =======================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nearby Kitchens',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (vendors.isEmpty)
                      const Center(child: Text('No vendors found.'))
                    else
                      Column(
                        children: vendors.map((vendor) {
                          final vendorId = vendor['id'] ?? '';
                          final name = vendor['kitchenName'] ?? 'No Name';
                          final imageUrl = vendor['profile']?['profileImage'] ?? '';
                          final rating = vendor['rating']?.toString() ?? '4.5';
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
            ],
          ),
        );
      }),
    );
  }

  // Category Card
  Widget _buildCategoryCard(String catName, String base64Image) {
    // If your "image" is base64, decode & show with Image.memory
    // (like in the previous code snippet)
    // or if it's an actual URL, call Image.network
    // For demonstration, let's assume base64 decoding:
    Uint8List? catImageBytes;
    try {
      // If there's a prefix like "data:image/png;base64," remove it
      if (base64Image.contains(',')) {
        base64Image = base64Image.split(',').last;
      }
      catImageBytes = base64Decode(base64Image);
    } catch (e) {
      // If decoding fails, it stays null
    }

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[200],
            child: (catImageBytes != null)
                ? Image.memory(catImageBytes, width: 30, height: 30)
                : const Icon(Icons.fastfood, size: 30, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(catName, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  // Kitchen Card
  Widget _buildKitchenCard(
    String name,
    String base64Image,
    String rating,
    bool isVeg,
    String vendorId,
  ) {
    // If you have base64 images for vendor as well, decode them
    Uint8List? vendorImageBytes;
    try {
      if (base64Image.contains(',')) {
        base64Image = base64Image.split(',').last;
      }
      vendorImageBytes = base64Decode(base64Image);
    } catch (e) {
      vendorImageBytes = null;
    }

    return GestureDetector(
      onTap: () {
        // Navigate to the kitchen details page with vendorId
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 3 / 2, // Maintains image proportions
                child: (vendorImageBytes != null)
                    ? Image.memory(
                        vendorImageBytes,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.broken_image,
                              size: 50, color: Colors.grey),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image,
                            size: 50, color: Colors.grey),
                      ),
              ),
            ),
            // Info Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kitchen Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Rating and Veg/Non-Veg Indicator
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.circle,
                        color: isVeg ? Colors.green : Colors.red,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isVeg ? 'Veg' : 'Non-Veg',
                        style: const TextStyle(fontSize: 14),
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
  }
}
