import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/complete_signup_controller.dart';

class CompleteSignupView extends GetView<CompleteSignupController> {
  const CompleteSignupView({Key? key}) : super(key: key);

  static const Color kYellow = Color(0xFFF8D247);
  static const Color kGrey = Color(0xFF8E8E93);
  static const Color kDarkGrey = Color(0xFF2A2A2A);

  @override
  Widget build(BuildContext context) {
    final signupCtrl = Get.find<CompleteSignupController>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (signupCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: kYellow));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // =============================
              // Top Section with Back Button
              // =============================
              Container(
                height: size.height * 0.4,
                padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
                child: Column(
                  children: [
                    // Back Button
                    Align(
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: kDarkGrey,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Fresmo Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3008),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          'Fresmo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Complete your profile',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color:  Color(0xFFFF3008),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    const Text(
                      'We need a few more details to get you started',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: kGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // =============================
              // Form Section
              // =============================
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // =============================
                    // First Name Input Field
                    // =============================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'First Name',
                          hintStyle: TextStyle(
                            color: kGrey,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        onChanged: signupCtrl.updateFirstName,
                        style: const TextStyle(
                          fontSize: 16,
                          color: kDarkGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // =============================
                    // Last Name Input Field
                    // =============================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Last Name',
                          hintStyle: TextStyle(
                            color: kGrey,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        onChanged: signupCtrl.updateLastName,
                        style: const TextStyle(
                          fontSize: 16,
                          color: kDarkGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // =============================
                    // Complete Signup Button
                    // =============================
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => signupCtrl.completeSignup(),
                        child: const Text(
                          'Complete Signup',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // =============================
                    // Terms and Conditions
                    // =============================
                    Text(
                      'By continuing, you agree to our Terms of service & Privacy policy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
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