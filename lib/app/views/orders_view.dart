import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../controllers/orders_controller.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({Key? key}) : super(key: key);

  static const Color kPrimaryColor = Color(0xFFFF3008);

  @override
  Widget build(BuildContext context) {
    final OrdersController ordersCtrl = Get.find<OrdersController>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "My Orders",
          style: GoogleFonts.workSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Obx(() {
        if (ordersCtrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: kPrimaryColor),
          );
        }
        if (ordersCtrl.errorMessage.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ordersCtrl.errorMessage.value,
                    style: GoogleFonts.workSans(
                      fontSize: 16,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ordersCtrl.fetchOrders(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Retry',
                      style: GoogleFonts.workSans(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (ordersCtrl.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Lottie.asset(
                    'assets/lottie/empty_orders.json',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "No Orders Found",
                  style: GoogleFonts.workSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Place your first order today!",
                  style: GoogleFonts.workSans(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ordersCtrl.fetchOrders(),
          color: kPrimaryColor,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ordersCtrl.orders.length,
            itemBuilder: (context, index) {
              final order = ordersCtrl.orders[index];
              final String orderId = order['id']?.toString() ?? 'N/A';
              final String status = order['status']?.toString() ?? 'Unknown';
              // Use createdAt for precise date and time
              final String createdAt = order['createdAt']?.toString() ?? '';
              String orderDateTime = 'N/A';
              if (createdAt.isNotEmpty) {
                try {
                  final DateTime parsedDate = DateTime.parse(createdAt);
                  orderDateTime = DateFormat('MMM d, h:mm a').format(parsedDate);
                } catch (e) {
                  orderDateTime = order['orderDate']?.toString() ?? 'N/A';
                }
              }
              final String totalAmount = order['totalAmount']?.toString() ?? '0.00';
              final List<Map<String, dynamic>> subOrders = (order['subOrders'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

              return _buildOrderCard(
                context,
                orderId,
                status,
                orderDateTime,
                totalAmount,
                subOrders,
              );
            },
          ),
        );
      }),
    );
  }

  void _showCancelSubOrderDialog(BuildContext context, String subOrderId) {
    final TextEditingController reasonController = TextEditingController();
    final RxString selectedReason = ''.obs;

    final List<String> predefinedReasons = [
      'Ordered by mistake',
      'Change of mind',
      'Delay in delivery',
      'Found a better deal',
      'Other',
    ];

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cancel Sub-Order',
          style: GoogleFonts.workSans(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => DropdownButtonFormField<String>(
                  value: selectedReason.value.isNotEmpty
                      ? selectedReason.value
                      : null,
                  hint: const Text('Select a reason'),
                  items: predefinedReasons.map((reason) {
                    return DropdownMenuItem(
                      value: reason,
                      child: Text(reason),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedReason.value = value ?? '';
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                )),
            const SizedBox(height: 12),
            if (selectedReason.value == 'Other')
              TextField(
                controller: reasonController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Please provide a reason',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final reason = selectedReason.value == 'Other'
                  ? reasonController.text.trim()
                  : selectedReason.value;

              if (reason.isEmpty) {
                Get.snackbar(
                  'Reason required',
                  'Please provide a reason for cancellation.',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
                return;
              }

              Get.back(); // Close dialog
              Get.find<OrdersController>().cancelSubOrder(subOrderId, reason);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    String orderId,
    String status,
    String orderDateTime,
    String totalAmount,
    List<Map<String, dynamic>> subOrders,
  ) {
    // Extract vendor details (assuming the first subOrder has the same vendor as the order)
    final vendor = subOrders.isNotEmpty ? subOrders[0]['vendor'] ?? {} : {};
    final String kitchenName = vendor['kitchenName']?.toString() ?? 'N/A';
    final String imagePath = subOrders.isNotEmpty &&
            subOrders[0]['orderItems'] != null &&
            subOrders[0]['orderItems'].isNotEmpty &&
            subOrders[0]['orderItems'][0]['vendorDish'] != null
        ? (subOrders[0]['orderItems'][0]['vendorDish']['imagePath']?.toString() ?? '')
        : '';
    final String fullImagePath = imagePath.isNotEmpty ? 'https://api.fresmo.in/$imagePath' : '';

    // Debug print to check image paths
    print('Image Path: $imagePath');
    print('Full Image Path: $fullImagePath');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant Info Row (Image, Name, Status)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Restaurant Image
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200], // Fallback color if image fails
                ),
                child: imagePath.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          fullImagePath,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('Image Load Error: $error');
                            return const Icon(
                              Icons.restaurant,
                              size: 24,
                              color: Colors.grey,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.restaurant,
                        size: 24,
                        color: Colors.grey,
                      ),
              ),
              const SizedBox(width: 12),
              // Restaurant Name and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          kitchenName,
                          style: GoogleFonts.workSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getStatusIcon(status),
                                size: 14,
                                color: _getStatusColor(status),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                StringExtension(status).capitalize,
                                style: GoogleFonts.workSans(
                                  fontSize: 12,
                                  color: _getStatusColor(status),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Order Items with Cancel and Rate Buttons for each Sub-Order
          ...subOrders.asMap().entries.map<Widget>((entry) {
            final int index = entry.key;
            final subOrder = entry.value;
            final String mealType = subOrder['mealType']?.toString() ?? 'N/A';
            final List orderItems = subOrder['orderItems'] ?? [];
            final String subOrderStatus = subOrder['status']?.toString().toLowerCase() ?? '';
            final bool isCancellable = subOrderStatus == 'created' || subOrderStatus == 'placed';
            final String? subOrderId = subOrder['id']?.toString();
            final String? vendorId = subOrder['vendor'] != null ? subOrder['vendor']['id']?.toString() : null;

            // Debug prints to verify data
            print('SubOrder ID: $subOrderId, Vendor ID: $vendorId, Status: $subOrderStatus');

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal Type with Cancel and Rate Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      StringExtension(mealType).capitalize,
                      style: GoogleFonts.workSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Row(
                      children: [
                        if (isCancellable && subOrderId != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ElevatedButton(
                              onPressed: () {
                                _showCancelSubOrderDialog(context, subOrderId);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                "Cancel",
                                style: GoogleFonts.workSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ),
                        // Show Rate button for all sub-orders (for testing)
                        if (subOrderId != null)
                          ElevatedButton(
                            onPressed: () {
                              // Use a placeholder vendorId if null for testing
                              final String effectiveVendorId = vendorId ?? 'placeholder-vendor-id';
                              _showRatingBottomSheet(context, subOrderId, effectiveVendorId, mealType);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[700], // For Rate
                              foregroundColor: const Color.fromARGB(255, 250, 250, 250),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              "Rate",
                              style: GoogleFonts.workSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.amber[700],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Order Items
                ...orderItems.map<Widget>((item) {
                  final String dishName = item['vendorDish']?['dishName']?.toString() ?? 'N/A';
                  final int quantity = item['quantity'] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          "$quantity×",
                          style: GoogleFonts.workSans(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dishName,
                            style: GoogleFonts.workSans(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                // Divider between sub-orders (except for the last one)
                if (index < subOrders.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(
                      color: Colors.grey[300],
                      thickness: 1,
                    ),
                  ),
              ],
            );
          }).toList(),
          const SizedBox(height: 12),
          // Star Rating (or empty stars if not available)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              // Average rating across all sub-orders if multiple ratings exist
              double averageRating = 0.0;
              int ratedSubOrders = 0;
              for (var subOrder in subOrders) {
                if (subOrder['rating'] != null) {
                  averageRating += (subOrder['rating'] as num).toDouble();
                  ratedSubOrders++;
                }
              }
              averageRating = ratedSubOrders > 0 ? averageRating / ratedSubOrders : 0.0;
              return Icon(
                index < averageRating ? Icons.star : Icons.star_border,
                size: 20,
                color: Colors.amber,
              );
            }),
          ),
          const SizedBox(height: 8),
          // Order Details
          Center(
            child: Text(
              "Ordered: ${orderDateTime} • Bill Total: ₹${totalAmount}",
              style: GoogleFonts.workSans(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRatingBottomSheet(BuildContext context, String subOrderId,
      String vendorId, String mealType) {
    final TextEditingController commentController = TextEditingController();
    RxInt rating = 0.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rate $mealType',
                style: GoogleFonts.workSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating.value ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          rating.value = index + 1;
                        },
                      );
                    }),
                  )),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Leave a comment (optional)',
                  hintStyle: GoogleFonts.workSans(
                    color: Colors.grey[500],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kPrimaryColor),
                  ),
                ),
                style: GoogleFonts.workSans(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () async {
                    // Allow submission even if rating is 0 (for testing)
                    await Get.find<OrdersController>().submitRating(
                      subOrderId,
                      vendorId,
                      rating.value,
                      commentController.text,
                    );
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    'Submit',
                    style: GoogleFonts.workSans(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'created':
        return Colors.blue;
      case 'placed':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_empty;
      case 'cancelled':
        return Icons.cancel;
      case 'created':
        return Icons.create;
      case 'placed':
        return Icons.place;
      default:
        return Icons.info;
    }
  }
}

// Extension for capitalizing strings
extension StringExtension on String {
  String get capitalize =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : this;
}