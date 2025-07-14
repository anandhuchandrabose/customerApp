import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeOnboardingView extends StatefulWidget {
  const WelcomeOnboardingView({Key? key}) : super(key: key);

  @override
  State<WelcomeOnboardingView> createState() => _WelcomeOnboardingViewState();
}

class _WelcomeOnboardingViewState extends State<WelcomeOnboardingView> {
  PageController pageController = PageController();
  int currentPage = 0;

  static const Color kPrimary = Color(0xFF4CAF50);
  static const Color kDarkGrey = Color(0xFF2A2A2A);
  static const Color kLightGrey = Color(0xFFF5F5F5);
  static const Color kGrey = Color(0xFF8E8E93);

  final List<OnboardingItem> onboardingItems = [
    OnboardingItem(
      title: 'Explore the World',
      description: 'Discover dream destinations at your fingertips.',
      image: 'assets/images/explore.png', // Add your image
      backgroundColor: Color(0xFFE3F2FD),
    ),
    OnboardingItem(
      title: 'Plan with Ease',
      description: 'Effortlessly book flights, hotels, and more.',
      image: 'assets/images/plan.png', // Add your image
      backgroundColor: Color(0xFFE8F5E8),
    ),
    OnboardingItem(
      title: 'Live Every Moment',
      description: 'Capture and share unforgettable travel moments.',
      image: 'assets/images/moments.png', // Add your image
      backgroundColor: Color(0xFFFFF3E0),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final phoneNumber = Get.arguments?['phone'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 60),
                  GestureDetector(
                    onTap: () => _navigateToSignup(phoneNumber),
                    child: Text(
                      'Skip',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: kGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView for onboarding screens
            Expanded(
              child: PageView.builder(
                controller: pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemCount: onboardingItems.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    item: onboardingItems[index],
                    size: size,
                  );
                },
              ),
            ),

            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onboardingItems.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: currentPage == index ? kPrimary : kGrey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (currentPage < onboardingItems.length - 1) {
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _navigateToSignup(phoneNumber);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    currentPage < onboardingItems.length - 1 ? 'Next' : 'Get Started',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSignup(String phoneNumber) {
    Get.toNamed('/complete-signup', arguments: {'phone': phoneNumber});
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingItem item;
  final Size size;

  const OnboardingPage({
    Key? key,
    required this.item,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image container
          Container(
            width: size.width * 0.8,
            height: size.height * 0.4,
            decoration: BoxDecoration(
              color: item.backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: item.image.startsWith('assets/')
                  ? Image.asset(
                      item.image,
                      width: size.width * 0.6,
                      height: size.height * 0.3,
                      fit: BoxFit.contain,
                    )
                  : Icon(
                      Icons.image,
                      size: size.width * 0.3,
                      color: Colors.grey[400],
                    ),
            ),
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            item.title,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2A2A2A),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            item.description,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF8E8E93),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String image;
  final Color backgroundColor;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.image,
    required this.backgroundColor,
  });
}