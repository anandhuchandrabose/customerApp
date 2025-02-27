import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import '../controllers/otp_controller.dart';

class OtpView extends GetView<OtpController> {
  const OtpView({Key? key}) : super(key: key);

  static const Color kOrange = Color(0xFFFF3008);
  static const Color kDarkGrey = Color(0xFF2A2A2A);

  @override
  Widget build(BuildContext context) {
    final otpCtrl = Get.find<OtpController>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Obx(() {
        if (otpCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: kOrange));
        }

        final phoneNumber = otpCtrl.phoneNumber.value;

        return SingleChildScrollView(
          child: Column(
            children: [
              // =============================
              // Top Header with Gradient
              // =============================
              Container(
                width: double.infinity,
                height: size.height * 0.25,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kOrange, kOrange.withOpacity(0.9)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'zero',
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Verify Your Number',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // =============================
              // OTP Form Section
              // =============================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Info Text
                    Text(
                      'Enter the 4-digit OTP sent to',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: kDarkGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phoneNumber,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: kDarkGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // DEV OTP (if present)
                    if (otpCtrl.devOtp.value.isNotEmpty) ...[
                      Text(
                        'DEV OTP: ${otpCtrl.devOtp.value}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 24),

                    // =============================
                    // Pinput OTP Field
                    // =============================
                    Pinput(
                      length: 4,
                      defaultPinTheme: PinTheme(
                        width: 60,
                        height: 60,
                        textStyle: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: kDarkGrey,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 60,
                        height: 60,
                        textStyle: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: kDarkGrey,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: kOrange.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      submittedPinTheme: PinTheme(
                        width: 60,
                        height: 60,
                        textStyle: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: kDarkGrey,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: kOrange.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      onChanged: (value) => otpCtrl.updateOtp(value),
                      onCompleted: (value) => otpCtrl.verifyOtp(),
                      keyboardType: TextInputType.number,
                      animationCurve: Curves.easeInOut,
                      animationDuration: const Duration(milliseconds: 200),
                    ),
                    const SizedBox(height: 32),

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
                        onPressed: () {
                          final otp = currentOtp(); // Use local method to get OTP
                          if (otp.length == 4) {
                            otpCtrl.updateOtp(otp); // Update controller with OTP
                            otpCtrl.verifyOtp();
                          }
                        },
                        child: Text(
                          'Verify OTP',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // =============================
                    // Resend OTP
                    // =============================
                    GestureDetector(
                      onTap: () => otpCtrl.resendOtp(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Resend OTP',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: kOrange,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(53s)',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // =============================
                    // Terms and Conditions
                    // =============================
                    Text(
                      'By continuing, you agree to our Terms & Conditions\nand Privacy Policy',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
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

  // Local method to get OTP from Pinput
  String currentOtp() {
    final otpCtrl = Get.find<OtpController>();
    return otpCtrl.otp.value; // Assuming otp is defined in OtpController
  }
}