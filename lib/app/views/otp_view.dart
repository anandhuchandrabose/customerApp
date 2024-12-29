// lib/app/views/otp_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/otp_controller.dart';

class OtpView extends GetView<OtpController> {
  const OtpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final otpCtrl = Get.find<OtpController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Obx(() {
        if (otpCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Phone: ${otpCtrl.phoneNumber.value}'),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Enter OTP',
                ),
                keyboardType: TextInputType.number,
                onChanged: otpCtrl.updateOtp,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => otpCtrl.verifyOtp(),
                child: const Text('Verify OTP'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
