import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  static const Color kOrange = Color(0xFFFF3008);

  @override
  Widget build(BuildContext context) {
    final loginCtrl = Get.find<LoginController>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Remove the default AppBar to replicate the screenshot more closely
      backgroundColor: Colors.white,
      body: Obx(() {
        if (loginCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // =============================
              // TOP ORANGE SECTION
              // =============================
              Container(
                width: double.infinity,
                height: size.height * 0.3, // ~30% of screen height
                color: kOrange,
                alignment: Alignment.center,
                child: const Text(
                  'zero',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // =============================
              // WHITE SECTION BELOW
              // =============================
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  children: [
                    // Tagline
                    const Text(
                      'Eat What Makes you happy',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Divider row with "Log in or Sign up"
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade400)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Log in or Signup',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                        const Text(
                          '...',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade400)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // =============================
                    // PHONE NUMBER FIELD
                    // =============================
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          // Simple Country Code (India +91)
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: '+91', // Default
                              items: const [
                                DropdownMenuItem(
                                  value: '+91',
                                  child: Text('🇮🇳 +91'),
                                ),
                                // Add other codes if needed
                              ],
                              onChanged: (value) {
                                // handle code change
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Enter Phone Number',
                                border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.phone,
                              onChanged: loginCtrl.updatePhoneNumber,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // =============================
                    // CONTINUE BUTTON
                    // =============================
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => loginCtrl.requestOtp(),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // =============================
                    // OR DIVIDER
                    // =============================
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                              color: Colors.grey.shade300, thickness: 1),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'or',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                              color: Colors.grey.shade300, thickness: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // =============================
                    // CONTINUE WITH GOOGLE
                    // =============================
                    // GestureDetector(
                    //   onTap: () {
                    //     // Handle Google sign in
                    //   },
                    //   child: Container(
                    //     width: double.infinity,
                    //     height: 50,
                    //     decoration: BoxDecoration(
                    //       border: Border.all(color: Colors.grey.shade300),
                    //       borderRadius: BorderRadius.circular(12),
                    //       color: Colors.white,
                    //     ),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         Image.asset(
                    //           'assets/images/google_logo.png', // Replace with actual google logo path
                    //           width: 24,
                    //           height: 24,
                    //         ),
                    //         const SizedBox(width: 8),
                    //         const Text(
                    //           'Continue with google',
                    //           style: TextStyle(
                    //             fontSize: 14,
                    //             color: Colors.black,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 20),

                    // =============================
                    // TERMS AND CONDITIONS
                    // =============================
                    const Text(
                      'By clicking you are agreed to Terms &\nConditions and Privacy Policy',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
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
