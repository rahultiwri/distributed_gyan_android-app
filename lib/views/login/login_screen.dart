
//  logic  implement login screen

// import 'package:flutter/material.dart';
//
// import '../../controllers/login_controller.dart';
// import '../../services/device_login_service.dart';
// import '../../services/preference_service.dart';
//
// class LoginScreen extends StatefulWidget {
// const LoginScreen({
// super.key,
// });
//
// @override
// State<LoginScreen> createState() =>
// _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
// late final LoginController controller;
//
// final TextEditingController userIdController =
// TextEditingController();
//
// final TextEditingController passwordController =
// TextEditingController();
//
// bool loading = false;
// bool obscurePassword = true;
// bool rememberMe = false;
//
// @override
// void initState() {
// super.initState();
//
// controller = LoginController();
//
// _loadRememberedLogin();
// }
//
// // ==========================================================
// // LOAD REMEMBERED LOGIN
// // ==========================================================
//
//   // autofill userid and password
//
// // Future<void> _loadRememberedLogin() async {
// // final savedRememberMe =
// // await PreferenceService.isRememberMe();
// //
// // if (!savedRememberMe) {
// // return;
// // }
// //
// // final savedUserId =
// // await PreferenceService.getUserId();
// //
// // final savedPassword =
// // await PreferenceService.getPassword();
// //
// // if (!mounted) return;
// //
// // setState(() {
// // rememberMe = true;
// //
// // if (savedUserId != null) {
// // userIdController.text = savedUserId;
// // }
// //
// // if (savedPassword != null) {
// // passwordController.text = savedPassword;
// // }
// // });
// // }
//
//
//   Future<void> _loadRememberedLogin() async {
//     final savedRememberMe =
//     await PreferenceService.isRememberMe();
//
//     if (!savedRememberMe) {
//       return;
//     }
//
//     final savedUserId =
//     await PreferenceService.getUserId();
//
//     if (!mounted) return;
//
//     setState(() {
//       rememberMe = true;
//
//       if (savedUserId != null) {
//         userIdController.text = savedUserId;
//       }
//     });
//   }
//
//
//
// // ==========================================================
// // LOGIN
// // ==========================================================
//
// Future<void> login() async {
// final userId =
// userIdController.text.trim();
//
// final password =
// passwordController.text;
//
// if (userId.isEmpty || password.isEmpty) {
// ScaffoldMessenger.of(context).showSnackBar(
// const SnackBar(
// content: Text(
// 'Please enter User ID and Password',
// ),
// ),
// );
// return;
// }
//
// setState(() {
// loading = true;
// });
//
// try {
// // ======================================================
// // CHECK WHETHER DEVICE LOGIN WAS ALREADY VERIFIED
// // ======================================================
//
// final deviceLoginVerified =
// await PreferenceService.isDeviceLoginVerified();
//
// bool success = false;
//
// if (deviceLoginVerified) {
// // ====================================================
// // ALREADY VERIFIED
// // DO NOT CALL GET API AGAIN
// // ====================================================
//
// debugPrint(
// 'Device Login already verified. '
// 'GET verification API will NOT be called.',
// );
//
// success = await controller.login(
// userId: userId,
// password: password,
// );
// } else {
// // ====================================================
// // FIRST LOGIN AFTER DEVICE REGISTRATION
// // CALL GET API
// // ====================================================
//
// debugPrint(
// 'First Device Login verification. '
// 'Calling GET verification API.',
// );
//
// final response =
// await DeviceLoginService.verifyLogin(
// userId: userId,
// password: password,
// );
//
// // ====================================================
// // SUCCESS RESPONSE
// // ====================================================
//
// if (response.trim() == 'Successfull') {
// debugPrint(
// 'Device Login verification successful.',
// );
//
// // Save User ID + Password only after
// // successful server verification.
// await PreferenceService.saveLoginCredentials(
// userId: userId,
// password: password,
// );
//
// // Mark device login as verified.
// // From next login, GET API will NOT be called.
// await PreferenceService.saveDeviceLoginVerified(
// true,
// );
//
// // Save Remember Me preference.
// await PreferenceService.saveRememberMe(
// rememberMe,
// );
//
// success = true;
// } else {
// // ==================================================
// // SERVER RETURNED ERROR
// // SHOW EXACT SERVER RESPONSE
// // ==================================================
//
// if (!mounted) return;
//
// await _showServerResponse(response);
//
// return;
// }
// }
//
// if (!mounted) return;
//
// // ======================================================
// // LOCAL LOGIN SUCCESS
// // ======================================================
//
// if (success) {
// // Remember Me preference is updated here also
// // for already verified login.
// await PreferenceService.saveRememberMe(
// rememberMe,
// );
//
// if (!rememberMe) {
// // Do not remove the verified status.
// // Only Remember Me preference is disabled.
// await PreferenceService.saveRememberMe(
// false,
// );
// }
//
// Navigator.pushNamedAndRemoveUntil(
// context,
// '/menu',
// (route) => false,
// );
//
// return;
// }
//
// // ======================================================
// // LOCAL LOGIN FAILED
// // ======================================================
//
// await _showServerResponse(
// 'Invalid User ID or Password',
// );
// } catch (e) {
// if (!mounted) return;
//
// await _showServerResponse(
// e.toString(),
// );
// } finally {
// if (mounted) {
// setState(() {
// loading = false;
// });
// }
// }
// }
//
// // ==========================================================
// // SERVER RESPONSE POPUP
// // ==========================================================
//
// Future<void> _showServerResponse(
// String message,
// ) async {
// await showDialog<void>(
// context: context,
// builder: (context) {
// return AlertDialog(
// title: const Text(
// 'Login Response',
// ),
// content: Text(
// message.isEmpty
// ? 'Empty response received from server.'
//     : message,
// ),
// actions: [
// TextButton(
// onPressed: () {
// Navigator.of(context).pop();
// },
// child: const Text('OK'),
// ),
// ],
// );
// },
// );
// }
//
// // ==========================================================
// // RESET
// // ==========================================================
//
// void reset() {
// userIdController.clear();
// passwordController.clear();
//
// setState(() {
// obscurePassword = true;
// });
// }
//
// @override
// Widget build(BuildContext context) {
// return Scaffold(
// body: Container(
// width: double.infinity,
// height: double.infinity,
// decoration: const BoxDecoration(
// gradient: LinearGradient(
// begin: Alignment.topLeft,
// end: Alignment.bottomRight,
// colors: [
// Color(0xFFE5F8FF),
// Color(0xFF9BDEF5),
// Color(0xFF62C3E8),
// Color(0xFF4B2395),
// ],
// stops: [
// 0.0,
// 0.43,
// 0.70,
// 1.0,
// ],
// ),
// ),
// child: Stack(
// children: [
// Positioned(
// top: -100,
// right: -80,
// child: Container(
// width: 260,
// height: 260,
// decoration: BoxDecoration(
// shape: BoxShape.circle,
// color: Colors.white.withOpacity(0.18),
// ),
// ),
// ),
//
// Positioned(
// top: 180,
// left: -100,
// child: Container(
// width: 220,
// height: 220,
// decoration: BoxDecoration(
// shape: BoxShape.circle,
// color: Colors.white.withOpacity(0.10),
// ),
// ),
// ),
//
// Positioned(
// top: 100,
// right: 45,
// child: _drop(18),
// ),
//
// Positioned(
// top: 240,
// left: 35,
// child: _drop(13),
// ),
//
// Positioned(
// bottom: 170,
// right: 30,
// child: _drop(12),
// ),
//
// Positioned(
// bottom: 100,
// left: 55,
// child: _drop(20),
// ),
//
// SafeArea(
// child: LayoutBuilder(
// builder: (
// context,
// constraints,
// ) {
// return SingleChildScrollView(
// padding: const EdgeInsets.symmetric(
// horizontal: 20,
// vertical: 20,
// ),
// child: ConstrainedBox(
// constraints: const BoxConstraints(
// maxWidth: 500,
// ),
// child: Column(
// crossAxisAlignment:
// CrossAxisAlignment.center,
// children: [
// const SizedBox(height: 55),
//
// Container(
// width: 88,
// height: 88,
// decoration: BoxDecoration(
// color: Colors.white.withOpacity(0.94),
// shape: BoxShape.circle,
// boxShadow: [
// BoxShadow(
// color: Colors.black
//     .withOpacity(0.12),
// blurRadius: 25,
// offset: const Offset(
// 0,
// 10,
// ),
// ),
// ],
// ),
// child: const Icon(
// Icons.person_rounded,
// size: 48,
// color: Color(0xFF4B2395),
// ),
// ),
//
// const SizedBox(height: 24),
//
// const Text(
// 'Welcome Back',
// textAlign: TextAlign.center,
// style: TextStyle(
// fontSize: 28,
// fontWeight: FontWeight.w800,
// color: Color(0xFF4B2395),
// ),
// ),
//
// const SizedBox(height: 8),
//
// const Text(
// 'Login to continue to your account',
// textAlign: TextAlign.center,
// style: TextStyle(
// fontSize: 14,
// fontWeight: FontWeight.w500,
// color: Color(0xFF36566A),
// ),
// ),
//
// const SizedBox(height: 28),
//
// Container(
// width: double.infinity,
// padding: const EdgeInsets.all(20),
// decoration: BoxDecoration(
// color:
// Colors.white.withOpacity(0.94),
// borderRadius:
// BorderRadius.circular(24),
// boxShadow: [
// BoxShadow(
// color: Colors.black
//     .withOpacity(0.12),
// blurRadius: 25,
// offset: const Offset(
// 0,
// 12,
// ),
// ),
// ],
// ),
// child: Column(
// children: [
// _buildTextField(
// controller:
// userIdController,
// label: 'User ID',
// hint: 'Enter your User ID',
// icon: Icons
//     .person_outline_rounded,
// ),
//
// const SizedBox(height: 16),
//
// _buildTextField(
// controller:
// passwordController,
// label: 'Password',
// hint:
// 'Enter your password',
// icon: Icons
//     .lock_outline_rounded,
// obscureText:
// obscurePassword,
// suffixIcon:
// IconButton(
// onPressed: () {
// setState(() {
// obscurePassword =
// !obscurePassword;
// });
// },
// icon: Icon(
// obscurePassword
// ? Icons
//     .visibility_off_outlined
//     : Icons
//     .visibility_outlined,
// color: const Color(
// 0xFF4B2395,
// ),
// ),
// ),
// ),
//
// const SizedBox(height: 8),
//
// // ==================================================
// // REMEMBER ME
// // ==================================================
//
// Align(
// alignment:
// Alignment.centerLeft,
// child: CheckboxListTile(
// contentPadding:
// EdgeInsets.zero,
// dense: true,
// controlAffinity:
// ListTileControlAffinity
//     .leading,
// title: const Text(
// 'Remember Me',
// style: TextStyle(
// fontSize: 14,
// fontWeight:
// FontWeight.w600,
// color:
// Color(0xFF36566A),
// ),
// ),
// value: rememberMe,
// activeColor:
// const Color(
// 0xFF4B2395,
// ),
// onChanged: loading
// ? null
//     : (value) {
// setState(() {
// rememberMe =
// value ?? false;
// });
// },
// ),
// ),
//
// const SizedBox(height: 16),
//
// Row(
// children: [
// Expanded(
// child: SizedBox(
// height: 55,
// child:
// OutlinedButton(
// onPressed: loading
// ? null
//     : reset,
// style:
// OutlinedButton
//     .styleFrom(
// foregroundColor:
// const Color(
// 0xFF4B2395,
// ),
// side:
// const BorderSide(
// color: Color(
// 0xFF4B2395,
// ),
// width: 1.5,
// ),
// shape:
// RoundedRectangleBorder(
// borderRadius:
// BorderRadius
//     .circular(
// 16,
// ),
// ),
// ),
// child: const Text(
// 'RESET',
// style: TextStyle(
// fontSize: 15,
// fontWeight:
// FontWeight.w700,
// ),
// ),
// ),
// ),
// ),
//
// const SizedBox(width: 12),
//
// Expanded(
// child: SizedBox(
// height: 55,
// child:
// ElevatedButton(
// onPressed: loading
// ? null
//     : login,
// style:
// ElevatedButton
//     .styleFrom(
// backgroundColor:
// const Color(
// 0xFF4B2395,
// ),
// foregroundColor:
// Colors.white,
// elevation: 5,
// shadowColor:
// const Color(
// 0xFF4B2395,
// ).withOpacity(0.35),
// shape:
// RoundedRectangleBorder(
// borderRadius:
// BorderRadius
//     .circular(
// 16,
// ),
// ),
// ),
// child: loading
// ? const SizedBox(
// width: 22,
// height: 22,
// child:
// CircularProgressIndicator(
// strokeWidth:
// 2.5,
// color:
// Colors.white,
// ),
// )
//     : const Text(
// 'LOGIN',
// style:
// TextStyle(
// fontSize: 15,
// fontWeight:
// FontWeight
//     .w700,
// ),
// ),
// ),
// ),
// ),
// ],
// ),
// ],
// ),
// ),
//
// const SizedBox(height: 24),
//
// Row(
// mainAxisAlignment:
// MainAxisAlignment.center,
// children: const [
// Icon(
// Icons
//     .verified_user_outlined,
// size: 17,
// color: Colors.white,
// ),
// SizedBox(width: 7),
// Flexible(
// child: Text(
// 'Your account information is securely protected',
// textAlign:
// TextAlign.center,
// style: TextStyle(
// color: Colors.white,
// fontSize: 12.5,
// fontWeight:
// FontWeight.w500,
// ),
// ),
// ),
// ],
// ),
//
// const SizedBox(height: 15),
// ],
// ),
// ),
// );
// },
// ),
// ),
// ],
// ),
// ),
// );
// }
//
// // ==========================================================
// // TEXT FIELD
// // ==========================================================
//
// Widget _buildTextField({
// required TextEditingController controller,
// required String label,
// required String hint,
// required IconData icon,
// bool obscureText = false,
// Widget? suffixIcon,
// }) {
// return SizedBox(
// height: 64,
// child: TextField(
// controller: controller,
// obscureText: obscureText,
// style: const TextStyle(
// fontSize: 15,
// fontWeight: FontWeight.w600,
// color: Color(0xFF263746),
// ),
// decoration: InputDecoration(
// labelText: label,
// hintText: hint,
// prefixIcon: Icon(
// icon,
// color: const Color(0xFF4B2395),
// ),
// suffixIcon: suffixIcon,
// filled: true,
// fillColor: const Color(0xFFF8FCFF),
// labelStyle: const TextStyle(
// color: Color(0xFF4B2395),
// fontWeight: FontWeight.w600,
// ),
// hintStyle: const TextStyle(
// color: Color(0xFF91A3AF),
// fontSize: 13.5,
// ),
// contentPadding:
// const EdgeInsets.symmetric(
// horizontal: 18,
// vertical: 18,
// ),
// enabledBorder:
// OutlineInputBorder(
// borderRadius:
// BorderRadius.circular(18),
// borderSide: BorderSide(
// color: const Color(0xFFB8DCEB)
//     .withOpacity(0.8),
// width: 1,
// ),
// ),
// focusedBorder:
// OutlineInputBorder(
// borderRadius:
// BorderRadius.circular(18),
// borderSide: const BorderSide(
// color: Color(0xFF4B2395),
// width: 1.7,
// ),
// ),
// border: OutlineInputBorder(
// borderRadius:
// BorderRadius.circular(18),
// ),
// ),
// ),
// );
// }
//
// // ==========================================================
// // DECORATIVE DROP
// // ==========================================================
//
// Widget _drop(double size) {
// return Container(
// width: size,
// height: size,
// decoration: BoxDecoration(
// color: Colors.white.withOpacity(0.25),
// shape: BoxShape.circle,
// ),
// );
// }
//
// @override
// void dispose() {
// userIdController.dispose();
// passwordController.dispose();
// super.dispose();
// }
// }
//





