import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/flagsmith_service.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';
import 'webview_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  Timer? _watchdogTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();

    // Absolute failsafe watchdog: guarantees navigation away from splash within 2.0s
    _watchdogTimer = Timer(const Duration(milliseconds: 2000), () {
      _navigateToNext(null);
    });

    _initApp();
  }

  @override
  void dispose() {
    _watchdogTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _navigateToNext(String? webviewUrl) {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    _watchdogTimer?.cancel();

    if (webviewUrl != null &&
        webviewUrl.isNotEmpty &&
        webviewUrl.startsWith('http')) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AppWebViewScreen(initialUrl: webviewUrl),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(),
        ),
      );
    }
  }

  Future<void> _initApp() async {
    final stopwatch = Stopwatch()..start();
    String? webviewUrl;

    try {
      // Fetch target URL based on IP GEO & Flagsmith config (strict 1.2s timeout)
      webviewUrl = await FlagsmithService.checkWebviewUrl()
          .timeout(const Duration(milliseconds: 1200));
    } catch (_) {
      webviewUrl = null;
    }

    // Keep splash visible for at least 1.0 second for smooth aesthetic animation
    final elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed < 1000) {
      await Future.delayed(Duration(milliseconds: 1000 - elapsed));
    }

    _navigateToNext(webviewUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppTheme.neonGlow,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/app_icon.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppTheme.surfaceCard,
                            child: const Icon(
                              Icons.bolt,
                              size: 48,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'ОЛИМ',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
