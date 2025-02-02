// lib/app/views/otp_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/otp_controller.dart';

class OtpView extends GetView<OtpController> {
  const OtpView({Key? key}) : super(key: key);

  static const Color kOrange = Color(0xFFFF3008);

  @override
  Widget build(BuildContext context) {
    final otpCtrl = Get.find<OtpController>();
    final size = MediaQuery.of(context).size;

    // We'll store 4 separate TextEditingControllers for the OTP fields
    final textControllers = List.generate(4, (_) => TextEditingController());
    // We'll keep references to each FocusNode for auto-focus
    final focusNodes = List.generate(4, (_) => FocusNode());

    // A helper method to combine the 4 digits
    String currentOtp() {
      return textControllers.map((e) => e.text).join();
    }

    // Called when we type in any box
    void onChanged(int index, String value) {
      // If the user typed a digit, move focus to the next field
      if (value.isNotEmpty && index < 3) {
        focusNodes[index + 1].requestFocus();
      }
      // If cleared the field and we're not in the first index, move back
      else if (value.isEmpty && index > 0) {
        focusNodes[index - 1].requestFocus();
      }
      // Update the OTP in the controller
      otpCtrl.updateOtp(currentOtp());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (otpCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final phoneNumber = otpCtrl.phoneNumber.value;
        return SingleChildScrollView(
          child: Column(
            children: [
              // ====================================
              // Top Orange Header
              // ====================================
              Container(
                width: double.infinity,
                height: size.height * 0.3,
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

              // ====================================
              // White section with content
              // ====================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  children: [
                    // Show the OTP (for development only)
                    if (otpCtrl.devOtp.value.isNotEmpty) ...[
                      Text(
                        'DEV OTP: ${otpCtrl.devOtp.value}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Info text
                    Text(
                      'A 4 digit OTP has been sent to $phoneNumber',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),

                    // "Log in or Sign up" row
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Log in or Sign up',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ====================================
                    // 4 Individual TextFields in a row
                    // ====================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (index) {
                        return SizedBox(
                          width: 50,
                          child: TextField(
                            controller: textControllers[index],
                            focusNode: focusNodes[index],
                            maxLength: 1,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              counterText: '', // Hide the length counter
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: kOrange),
                              ),
                            ),
                            onChanged: (value) => onChanged(index, value),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    // Continue Button
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
                        onPressed: () {
                          // Combine the 4 digits
                          final otp = currentOtp();
                          // Trigger your verify logic
                          otpCtrl.updateOtp(otp);
                          otpCtrl.verifyOtp();
                        },
                        child: const Text(
                          'Continue',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Resend OTP row
                    GestureDetector(
                      onTap: () => otpCtrl.resendOtp(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Resend OTP',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: kOrange,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Example, if you have a countdown
                          const Text(
                            '(53s)',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Terms & Conditions
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
