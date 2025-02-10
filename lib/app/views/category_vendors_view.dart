import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/category_vendors_controller.dart';

class CategoryVendorsView extends GetView<CategoryVendorsController> {
  const CategoryVendorsView({Key? key}) : super(key: key);

  // Same primary color as your home view, if needed
  static const Color kPrimaryColor = Color(0xFFFF3008);

  @override
  Widget build(BuildContext context) {
    // The category name is passed via Get.arguments as a String
    final String categoryName = Get.arguments ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          categoryName,
          style: GoogleFonts.workSans(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        // 1) Loading
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        // 2) Error
        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              'Error: ${controller.errorMessage.value}',
              style: GoogleFonts.workSans(color: Colors.red),
            ),
          );
        }
        // 3) No vendors
        if (controller.vendors.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 48, color: Colors.grey.shade500),
                const SizedBox(height: 16),
                Text(
                  'No restaurants found in $categoryName',
                  style: GoogleFonts.workSans(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          );
        }
        // 4) Show vendor list
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$categoryName Restaurants',
                  style: GoogleFonts.workSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  children: controller.vendors.map((vendor) {
                    final vendorId = vendor['id'] ?? '';
                    final name = vendor['kitchenName'] ?? 'No Name';
                    final imageUrl =
                        vendor['profile']?['profileImage'] ?? '';
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
        );
      }),
    );
  }

  /// Reuse the same style as in HomeView to keep a consistent card UI
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
                            ? 'icons/veg.png'
                            : 'icons/nonveg.png',
                        height: 18,
                        width: 18,
                        errorBuilder: (_, __, ___) => Icon(
                          isVeg ? Icons.eco : Icons.no_food,
                          size: 18,
                          color: isVeg ? Colors.green : Colors.red,
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
  }
}
