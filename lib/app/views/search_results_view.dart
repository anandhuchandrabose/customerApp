import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/search_results_controller.dart';

class SearchResultsView extends GetView<SearchResultsController> {
  const SearchResultsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String searchKey = Get.arguments['searchKey'] ?? "";
    controller.searchDishes(searchKey);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Search Results",
          style: GoogleFonts.workSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFF3008),
            ),
          );
        }
        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              "Error: ${controller.errorMessage.value}",
              style: GoogleFonts.workSans(
                fontSize: 16,
                color: Colors.redAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }
        if (controller.searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 60,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  "No results found for '$searchKey'",
                  style: GoogleFonts.workSans(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.searchResults.length,
          itemBuilder: (context, index) {
            final result = controller.searchResults[index];
            final dish = result['dish'] ?? {};
            final dishName = dish['name'] ?? 'Unknown';
            final dishDescription = dish['description'] ?? '';
            final dishCategory = dish['category'] ?? '';
            final imagePath = result['imagePath'] ?? '';
            final vendor = result['vendor'] ?? {};
            final vendorName = vendor['kitchenName'] ?? 'Unknown Vendor';

            return _buildSearchResultCard(
              dishName,
              dishDescription,
              dishCategory,
              imagePath,
              vendorName,
            );
          },
        );
      }),
    );
  }

  // ===== Redesigned Food Card =====
  Widget _buildSearchResultCard(
    String dishName,
    String dishDescription,
    String dishCategory,
    String imagePath,
    String vendorName,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to dish details if implemented
        // Get.toNamed('/dish-details', arguments: {...});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: imagePath.isNotEmpty
                      ? Image.network(
                          "https://api.fresmo.in/$imagePath",
                          width: double.infinity,
                          height: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: double.infinity,
                            height: 140,
                            color: Colors.grey[300],
                            child: Icon(Icons.fastfood, color: Colors.grey[500], size: 50),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: 140,
                          color: Colors.grey[300],
                          child: Icon(Icons.fastfood, color: Colors.grey[500], size: 50),
                        ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      dishCategory,
                      style: GoogleFonts.workSans(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Details Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dishName,
                    style: GoogleFonts.workSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dishDescription,
                    style: GoogleFonts.workSans(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.store,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          vendorName,
                          style: GoogleFonts.workSans(
                            fontSize: 13,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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