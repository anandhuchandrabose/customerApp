import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/cart_controller.dart';
import '../controllers/location_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({Key? key}) : super(key: key);

  static const Color kPrimaryColor = Color(0xFFFF3008);

  @override
  Widget build(BuildContext context) {
    final cartCtrl = Get.find<CartController>();
    final locationCtrl = Get.find<LocationController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard
        child: Obx(() {
          if (cartCtrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
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
                      onPressed: () => cartCtrl.fetchCartItems(),
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
          if (cartCtrl.cartItems.isEmpty) {
            return _buildEmptyCart();
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  // Find the selected address from LocationController's addresses
                  final selectedAddressMap = locationCtrl.addresses.firstWhere(
                    (address) => address['isSelected'] == true,
                    orElse: () => <String, dynamic>{},
                  );
                  final flatHouseNo = selectedAddressMap['flatHouseNo']?.toString() ?? '';
                  // Only show flat/house number
                  final displayAddress = flatHouseNo.isNotEmpty
                      ? flatHouseNo
                      : 'Select Delivery Address';

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: Colors.white,
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.black54),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            displayAddress,
                            style: GoogleFonts.workSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: flatHouseNo.isNotEmpty ? Colors.black87 : Colors.grey,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.toNamed('/address-input'); // Navigate to AddressInputView
                          },
                          child: Text(
                            flatHouseNo.isNotEmpty ? 'Change' : 'Select',
                            style: GoogleFonts.workSans(
                              fontSize: 14,
                              color: kPrimaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 1, color: Colors.black12),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      // Dynamic cutlery checkboxes based on meal types
                      Obx(() {
                        final mealTypes = cartCtrl.getMealTypes();
                        if (mealTypes.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cutlery Options',
                              style: GoogleFonts.workSans(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (mealTypes.contains('lunch'))
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Require cutlery for lunch',
                                    style: GoogleFonts.workSans(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Checkbox(
                                    value: cartCtrl.isLunchCutleryRequired.value,
                                    onChanged: (value) {
                                      cartCtrl.isLunchCutleryRequired.value = value ?? false;
                                    },
                                    activeColor: kPrimaryColor,
                                  ),
                                ],
                              ),
                            if (mealTypes.contains('dinner'))
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Require cutlery for dinner',
                                    style: GoogleFonts.workSans(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Checkbox(
                                    value: cartCtrl.isDinnerCutleryRequired.value,
                                    onChanged: (value) {
                                      cartCtrl.isDinnerCutleryRequired.value = value ?? false;
                                    },
                                    activeColor: kPrimaryColor,
                                  ),
                                ],
                              ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildCartItemsSection(),
                const SizedBox(height: 12),
                _buildOrderSummary(),
                const SizedBox(height: 24),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: SlideAction(
                    key: UniqueKey(),
                    outerColor: kPrimaryColor,
                    innerColor: Colors.white,
                    text: "Slide to Pay",
                    textStyle: GoogleFonts.workSans(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    onSubmit: () {
                      cartCtrl.initiatePayment();
                      return null; // Remove premature success snackbar
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        }),
      ),
    );
  }

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

  Widget _buildCartItemsSection() {
    final cartCtrl = Get.find<CartController>();
    final cartItems = cartCtrl.cartItems;

    final groupedItems = _groupCartItemsByMealType(cartItems);

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          ...groupedItems.entries.map((entry) {
            final mealType = entry.key;
            final items = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

  Map<String, List<Map<String, dynamic>>> _groupCartItemsByMealType(
      List<Map<String, dynamic>> items) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final item in items) {
      final vendorDish = item['vendorDish'] ?? {};
      final mealType = vendorDish['mealType'] ?? 'Unknown';
      grouped.putIfAbsent(mealType, () => []);
      grouped[mealType]!.add(item);
    }
    return grouped;
  }

  Widget _buildCartItemRow(Map<String, dynamic> item) {
    final cartCtrl = Get.find<CartController>();
    final quantity = item['quantity'] ?? 1;
    final vendorDish = item['vendorDish'] ?? {};
    final dish = vendorDish['dish'] ?? {};
    final dishName = dish['name'] ?? 'Unknown Dish';
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

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
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

  Widget _menuItemRow({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: subtitle != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: subtitle == null
                ? Text(title, style: GoogleFonts.workSans(fontSize: 15))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.workSans(fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.workSans(fontSize: 14, color: Colors.black45),
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

class BouncyPage extends StatefulWidget {
  final Widget child;
  const BouncyPage({super.key, required this.child});

  @override
  _BouncyPageState createState() => _BouncyPageState();
}

class _BouncyPageState extends State<BouncyPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

class AnimatedDishTile extends StatefulWidget {
  final Widget child;
  final int delay;
  const AnimatedDishTile({super.key, required this.child, this.delay = 0});

  @override
  _AnimatedDishTileState createState() => _AnimatedDishTileState();
}

class _AnimatedDishTileState extends State<AnimatedDishTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _offsetAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _offsetAnimation,
        child: widget.child,
      ),
    );
  }
}