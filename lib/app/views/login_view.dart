import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  static const Color kYellow = Color(0xFFF8D247);
  static const Color kGrey = Color(0xFF8E8E93);
  static const Color kDarkGrey = Color(0xFF2A2A2A);

  @override
  Widget build(BuildContext context) {
    final loginCtrl = Get.find<LoginController>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (loginCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: kYellow));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // =============================
              // Top Product Grid Section
              // =============================
              Container(
                height: size.height * 0.4,
                padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
                child: Column(
                  children: [
                    // Skip Login Button
                    Align(
                      alignment: Alignment.topRight,
                      // child: Container(
                      //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      //   decoration: BoxDecoration(
                      //     color: Colors.white,
                      //     borderRadius: BorderRadius.circular(20),
                      //     boxShadow: [
                      //       BoxShadow(
                      //         color: Colors.grey.withOpacity(0.2),
                      //         blurRadius: 8,
                      //         offset: const Offset(0, 2),
                      //       ),
                      //     ],
                      //   ),
                      //   child: const Text(
                      //     'Skip login',
                      //     style: TextStyle(
                      //       fontSize: 14,
                      //       fontWeight: FontWeight.w500,
                      //       color: kDarkGrey,
                      //     ),
                      //   ),
                      // ),
                    ),
                    // const SizedBox(height: 20),
                    
                    // Product Grid (4 rows x 3 columns)
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 3,
                        childAspectRatio: 1.0,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                          _buildProductCard('assets/img/vaporub.png', Colors.blue[50]!),
                          _buildProductCard('assets/img/banana.png', Colors.yellow[50]!),
                          _buildProductCard('assets/img/pampers.png', Colors.teal[50]!),
                          _buildProductCard('assets/img/daawat.png', Colors.orange[50]!),
                          _buildProductCard('assets/img/durex.png', Colors.red[50]!),
                          _buildProductCard('assets/img/icecream.png', Colors.blue[50]!),
                          _buildProductCard('assets/img/broccoli.png', Colors.green[50]!),
                          _buildProductCard('assets/img/nescafe.png', Colors.brown[50]!),
                          _buildProductCard('assets/img/spoon.png', Colors.orange[50]!),
                          _buildProductCard('assets/img/tata_tea.png', Colors.green[50]!),
                          _buildProductCard('assets/img/cocacola.png', Colors.red[50]!),
                          _buildProductCard('assets/img/jaggery.png', Colors.brown[50]!),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // =============================
              // Bottom Section
              // =============================
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Blinkit Logo
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
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Experience the Luxury of Home-Cooked Art',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: kDarkGrey,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    const Text(
                      'Log In or Sign Up',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: kGrey,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // =============================
                    // Phone Number Input Field
                    // =============================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          // Country Code
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: const Text(
                              '+91',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: kDarkGrey,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Phone Number Input
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Enter mobile number',
                                hintStyle: TextStyle(
                                  color: kGrey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                              ),
                              keyboardType: TextInputType.phone,
                              onChanged: loginCtrl.updatePhoneNumber,
                              style: const TextStyle(
                                fontSize: 16,
                                color: kDarkGrey,
                                fontWeight: FontWeight.w500,
                              ),
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
                          backgroundColor: const Color(0xFFFF3008),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => loginCtrl.requestOtp(),
                        child: const Text(
                          'Continue',
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

  Widget _buildProductCard(String imagePath, Color backgroundColor) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to colored container if image fails to load
            return Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.grey,
                size: 30,
              ),
            );
          },
        ),
      ),
    );
  }
}