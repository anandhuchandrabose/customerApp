import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String orderId;
  const PaymentSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie animation for order success
          Expanded(
            child: Center(
              child: Lottie.asset(
                'assets/lottie/order_complete.json', // Ensure this file exists in assets
                width: 400,
                height: 400,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Text(
            'Order Confirmed!',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          // SizedBox(height: 10),
          // Text(
          //   'Your order has been successfully placed.',
          //   style: TextStyle(fontSize: 16),
          //   textAlign: TextAlign.center,
          // ),
          SizedBox(height: 10),
          Text(
            'Order ID: $orderId',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
          ),
          SizedBox(height: 10),

          // Continue Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to Home and pass an argument to restore the bottom nav.
                  Get.offAllNamed('/dashboard',
                      arguments: {'showBottomNav': true});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF3008), 
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),

          SizedBox(height: 50),
        ],
      ),
    );
  }
}
