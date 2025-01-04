// lib/app/views/cart_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slide_to_act/slide_to_act.dart';
import '../controllers/cart_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartCtrl = Get.find<CartController>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: Obx(() {
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
        if (cartCtrl.cartItems.isEmpty) {
          return const Center(child: Text('Your cart is empty.'));
        }

        // Use a SingleChildScrollView so we can show items + the price breakdown in one scroll
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 1) List of items
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cartCtrl.cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartCtrl.cartItems[index];
                  final itemId = item['id'] ?? '';
                  final quantity = item['quantity'] ?? 1;

                  final vendorDish = item['vendorDish'] as Map<String, dynamic>?;
                  final vendorDishId = vendorDish?['id'] ?? '';
                  final mealType = vendorDish?['mealType'] ?? 'lunch';
                  final dish = vendorDish?['dish'] as Map<String, dynamic>?;
                  final dishName = dish?['name'] ?? 'Unknown Dish';
                  final price = vendorDish?['vendorSpecificPrice'] ?? '0.00';
                  final vendor = vendorDish?['vendor'] as Map<String, dynamic>?;
                  final vendorName = vendor?['kitchenName'] ?? 'Unknown Kitchen';

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      isThreeLine: true,
                      leading: const Icon(Icons.fastfood, size: 36),
                      title: Text(
                        dishName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('From: $vendorName\nPrice: ₹$price'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              cartCtrl.decreaseItemQuantity(vendorDishId, mealType);
                            },
                          ),
                          Text(
                            quantity.toString(),
                            style: const TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              cartCtrl.increaseItemQuantity(vendorDishId, mealType);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // 2) Price Details
              _buildPriceBreakdown(cartCtrl),

              const SizedBox(height: 24),

              // 3) Slide to Pay
              _buildSlideToPay(cartCtrl),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPriceBreakdown(CartController cartCtrl) {
    // Access cartData fields from the controller
    final subtotal = cartCtrl.cartData['subtotal'] ?? 0;
    final deliveryCharge = cartCtrl.cartData['deliveryCharge'] ?? 0;
    final tax = cartCtrl.cartData['tax'] ?? 0;
    final platformFees = cartCtrl.cartData['platformFees'] ?? 0;
    final total = cartCtrl.cartData['total'] ?? 0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Price Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(thickness: 1, height: 20),
            _buildRow('Subtotal', '₹$subtotal'),
            const SizedBox(height: 4),
            _buildRow('Delivery Charge', '₹$deliveryCharge'),
            const SizedBox(height: 4),
            _buildRow('Tax', '₹$tax'),
            const SizedBox(height: 4),
            _buildRow('Platform Fees', '₹$platformFees'),
            const Divider(thickness: 1, height: 20),
            _buildRow('Total', '₹$total', isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildSlideToPay(CartController cartCtrl) {
    return SlideAction(
      text: 'Slide to Pay',
      textStyle: const TextStyle(color: Colors.white, fontSize: 18),
      innerColor: Colors.green,
      outerColor: Colors.green.shade700,
      borderRadius: 8,
      onSubmit: () {
        // Trigger the checkout
        cartCtrl.checkoutCart();
      },
    );
  }
}
