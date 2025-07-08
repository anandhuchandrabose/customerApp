import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  static const Color kOrange = Color(0xFFFF3008);
  static const Color kDarkGrey = Color(0xFF2A2A2A);

  @override
  Widget build(BuildContext context) {
    final loginCtrl = Get.find<LoginController>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Obx(() {
        if (loginCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: kOrange));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // =============================
              // Top Image Section with JPG
              // =============================
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: size.height * 0.4,
                    child: Image.asset(
                      'assets/img/icon.jpg', // Ensure this matches your file path
                      fit: BoxFit.cover,
                      color: Colors.black38, // Overlay for darkening
                      colorBlendMode: BlendMode.darken,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Text(
                              'Image Failed to Load',
                              style: TextStyle(color: Colors.red, fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Get.back(),
                            ),
                            Text(
                              'zero',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 48), // Balance the layout
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // =============================
              // Login Form Section
              // =============================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Text
                    Text(
                      'Let’s Get Started',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: kDarkGrey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in with your phone number',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // =============================
                    // Phone Number Field
                    // =============================
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: '+91',
                              items: const [
                                DropdownMenuItem(
                                  value: '+91',
                                  child: Text(
                                    '🇮🇳 +91',
                                    style: TextStyle(fontSize: 16, color: kDarkGrey),
                                  ),
                                ),
                              ],
                              onChanged: (value) {},
                              icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Phone Number',
                                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                                border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.phone,
                              onChanged: loginCtrl.updatePhoneNumber,
                              style: TextStyle(fontSize: 16, color: kDarkGrey),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // =============================
                    // Continue Button
                    // =============================
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          shadowColor: kOrange.withOpacity(0.4),
                        ),
                        onPressed: () => loginCtrl.requestOtp(),
                        child: const Text(
                          'Get OTP',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // =============================
                    // OR Divider
                    // =============================
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // =============================
                    // Terms and Conditions
                    // =============================
                    Text(
                      'By continuing, you agree to our Terms & Conditions\nand Privacy Policy',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}