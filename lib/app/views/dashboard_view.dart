// lib/app/views/dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import 'home_view.dart';    // Home Screen
import 'cart_view.dart';    // Cart Screen
import 'profile_view.dart'; // Profile Screen

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // Display the current page based on the selected tab index
        switch (controller.selectedIndex.value) {
          case 0:
            return const HomeView();
          case 1:
            return const CartView();
          case 2:
            return const ProfileView();
          default:
            return const HomeView();
        }
      }),
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeTabIndex,
          // --- Add these lines to control the item colors:
          selectedItemColor: const Color(0xFFFF3008), 
          unselectedItemColor: Colors.grey, // or any color you prefer
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        );
      }),
    );
  }
}
