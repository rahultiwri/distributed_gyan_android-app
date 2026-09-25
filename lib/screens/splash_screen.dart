
import 'dart:async';

import 'package:flutter/material.dart';

import '../views/splash/splash_screen_ui.dart';
import '../controllers/splash_controller.dart';

class SplashScreen extends StatefulWidget {
const SplashScreen({super.key});

@override
State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
with TickerProviderStateMixin {
late AnimationController _mainController;
late AnimationController _productController;
late AnimationController _milkController;
late AnimationController _footerController;

late Animation<double> _logoFade;
late Animation<double> _logoScale;
late Animation<Offset> _logoSlide;

late Animation<double> _textFade;
late Animation<Offset> _textSlide;

// Splash Controller
final SplashController _splashController =
SplashController();

@override
void initState() {
super.initState();

// ============================================================
// MAIN ANIMATION
// ============================================================

_mainController = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 1800),
);

_logoFade = CurvedAnimation(
parent: _mainController,
curve: const Interval(
0.0,
0.50,
curve: Curves.easeOut,
),
);

_logoScale = Tween<double>(
begin: 0.72,
end: 1.0,
).animate(
CurvedAnimation(
parent: _mainController,
curve: const Interval(
0.0,
0.65,
curve: Curves.easeOutBack,
),
),
);

_logoSlide = Tween<Offset>(
begin: const Offset(0, 0.10),
end: Offset.zero,
).animate(
CurvedAnimation(
parent: _mainController,
curve: const Interval(
0.0,
0.65,
curve: Curves.easeOutCubic,
),
),
);

_textFade = CurvedAnimation(
parent: _mainController,
curve: const Interval(
0.30,
0.80,
curve: Curves.easeIn,
),
);

_textSlide = Tween<Offset>(
begin: const Offset(0, 0.15),
end: Offset.zero,
).animate(
CurvedAnimation(
parent: _mainController,
curve: const Interval(
0.30,
0.85,
curve: Curves.easeOutCubic,
),
),
);

// ============================================================
// PRODUCT FLOW
// ============================================================

_productController = AnimationController(
vsync: this,
duration: const Duration(seconds: 10),
)..repeat();

// ============================================================
// MILK FLOW
// ============================================================

_milkController = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 2200),
)..repeat();

// ============================================================
// FOOTER
// ============================================================

_footerController = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 1400),
)..repeat();

// ============================================================
// START ANIMATION
// ============================================================

_mainController.forward();

// ============================================================
// START SPLASH LOGIC
// ============================================================

_startSplashFlow();
}

// ============================================================
// SPLASH FLOW
// ============================================================

// void _startSplashFlow() {
// Timer(const Duration(seconds: 2), () async {
// if (!mounted) return;
//
// // SharedPreferences check
// final hasSavedUrl =
// await _splashController.hasSavedUrl();
//
// if (!mounted) return;
//
// // ========================================================
// // URL SAVED
// // DIRECT LOGIN
// // ========================================================
//
// if (hasSavedUrl) {
// Navigator.pushReplacementNamed(
// context,
// '/login',
// );
//
// return;
// }
//
// // ========================================================
// // URL NOT SAVED
// // URL VALIDATION SCREEN
// // ========================================================
//
// Navigator.pushReplacementNamed(
// context,
// '/url-validation',
// );
// });
// }


  void _startSplashFlow() {
    Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;

      // ========================================================
      // CHECK URL
      // ========================================================

      final hasSavedUrl =
      await _splashController.hasSavedUrl();

      if (!mounted) return;

      // ========================================================
      // URL NOT SAVED
      // ========================================================

      if (!hasSavedUrl) {
        Navigator.pushReplacementNamed(
          context,
          '/url-validation',
        );

        return;
      }

      // ========================================================
      // URL SAVED
      // NOW CHECK REGISTRATION
      // ========================================================

      final registrationCompleted =
      await _splashController.isRegistrationCompleted();

      if (!mounted) return;

      // ========================================================
      // REGISTRATION NOT COMPLETED
      // ========================================================

      if (!registrationCompleted) {
        Navigator.pushReplacementNamed(
          context,
          '/device-registration',
        );

        return;
      }

      // ========================================================
      // REGISTRATION COMPLETED
      // DIRECT LOGIN
      // ========================================================

      Navigator.pushReplacementNamed(
        context,
        '/login',
      );
    });
  }

// ============================================================
// DISPOSE
// ============================================================

@override
void dispose() {
_mainController.dispose();
_productController.dispose();
_milkController.dispose();
_footerController.dispose();

super.dispose();
}

// ============================================================
// UI
// ============================================================

@override
Widget build(BuildContext context) {
return SplashScreenUI(
logoFade: _logoFade,
logoScale: _logoScale,
logoSlide: _logoSlide,
textFade: _textFade,
textSlide: _textSlide,
productController: _productController,
milkController: _milkController,
footerController: _footerController,
);
}
}

