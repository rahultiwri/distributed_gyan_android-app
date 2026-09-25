import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'views/url_validation/url_validation_screen.dart';
import 'views/device_registration/device_registration_screen.dart';

import 'views/login/login_screen.dart';
import 'views/menu/menu_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const GyanMilkApp());
}

class GyanMilkApp extends StatelessWidget {
  const GyanMilkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Distributor Demand',

      // ==========================================================
      // ROUTES
      // ==========================================================

      initialRoute: '/',

      routes: {
        // Splash
        '/': (context) => const SplashScreen(),

        // URL Validation
        '/url-validation': (context) =>
        const UrlValidationScreen(),

        // Device Registration
        '/device-registration': (context) =>
        const DeviceRegistrationScreen(),

        // // OTP Verification
        // '/otp': (context) =>
        // const OtpScreen(),

        // Login
        '/login': (context) =>
        const LoginScreen(),

        // Menu
        '/menu': (context) =>
        const MenuScreen(),
      },
    );
  }
}