// ui modify in login screen
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../controllers/login_controller.dart';
import '../../services/device_login_service.dart';
import '../../services/preference_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // ==========================================================
  // THEME — milk / dairy palette
  // ==========================================================
  static const Color deepBlue = Color(0xFF0C447C);
  static const Color midBlue = Color(0xFF185FA5);
  static const Color lightBlue = Color(0xFF2E93CE);
  static const Color skyBlueBg1 = Color(0xFFEEF8FF);
  static const Color skyBlueBg2 = Color(0xFFDCF0FA);
  static const Color skyBlueBg3 = Color(0xFFC3E6F5);
  static const Color mintBg = Color(0xFFD9F0E6);
  static const Color mint = Color(0xFF1D9E75);
  static const Color textDark = Color(0xFF1B1E30);
  static const Color textMuted = Color(0xFF8B93A3);

  late final LoginController controller;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FocusNode userIdFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  // Entrance animation for the card.
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // Background wave drift.
  late final AnimationController _waveController;

  // Floating milk drops bobbing.
  late final AnimationController _dropsController;

  // Logo shimmer sweep + glow pulse.
  late final AnimationController _logoController;

  bool loading = false;
  bool obscurePassword = true;
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();

    controller = LoginController();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(_fadeAnim);

    // ==========================================================
    // WAVE ANIMATION
    // ==========================================================

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )
      ..repeat();

    // ==========================================================
    // FLOATING DROPS ANIMATION
    // ==========================================================

    _dropsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )
      ..repeat();

    // ==========================================================
    // LOGO ANIMATION
    // ==========================================================

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )
      ..repeat();

    _loadRememberedLogin();
    _entranceController.forward();
  }

  // ==========================================================
  // LOAD REMEMBERED LOGIN
  // ==========================================================

  Future<void> _loadRememberedLogin() async {
    final savedRememberMe = await PreferenceService.isRememberMe();

    if (!savedRememberMe) return;

    final savedUserId = await PreferenceService.getUserId();
    final savedPassword = await PreferenceService.getPassword();

    if (!mounted) return;

    setState(() {
      rememberMe = true;

      // Only User ID is auto-filled.
      // Password is intentionally left blank.
      if (savedUserId != null) {
        userIdController.text = savedUserId;
      }
       //  Only Password is auto-filled.
      if (savedPassword != null) {
        passwordController.text = savedPassword;
      }
    });
  }

  // ==========================================================
  // LOGIN
  // ==========================================================

  Future<void> login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final userId = userIdController.text.trim();
    final password = passwordController.text;

    setState(() => loading = true);

    try {
      final deviceLoginVerified =
      await PreferenceService.isDeviceLoginVerified();

      bool success = false;

      if (deviceLoginVerified) {
        // Already verified on this device — skip the GET verification call.
        debugPrint('Device Login already verified.');
        debugPrint('GET verification API will NOT be called.');

        success = await controller.login(
          userId: userId,
          password: password,
        );
      } else {
        // First login after device registration — verify via GET API.
        debugPrint('First Device Login verification.');
        debugPrint('Calling GET verification API.');

        final response = await DeviceLoginService.verifyLogin(
          userId: userId,
          password: password,
        );

        if (response.trim() == 'Successfull') {
          debugPrint('Device Login verification successful.');

          await PreferenceService.saveLoginCredentials(
            userId: userId,
            password: password,
          );

          await PreferenceService.saveDeviceLoginVerified(true);
          await PreferenceService.saveRememberMe(rememberMe);

          success = true;
        } else {
          if (!mounted) return;

          await _showServerResponse(response);

          return;
        }
      }

      if (!mounted) return;

      if (success) {
        await PreferenceService.saveRememberMe(rememberMe);

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/menu',
              (route) => false,
        );

        return;
      }

      await _showServerResponse(
        'Invalid User ID or Password',
      );
    } catch (e) {
      if (!mounted) return;

      await _showServerResponse(
        e.toString(),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  // ==========================================================
  // SERVER RESPONSE POPUP
  // ==========================================================

  Future<void> _showServerResponse(String message,) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Login Response',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            message.isEmpty
                ? 'Empty response received from server.'
                : message,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // RESET
  // ==========================================================

  void reset() {
    userIdController.clear();
    passwordController.clear();

    _formKey.currentState?.reset();

    setState(() {
      obscurePassword = true;
    });
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      backgroundColor: skyBlueBg1,
      body: Stack(
        children: [
          _buildBackground(size),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 460,
                  ),
                  child: Column(
                    children: [
                      _buildBrandHeader(),

                      const SizedBox(height: 24),

                      FadeTransition(
                        opacity: _fadeAnim,
                        child: SlideTransition(
                          position: _slideAnim,
                          child: Column(
                            children: [
                              _buildLoginCard(),

                              const SizedBox(height: 14),

                              _buildSecurityFooter(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BACKGROUND — gradient + animated waves + floating drops
  // ==========================================================

  Widget _buildBackground(Size size) {
    return Positioned.fill(
      child: Stack(
        children: [
          // ======================================================
          // BASE GRADIENT
          // ======================================================

          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  skyBlueBg1,
                  skyBlueBg2,
                  skyBlueBg3,
                  mintBg,
                ],
                stops: [
                  0.0,
                  0.3,
                  0.55,
                  1.0,
                ],
              ),
            ),
          ),

          // ======================================================
          // ANIMATED WAVES
          // ======================================================

          SizedBox(
            width: size.width,
            height: size.height * 0.3,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _WavesPainter(
                    progress: _waveController.value,
                  ),
                  size: Size(
                    size.width,
                    size.height * 0.3,
                  ),
                );
              },
            ),
          ),

          // ======================================================
          // FLOATING MILK DROPS
          // ======================================================

          AnimatedBuilder(
            animation: _dropsController,
            builder: (context, _) {
              final t =
                  _dropsController.value * 2 * math.pi;

              return Stack(
                children: [
                  _floatingDrop(
                    left: size.width * 0.08,
                    top: size.height * 0.16,
                    dropSize: 18,
                    color: lightBlue,
                    opacity: 0.55,
                    phase: t,
                    amplitude: 12,
                  ),

                  _floatingDrop(
                    right: size.width * 0.09,
                    top: size.height * 0.24,
                    dropSize: 13,
                    color: mint,
                    opacity: 0.5,
                    phase: t + 1.4,
                    amplitude: 10,
                  ),

                  _floatingDrop(
                    left: size.width * 0.13,
                    bottom: size.height * 0.22,
                    dropSize: 10,
                    color: lightBlue,
                    opacity: 0.4,
                    phase: t + 2.6,
                    amplitude: 8,
                  ),

                  _floatingDrop(
                    right: size.width * 0.18,
                    bottom: size.height * 0.34,
                    dropSize: 9,
                    color: mint,
                    opacity: 0.35,
                    phase: t + 3.8,
                    amplitude: 7,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FLOATING DROP
  // ==========================================================

  Widget _floatingDrop({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required double dropSize,
    required Color color,
    required double opacity,
    required double phase,
    required double amplitude,
  }) {
    final dy = math.sin(phase) * amplitude;

    final rotation =
        math.sin(phase) * 0.08;

    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Transform.translate(
        offset: Offset(0, dy),
        child: Transform.rotate(
          angle: rotation,
          child: Opacity(
            opacity: opacity,
            child: CustomPaint(
              size: Size(
                dropSize,
                dropSize * 1.4,
              ),
              painter: _RaindropPainter(
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // BRAND HEADER — logo with shimmer + glow
  // ==========================================================

  Widget _buildBrandHeader() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _logoController,
          builder: (context, _) {
            final t = _logoController.value;

            // Smooth 0 -> 1 -> 0 glow.
            final glow =
                (math.sin(t * 2 * math.pi) + 1) / 2;

            final blur =
                36 + glow * 8;

            final glowOpacity =
                0.18 + glow * 0.16;

            return Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(28),
                gradient:
                const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    skyBlueBg1,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                    lightBlue.withOpacity(
                      glowOpacity,
                    ),
                    blurRadius: blur,
                    offset: const Offset(
                      0,
                      18,
                    ),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius:
                BorderRadius.circular(28),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // ==================================================
                    // GYAN DAIRY LOGO (actual image asset)
                    // ==================================================

                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Image.asset(
                        'assets/images/Gyan_dairy_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    // ==================================================
                    // SHIMMER
                    // ==================================================

                    Positioned.fill(
                      child: _ShimmerSweep(
                        progress: t,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 15),

        const Text(
          'Gyan Dairy',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
            color: deepBlue,
          ),
        ),

        const SizedBox(height: 3),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.95),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: deepBlue.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Text(
            'DISTRIBUTOR DEMAND',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // LOGIN CARD
  // ==========================================================

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        26,
        20,
        24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: deepBlue.withOpacity(0.18),
            blurRadius: 48,
            offset: const Offset(0, 24),
          ),
          BoxShadow(
            color: deepBlue.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(13),
                    gradient:
                    const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE6F1FB),
                        Color(0xFFD3E9FA),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.water_drop_outlined,
                    size: 21,
                    color: midBlue,
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back!',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight:
                          FontWeight.w800,
                          color: textDark,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Let's get your order rolling",
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight:
                          FontWeight.w500,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            _buildUserIdField(),

            const SizedBox(height: 14),

            _buildPasswordField(),

            const SizedBox(height: 14),

            _buildRememberMe(),

            const SizedBox(height: 22),

            _buildActionButtons(),

            const SizedBox(height: 20),

            // _buildSecurityFooter(),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // USER ID FIELD
  // ==========================================================

  Widget _buildUserIdField() {
    return _buildTextField(
      controller: userIdController,
      focusNode: userIdFocus,
      label: 'User ID',
      hint: 'Enter User ID',
      icon: Icons.person_outline_rounded,
      textInputAction:
      TextInputAction.next,
      onFieldSubmitted: (_) =>
          FocusScope.of(context)
              .requestFocus(
            passwordFocus,
          ),
      validator: (value) {
        if (value == null ||
            value
                .trim()
                .isEmpty) {
          return 'Please enter your User ID';
        }

        return null;
      },
    );
  }

  // ==========================================================
  // PASSWORD FIELD
  // ==========================================================

  Widget _buildPasswordField() {
    return _buildTextField(
      controller: passwordController,
      focusNode: passwordFocus,
      label: 'Password',
      hint: 'Enter Password',
      icon: Icons.lock_outline_rounded,
      obscureText: obscurePassword,
      textInputAction:
      TextInputAction.done,
      onFieldSubmitted: (_) => login(),
      validator: (value) {
        if (value == null ||
            value.isEmpty) {
          return 'Please enter your password';
        }

        return null;
      },
      suffixIcon: IconButton(
        onPressed: loading
            ? null
            : () =>
            setState(
                  () =>
              obscurePassword =
              !obscurePassword,
            ),
        splashRadius: 22,
        icon: Icon(
          obscurePassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 21,
          color: const Color(
            0xFF6F8AA5,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // REMEMBER ME
  // ==========================================================

  Widget _buildRememberMe() {
    return InkWell(
      borderRadius:
      BorderRadius.circular(16),
      onTap: loading
          ? null
          : () =>
          setState(
                () =>
            rememberMe =
            !rememberMe,
          ),
      child: AnimatedContainer(
        duration:
        const Duration(milliseconds: 180),
        padding:
        const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),

        // remember me background box decoration design

        // decoration: BoxDecoration(
        //   gradient: rememberMe
        //       ? const LinearGradient(
        //     begin: Alignment.topLeft,
        //     end: Alignment.bottomRight,
        //     colors: [
        //       Color(0xFFEAF8F1),
        //       Color(0xFFDFF4E9),
        //     ],
        //   )
        //       : null,
        //   color: rememberMe
        //       ? null
        //       : const Color(0xFFF8FAFD),
        //   borderRadius:
        //   BorderRadius.circular(16),
        //   border: Border.all(
        //     color: rememberMe
        //         ? const Color(0xFFA7E3C9)
        //         : const Color(0xFFE3E7EF),
        //     width: 1.5,
        //   ),
        // ),
        child: Row(
          children: [
            AnimatedContainer(
              duration:
              const Duration(
                milliseconds: 180,
              ),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: rememberMe
                    ? mint
                    : Colors.white,
                borderRadius:
                BorderRadius.circular(7),
                border: Border.all(
                  color: rememberMe
                      ? mint
                      : const Color(
                    0xFFB4BBC9,
                  ),
                  width: 1.5,
                ),
              ),
              child: rememberMe
                  ? const Icon(
                Icons.check_rounded,
                size: 15,
                color: Colors.white,
              )
                  : null,
            ),

            const SizedBox(width: 12),

            Text(
              'Remember Me',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight:
                FontWeight.w700,
                color: rememberMe
                    ? const Color(
                  0xFF0F6E56,
                )
                    : const Color(
                  0xFF303548,
                ),
              ),
            ),

            const Spacer(),

            AnimatedSwitcher(
              duration:
              const Duration(
                milliseconds: 180,
              ),
              child: Icon(
                rememberMe
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                key: ValueKey(
                  rememberMe,
                ),
                size: 20,
                color: rememberMe
                    ? mint
                    : const Color(
                  0xFF9AA1B1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ACTION BUTTONS
  // ==========================================================

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed:
              loading ? null : reset,
              style:
              OutlinedButton.styleFrom(
                foregroundColor: midBlue,
                side: const BorderSide(
                  color: Color(0xFFD6E8F5),
                  width: 1.6,
                ),
                backgroundColor:
                const Color(0xFFF7FBFF),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'RESET',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight:
                  FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          flex: 6,
          child: SizedBox(
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(18),
                gradient: loading
                    ? null
                    : const LinearGradient(
                  begin:
                  Alignment.centerLeft,
                  end:
                  Alignment.centerRight,
                  colors: [
                    Color(0xFF4FA8DE),
                    midBlue,
                    deepBlue,
                  ],
                  stops: [
                    0.0,
                    0.55,
                    1.0,
                  ],
                ),
                boxShadow: loading
                    ? []
                    : [
                  BoxShadow(
                    color:
                    midBlue.withOpacity(
                      0.38,
                    ),
                    blurRadius: 26,
                    offset:
                    const Offset(
                      0,
                      14,
                    ),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed:
                loading ? null : login,
                style:
                ElevatedButton.styleFrom(
                  backgroundColor: loading
                      ? const Color(
                    0xFFAFCBE6,
                  )
                      : Colors.transparent,
                  foregroundColor:
                  Colors.white,
                  elevation: 0,
                  shadowColor:
                  Colors.transparent,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      18,
                    ),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
                    : const Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,
                  children: [
                    Text(
                      'LOGIN',
                      style:
                      TextStyle(
                        fontSize: 13,
                        fontWeight:
                        FontWeight.w800,
                        letterSpacing:
                        0.6,
                      ),
                    ),
                    SizedBox(width: 7),
                    Icon(
                      Icons
                          .arrow_forward_rounded,
                      size: 17,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
// SECURITY FOOTER
// ==========================================================

  Widget _buildSecurityFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ======================================================
          // SECURITY ICON
          // ======================================================

          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.72),
              border: Border.all(
                color: Colors.white.withOpacity(0.9),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: midBlue.withOpacity(0.10),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE6F1FB),
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                size: 17,
                color: midBlue,
              ),
            ),
          ),

          const SizedBox(width: 11),

          // ======================================================
          // SECURITY TEXT
          // ======================================================

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Secure Login',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: deepBlue,
                      letterSpacing: 0.1,
                    ),
                  ),

                  const SizedBox(width: 6),

                  Container(
                    width: 15,
                    height: 15,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: mint,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 3),

              const Text(
                'Your credentials are safe & secure',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: textMuted,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // TEXT FIELD
  // ==========================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    FocusNode? focusNode,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onFieldSubmitted:
      onFieldSubmitted,
      validator: validator,
      autovalidateMode:
      AutovalidateMode
          .onUserInteraction,
      style: const TextStyle(
        fontSize: 14.5,
        fontWeight:
        FontWeight.w600,
        color: Color(0xFF303548),
      ),
      cursorColor: midBlue,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          size: 20,
          color: midBlue,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor:
        const Color(0xFFF2F9FF),
        labelStyle:
        const TextStyle(
          fontSize: 13,
          fontWeight:
          FontWeight.w600,
          color: Color(0xFF3E7DA8),
        ),
        floatingLabelStyle:
        const TextStyle(
          fontSize: 12.5,
          fontWeight:
          FontWeight.w700,
          color: midBlue,
        ),
        hintStyle:
        const TextStyle(
          fontSize: 13.5,
          fontWeight:
          FontWeight.w500,
          color: Color(0xFFA9C1D6),
        ),
        errorStyle:
        const TextStyle(
          fontSize: 12,
          fontWeight:
          FontWeight.w600,
        ),
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide:
          const BorderSide(
            color: Color(0xFFD6E8F5),
            width: 1.5,
          ),
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide:
          const BorderSide(
            color: midBlue,
            width: 1.6,
          ),
        ),
        errorBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide:
          const BorderSide(
            color: Colors.redAccent,
            width: 1.2,
          ),
        ),
        focusedErrorBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide:
          const BorderSide(
            color: Colors.redAccent,
            width: 1.6,
          ),
        ),
        border:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
        ),
      ),
    );
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    userIdController.dispose();
    passwordController.dispose();

    userIdFocus.dispose();
    passwordFocus.dispose();

    _entranceController.dispose();
    _waveController.dispose();
    _dropsController.dispose();
    _logoController.dispose();

    super.dispose();
  }
}

// ==========================================================
// PAINTER — decorative background waves
// ==========================================================

class _WavesPainter extends CustomPainter {
  final double progress;

  _WavesPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas,
      Size size,) {
    final t =
        progress * 2 * math.pi;

    // ========================================================
    // WAVE 1
    // ========================================================

    _paintWave(
      canvas,
      size,
      phase: t,
      amplitude: 18,
      heightFactor: 0.62,
      opacity: 0.55,
      frequency: 1.25,
    );

    // ========================================================
    // WAVE 2
    // ========================================================

    _paintWave(
      canvas,
      size,
      phase: t + 1.8,
      amplitude: 14,
      heightFactor: 0.42,
      opacity: 0.40,
      frequency: 1.05,
    );

    // ========================================================
    // WAVE 3
    // ========================================================

    _paintWave(
      canvas,
      size,
      phase: t + 3.2,
      amplitude: 10,
      heightFactor: 0.28,
      opacity: 0.30,
      frequency: 0.9,
    );
  }

  void _paintWave(Canvas canvas,
      Size size, {
        required double phase,
        required double amplitude,
        required double heightFactor,
        required double opacity,
        required double frequency,
      }) {
    final paint = Paint()
      ..color =
      Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final path = Path();

    final baseY =
        size.height * heightFactor;

    path.moveTo(
      0,
      baseY,
    );

    // Smooth wave across complete width.
    for (
    double x = 0;
    x <= size.width;
    x += 4
    ) {
      final normalized =
          x / size.width;

      final y =
          baseY +
              math.sin(
                normalized *
                    math.pi *
                    2 *
                    frequency +
                    phase,
              ) *
                  amplitude;

      path.lineTo(
        x,
        y,
      );
    }

    path.lineTo(
      size.width,
      size.height,
    );

    path.lineTo(
      0,
      size.height,
    );

    path.close();

    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _WavesPainter oldDelegate,) {
    return oldDelegate.progress !=
        progress;
  }
}

// ==========================================================
// PAINTER — single milk drop
// ==========================================================

class _RaindropPainter extends CustomPainter {
  final Color color;

  _RaindropPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas,
      Size size,) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      _raindropPath(size),
      paint,
    );
  }

  static Path _raindropPath(Size size,) {
    final w = size.width;
    final h = size.height;

    final path = Path();

    // ========================================================
    // TOP POINT
    // ========================================================

    path.moveTo(
      w * 0.50,
      0,
    );

    // ========================================================
    // LEFT SIDE
    // ========================================================

    path.cubicTo(
      w * 0.42,
      h * 0.16,
      w * 0.08,
      h * 0.48,
      w * 0.08,
      h * 0.68,
    );

    // ========================================================
    // BOTTOM LEFT -> BOTTOM
    // ========================================================

    path.cubicTo(
      w * 0.08,
      h * 0.88,
      w * 0.26,
      h,
      w * 0.50,
      h,
    );

    // ========================================================
    // BOTTOM -> RIGHT
    // ========================================================

    path.cubicTo(
      w * 0.74,
      h,
      w * 0.92,
      h * 0.88,
      w * 0.92,
      h * 0.68,
    );

    // ========================================================
    // RIGHT SIDE -> TOP
    // ========================================================

    path.cubicTo(
      w * 0.92,
      h * 0.48,
      w * 0.58,
      h * 0.16,
      w * 0.50,
      0,
    );

    path.close();

    return path;
  }

  @override
  bool shouldRepaint(covariant _RaindropPainter oldDelegate,) {
    return oldDelegate.color !=
        color;
  }
}

// ==========================================================
// SHIMMER SWEEP — diagonal light streak
// ==========================================================

class _ShimmerSweep extends StatelessWidget {
  final double progress;

  const _ShimmerSweep({
    required this.progress,
  });

  @override
  Widget build(BuildContext context,) {
    return LayoutBuilder(
      builder:
          (context, constraints) {
        final width =
            constraints.maxWidth;

        final height =
            constraints.maxHeight;

        // ====================================================
        // SHIMMER ONLY RUNS IN FIRST PART
        // ====================================================

        final sweepT =
        Curves.easeInOut.transform(
          (progress / 0.45)
              .clamp(0.0, 1.0),
        );

        final streakWidth =
            width * 0.38;

        final startX =
            -streakWidth * 1.5;

        final endX =
            width + streakWidth * 1.5;

        final dx =
            startX +
                (endX - startX) *
                    sweepT;

        return ClipRRect(
          borderRadius:
          BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned(
                left: dx,
                top: -height * 0.3,
                child: Transform.rotate(
                  angle: -0.32,
                  child: Container(
                    width: streakWidth,
                    height:
                    height * 1.8,
                    decoration:
                    BoxDecoration(
                      gradient:
                      LinearGradient(
                        begin:
                        Alignment
                            .centerLeft,
                        end:
                        Alignment
                            .centerRight,
                        colors: [
                          Colors.white
                              .withOpacity(
                            0.0,
                          ),
                          Colors.white
                              .withOpacity(
                            0.65,
                          ),
                          Colors.white
                              .withOpacity(
                            0.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}