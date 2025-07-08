// File: lib/views/profile_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/profile_controller.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:url_launcher/url_launcher_string.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileCtrl = Get.find<ProfileController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      backgroundColor: Colors.white,
     body: Obx(() => profileCtrl.isLoading.value
    ? const Center(child: CircularProgressIndicator())
    : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(
                Icons.person,
                size: 60,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Obx(() => Text(
                  'Hello, ${profileCtrl.userName.value}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                )),
          ),
          const SizedBox(height: 10),
          Center(
            child: Obx(() => Text(
                  profileCtrl.email.value,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                )),
          ),
          const SizedBox(height: 10),
          Center(
            child: Obx(() => Text(
                  profileCtrl.phoneNumber.value.isEmpty
                      ? 'No phone number provided'
                      : profileCtrl.phoneNumber.value,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                )),
          ),
          const SizedBox(height: 20),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Address'),
            onTap: () => Get.toNamed('/address-input'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy'),
            onTap: () async {
  const url = 'https://fresmo.in';
  final uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    Get.snackbar('Error', 'Could not open the privacy page.');
  }
},
          ),
          ListTile(
            leading: const Icon(Icons.gavel),
            title: const Text('Legal'),
            onTap: () async {
              const url = 'https://fresmo.in';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              } else {
                Get.snackbar('Error', 'Could not open the legal page.');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: Obx(() => Switch(
                  value: profileCtrl.notificationsEnabled.value,
                  onChanged: profileCtrl.toggleNotifications,
                )),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout',
                style: TextStyle(color: Colors.red)),
            onTap: profileCtrl.logout,
          ),
        ],
      )),
    );
  }
}
