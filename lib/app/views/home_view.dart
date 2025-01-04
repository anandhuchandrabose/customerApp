import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeCtrl = Get.find<HomeController>();

    // Same logic as before:
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
      // Remove the original AppBar (since we’ll use the stacked/transparent AppBar from the first snippet)
      backgroundColor: Colors.white,
      body: Obx(() {
        if (homeCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (homeCtrl.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              'Error: ${homeCtrl.errorMessage.value}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final vendors = homeCtrl.vendors;

        // ========== REUSED UI FROM FIRST SNIPPET (Stack + Column) ==========
        return SingleChildScrollView(
          child: Column(
            children: [
              // Top Section with Image and Transparent AppBar
              Stack(
                children: [
                  // Background Image
                  Container(
                    height: MediaQuery.of(context).size.height * 0.45,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/img/webpng.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Transparent AppBar
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.location_pin, color: Colors.white),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Home',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '1234 Some Street',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.account_circle,
                            color: Colors.white),
                        onPressed: () {
                          // Your profile navigate logic can stay here if needed
                        },
                      ),
                    ],
                  ),

                  // Positioned Search Field (replacing currentHint with randomPlaceholder)
                  Positioned(
                    top: kToolbarHeight + 60,
                    left: 16,
                    right: 16,
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: '', // We'll show randomPlaceholder manually
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 8),
                            const Icon(Icons.search, color: Colors.grey),
                            const SizedBox(width: 8),
                            // Use randomPlaceholder from second snippet's logic
                            Text(
                              randomPlaceholder,
                              key: ValueKey<String>(randomPlaceholder),
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: (value) {
                        // If you want search logic, keep it from second snippet
                      },
                    ),
                  ),
                ],
              ),

              // Remaining Content: Explore, Categories, Kitchens, etc.
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Explore',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey[700],
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Horizontal List of Food Categories
                    // SizedBox(
                    //   height: 120,
                    //   child: ListView(
                    //     scrollDirection: Axis.horizontal,
                    //     children: [
                    //       _buildHorizontalImageItem(
                    //           'assets/svg/burger.svg', 'Burger'),
                    //       _buildHorizontalImageItem(
                    //           'assets/svg/noodles.svg', 'Noodles'),
                    //       _buildHorizontalImageItem(
                    //           'assets/svg/pizza.svg', 'Pizza'),
                    //       _buildHorizontalImageItem(
                    //           'assets/svg/momos.svg', 'Momos'),
                    //     ],
                    //   ),
                    // ),
                    const SizedBox(height: 16),

                    // Row with Filter (Left) and "All Kitchens" (Right)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            // Filter action from first snippet, or keep your existing logic
                          },
                          icon: const Icon(Icons.filter_list,
                              color: Colors.black),
                          label: const Text(
                            'Filter',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        const Text(
                          'All Kitchens',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Instead of _kitchens, we map over your 'vendors'
                    // preserving the second snippet's onTap logic if desired
                    if (vendors.isEmpty) ...[
                      const Center(child: Text('No vendors found.')),
                    ] else ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: vendors.map((vendor) {
                          final name = vendor['kitchenName'] ?? 'No Name';
                          final imageUrl = vendor['imageUrl'] ?? '';
                          final rating =
                              vendor['rating']?.toString() ?? '4.5';
                          // If you have a field for isVeg or not:
                          final isVeg = vendor['isVeg'] ?? false;

                          // Wrap with GestureDetector so we preserve navigation logic
                          return GestureDetector(
                            onTap: () {
                              // Navigate to details (same as the second snippet logic)
                              Get.toNamed('/restaurant-details', arguments: {
                                'vendorId': vendor['id'],
                              });
                            },
                            child: _buildKitchenCard(
                              name,
                              imageUrl,
                              rating,
                              isVeg,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ============= HELPERS (UI-ONLY) BELOW ============= //

  // Horizontal food category item (like the burger/noodles/pizza in first snippet)
  Widget _buildHorizontalImageItem(String assetPath, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          // Replace with your choice of svg or image
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/img/fallback.png', // fallback image if needed
              width: 30,
              height: 30,
            ),
            // If you have an SVG, use an SVG widget from flutter_svg, e.g.:
            // SvgPicture.asset(assetPath, width: 30, height: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  // Adapted from your first snippet’s _buildKitchenCard but we keep it as 
  // a Card (or Container) and preserve minimal logic from second snippet.
  Widget _buildKitchenCard(
    String name,
    String imageUrl,
    String rating,
    bool isVeg,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Row(
        children: [
          // Kitchen Image
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
            ),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 80,
                    width: 80,
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.image,
                      size: 40,
                      color: Colors.white70,
                    ),
                  ),
          ),
          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Rating & Veg indicator row
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(rating),
                      const SizedBox(width: 10),
                      if (isVeg)
                        const Icon(Icons.circle, color: Colors.green, size: 12)
                      else
                        const Icon(Icons.circle,
                            color: Colors.red, size: 12),
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
