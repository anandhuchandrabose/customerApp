import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:lottie/lottie.dart'; // <-- Lottie import

import '../controllers/cart_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartCtrl = Get.find<CartController>();

    return Scaffold(
      // AppBar with a more modern look
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

  /// The normal "cart" UI when items exist
  Widget _buildCartContent(BuildContext context) {
    final cartCtrl = Get.find<CartController>();
    final cartItems = cartCtrl.cartItems;

    // If you have a breakdown in cartData
    final subtotal = cartCtrl.cartData['subtotal'] ?? 0;
    final deliveryCharge = cartCtrl.cartData['deliveryCharge'] ?? 0;
    final tax = cartCtrl.cartData['tax'] ?? 0;
    final platformFees = cartCtrl.cartData['platformFees'] ?? 0;
    final total = cartCtrl.cartData['total'] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // ===== Items Title =====
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Text(
              'Items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),

          // ===== Cart Items List =====
          Container(
            color: Colors.white,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cartItems.length,
              separatorBuilder: (ctx, idx) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = cartItems[index];
                final quantity = item['quantity'] ?? 1;

                final vendorDish = item['vendorDish'] as Map<String, dynamic>?;
                final dish = vendorDish?['dish'] as Map<String, dynamic>?;
                final dishName = dish?['name'] ?? 'Unknown Dish';

                // If your API has a real image, set here:
                final imageUrl = ''; // dish?['imageUrl'] ?? '';

                final price = vendorDish?['vendorSpecificPrice'] ?? '0.00';
                final double priceDouble =
                    double.tryParse(price.toString()) ?? 0.0;
                final lineTotal = priceDouble * quantity;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
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
                                      vendorDish?['id'] ?? '',
                                      vendorDish?['mealType'] ?? '',
                                    );
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Text(
                                    '$quantity',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                                _circleButton(
                                  icon: Icons.add,
                                  onTap: () {
                                    cartCtrl.increaseItemQuantity(
                                      vendorDish?['id'] ?? '',
                                      vendorDish?['mealType'] ?? '',
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
              },
            ),
          ),

          // ===== Address Section =====
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                _summaryRow('Subtotal', subtotal.toStringAsFixed(2)),
                const SizedBox(height: 4),
                _summaryRow('Delivery Charge', deliveryCharge.toString()),
                const SizedBox(height: 4),
                _summaryRow('Tax', tax.toString()),
                const SizedBox(height: 4),
                _summaryRow('Platform Fees', platformFees.toString()),
                const Divider(height: 1),
                _summaryRow('Total', total.toStringAsFixed(2), isTotal: true),
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

  /// The Lottie-based empty cart screen
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
                'assets/lottie/empty_cart.json', // The JSON you shared
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

            // ElevatedButton(
            //   onPressed: () {
            //     // Example: navigate to home or categories
            //     Get.offAllNamed('/home');
            //   },
            //   style: ElevatedButton.styleFrom(
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 24,
            //       vertical: 12,
            //     ),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //   ),
            //   child: const Text(
            //     'Explore Menu',
            //     style: TextStyle(fontSize: 16),
            //   ),
            // ),
          ],
        ),
      ),
    );
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

  /// Dish image with a more interesting look
  Widget _buildDishImage(String imageUrl) {
    // If your JSON had dish?["imageUrl"], decode it or load it as below:
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
    // Otherwise, show a Lottie fallback or an icon
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
