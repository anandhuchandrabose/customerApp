// lib/app/views/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import 'home_view.dart'; // Home Screen
import 'cart_view.dart'; // Cart Screen
import 'profile_view.dart'; // Profile Screen
import 'orders_view.dart'; // Orders Screen

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Display the current page based on the selected tab index.
      body: Obx(() {
        switch (controller.selectedIndex.value) {
          case 0:
            return const HomeView();
          case 1:
            return CartView();
          case 2:
            return const ProfileView();
          case 3:
            return const OrdersView();
          default:
            return const HomeView();
        }
      }),
      bottomNavigationBar: Obx(() {
        final int currentIndex = controller.selectedIndex.value;
        return BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: controller.changeTabIndex,
          selectedItemColor: const Color(0xFFFF3008),
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                currentIndex == 0 ? Icons.home : Icons.home_outlined,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                currentIndex == 1
                    ? Icons.shopping_cart
                    : Icons.shopping_cart_outlined,
              ),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                currentIndex == 2 ? Icons.person : Icons.person_outline,
              ),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                currentIndex == 3 ? Icons.history : Icons.history_outlined,
              ),
              label: 'Orders',
            ),
          ],
        );
      }),
    );
  }
}
