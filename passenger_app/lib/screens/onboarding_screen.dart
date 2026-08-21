import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../routes/app_routes.dart';
import '../theme/design_tokens.dart';
import '../widgets/gradient_background.dart';
import '../widgets/polished_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _OnboardingData(
      icon: Icons.map_rounded,
      title: 'Explore Intercity Routes',
      description:
          'Search and compare scheduled bus trips across all major intercity routes with real-time departure schedules and transparent fares.',
      badgeColor: DesignTokens.primary,
    ),
    _OnboardingData(
      icon: Icons.airline_seat_recline_extra_rounded,
      title: 'Pick Your Favorite Seat',
      description:
          'Choose your exact seat from an interactive bus cabin layout and confirm your booking instantly with secure Chapa payment.',
      badgeColor: DesignTokens.accent,
    ),
    _OnboardingData(
      icon: Icons.qr_code_scanner_rounded,
      title: 'Live Tracking & Digital QR',
      description:
          'Track your bus location live with real-time GPS updates and board hassle-free using your digital QR boarding ticket.',
      badgeColor: DesignTokens.primary,
    ),
  ];

  Future<void> _finishOnboarding() async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'has_seen_onboarding', value: 'true');
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.signup);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with "Skip" button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceMd,
                  vertical: DesignTokens.spaceSm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isLastPage)
                      TextButton(
                        onPressed: _finishOnboarding,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: isDark
                                ? DesignTokens.darkPrimary
                                : DesignTokens.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 48),
                  ],
                ),
              ),

              // Page carousel
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spaceLg,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Visual badge container
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  slide.badgeColor.withValues(alpha: 0.2),
                                  slide.badgeColor.withValues(alpha: 0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: slide.badgeColor.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                slide.icon,
                                size: 64,
                                color: slide.badgeColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spaceXl),
                          Text(
                            slide.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spaceMd),
                          Text(
                            slide.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Dot Indicators + Action Button
              Padding(
                padding: const EdgeInsets.all(DesignTokens.spaceLg),
                child: Column(
                  children: [
                    // Dot indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (index) {
                        final isSelected = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isSelected ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                    ? DesignTokens.darkPrimary
                                    : DesignTokens.primary)
                                : (isDark
                                    ? Colors.white24
                                    : const Color(0xFFCBD5E1)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: DesignTokens.spaceLg),
                    // Action button
                    PolishedButton(
                      label: isLastPage ? 'Get Started' : 'Continue',
                      icon: isLastPage
                          ? Icons.arrow_forward_rounded
                          : Icons.chevron_right_rounded,
                      onPressed: () {
                        if (isLastPage) {
                          _finishOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final Color badgeColor;

  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.badgeColor,
  });
}
