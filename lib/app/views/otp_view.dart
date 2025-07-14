import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import '../controllers/otp_controller.dart';

class OtpView extends GetView<OtpController> {
  const OtpView({Key? key}) : super(key: key);

  static const Color kGrey = Color(0xFF8E8E93);
  static const Color kDarkGrey = Color(0xFF2A2A2A);
  static const Color kLightGrey = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    final otpCtrl = Get.find<OtpController>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kDarkGrey),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'OTP verification',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: kDarkGrey,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (otpCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: kGrey));
        }

        final phoneNumber = otpCtrl.phoneNumber.value;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // =============================
                // Info Text
                // =============================
                Text(
                  'We\'ve sent a verification code to',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: kGrey,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  phoneNumber,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: kDarkGrey,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),

                // DEV OTP (if present)
                if (otpCtrl.devOtp.value.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      'DEV OTP: ${otpCtrl.devOtp.value}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.red[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],

                // =============================
                // OTP Input Fields
                // =============================
                Pinput(
                  length: 4,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  defaultPinTheme: PinTheme(
                    width: 60,
                    height: 60,
                    textStyle: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: kDarkGrey,
                    ),
                    decoration: BoxDecoration(
                      color: kLightGrey,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.transparent),
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
                      color: kLightGrey,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kDarkGrey, width: 2),
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
                      color: kLightGrey,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                  ),
                  onChanged: (value) => otpCtrl.updateOtp(value),
                  onCompleted: (value) => otpCtrl.verifyOtp(),
                  keyboardType: TextInputType.number,
                  animationCurve: Curves.easeInOut,
                  animationDuration: const Duration(milliseconds: 200),
                ),
                const SizedBox(height: 40),

                // =============================
                // Resend OTP Timer
                // =============================
                Obx(() {
                  final remainingTime = otpCtrl.remainingTime.value;
                  if (remainingTime > 0) {
                    return Text(
                      'Resend OTP in $remainingTime',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: kGrey,
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  } else {
                    return GestureDetector(
                      onTap: () => otpCtrl.resendOtp(),
                      child: Text(
                        'Resend OTP',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: kDarkGrey,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    );
                  }
                }),
                const SizedBox(height: 100),

                // =============================
                // SMS Notification
                // =============================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kDarkGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'We have sent a verification code to you via SMS',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // =============================
                // Hidden Continue Button (for programmatic access)
                // =============================
                Opacity(
                  opacity: 0,
                  child: SizedBox(
                    width: double.infinity,
                    height: 0,
                    child: ElevatedButton(
                      onPressed: () {
                        final otp = currentOtp();
                        if (otp.length == 4) {
                          otpCtrl.updateOtp(otp);
                          otpCtrl.verifyOtp();
                        }
                      },
                      child: const SizedBox.shrink(),
                    ),
                  ),
                ),
              ],
            ),
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