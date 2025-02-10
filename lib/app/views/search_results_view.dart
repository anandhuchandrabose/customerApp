import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/search_results_controller.dart';

class SearchResultsView extends GetView<SearchResultsController> {
  const SearchResultsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Retrieve the search key from arguments.
    final String searchKey = Get.arguments['searchKey'] ?? "";
    // Trigger search when the view loads.
    controller.searchDishes(searchKey);

    return Scaffold(
      appBar: AppBar(
        title: Text("Search Results", style: GoogleFonts.workSans()),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text("Error: ${controller.errorMessage.value}",
                style: GoogleFonts.workSans()),
          );
        }
        if (controller.searchResults.isEmpty) {
          return Center(
            child: Text("No results found for '$searchKey'",
                style: GoogleFonts.workSans()),
          );
        }
        return ListView.builder(
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

            return ListTile(
              leading: imagePath.isNotEmpty
                  ? Image.network(
                      "https://www.fresmo.in/$imagePath",
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                    ),
              title: Text(dishName,
                  style: GoogleFonts.workSans(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dishCategory, style: GoogleFonts.workSans()),
                  Text(
                    dishDescription,
                    style: GoogleFonts.workSans(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text("From: $vendorName",
                      style: GoogleFonts.workSans(fontSize: 12)),
                ],
              ),
              onTap: () {
                // Optionally, navigate to dish details.
              },
            );
          },
        );
      }),
    );
  }
}
