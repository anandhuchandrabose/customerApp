// lib/app/views/login_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginCtrl = Get.find<LoginController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Login with Phone')),
      body: Obx(() {
        if (loginCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                ),
                keyboardType: TextInputType.phone,
                onChanged: loginCtrl.updatePhoneNumber,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => loginCtrl.requestOtp(),
                child: const Text('Request OTP'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
