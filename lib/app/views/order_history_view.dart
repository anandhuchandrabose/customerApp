import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_history_controller.dart';

class OrderHistoryView extends GetView<OrderHistoryController> {
  const OrderHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderHistoryCtrl = Get.find<OrderHistoryController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: Obx(() {
        if (orderHistoryCtrl.orders.isEmpty) {
          return const Center(child: Text('No past orders.'));
        }
        return ListView.builder(
          itemCount: orderHistoryCtrl.orders.length,
          itemBuilder: (context, index) {
            final orderItem = orderHistoryCtrl.orders[index];
            return ListTile(
              title: Text(orderItem),
              subtitle: const Text('Ordered on XX-XX-XXXX'), // placeholder
            );
          },
        );
      }),
    );
  }
}
