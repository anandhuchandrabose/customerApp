import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:lottie/lottie.dart';

import '../controllers/cart_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartCtrl = Get.find<CartController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text('Orders', style: TextStyle(color: Colors.black)),
        centerTitle: false,
      ),
      backgroundColor: Colors.grey.shade100,

      body: Obx(() {
        // 1) Loading or error
        if (cartCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (cartCtrl.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              cartCtrl.errorMessage.value,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // 2) Check if cart is empty => show Lottie-based empty state
        if (cartCtrl.cartItems.isEmpty) {
          return _buildEmptyCart();
        }

        // 3) Otherwise, show cart items
        return _buildCartContent(context);
      }),
    );
  }

  /// If the cart is not empty, build the list of grouped items + summary
  Widget _buildCartContent(BuildContext context) {
    final cartCtrl = Get.find<CartController>();
    final cartItems = cartCtrl.cartItems;

    // Group items by mealType
    final groupedItems = _groupCartItemsByMealType(cartItems);

    // If you have a breakdown in cartData
    final subtotal       = cartCtrl.cartData['subtotal']       ?? 0;
    final deliveryCharge = cartCtrl.cartData['deliveryCharge'] ?? 0;
    final tax            = cartCtrl.cartData['tax']            ?? 0;
    final platformFees   = cartCtrl.cartData['platformFees']   ?? 0;
    final total          = cartCtrl.cartData['total']          ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Title =====
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Text(
              'Items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),

          // ===== Display each mealType group =====
          ...groupedItems.entries.map((entry) {
            final mealType = entry.key; // e.g. "lunch", "dinner"
            final items    = entry.value;

            return Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal Type Label
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 10, bottom: 6,
                    ),
                    child: Text(
                      mealType.capitalizeFirst ?? mealType,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  // The items for this mealType
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (ctx, idx) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildCartItemRow(item);
                    },
                  ),
                ],
              ),
            );
          }),

          // ===== Address Section (Optional) =====
          Container(
            color: Colors.white,
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Address',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  '91 Blvd, Colony Foberz, 75010 Paris',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    // "Add new address" logic
                  },
                  child: Text(
                    '+ Add new address',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===== Order Summary =====
          Container(
            margin: const EdgeInsets.only(top: 12),
            color: Colors.white,
            child: Column(
              children: [
                // Label
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16,
                  ),
                  child: Row(
                    children: const [
                      Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
                const Divider(height: 1),
                _summaryRow('Subtotal',         subtotal.toStringAsFixed(2)),
                const SizedBox(height: 4),
                _summaryRow('Delivery Charge',  deliveryCharge.toString()),
                const SizedBox(height: 4),
                _summaryRow('Tax',              tax.toString()),
                const SizedBox(height: 4),
                _summaryRow('Platform Fees',    platformFees.toString()),
                const Divider(height: 1),
                _summaryRow('Total',            total.toStringAsFixed(2),
                  isTotal: true,
                ),
              ],
            ),
          ),

          // ===== Slide to Pay =====
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: SlideAction(
              outerColor: Colors.orange,
              innerColor: Colors.white,
              text: "Slide to Pay",
              textStyle: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              onSubmit: () {
                cartCtrl.initiatePayment();
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build a single Cart Item row (with dish image, name, +/- buttons, total)
  Widget _buildCartItemRow(Map<String, dynamic> item) {
    final cartCtrl = Get.find<CartController>();
    final quantity = item['quantity'] ?? 1;

    final vendorDish = item['vendorDish'] as Map<String, dynamic>?;
    final dish       = vendorDish?['dish'] as Map<String, dynamic>?; 
    final dishName   = dish?['name'] ?? 'Unknown Dish';
    final imageUrl   = dish?['imageUrl'] ?? '';
    final mealType   = vendorDish?['mealType'] ?? ''; 
    final vendorDishId = vendorDish?['id'] ?? '';

    // Price 
    // Possibly the server returns `vendorDish.vendorSpecificPrice`, or item['price'].
    final priceStr = vendorDish?['vendorSpecificPrice']?.toString() ?? '0.00';
    final priceDouble = double.tryParse(priceStr) ?? 0.0;
    final lineTotal = priceDouble * quantity;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDishImage(imageUrl),
          const SizedBox(width: 12),

          // Dish info + plus/minus
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  dishName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  'Price per: ₹${priceDouble.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),

                // Stepper row
                Row(
                  children: [
                    _circleButton(
                      icon: Icons.remove,
                      onTap: () {
                        cartCtrl.decreaseItemQuantity(
                          vendorDishId: vendorDishId,
                          mealType: mealType,
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '$quantity',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    _circleButton(
                      icon: Icons.add,
                      onTap: () {
                        cartCtrl.increaseItemQuantity(
                          vendorDishId: vendorDishId,
                          mealType: mealType,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Line total
          Text(
            '₹${lineTotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Lottie-based empty cart screen
  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie Animation
            SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset(
                'assets/lottie/empty_cart.json',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Cart is Empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Looks like you haven’t added anything yet.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Optional button...
          ],
        ),
      ),
    );
  }

  /// Group items by mealType
  Map<String, List<Map<String, dynamic>>> _groupCartItemsByMealType(
      List<Map<String, dynamic>> items) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final item in items) {
      final vendorDish = item['vendorDish'] ?? {};
      final mealType   = vendorDish['mealType'] ?? 'Unknown';
      grouped.putIfAbsent(mealType, () => []);
      grouped[mealType]!.add(item);
    }
    return grouped;
  }

  /// Builds each summary row
  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const Spacer(),
          Text(
            '₹$value',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// A small circular button for +/- quantity
  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade400),
          color: Colors.white,
        ),
        child: Icon(
          icon,
          size: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  /// Dish image with a fallback if empty
  Widget _buildDishImage(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 60,
            height: 60,
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image),
          ),
        ),
      );
    }
    // Fallback if no URL
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.fastfood, color: Colors.orange, size: 30),
    );
  }
}
