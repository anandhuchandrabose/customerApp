// lib/app/views/splash_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import '../controllers/auth_service.dart';    
import '../middleware/auth_service.dart';
import 'design_system/colors.dart';           // optional

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Do the token check after a single frame so the UI can paint first
    Future.microtask(() async {
      await Future.delayed(const Duration(milliseconds: 800)); // splash delay
      final next = AuthService.token != null ? '/dashboard' : '/login';
      Get.offAllNamed(next);
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,      // or any color you like
      body: Center(
        child: Image.asset(
          'assets/img/icon.jpg',               // put your logo here
          width: 160,
        ),
      ),
    );
  }
}