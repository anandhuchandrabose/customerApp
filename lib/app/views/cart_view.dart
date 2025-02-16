import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/cart_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({Key? key}) : super(key: key);

  // Primary color (matching the red tone in your screenshot).
  static const Color kPrimaryColor = Color(0xFFFF3008);

  @override
  Widget build(BuildContext context) {
    final cartCtrl = Get.find<CartController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Checkout',
          style: GoogleFonts.workSans(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        // 1) Loading state
        if (cartCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        // 2) Error state: Show error message with a retry button.
        if (cartCtrl.errorMessage.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cartCtrl.errorMessage.value,
                    style: GoogleFonts.workSans(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      cartCtrl.fetchCartItems();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                    ),
                    child: Text(
                      'Retry',
                      style: GoogleFonts.workSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }
        // 3) Empty cart state
        if (cartCtrl.cartItems.isEmpty) {
          return _buildEmptyCart();
        }

        // 4) Normal state: show the checkout UI
        return SingleChildScrollView(
          child: Column(
            children: [
              // ===== STORE NAME =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.black12)),
                ),
                child: Text(
                  // For illustration, we’ll just hardcode "Fresmo"
                  'Fresmo',
                  style: GoogleFonts.workSans(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),

              // ===== ADDRESS / DELIVERY / PHONE =====
              Container(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
                color: Colors.white,
                child: Column(
                  children: [
                    _menuItemRow(
                      icon: Icons.location_on,
                      title: cartCtrl.cartData['address'] ??
                          '56 Miami Beach Promenade\nIluka WA 6028, Australia',
                      onTap: () {
                        // Implement "Change address" or detail screen
                      },
                    ),
                    const SizedBox(height: 8),
                    _menuItemRow(
                      icon: Icons.phone,
                      title: cartCtrl.cartData['phone'] ?? '(215) 268-8872',
                      onTap: () {
                        // Possibly let user edit phone number
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              const Divider(height: 1, color: Colors.black12),

              // ===== PROMOTION + REWARD PROGRESS =====
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add a promotion',
                          style: GoogleFonts.workSans(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.black38),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // You can add promotion/reward progress if available.
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ===== SHOW CART ITEMS (grouped by mealType) =====
              _buildCartItemsSection(),

              const SizedBox(height: 12),

              // ===== FEES & ORDER SUMMARY =====
              _buildOrderSummary(),

              const SizedBox(height: 24),

              // ===== SLIDE TO PAY (Place Order) =====
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: SlideAction(
                  outerColor: kPrimaryColor,
                  innerColor: Colors.white,
                  text: "Slide to Pay",
                  textStyle: GoogleFonts.workSans(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  onSubmit: () {
                    // Trigger your actual payment flow:
                    cartCtrl.initiatePayment();
                    Future.delayed(const Duration(milliseconds: 300), () {
                      Get.snackbar(
                        'Success',
                        'Your order has been placed!',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  // -----------------------------
  // 1) Empty cart screen
  // -----------------------------
  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset(
                'assets/lottie/empty_cart.json',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Cart is Empty',
              style: GoogleFonts.workSans(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Looks like you haven’t added anything yet.',
              style: GoogleFonts.workSans(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // -----------------------------
  // 2) Builds the cart items section, grouped by mealType
  // -----------------------------
  Widget _buildCartItemsSection() {
    final cartCtrl = Get.find<CartController>();
    final cartItems = cartCtrl.cartItems;

    // Group items by mealType
    final groupedItems = _groupCartItemsByMealType(cartItems);

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              'Items',
              style: GoogleFonts.workSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Each mealType group
          ...groupedItems.entries.map((entry) {
            final mealType = entry.key;
            final items = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal Type label
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 6),
                    child: Text(
                      mealType.capitalizeFirst ?? mealType,
                      style: GoogleFonts.workSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  // Items list
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
          }).toList(),
        ],
      ),
    );
  }

  // Groups cart items by meal type.
  Map<String, List<Map<String, dynamic>>> _groupCartItemsByMealType(
    List<Map<String, dynamic>> items,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final item in items) {
      final vendorDish = item['vendorDish'] ?? {};
      final mealType = vendorDish['mealType'] ?? 'Unknown';
      grouped.putIfAbsent(mealType, () => []);
      grouped[mealType]!.add(item);
    }
    return grouped;
  }

  // Builds a single cart item row.
  Widget _buildCartItemRow(Map<String, dynamic> item) {
    final cartCtrl = Get.find<CartController>();
    final quantity = item['quantity'] ?? 1;

    final vendorDish = item['vendorDish'] ?? {};
    final dish = vendorDish['dish'] ?? {};
    final dishName = dish['name'] ?? 'Unknown Dish';
    // Retrieve the image from vendorDish.
    final imageUrl = vendorDish['image'] ?? '';
    final mealType = vendorDish['mealType'] ?? '';
    final vendorDishId = vendorDish['id'] ?? '';

    final priceStr = vendorDish['vendorSpecificPrice']?.toString() ?? '0.00';
    final priceDouble = double.tryParse(priceStr) ?? 0.0;
    final lineTotal = priceDouble * quantity;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDishImage(imageUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dishName,
                  style: GoogleFonts.workSans(
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
                        style: GoogleFonts.workSans(fontSize: 15),
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
          Text(
            '₹${lineTotal.toStringAsFixed(2)}',
            style: GoogleFonts.workSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Shows dish image or fallback icon if no URL.
  Widget _buildDishImage(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      if (imageUrl.startsWith("data:image")) {
        final base64Str = imageUrl.split(",").last;
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            base64Decode(base64Str),
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
      } else {
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
    }
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

  // -----------------------------
  // Builds the fees + order summary
  // -----------------------------
  Widget _buildOrderSummary() {
    final cartCtrl = Get.find<CartController>();

    final subtotal = cartCtrl.cartData['subtotal'] ?? 0.0;
    final deliveryFee = cartCtrl.cartData['deliveryCharge'] ?? 0.0;
    final serviceFee = cartCtrl.cartData['tax'] ?? 0.0;
    final platformFees = cartCtrl.cartData['platformFees'] ?? 0.0;
    final total = cartCtrl.cartData['total'] ?? 0.0;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          _rowItem('Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
          _rowItem('Delivery fee', '₹${deliveryFee.toStringAsFixed(2)}'),
          _rowItem('Service Fee', '₹${serviceFee.toStringAsFixed(2)}'),
          if (platformFees != 0.0)
            _rowItem('Platform Fees', '₹${platformFees.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          const Divider(color: Colors.black12),
          const SizedBox(height: 8),
          _rowItem(
            'Total',
            '₹${total.toStringAsFixed(2)}',
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _rowItem(String label, String amount, {bool bold = false}) {
    final style = GoogleFonts.workSans(
      fontSize: bold ? 16 : 15,
      fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: style),
          const Spacer(),
          Text(amount, style: style),
        ],
      ),
    );
  }

  // Reusable row for address & phone, etc.
  Widget _menuItemRow({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment:
            subtitle != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: subtitle == null
                ? Text(
                    title,
                    style: GoogleFonts.workSans(fontSize: 15),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.workSans(fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.workSans(
                          fontSize: 14,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.black38),
        ],
      ),
    );
  }
}
