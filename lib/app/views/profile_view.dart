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
      backgroundColor: Colors.white, // Set background color to white
      body: Column(
        children: [
          // Profile Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Profile picture placeholder
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade300,
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // User name
                    Text(
                      'Hello, ${profileCtrl.userName.value}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Email
                    Text(
                      profileCtrl.email.value.isEmpty
                          ? 'No email provided'
                          : profileCtrl.email.value,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    // Phone number
                    Text(
                      profileCtrl.phoneNumber.value.isEmpty
                          ? 'No phone number provided'
                          : profileCtrl.phoneNumber.value,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                );
              }),
            ),
          ),
          // Profile Options List
          ListTile(
            leading: const Icon(Icons.card_giftcard),
            title: const Text('Coupons'),
            onTap: profileCtrl.navigateToCoupons,
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Address'),
            onTap: profileCtrl.navigateToAddress,
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Get Help'),
            onTap: profileCtrl.navigateToHelp,
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy'),
            onTap: profileCtrl.navigateToPrivacy,
          ),
          ListTile(
            leading: const Icon(Icons.gavel),
            title: const Text('Legal'),
            onTap: profileCtrl.navigateToLegal,
          ),
          ListTile(
            leading: const Icon(Icons.question_answer),
            title: const Text('FAQ'),
            onTap: profileCtrl.navigateToFAQ,
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: Obx(() => Switch(
                  value: profileCtrl.notificationsEnabled.value,
                  onChanged: (value) => profileCtrl.toggleNotifications(value),
                )),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: profileCtrl.logout,
          ),
        ],
      ),
    );
  }
}