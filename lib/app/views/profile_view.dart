// lib/app/views/profile_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileCtrl = Get.find<ProfileController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Obx(() {
          // Display the user's name
          return Text(
            'Hello, ${profileCtrl.userName.value}!',
            style: const TextStyle(fontSize: 24),
          );
        }),
      ),
    );
  }
}
