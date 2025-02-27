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
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Indicator Line
                  Container(
                    height: 4,
                    margin: const EdgeInsets.only(top: 8),
                    child: Stack(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(4, (index) {
                            return Expanded(
                              child: Center(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  width: currentIndex == index ? 70 : 0,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF3008),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  // Navigation Items
                  BottomNavigationBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    type: BottomNavigationBarType.fixed,
                    currentIndex: currentIndex,
                    onTap: controller.changeTabIndex,
                    selectedItemColor: const Color(0xFFFF3008),
                    unselectedItemColor: Colors.grey.withOpacity(0.6),
                    selectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 11,
                    ),
                    showSelectedLabels: true,
                    showUnselectedLabels: true,
                    items: [
                      _buildNavItem(
                        currentIndex: currentIndex,
                        index: 0,
                        filledIcon: Icons.home,
                        outlinedIcon: Icons.home_outlined,
                        label: 'Home',
                      ),
                      _buildNavItem(
                        currentIndex: currentIndex,
                        index: 1,
                        filledIcon: Icons.shopping_cart,
                        outlinedIcon: Icons.shopping_cart_outlined,
                        label: 'Cart',
                      ),
                      _buildNavItem(
                        currentIndex: currentIndex,
                        index: 2,
                        filledIcon: Icons.person,
                        outlinedIcon: Icons.person_outline,
                        label: 'Profile',
                      ),
                      _buildNavItem(
                        currentIndex: currentIndex,
                        index: 3,
                        filledIcon: Icons.history,
                        outlinedIcon: Icons.history_outlined,
                        label: 'Orders',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required int currentIndex,
    required int index,
    required IconData filledIcon,
    required IconData outlinedIcon,
    required String label,
  }) {
    return BottomNavigationBarItem(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: child,
        ),
        child: Icon(
          currentIndex == index ? filledIcon : outlinedIcon,
          key: ValueKey(currentIndex == index),
          size: 28,
        ),
      ),
      label: label,
      tooltip: label,
    );
  }
}