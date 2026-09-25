// main url validation screen


// import 'package:flutter/material.dart';
//
// import '../../controllers/url_validation_controller.dart';
//
// class UrlValidationScreen extends StatefulWidget {
// const UrlValidationScreen({
// super.key,
// });
//
// @override
// State<UrlValidationScreen> createState() =>
// _UrlValidationScreenState();
// }
//
// class _UrlValidationScreenState extends State<UrlValidationScreen> {
// late final UrlValidationController _controller;
//
// bool _isSubmitting = false;
//
// @override
// void initState() {
// super.initState();
// _controller = UrlValidationController();
// }
//
// @override
// void dispose() {
// _controller.dispose();
// super.dispose();
// }
//
// // ============================================================
// // SUBMIT
// // ============================================================
//
// // Future<void> _submit() async {
// // FocusScope.of(context).unfocus();
// //
// // setState(() {
// // _isSubmitting = true;
// // });
// //
// // final isValid = _controller.validateUrlFormat();
// //
// // if (!isValid) {
// // if (!mounted) return;
// //
// // setState(() {
// // _isSubmitting = false;
// // });
// //
// // _showMessage(
// // 'Please enter a valid server URL.',
// // );
// //
// // return;
// // }
// //
// // final saved = await _controller.submitUrl();
// //
// // if (!mounted) return;
// //
// // setState(() {
// // _isSubmitting = false;
// // });
// //
// // if (!saved) {
// // _showMessage(
// // 'Unable to save server URL.',
// // );
// //
// // return;
// // }
// //
// // Navigator.pushReplacementNamed(
// //   context,
// //   '/device-registration',
// // );
// // }
//
//
//   // ============================================================
// // SUBMIT
// // ============================================================
//
//   Future<void> _submit() async {
//     FocusScope.of(context).unfocus();
//
//     setState(() {
//       _isSubmitting = true;
//     });
//
//     final result = await _controller.submitUrl();
//
//     if (!mounted) return;
//
//     setState(() {
//       _isSubmitting = false;
//     });
//
//     // ==========================================================
//     // SUCCESS
//     // ==========================================================
//
//     if (result.success) {
//       Navigator.pushReplacementNamed(
//         context,
//         '/device-registration',
//       );
//
//       return;
//     }
//
//     // ==========================================================
//     // ERROR / SERVER RESPONSE
//     // ==========================================================
//
//     _showMessage(
//       result.message ?? 'URL Error',
//     );
//   }
//
// // ============================================================
// // RESET
// // ============================================================
//
// void _reset() {
// _controller.resetUrl();
//
// FocusScope.of(context).unfocus();
//
// setState(() {});
// }
//
// // ============================================================
// // MESSAGE
// // ============================================================
//
// void _showMessage(String message) {
// ScaffoldMessenger.of(context)
// ..hideCurrentSnackBar()
// ..showSnackBar(
// SnackBar(
// content: Text(message),
// behavior: SnackBarBehavior.floating,
// margin: const EdgeInsets.all(16),
// duration: const Duration(seconds: 2),
// shape: RoundedRectangleBorder(
// borderRadius: BorderRadius.circular(12),
// ),
// ),
// );
// }
//
// // ============================================================
// // BUILD
// // ============================================================
//
// @override
// Widget build(BuildContext context) {
// final size = MediaQuery.of(context).size;
//
// return Scaffold(
// resizeToAvoidBottomInset: true,
//
// body: Container(
// width: double.infinity,
// height: double.infinity,
//
// decoration: const BoxDecoration(
// gradient: LinearGradient(
// begin: Alignment.topCenter,
// end: Alignment.bottomCenter,
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
//
// child: Stack(
// children: [
//
// // ====================================================
// // TOP RIGHT GLOW
// // ====================================================
//
// Positioned(
// top: -size.width * 0.25,
// right: -size.width * 0.20,
// child: Container(
// width: size.width * 0.75,
// height: size.width * 0.75,
// decoration: BoxDecoration(
// shape: BoxShape.circle,
// color: Colors.white.withValues(
// alpha: 0.18,
// ),
// ),
// ),
// ),
//
// // ====================================================
// // LEFT GLOW
// // ====================================================
//
// Positioned(
// top: size.height * 0.38,
// left: -size.width * 0.32,
// child: Container(
// width: size.width * 0.68,
// height: size.width * 0.68,
// decoration: BoxDecoration(
// shape: BoxShape.circle,
// color: Colors.white.withValues(
// alpha: 0.08,
// ),
// ),
// ),
// ),
//
// // ====================================================
// // DECORATIVE DROPS
// // ====================================================
//
// Positioned(
// top: size.height * 0.12,
// left: size.width * 0.10,
// child: _drop(7),
// ),
//
// Positioned(
// top: size.height * 0.19,
// right: size.width * 0.10,
// child: _drop(5),
// ),
//
// Positioned(
// top: size.height * 0.37,
// left: size.width * 0.07,
// child: _drop(5),
// ),
//
// Positioned(
// top: size.height * 0.32,
// right: size.width * 0.08,
// child: _drop(8),
// ),
//
// // ====================================================
// // MAIN CONTENT
// // ====================================================
//
// SafeArea(
// child: LayoutBuilder(
// builder: (context, constraints) {
// return SingleChildScrollView(
// physics:
// const BouncingScrollPhysics(),
//
// padding: const EdgeInsets.symmetric(
// horizontal: 22,
// vertical: 18,
// ),
//
// child: ConstrainedBox(
// constraints: BoxConstraints(
// minHeight:
// constraints.maxHeight - 36,
// maxWidth: 500,
// ),
//
// child: Column(
// mainAxisAlignment:
// MainAxisAlignment.center,
// children: [
//
// // ======================================
// // LOGO
// // ======================================
//
// Padding(
// padding:
// const EdgeInsets.only(
// top: 4,
// ),
// child: Image.asset(
// 'assets/images/Gyan_dairy_logo.png',
// width: 220,
// height: 160,
// fit: BoxFit.contain,
// ),
// ),
//
// // ======================================
// // LOGO → TITLE
// // ======================================
//
// const SizedBox(height: 20),
//
// // ======================================
// // TITLE
// // ======================================
//
// const Text(
// 'Server URL Validation',
// textAlign: TextAlign.center,
// style: TextStyle(
// fontSize: 26,
// fontWeight: FontWeight.w800,
// letterSpacing: 0.2,
// color: Color(0xFF4B2395),
// ),
// ),
//
// // ======================================
// // TITLE → SUBTITLE
// // ======================================
//
// const SizedBox(height: 9),
//
// Text(
// 'Connect your application to the server',
// textAlign: TextAlign.center,
// style: TextStyle(
// fontSize: 13,
// fontWeight: FontWeight.w500,
// color: const Color(0xFF245D75)
//     .withValues(alpha: 0.90),
// ),
// ),
//
// // ======================================
// // SUBTITLE → URL
// // ======================================
//
// const SizedBox(height: 58),
//
// // ======================================
// // URL FIELD
// // ======================================
//
// Container(
// width: double.infinity,
// height: 64,
// padding:
// const EdgeInsets.symmetric(
// horizontal: 4,
// ),
// decoration: BoxDecoration(
// color: Colors.white.withValues(
// alpha: 0.91,
// ),
// borderRadius:
// BorderRadius.circular(18),
// border: Border.all(
// color:
// Colors.white.withValues(
// alpha: 0.95,
// ),
// width: 1,
// ),
// boxShadow: [
// BoxShadow(
// color:
// const Color(
// 0xFF4B2395,
// ).withValues(
// alpha: 0.14,
// ),
// blurRadius: 22,
// offset:
// const Offset(0, 9),
// ),
// ],
// ),
//
// child: TextField(
// controller:
// _controller.urlController,
//
// keyboardType:
// TextInputType.url,
//
// textInputAction:
// TextInputAction.done,
//
// autocorrect: false,
// enableSuggestions: false,
//
// // IMPORTANT:
// // URL single line rahega.
// maxLines: 1,
// minLines: 1,
//
// style: const TextStyle(
// fontSize: 15,
// fontWeight:
// FontWeight.w600,
// color:
// Color(0xFF252525),
// ),
//
// decoration:
// InputDecoration(
//   hintText: 'Please enter your URL',
// hintStyle:
// TextStyle(
// fontSize: 12,
// fontWeight:
// FontWeight.w500,
// color:
// Colors.grey.shade500,
// ),
//
// prefixIcon:
// Container(
// width: 37,
// height: 37,
// margin:
// const EdgeInsets.all(
// 11,
// ),
// decoration:
// BoxDecoration(
// color:
// const Color(
// 0xFF4B2395,
// ),
// borderRadius:
// BorderRadius
//     .circular(
// 10,
// ),
// ),
// child: const Icon(
// Icons.link_rounded,
// color:
// Colors.white,
// size: 20,
// ),
// ),
//
// border:
// InputBorder.none,
//
// contentPadding:
// const EdgeInsets
//     .symmetric(
// horizontal: 7,
// vertical: 22,
// ),
// ),
// ),
// ),
//
// // ======================================
// // URL → BUTTONS
// // ======================================
//
// const SizedBox(height: 50),
//
// // ======================================
// // BUTTONS
// // ======================================
//
// Row(
// children: [
//
// // ==================================
// // RESET
// // ==================================
//
// Expanded(
// child: SizedBox(
// height: 55,
// child:
// OutlinedButton(
// onPressed:
// _isSubmitting
// ? null
//     : _reset,
//
// style:
// OutlinedButton
//     .styleFrom(
// foregroundColor:
// const Color(
// 0xFF4B2395,
// ),
//
// backgroundColor:
// Colors.white
//     .withValues(
// alpha: 0.25,
// ),
//
// side:
// const BorderSide(
// color:
// Color(
// 0xFF4B2395,
// ),
// width: 1.4,
// ),
//
// shape:
// RoundedRectangleBorder(
// borderRadius:
// BorderRadius
//     .circular(
// 16,
// ),
// ),
// ),
//
// child:
// const Row(
// mainAxisAlignment:
// MainAxisAlignment
//     .center,
// children: [
//
// Icon(
// Icons
//     .refresh_rounded,
// size: 19,
// ),
//
// SizedBox(
// width: 7,
// ),
//
// Text(
// 'RESET',
// style:
// TextStyle(
// fontSize: 14,
// fontWeight:
// FontWeight
//     .w700,
// ),
// ),
// ],
// ),
// ),
// ),
// ),
//
// const SizedBox(width: 14),
//
// // ==================================
// // SUBMIT
// // ==================================
//
// Expanded(
// child: SizedBox(
// height: 55,
// child:
// ElevatedButton(
// onPressed:
// _isSubmitting
// ? null
//     : _submit,
//
// style:
// ElevatedButton
//     .styleFrom(
// backgroundColor:
// const Color(
// 0xFF4B2395,
// ),
//
// foregroundColor:
// Colors.white,
//
// elevation: 7,
//
// shadowColor:
// const Color(
// 0xFF4B2395,
// ).withValues(
// alpha: 0.35,
// ),
//
// shape:
// RoundedRectangleBorder(
// borderRadius:
// BorderRadius
//     .circular(
// 16,
// ),
// ),
// ),
//
// child:
// _isSubmitting
// ? const SizedBox(
// width: 22,
// height: 22,
// child:
// CircularProgressIndicator(
// strokeWidth:
// 2.2,
// color:
// Colors
//     .white,
// ),
// )
//     : const Row(
// mainAxisAlignment:
// MainAxisAlignment
//     .center,
// children: [
//
// Text(
// 'SUBMIT',
// style:
// TextStyle(
// fontSize:
// 14,
// fontWeight:
// FontWeight
//     .w700,
// ),
// ),
//
// SizedBox(
// width: 7,
// ),
//
// Icon(
// Icons
//     .arrow_forward_rounded,
// size: 19,
// ),
// ],
// ),
// ),
// ),
// ),
// ],
// ),
//
// // ======================================
// // BUTTONS → SECURITY
// // ======================================
//
// const SizedBox(height: 30),
//
// // ======================================
// // SECURITY MESSAGE
// // ======================================
//
// Row(
// mainAxisAlignment:
// MainAxisAlignment.center,
// children: [
//
// Icon(
// Icons
//     .verified_user_outlined,
// size: 14,
// color: Colors.white
//     .withValues(
// alpha: 0.90,
// ),
// ),
//
// const SizedBox(width: 6),
//
// Flexible(
// child: Text(
// 'Server configuration is saved securely',
// textAlign:
// TextAlign.center,
// style: TextStyle(
// fontSize: 11,
// fontWeight:
// FontWeight.w500,
// color: Colors.white
//     .withValues(
// alpha: 0.90,
// ),
// ),
// ),
// ),
// ],
// ),
//
// const SizedBox(height: 20),
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
// // ============================================================
// // DECORATIVE DROP
// // ============================================================
//
// Widget _drop(double size) {
// return Container(
// width: size,
// height: size,
// decoration: BoxDecoration(
// shape: BoxShape.circle,
// color: Colors.white.withValues(
// alpha: 0.60,
// ),
// boxShadow: [
// BoxShadow(
// color: Colors.white.withValues(
// alpha: 0.20,
// ),
// blurRadius: 8,
// spreadRadius: 2,
// ),
// ],
// ),
// );
// }
// }
//



