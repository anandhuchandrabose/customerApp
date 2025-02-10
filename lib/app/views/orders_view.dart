// lib/app/views/orders_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/orders_controller.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final OrdersController ordersCtrl = Get.find<OrdersController>();
    return Scaffold(
      appBar: AppBar(
        title: Text("My Orders", style: GoogleFonts.workSans()),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: Obx(() {
        if (ordersCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ordersCtrl.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              ordersCtrl.errorMessage.value,
              style: GoogleFonts.workSans(color: Colors.red),
            ),
          );
        }
        if (ordersCtrl.orders.isEmpty) {
          return Center(
            child: Text("No orders found", style: GoogleFonts.workSans()),
          );
        }
        return ListView.builder(
          itemCount: ordersCtrl.orders.length,
          itemBuilder: (context, index) {
            final order = ordersCtrl.orders[index];
            final String orderId = order['id'] ?? '';
            final String status = order['status'] ?? '';
            final String orderDate = order['orderDate'] ?? '';
            final String totalAmount = order['totalAmount'] ?? '';
            final List subOrders = order['subOrders'] ?? [];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ExpansionTile(
                title: Text("Order ID: $orderId", style: GoogleFonts.workSans()),
                subtitle: Text(
                  "Status: $status\nTotal: ₹$totalAmount",
                  style: GoogleFonts.workSans(),
                ),
                children: subOrders.map<Widget>((subOrder) {
                  final String mealType = subOrder['mealType'] ?? '';
                  final String deliveryDate = subOrder['deliveryDate'] ?? '';
                  final String subTotalAmount = subOrder['subTotalAmount'] ?? '';
                  final List orderItems = subOrder['orderItems'] ?? [];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Meal Type: $mealType",
                          style: GoogleFonts.workSans(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Delivery Date: $deliveryDate",
                          style: GoogleFonts.workSans(),
                        ),
                        Text(
                          "Subtotal: ₹$subTotalAmount",
                          style: GoogleFonts.workSans(),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: orderItems.length,
                          itemBuilder: (context, itemIndex) {
                            final item = orderItems[itemIndex];
                            final String dishName = item['vendorDish']?['dishName'] ?? '';
                            final int quantity = item['quantity'] ?? 0;
                            final String priceAtOrder = item['priceAtOrder'] ?? '';
                            return ListTile(
                              title: Text(dishName, style: GoogleFonts.workSans()),
                              subtitle: Text("Quantity: $quantity", style: GoogleFonts.workSans()),
                              trailing: Text("₹$priceAtOrder", style: GoogleFonts.workSans()),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      }),
    );
  }
}
