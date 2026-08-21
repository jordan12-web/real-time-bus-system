import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';
import '../theme/design_tokens.dart';
import '../widgets/gradient_background.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _busSlideAnimation;
  late final Animation<double> _textFadeAnimation;
  late final Animation<double> _textSlideAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _busSlideAnimation = Tween<double>(begin: -60.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _textSlideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.9, curve: Curves.easeOut),
      ),
    );

    _animController.forward();
    _navigationTimer = Timer(const Duration(milliseconds: 1100), () {
      _checkNavigation();
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkNavigation() async {
    if (!mounted) return;

    const storage = FlutterSecureStorage();
    final seenOnboarding = await storage.read(key: 'has_seen_onboarding');
    final token = await storage.read(key: 'access_token');

    if (!mounted) return;

    if (seenOnboarding != 'true') {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    } else if (token != null && token.isNotEmpty) {
      // User is logged in — restore session and go to TripList
      ref.read(authControllerProvider.notifier).refreshSession();
      Navigator.pushReplacementNamed(context, AppRoutes.tripList);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? DesignTokens.darkPrimary : DesignTokens.primary;
    final accent = isDark ? DesignTokens.darkAccent : DesignTokens.accent;

    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bus icon badge sliding in from the left
                    Transform.translate(
                      offset: Offset(_busSlideAnimation.value, 0),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primary, accent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.directions_bus_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceLg),
                    // "Guzo" script text fading and sliding in
                    Opacity(
                      opacity: _textFadeAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _textSlideAnimation.value),
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [primary, accent],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ).createShader(bounds),
                              child: const Text(
                                'Guzo',
                                style: TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: DesignTokens.spaceXs),
                            Text(
                              'Seamless Intercity Travel',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF64748B),
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceXl),
                    // Subtle loading progress indicator
                    Opacity(
                      opacity: _textFadeAnimation.value,
                      child: SizedBox(
                        width: 36,
                        height: 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            backgroundColor:
                                primary.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(primary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
