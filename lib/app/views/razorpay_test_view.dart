// lib/app/views/razorpay_test_view.dart

import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:get/get.dart';


class RazorpayTestView extends StatefulWidget {
  const RazorpayTestView({super.key});

  @override
  _RazorpayTestViewState createState() => _RazorpayTestViewState();
}

class _RazorpayTestViewState extends State<RazorpayTestView> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    // Attach event listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Get.snackbar(
      'Success',
      'Payment successful! Payment ID: ${response.paymentId}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar(
      'Error',
      'Payment failed! Code: ${response.code}, Message: ${response.message}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar(
      'External Wallet',
      'Payment via ${response.walletName} was selected.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _openRazorpay() {
    var options = {
      'key': 'rzp_test_XXXXXXXXXXXXXX', // Replace with your Razorpay Test Key
      'amount': 50000, // Amount in paise (₹500.00)
      'currency': 'INR',
      'name': 'Test Payment',
      'description': 'Testing Razorpay Integration',
      'prefill': {
        'contact': '9123456789',
        'email': 'test@example.com',
      },
      'theme': {
        'color': '#F37254'
      },
      // Remove external wallets during emulator testing
      // 'external': {
      //   'wallets': ['paytm']
      // }
    };

    try {
      print("Opening Razorpay with options: $options"); // Debugging
      _razorpay.open(options);
    } catch (e, stacktrace) {
      print("Error opening Razorpay checkout: $e");
      print(stacktrace);
      Get.snackbar('Error', 'Could not open payment gateway.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Razorpay Test')),
        body: Center(
          child: ElevatedButton(
            onPressed: _openRazorpay,
            child: Text('Pay with Razorpay'),
          ),
        ));
  }
}
