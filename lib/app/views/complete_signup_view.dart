// lib/app/views/complete_signup_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/complete_signup_controller.dart';

class CompleteSignupView extends GetView<CompleteSignupController> {
  const CompleteSignupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final signupCtrl = Get.find<CompleteSignupController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Signup')),
      body: Obx(() {
        if (signupCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'First Name'),
                onChanged: signupCtrl.updateFirstName,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Last Name'),
                onChanged: signupCtrl.updateLastName,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => signupCtrl.completeSignup(),
                child: const Text('Complete Signup'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
