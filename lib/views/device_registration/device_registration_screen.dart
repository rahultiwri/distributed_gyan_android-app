 // main logic wali screen
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// import '../../controllers/device_registration_controller.dart';
//
// class DeviceRegistrationScreen extends StatefulWidget {
// const DeviceRegistrationScreen({
// super.key,
// });
//
// @override
// State<DeviceRegistrationScreen> createState() =>
// _DeviceRegistrationScreenState();
// }
//
// class _DeviceRegistrationScreenState
// extends State<DeviceRegistrationScreen> {
// late final DeviceRegistrationController controller;
//
// bool loading = false;
// bool obscurePassword = true;
//
// @override
// void initState() {
// super.initState();
//
// controller = DeviceRegistrationController();
// controller.initialize();
// }
//
//
//
// Future<void> submit() async {
//   // ==================================================
//   // MOBILE NUMBER VALIDATION
//   // ==================================================
//
//   final mobile =
//   controller.mobileController.text.trim();
//
//   if (mobile.length > 10) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text(
//           'Mobile number cannot be more than 10 digits',
//         ),
//       ),
//     );
//     return;
//   }
//
//   if (mobile.length < 10) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text(
//           'Mobile number must be 10 digits',
//         ),
//       ),
//     );
//     return;
//   }
//
//   // ==================================================
//   // OTHER FIELD VALIDATION
//   // ==================================================
//
//   if (!controller.validate()) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text(
//           'Please enter all required details',
//         ),
//       ),
//     );
//     return;
//   }
//
//   // ==================================================
//   // REGISTRATION
//   // ==================================================
//
//   setState(() {
//     loading = true;
//   });
//
//   final response =
//   await controller.submitRegistration();
//
//   if (!mounted) return;
//
//   setState(() {
//     loading = false;
//   });
//
//   // ==================================================
//   // API FAILED
//   // ==================================================
//
//   if (response == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text(
//           'Registration failed',
//         ),
//       ),
//     );
//     return;
//   }
//
//   // ==================================================
//   // CONDITION 1
//   // EXPDATE IS NOT BLANK
//   // ==================================================
//
//   if (response.expDate.isNotEmpty) {
//     // =================================================
//     // MSG == Registered
//     // =================================================
//
//     if (response.msg == 'Registered') {
//       Navigator.pushNamedAndRemoveUntil(
//         context,
//         '/login',
//             (route) => false,
//       );
//
//       return;
//     }
//
//     // =================================================
//     // EXPDATE EXISTS BUT MSG IS NOT REGISTERED
//     // =================================================
//
//     await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Registration'),
//           content: Text(
//             response.msg,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//
//     return;
//   }
//
//   // ==================================================
//   // CONDITION 2
//   // EXPDATE IS BLANK
//   // ERRORTYPE == OTP
//   // ==================================================
//
//   if (response.errType == 'OTP') {
//     await showOtpDialog(
//       title: response.title,
//     );
//
//     return;
//   }
//
//   // ==================================================
//   // CONDITION 3
//   // EXPDATE IS BLANK
//   // ERRORTYPE != OTP
//   // ==================================================
//
//   await showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: const Text('Registration'),
//         content: Text(
//           response.msg,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: const Text('OK'),
//           ),
//         ],
//       );
//     },
//   );
// }
//
//
//
// Future<void> showOtpDialog({
//   required String title,
// }) async {
//   final otpController =
//   TextEditingController();
//
//   await showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) {
//       return AlertDialog(
//         title: Text(title),
//         content: TextField(
//           controller: otpController,
//           keyboardType: TextInputType.number,
//           maxLength: 6,
//           inputFormatters: [
//             FilteringTextInputFormatter.digitsOnly,
//             LengthLimitingTextInputFormatter(10),
//           ],
//           decoration: const InputDecoration(
//             labelText: 'Enter OTP',
//             hintText: 'Enter 6 digit OTP',
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: const Text('CANCEL'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final otp =
//               otpController.text.trim();
//
//               if (otp.length != 6) {
//                 ScaffoldMessenger.of(context)
//                     .showSnackBar(
//                   const SnackBar(
//                     content: Text(
//                       'Please enter 6 digit OTP',
//                     ),
//                   ),
//                 );
//                 return;
//               }
//
//               // ========================================
//               // OTP VERIFICATION API
//               // ========================================
//               //
//               // Yahan abhi API nahi lagayenge.
//               // Aap verification API ka Java code/
//               // condition doge, uske baad yahan
//               // exact same logic add karenge.
//               //
//               // Parameters:
//               // cmd      = verifyotp
//               // otp      = entered OTP
//               // loginname = user ID
//               // ========================================
//
//               // debugPrint(
//               //   'OTP ENTERED: $otp',
//               // );
//             },
//             child: const Text('SUBMIT'),
//           ),
//         ],
//       );
//     },
//   );
//
//   otpController.dispose();
// }
//
//
//
//
//
//
// void reset() {
// controller.reset();
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
// // ==================================================
// // TOP RIGHT GLOW
// // ==================================================
//
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
// // ==================================================
// // LEFT GLOW
// // ==================================================
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
// // ==================================================
// // DECORATIVE DROPS
// // ==================================================
//
// Positioned(
// top: 100,
// right: 45,
// child: _drop(
// size: 18,
// ),
// ),
//
// Positioned(
// top: 240,
// left: 35,
// child: _drop(
// size: 13,
// ),
// ),
//
// Positioned(
// bottom: 170,
// right: 30,
// child: _drop(
// size: 12,
// ),
// ),
//
// Positioned(
// bottom: 100,
// left: 55,
// child: _drop(
// size: 20,
// ),
// ),
//
// // ==================================================
// // MAIN CONTENT
// // ==================================================
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
// child: Center(
// child: ConstrainedBox(
// constraints: const BoxConstraints(
// maxWidth: 500,
// ),
// child: Column(
// crossAxisAlignment:
// CrossAxisAlignment.center,
// children: [
// // ==================================================
// // LOGO
// // ==================================================
//
// Image.asset(
// 'assets/images/Gyan_dairy_logo.png',
// width: 220,
// height: 150,
// fit: BoxFit.contain,
// ),
//
// const SizedBox(height: 4),
//
// // ==================================================
// // TITLE
// // ==================================================
//
// const Text(
// 'Device Registration',
// textAlign: TextAlign.center,
// style: TextStyle(
// fontSize: 26,
// fontWeight: FontWeight.w800,
// color: Color(0xFF4B2395),
// letterSpacing: 0.2,
// ),
// ),
//
// const SizedBox(height: 8),
//
// const Text(
// 'Register your device to continue',
// textAlign: TextAlign.center,
// style: TextStyle(
// fontSize: 14,
// fontWeight: FontWeight.w500,
// color: Color(0xFF36566A),
// ),
// ),
//
// const SizedBox(height: 24),
//
// // ==================================================
// // REGISTRATION CARD
// // ==================================================
//
// Container(
// width: double.infinity,
// padding: const EdgeInsets.all(20),
// decoration: BoxDecoration(
// color: Colors.white.withOpacity(0.94),
// borderRadius:
// BorderRadius.circular(24),
// boxShadow: [
// BoxShadow(
// color:
// Colors.black.withOpacity(0.12),
// blurRadius: 25,
// offset: const Offset(0, 12),
// ),
// ],
// ),
// child: Column(
// children: [
// // ==================================================
// // IMEI / UUID
// // ==================================================
//
// _buildTextField(
// controller:
// controller.imeiController,
// label: 'IMEI',
// hint: 'Device identifier',
// icon:
// Icons.smartphone_rounded,
// readOnly: true,
// ),
//
// const SizedBox(height: 15),
//
// // ==================================================
// // MOBILE NUMBER
// // ==================================================
//
//   _buildTextField(
//     controller: controller.mobileController,
//     label: 'Mobile Number',
//     hint: 'Enter mobile number',
//     icon: Icons.phone_outlined,
//     keyboardType: TextInputType.phone,
//     inputFormatters: [
//       FilteringTextInputFormatter.digitsOnly,
//       LengthLimitingTextInputFormatter(10),
//     ],
//   ),
//
// const SizedBox(height: 15),
//
// // ==================================================
// // USER ID
// // ==================================================
//
// _buildTextField(
// controller:
// controller.userIdController,
// label: 'User ID',
// hint: 'Enter your User ID',
// icon:
// Icons.person_outline_rounded,
// ),
//
// const SizedBox(height: 15),
//
// // ==================================================
// // PASSWORD
// // ==================================================
//
// _buildTextField(
// controller:
// controller.passwordController,
// label: 'Password',
// hint: 'Enter your password',
// icon:
// Icons.lock_outline_rounded,
// obscureText:
// obscurePassword,
// suffixIcon: IconButton(
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
// const SizedBox(height: 22),
//
// // ==================================================
// // BUTTONS
// // ==================================================
//
// Row(
// children: [
// Expanded(
// child: SizedBox(
// height: 55,
// child: OutlinedButton(
// onPressed:
// loading
// ? null
//     : reset,
// style:
// OutlinedButton.styleFrom(
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
// BorderRadius.circular(
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
// child: ElevatedButton(
// onPressed:
// loading
// ? null
//     : submit,
// style:
// ElevatedButton.styleFrom(
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
// BorderRadius.circular(
// 16,
// ),
// ),
// ),
// child:
// loading
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
// 'SUBMIT',
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
// const SizedBox(height: 22),
//
// // ==================================================
// // SECURITY MESSAGE
// // ==================================================
//
// const Row(
// mainAxisAlignment:
// MainAxisAlignment.center,
// children: [
// Icon(
// Icons
//     .verified_user_outlined,
// size: 17,
// color: Colors.white,
// ),
// SizedBox(width: 7),
// Flexible(
// child: Text(
// 'Your registration details are securely stored',
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
// const SizedBox(height: 12),
// ],
// ),
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
// bool readOnly = false,
// bool obscureText = false,
// TextInputType? keyboardType,
// Widget? suffixIcon,
// int? maxLength,
// List<TextInputFormatter>? inputFormatters,
// }) {
// return SizedBox(
// height: 64,
// child: TextField(
// controller: controller,
// readOnly: readOnly,
// obscureText: obscureText,
// keyboardType: keyboardType,
// maxLength: maxLength,
// inputFormatters: inputFormatters,
// style: const TextStyle(
// fontSize: 15,
// fontWeight: FontWeight.w600,
// color: Color(0xFF263746),
// ),
// decoration: InputDecoration(
// labelText: label,
// hintText: hint,
// counterText: '',
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
// enabledBorder: OutlineInputBorder(
// borderRadius:
// BorderRadius.circular(18),
// borderSide: BorderSide(
// color: const Color(0xFFB8DCEB)
//     .withOpacity(0.8),
// width: 1,
// ),
// ),
// focusedBorder: OutlineInputBorder(
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
// Widget _drop({
// required double size,
// }) {
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
// controller.dispose();
// super.dispose();
// }
// }
//

 // ui modification implement


 import 'dart:math' as math;

 import 'package:flutter/material.dart';
 import 'package:flutter/services.dart';

 import '../../controllers/device_registration_controller.dart';

 class DeviceRegistrationScreen extends StatefulWidget {
   const DeviceRegistrationScreen({
     super.key,
   });

   @override
   State<DeviceRegistrationScreen> createState() =>
       _DeviceRegistrationScreenState();
 }

 class _DeviceRegistrationScreenState extends State<DeviceRegistrationScreen>
     with TickerProviderStateMixin {
   late final DeviceRegistrationController controller;

   bool loading = false;
   bool obscurePassword = true;

   // Background wave drift.
   late final AnimationController _waveController;

   // Floating milk drops bobbing.
   late final AnimationController _dropsController;

   // Logo shimmer sweep + glow pulse.
   late final AnimationController _logoController;

   @override
   void initState() {
     super.initState();

     controller = DeviceRegistrationController();
     controller.initialize();

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

   Future<void> submit() async {
     // ==================================================
     // MOBILE NUMBER VALIDATION
     // ==================================================

     final mobile = controller.mobileController.text.trim();

     if (mobile.length > 10) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
           content: Text(
             'Mobile number cannot be more than 10 digits',
           ),
         ),
       );
       return;
     }

     if (mobile.length < 10) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
           content: Text(
             'Mobile number must be 10 digits',
           ),
         ),
       );
       return;
     }

     // ==================================================
     // OTHER FIELD VALIDATION
     // ==================================================

     if (!controller.validate()) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
           content: Text(
             'Please enter all required details',
           ),
         ),
       );
       return;
     }

     // ==================================================
     // REGISTRATION
     // ==================================================

     setState(() {
       loading = true;
     });

     final response = await controller.submitRegistration();

     if (!mounted) return;

     setState(() {
       loading = false;
     });

     // ==================================================
     // API FAILED
     // ==================================================

     if (response == null) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
           content: Text(
             'Registration failed',
           ),
         ),
       );
       return;
     }

     // ==================================================
     // CONDITION 1
     // EXPDATE IS NOT BLANK
     // ==================================================

     if (response.expDate.isNotEmpty) {
       // =================================================
       // MSG == Registered
       // =================================================

       if (response.msg == 'Registered') {
         Navigator.pushNamedAndRemoveUntil(
           context,
           '/login',
               (route) => false,
         );

         return;
       }

       // =================================================
       // EXPDATE EXISTS BUT MSG IS NOT REGISTERED
       // =================================================

       await showDialog(
         context: context,
         builder: (context) {
           return AlertDialog(
             title: const Text('Registration'),
             content: Text(
               response.msg,
             ),
             actions: [
               TextButton(
                 onPressed: () {
                   Navigator.of(context).pop();
                 },
                 child: const Text('OK'),
               ),
             ],
           );
         },
       );

       return;
     }

     // ==================================================
     // CONDITION 2
     // EXPDATE IS BLANK
     // ERRORTYPE == OTP
     // ==================================================

     if (response.errType == 'OTP') {
       await showOtpDialog(
         title: response.title,
       );

       return;
     }

     // ==================================================
     // CONDITION 3
     // EXPDATE IS BLANK
     // ERRORTYPE != OTP
     // ==================================================

     await showDialog(
       context: context,
       builder: (context) {
         return AlertDialog(
           title: const Text('Registration'),
           content: Text(
             response.msg,
           ),
           actions: [
             TextButton(
               onPressed: () {
                 Navigator.of(context).pop();
               },
               child: const Text('OK'),
             ),
           ],
         );
       },
     );
   }

   Future<void> showOtpDialog({
     required String title,
   }) async {
     final otpController = TextEditingController();

     await showDialog(
       context: context,
       barrierDismissible: false,
       builder: (context) {
         return AlertDialog(
           title: Text(title),
           content: TextField(
             controller: otpController,
             keyboardType: TextInputType.number,
             maxLength: 6,
             inputFormatters: [
               FilteringTextInputFormatter.digitsOnly,
               LengthLimitingTextInputFormatter(10),
             ],
             decoration: const InputDecoration(
               labelText: 'Enter OTP',
               hintText: 'Enter 6 digit OTP',
             ),
           ),
           actions: [
             TextButton(
               onPressed: () {
                 Navigator.of(context).pop();
               },
               child: const Text('CANCEL'),
             ),
             ElevatedButton(
               onPressed: () {
                 final otp = otpController.text.trim();

                 if (otp.length != 6) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(
                       content: Text(
                         'Please enter 6 digit OTP',
                       ),
                     ),
                   );
                   return;
                 }

                 // ========================================
                 // OTP VERIFICATION API
                 // ========================================
                 //
                 // Yahan abhi API nahi lagayenge.
                 // Aap verification API ka Java code/
                 // condition doge, uske baad yahan
                 // exact same logic add karenge.
                 //
                 // Parameters:
                 // cmd      = verifyotp
                 // otp      = entered OTP
                 // loginname = user ID
                 // ========================================

                 // debugPrint(
                 //   'OTP ENTERED: $otp',
                 // );
               },
               child: const Text('SUBMIT'),
             ),
           ],
         );
       },
     );

     otpController.dispose();
   }

   void reset() {
     controller.reset();

     setState(() {
       obscurePassword = true;
     });
   }

   @override
   Widget build(BuildContext context) {
     final size = MediaQuery.of(context).size;

     return Scaffold(
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
                   padding: const EdgeInsets.symmetric(
                     horizontal: 20,
                     vertical: 20,
                   ),
                   child: Center(
                     child: ConstrainedBox(
                       constraints: const BoxConstraints(maxWidth: 500),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.center,
                         children: [
                           // ==================================================
                           // LOGO (animated: glow + shimmer)
                           // ==================================================
                           _buildAnimatedLogo(),

                           const SizedBox(height: 4),

                           // ==================================================
                           // TITLE
                           // ==================================================

                           const Text(
                             'Device Registration',
                             textAlign: TextAlign.center,
                             style: TextStyle(
                               fontSize: 26,
                               fontWeight: FontWeight.w800,
                               color: Color(0xFF0C447C),
                               letterSpacing: 0.2,
                             ),
                           ),

                           const SizedBox(height: 8),

                           const Text(
                             'Register your device to continue',
                             textAlign: TextAlign.center,
                             style: TextStyle(
                               fontSize: 14,
                               fontWeight: FontWeight.w500,
                               color: Color(0xFF3E7DA8),
                             ),
                           ),

                           const SizedBox(height: 24),

                           // ==================================================
                           // REGISTRATION CARD
                           // ==================================================

                           Container(
                             width: double.infinity,
                             padding: const EdgeInsets.all(20),
                             decoration: BoxDecoration(
                               color: Colors.white.withOpacity(0.96),
                               borderRadius: BorderRadius.circular(28),
                               boxShadow: [
                                 BoxShadow(
                                   color: const Color(0xFF0C447C)
                                       .withOpacity(0.16),
                                   blurRadius: 34,
                                   offset: const Offset(0, 16),
                                 ),
                               ],
                             ),
                             child: Column(
                               children: [
                                 // ==================================================
                                 // CARD HEADER
                                 // ==================================================

                                 Row(
                                   children: [
                                     Container(
                                       width: 34,
                                       height: 34,
                                       decoration: BoxDecoration(
                                         borderRadius:
                                         BorderRadius.circular(11),
                                         gradient: const LinearGradient(
                                           begin: Alignment.topLeft,
                                           end: Alignment.bottomRight,
                                           colors: [
                                             Color(0xFFE6F1FB),
                                             Color(0xFFD3E9FA),
                                           ],
                                         ),
                                       ),
                                       child: const Icon(
                                         Icons.shield_outlined,
                                         size: 17,
                                         color: Color(0xFF185FA5),
                                       ),
                                     ),
                                     const SizedBox(width: 10),
                                     const Expanded(
                                       child: Column(
                                         crossAxisAlignment:
                                         CrossAxisAlignment.start,
                                         children: [
                                           Text(
                                             'Your details',
                                             style: TextStyle(
                                               fontSize: 15,
                                               fontWeight: FontWeight.w700,
                                               color: Color(0xFF1B1E30),
                                             ),
                                           ),
                                           Text(
                                             'Used only to verify this device',
                                             style: TextStyle(
                                               fontSize: 11,
                                               fontWeight: FontWeight.w500,
                                               color: Color(0xFF9AAFC2),
                                             ),
                                           ),
                                         ],
                                       ),
                                     ),
                                   ],
                                 ),

                                 const SizedBox(height: 16),

                                 // ==================================================
                                 // IMEI / UUID
                                 // ==================================================

                                 _buildTextField(
                                   controller: controller.imeiController,
                                   label: 'IMEI',
                                   hint: 'Device identifier',
                                   icon: Icons.smartphone_rounded,
                                   readOnly: true,
                                   isLocked: true,
                                 ),

                                 const SizedBox(height: 15),

                                 // ==================================================
                                 // MOBILE NUMBER
                                 // ==================================================

                                 _buildTextField(
                                   controller: controller.mobileController,
                                   label: 'Mobile Number',
                                   hint: 'Enter mobile number',
                                   icon: Icons.phone_outlined,
                                   keyboardType: TextInputType.phone,
                                   inputFormatters: [
                                     FilteringTextInputFormatter.digitsOnly,
                                     LengthLimitingTextInputFormatter(10),
                                   ],
                                 ),

                                 const SizedBox(height: 15),

                                 // ==================================================
                                 // USER ID
                                 // ==================================================

                                 _buildTextField(
                                   controller: controller.userIdController,
                                   label: 'User ID',
                                   hint: 'Enter your User ID',
                                   icon: Icons.person_outline_rounded,
                                 ),

                                 const SizedBox(height: 15),

                                 // ==================================================
                                 // PASSWORD
                                 // ==================================================

                                 _buildTextField(
                                   controller: controller.passwordController,
                                   label: 'Password',
                                   hint: 'Enter your password',
                                   icon: Icons.lock_outline_rounded,
                                   obscureText: obscurePassword,
                                   suffixIcon: IconButton(
                                     onPressed: () {
                                       setState(() {
                                         obscurePassword = !obscurePassword;
                                       });
                                     },
                                     icon: Icon(
                                       obscurePassword
                                           ? Icons.visibility_off_outlined
                                           : Icons.visibility_outlined,
                                       color: const Color(0xFF185FA5),
                                     ),
                                   ),
                                 ),

                                 const SizedBox(height: 22),

                                 // ==================================================
                                 // BUTTONS
                                 // ==================================================

                                 Row(
                                   children: [
                                     Expanded(
                                       flex: 4,
                                       child: SizedBox(
                                         height: 55,
                                         child: OutlinedButton(
                                           onPressed: loading ? null : reset,
                                           style: OutlinedButton.styleFrom(
                                             foregroundColor:
                                             const Color(0xFF185FA5),
                                             backgroundColor:
                                             const Color(0xFFF9FCFF),
                                             side: const BorderSide(
                                               color: Color(0xFFD6E8F5),
                                               width: 1.6,
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
                                                 size: 17,
                                               ),
                                               SizedBox(width: 6),
                                               Text(
                                                 'RESET',
                                                 style: TextStyle(
                                                   fontSize: 13,
                                                   fontWeight: FontWeight.w700,
                                                 ),
                                               ),
                                             ],
                                           ),
                                         ),
                                       ),
                                     ),
                                     const SizedBox(width: 12),
                                     Expanded(
                                       flex: 6,
                                       child: SizedBox(
                                         height: 55,
                                         child: DecoratedBox(
                                           decoration: BoxDecoration(
                                             borderRadius:
                                             BorderRadius.circular(16),
                                             gradient: loading
                                                 ? null
                                                 : const LinearGradient(
                                               begin:
                                               Alignment.centerLeft,
                                               end: Alignment
                                                   .centerRight,
                                               colors: [
                                                 Color(0xFF4FA8DE),
                                                 Color(0xFF185FA5),
                                                 Color(0xFF0C447C),
                                               ],
                                               stops: [0.0, 0.55, 1.0],
                                             ),
                                             boxShadow: loading
                                                 ? []
                                                 : [
                                               BoxShadow(
                                                 color: const Color(
                                                     0xFF185FA5)
                                                     .withOpacity(0.36),
                                                 blurRadius: 24,
                                                 offset:
                                                 const Offset(0, 12),
                                               ),
                                             ],
                                           ),
                                           child: ElevatedButton(
                                             onPressed:
                                             loading ? null : submit,
                                             style: ElevatedButton.styleFrom(
                                               backgroundColor: loading
                                                   ? const Color(0xFFAFCBE6)
                                                   : Colors.transparent,
                                               foregroundColor: Colors.white,
                                               elevation: 0,
                                               shadowColor: Colors.transparent,
                                               shape: RoundedRectangleBorder(
                                                 borderRadius:
                                                 BorderRadius.circular(16),
                                               ),
                                             ),
                                             child: loading
                                                 ? const SizedBox(
                                               width: 22,
                                               height: 22,
                                               child:
                                               CircularProgressIndicator(
                                                 strokeWidth: 2.5,
                                                 color: Colors.white,
                                               ),
                                             )
                                                 : const Row(
                                               mainAxisAlignment:
                                               MainAxisAlignment
                                                   .center,
                                               children: [
                                                 Text(
                                                   'SUBMIT',
                                                   style: TextStyle(
                                                     fontSize: 14,
                                                     fontWeight:
                                                     FontWeight.w800,
                                                     letterSpacing: 0.5,
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
                                 ),
                               ],
                             ),
                           ),

                           const SizedBox(height: 22),

                           // ==================================================
                           // SECURITY MESSAGE
                           // ==================================================

                           Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Container(
                                 width: 24,
                                 height: 24,
                                 decoration: const BoxDecoration(
                                   color: Color(0xFFE6F1FB),
                                   shape: BoxShape.circle,
                                 ),
                                 child: const Icon(
                                   Icons.verified_user_outlined,
                                   size: 13,
                                   color: Color(0xFF185FA5),
                                 ),
                               ),
                               const SizedBox(width: 8),
                               const Flexible(
                                 child: Text(
                                   'Your registration details are securely stored',
                                   textAlign: TextAlign.center,
                                   style: TextStyle(
                                     color: Color(0xFF0C447C),
                                     fontSize: 11,
                                     fontWeight: FontWeight.w600,
                                   ),
                                 ),
                               ),
                             ],
                           ),

                           const SizedBox(height: 12),
                         ],
                       ),
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
   // (drops are positioned only within top/side safe zones so
   //  they never render behind the opaque registration card)
   // ============================================================
   Widget _buildBackground(Size size) {
     return Positioned.fill(
       child: Stack(
         children: [
           // Base gradient — same milk theme as the other screens.
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
             height: size.height * 0.28,
             child: AnimatedBuilder(
               animation: _waveController,
               builder: (context, _) {
                 return CustomPaint(
                   painter: _WavesPainter(progress: _waveController.value),
                   size: Size(size.width, size.height * 0.28),
                 );
               },
             ),
           ),

           // Floating milk drops — kept along the edges / corners so
           // they stay visible instead of sitting behind the card.
           AnimatedBuilder(
             animation: _dropsController,
             builder: (context, _) {
               final t = _dropsController.value * 2 * math.pi;
               return Stack(
                 children: [
                   _floatingDrop(
                     right: size.width * 0.08,
                     top: size.height * 0.09,
                     dropSize: 16,
                     color: const Color(0xFF2E93CE),
                     opacity: 0.55,
                     phase: t,
                     amplitude: 11,
                   ),
                   _floatingDrop(
                     left: size.width * 0.07,
                     top: size.height * 0.16,
                     dropSize: 12,
                     color: const Color(0xFF1D9E75),
                     opacity: 0.5,
                     phase: t + 1.4,
                     amplitude: 9,
                   ),
                   _floatingDrop(
                     right: size.width * 0.06,
                     bottom: size.height * 0.14,
                     dropSize: 11,
                     color: const Color(0xFF2E93CE),
                     opacity: 0.4,
                     phase: t + 2.6,
                     amplitude: 8,
                   ),
                   _floatingDrop(
                     left: size.width * 0.10,
                     bottom: size.height * 0.06,
                     dropSize: 14,
                     color: const Color(0xFF1D9E75),
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
               color: color.withOpacity(opacity),
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
         final blur = 26 + glow * 10;
         final glowOpacity = 0.10 + glow * 0.14;

         return Container(
           decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(20),
             boxShadow: [
               BoxShadow(
                 color: const Color(0xFF2E93CE).withOpacity(glowOpacity),
                 blurRadius: blur,
                 offset: const Offset(0, 10),
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
                   height: 150,
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

   // ==========================================================
   // TEXT FIELD
   // ==========================================================

   Widget _buildTextField({
     required TextEditingController controller,
     required String label,
     required String hint,
     required IconData icon,
     bool readOnly = false,
     bool obscureText = false,
     bool isLocked = false,
     TextInputType? keyboardType,
     Widget? suffixIcon,
     int? maxLength,
     List<TextInputFormatter>? inputFormatters,
   }) {
     // Locked fields (e.g. read-only IMEI) get a muted look with a
     // trailing lock icon, to visually signal they can't be edited.
     final Color iconColor =
     isLocked ? const Color(0xFF7C93A6) : const Color(0xFF185FA5);
     final Color fillColor =
     isLocked ? const Color(0xFFF5FAFE) : const Color(0xFFF2F9FF);
     final Color borderColor =
     isLocked ? const Color(0xFFE1EEF7) : const Color(0xFFD6E8F5);

     return SizedBox(
       height: 64,
       child: TextField(
         controller: controller,
         readOnly: readOnly,
         obscureText: obscureText,
         keyboardType: keyboardType,
         maxLength: maxLength,
         inputFormatters: inputFormatters,
         style: TextStyle(
           fontSize: 15,
           fontWeight: FontWeight.w600,
           color: isLocked ? const Color(0xFF7C93A6) : const Color(0xFF263746),
         ),
         decoration: InputDecoration(
           labelText: label,
           hintText: hint,
           counterText: '',
           prefixIcon: Icon(
             icon,
             color: iconColor,
           ),
           suffixIcon: suffixIcon ??
               (isLocked
                   ? const Icon(
                 Icons.lock_outline_rounded,
                 size: 17,
                 color: Color(0xFFC3D2DD),
               )
                   : null),
           filled: true,
           fillColor: fillColor,
           labelStyle: TextStyle(
             color: iconColor,
             fontWeight: FontWeight.w600,
           ),
           hintStyle: const TextStyle(
             color: Color(0xFFA9C1D6),
             fontSize: 13.5,
           ),
           contentPadding: const EdgeInsets.symmetric(
             horizontal: 18,
             vertical: 18,
           ),
           enabledBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(18),
             borderSide: BorderSide(
               color: borderColor,
               width: 1,
             ),
           ),
           focusedBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(18),
             borderSide: const BorderSide(
               color: Color(0xFF185FA5),
               width: 1.7,
             ),
           ),
           border: OutlineInputBorder(
             borderRadius: BorderRadius.circular(18),
           ),
         ),
       ),
     );
   }

   @override
   void dispose() {
     controller.dispose();
     _waveController.dispose();
     _dropsController.dispose();
     _logoController.dispose();
     super.dispose();
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