// modify url validation screen with animation

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../controllers/url_validation_controller.dart';

class UrlValidationScreen extends StatefulWidget {
  const UrlValidationScreen({
    super.key,
  });

  @override
  State<UrlValidationScreen> createState() => _UrlValidationScreenState();
}

class _UrlValidationScreenState extends State<UrlValidationScreen>
    with TickerProviderStateMixin {
  late final UrlValidationController _controller;

  bool _isSubmitting = false;

  // Background wave drift.
  late final AnimationController _waveController;

  // Floating milk drops bobbing.
  late final AnimationController _dropsController;

  // Logo shimmer sweep + glow pulse.
  late final AnimationController _logoController;

  @override
  void initState() {
    super.initState();
    _controller = UrlValidationController();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();

    _dropsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _waveController.dispose();
    _dropsController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  // Future<void> _submit() async {
  //   FocusScope.of(context).unfocus();
  //
  //   setState(() {
  //     _isSubmitting = true;
  //   });
  //
  //   final isValid = _controller.validateUrlFormat();
  //
  //   if (!isValid) {
  //     if (!mounted) return;
  //
  //     setState(() {
  //       _isSubmitting = false;
  //     });
  //
  //     _showMessage(
  //       'Please enter a valid server URL.',
  //     );
  //
  //     return;
  //   }
  //
  //   final saved = await _controller.submitUrl();
  //
  //   if (!mounted) return;
  //
  //   setState(() {
  //     _isSubmitting = false;
  //   });
  //
  //   if (!saved) {
  //     _showMessage(
  //       'Unable to save server URL.',
  //     );
  //
  //     return;
  //   }
  //
  //   Navigator.pushReplacementNamed(
  //     context,
  //     '/device-registration',
  //   );
  // }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
    });

    final result = await _controller.submitUrl();

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    // ==========================================================
    // SUCCESS
    // ==========================================================

    if (result.success) {
      Navigator.pushReplacementNamed(
        context,
        '/device-registration',
      );

      return;
    }

    // ==========================================================
    // ERROR / SERVER RESPONSE
    // ==========================================================

    _showMessage(
      result.message ?? 'URL Error',
    );
  }

  // ============================================================
  // RESET
  // ============================================================

  void _reset() {
    _controller.resetUrl();

    FocusScope.of(context).unfocus();

    setState(() {});
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ====================================================
          // ANIMATED MILK-THEME BACKGROUND
          // ====================================================
          _buildBackground(size),

          // ====================================================
          // MAIN CONTENT
          // ====================================================
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 18,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 36,
                      maxWidth: 560,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ======================================
                        // LOGO (animated: glow + shimmer)
                        // ======================================
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: _buildAnimatedLogo(),
                        ),

                        // ======================================
                        // LOGO -> TITLE
                        // ======================================
                        const SizedBox(height: 20),

                        // ======================================
                        // TITLE
                        // ======================================
                        const Text(
                          'Server URL Validation',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                            color: Color(0xFF0C447C),
                          ),
                        ),

                        // ======================================
                        // TITLE -> SUBTITLE
                        // ======================================
                        const SizedBox(height: 9),

                        Text(
                          'Connect your application to the server',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF3E7DA8)
                                .withValues(alpha: 0.90),
                          ),
                        ),

                        // ======================================
                        // SUBTITLE -> URL
                        // ======================================
                        const SizedBox(height: 58),

                        // ======================================
                        // URL FIELD
                        // ======================================
                        Container(
                          width: double.infinity,
                          height: 72,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.95),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0C447C)
                                    .withValues(alpha: 0.14),
                                blurRadius: 22,
                                offset: const Offset(0, 9),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _controller.urlController,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            autocorrect: false,
                            enableSuggestions: false,

                            // IMPORTANT:
                            // URL single line rahega.
                            maxLines: 1,
                            minLines: 1,

                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF252525),
                            ),

                            decoration: InputDecoration(
                              hintText: 'Please enter your URL',
                              hintStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade500,
                              ),
                              prefixIcon: Container(
                                width: 42,
                                height: 42,
                                margin: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF185FA5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.link_rounded,
                                  color: Colors.white,
                                  size: 21,
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 22,
                              ),
                            ),
                          ),
                        ),

                        // ======================================
                        // URL -> BUTTONS
                        // ======================================
                        const SizedBox(height: 50),

                        // ======================================
                        // BUTTONS
                        // ======================================
                        Row(
                          children: [
                            // ==================================
                            // RESET
                            // ==================================
                            Expanded(
                              child: SizedBox(
                                height: 55,
                                child: OutlinedButton(
                                  onPressed: _isSubmitting ? null : _reset,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF185FA5),
                                    backgroundColor:
                                    Colors.white.withValues(alpha: 0.35),
                                    side: const BorderSide(
                                      color: Color(0xFF185FA5),
                                      width: 1.4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.refresh_rounded,
                                        size: 19,
                                      ),
                                      SizedBox(width: 7),
                                      Text(
                                        'RESET',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            // ==================================
                            // SUBMIT
                            // ==================================
                            Expanded(
                              child: SizedBox(
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: _isSubmitting ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF185FA5),
                                    foregroundColor: Colors.white,
                                    elevation: 7,
                                    shadowColor: const Color(0xFF185FA5)
                                        .withValues(alpha: 0.35),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isSubmitting
                                      ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                      : const Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'SUBMIT',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 7),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 19,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // ======================================
                        // BUTTONS -> SECURITY
                        // ======================================
                        const SizedBox(height: 30),

                        // ======================================
                        // SECURITY MESSAGE
                        // ======================================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              size: 14,
                              color: const Color(0xFF0C447C)
                                  .withValues(alpha: 0.90),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Server configuration is saved securely',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF0C447C)
                                      .withValues(alpha: 0.90),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BACKGROUND — gradient + animated waves + floating drops
  // (drops are positioned only within the top/side safe zones so
  //  they never render behind the opaque form content)
  // ============================================================
  Widget _buildBackground(Size size) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Base gradient — same milk theme as the login screen.
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFEEF8FF),
                  Color(0xFFDCF0FA),
                  Color(0xFFC3E6F5),
                  Color(0xFFD9F0E6),
                ],
                stops: [0.0, 0.3, 0.55, 1.0],
              ),
            ),
          ),

          // Animated waves near the top.
          SizedBox(
            width: size.width,
            height: size.height * 0.3,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _WavesPainter(progress: _waveController.value),
                  size: Size(size.width, size.height * 0.3),
                );
              },
            ),
          ),

          // Floating milk drops — kept along the edges / corners so
          // they stay visible instead of sitting behind the form.


          AnimatedBuilder(

            animation: _dropsController,
            builder: (context, _) {
              final t = _dropsController.value * 2 * math.pi;

              return Stack(
                children: [
                  _floatingDrop(
                    left: size.width * 0.08,
                    top: size.height * 0.16,
                    dropSize: 18,
                    color: Color(0xFF2E93CE),
                    opacity: 0.55,
                    phase: t,
                    amplitude: 12,
                  ),

                  _floatingDrop(
                    right: size.width * 0.09,
                    top: size.height * 0.24,
                    dropSize: 13,
                    color: Color(0xFF1D9E75),
                    opacity: 0.5,
                    phase: t + 1.4,
                    amplitude: 10,
                  ),

                  _floatingDrop(
                    left: size.width * 0.13,
                    bottom: size.height * 0.22,
                    dropSize: 10,
                    color: Color(0xFF2E93CE),
                    opacity: 0.4,
                    phase: t + 2.6,
                    amplitude: 8,
                  ),

                  _floatingDrop(
                    right: size.width * 0.18,
                    bottom: size.height * 0.34,
                    dropSize: 9,
                    color: Color(0xFF1D9E75),
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
    final rotation = math.sin(phase) * 0.08;

    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Transform.translate(
        offset: Offset(0, dy),
        child: Transform.rotate(
          angle: rotation,
          child: CustomPaint(
            size: Size(dropSize, dropSize * 1.4),
            painter: _RaindropPainter(
              color: color.withValues(alpha: opacity),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ANIMATED LOGO — same image asset, with glow pulse + shimmer
  // ============================================================
  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, _) {
        final t = _logoController.value;
        final glow = (math.sin(t * 2 * math.pi) + 1) / 2;
        final blur = 28 + glow * 10;
        final glowOpacity = 0.12 + glow * 0.14;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E93CE).withValues(alpha: glowOpacity),
                blurRadius: blur,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/Gyan_dairy_logo.png',
                  width: 220,
                  height: 160,
                  fit: BoxFit.contain,
                ),
                Positioned.fill(
                  child: _ShimmerSweep(progress: t),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // DECORATIVE DROP (kept for compatibility — no longer used
  // directly, replaced by the animated _floatingDrop above)
  // ============================================================

  Widget _drop(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.60),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.20),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// PAINTER — decorative background waves (drift horizontally)
// ==========================================================
class _WavesPainter extends CustomPainter {
  final double progress;

  _WavesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * 2 * math.pi;

    _paintWave(canvas, size, dx: math.sin(t) * 14, heightFactor: 0.62, opacity: 0.55);
    _paintWave(canvas, size, dx: math.sin(t + 1.6) * 11, heightFactor: 0.42, opacity: 0.4);
    _paintWave(canvas, size, dx: math.sin(t + 2.8) * 8, heightFactor: 0.28, opacity: 0.3);
  }

  void _paintWave(
      Canvas canvas,
      Size size, {
        required double dx,
        required double heightFactor,
        required double opacity,
      }) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(-40 + dx, 0)
      ..lineTo(size.width + 40 + dx, 0)
      ..lineTo(size.width + 40 + dx, size.height * heightFactor)
      ..quadraticBezierTo(
        size.width * 0.65 + dx,
        size.height * (heightFactor + 0.28),
        size.width * 0.5 + dx,
        size.height * heightFactor * 0.75,
      )
      ..quadraticBezierTo(
        size.width * 0.3 + dx,
        size.height * (heightFactor * 0.4),
        -40 + dx,
        size.height * heightFactor * 0.9,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ==========================================================
// PAINTER — a single milk drop / raindrop shape
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
// SHIMMER SWEEP — diagonal light streak across the logo
// ==========================================================
class _ShimmerSweep extends StatelessWidget {
  final double progress;

  const _ShimmerSweep({required this.progress});

  @override
  Widget build(BuildContext context) {
    final sweepT = (progress / 0.45).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final streakWidth = width * 0.3;
        final dx = -streakWidth + sweepT * (width + streakWidth * 2);

        return ClipRect(
          child: Transform.translate(
            offset: Offset(dx, 0),
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                width: streakWidth,
                height: constraints.maxHeight * 1.8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.white.withOpacity(0),
                      Colors.white.withOpacity(0.35),
                      Colors.white.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}