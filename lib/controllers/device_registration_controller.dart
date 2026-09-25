// first time used code




// import 'package:flutter/material.dart';
//
// import '../models/device_registration_model.dart';
// import '../services/device_id_service.dart';
// import '../services/preference_service.dart';
//
// class DeviceRegistrationController {
// final TextEditingController imeiController =
// TextEditingController();
//
// final TextEditingController userIdController =
// TextEditingController();
//
// final TextEditingController mobileController =
// TextEditingController();
//
// final TextEditingController passwordController =
// TextEditingController();
//
// Future<void> initialize() async {
// final imei =
// await DeviceIdService.getOrCreateDeviceId();
//
// imeiController.text = imei;
// }
//
// bool validate() {
// if (userIdController.text.trim().isEmpty) {
// return false;
// }
//
// if (mobileController.text.trim().isEmpty) {
// return false;
// }
//
// if (passwordController.text.isEmpty) {
// return false;
// }
//
// return true;
// }
//
// DeviceRegistrationModel get registrationData {
// return DeviceRegistrationModel(
// imei: imeiController.text.trim(),
// userId: userIdController.text.trim(),
// mobileNumber: mobileController.text.trim(),
// password: passwordController.text,
// );
// }
//
// Future<bool> submitRegistration() async {
// if (!validate()) {
// return false;
// }
//
// final data = registrationData;
//
// final baseUrl =
// await PreferenceService.getBaseUrl();
//
// if (baseUrl == null || baseUrl.isEmpty) {
// return false;
// }
//
// await PreferenceService.saveRegistrationData(
// imei: data.imei,
// userId: data.userId,
// mobileNumber: data.mobileNumber,
// password: data.password,
// );
//
// return true;
// }
//
// void reset() {
// mobileController.clear();
// userIdController.clear();
// passwordController.clear();
//
// // IMEI intentionally clear nahi hoga.
// }
//
// void dispose() {
// imeiController.dispose();
// userIdController.dispose();
// mobileController.dispose();
// passwordController.dispose();
// }
// }







// main working code


// import 'package:flutter/material.dart';
//
// import '../models/device_registration_model.dart';
// import '../models/device_registration_response.dart';
// import '../services/device_id_service.dart';
// import '../services/preference_service.dart';
// import '../services/device_registration_service.dart';
//
// class DeviceRegistrationController {
// final TextEditingController imeiController =
// TextEditingController();
//
// final TextEditingController userIdController =
// TextEditingController();
//
// final TextEditingController mobileController =
// TextEditingController();
//
// final TextEditingController passwordController =
// TextEditingController();
//
// Future<void> initialize() async {
// final imei =
// await DeviceIdService.getOrCreateDeviceId();
//
// imeiController.text = imei;
// }
//
// bool validate() {
// if (userIdController.text.trim().isEmpty) {
// return false;
// }
//
// if (mobileController.text.trim().isEmpty) {
// return false;
// }
//
// if (passwordController.text.isEmpty) {
// return false;
// }
//
// return true;
// }
//
// DeviceRegistrationModel get registrationData {
// return DeviceRegistrationModel(
// imei: imeiController.text.trim(),
// userId: userIdController.text.trim(),
// mobileNumber: mobileController.text.trim(),
// password: passwordController.text,
// );
// }
//
// Future<DeviceRegistrationResponse?> submitRegistration() async {
// if (!validate()) {
// return null;
// }
//
// final data = registrationData;
//
// final baseUrl =
// await PreferenceService.getBaseUrl();
//
// if (baseUrl == null || baseUrl.isEmpty) {
// debugPrint(
// 'DEVICE REGISTRATION: Base URL not found.',
// );
//
// return null;
// }
//
// // ==================================================
// // API CALL
// // ==================================================
//
// final response =
// await DeviceRegistrationService.registerDevice(
// baseUrl: baseUrl,
// imei: data.imei,
// mobileNumber: data.mobileNumber,
// userId: data.userId,
// password: data.password,
// );
//
// // ==================================================
// // API FAILED
// // ==================================================
//
// if (response == null) {
// debugPrint(
// 'DEVICE REGISTRATION: API call failed.',
// );
//
// return null;
// }
//
// // ==================================================
// // EXPDATE IS NOT BLANK
// // ==================================================
//
// if (response.expDate.isNotEmpty) {
// // =================================================
// // MSG == Registered
// // =================================================
//
// if (response.msg == 'Registered') {
// debugPrint(
// 'DEVICE REGISTRATION: Registered successfully.',
// );
//
// // ==============================================
// // SAVE REGISTRATION DATA
// // ==============================================
//
// await PreferenceService.saveRegistrationData(
// imei: data.imei,
// userId: data.userId,
// mobileNumber: data.mobileNumber,
// password: data.password,
//   userType: response.userType,
// );
//
// return response;
// }
//
// return response;
// }
//
// // ==================================================
// // EXPDATE IS BLANK
// // ERRORTYPE == OTP
// // ==================================================
//
// if (response.errType == 'OTP') {
// debugPrint(
// 'DEVICE REGISTRATION: OTP verification required.',
// );
//
// return response;
// }
//
// // ==================================================
// // EXPDATE IS BLANK
// // ERRORTYPE != OTP
// // ==================================================
//
// debugPrint(
// 'DEVICE REGISTRATION MESSAGE: ${response.msg}',
// );
//
// return response;
// }
//
// void reset() {
// mobileController.clear();
// userIdController.clear();
// passwordController.clear();
//
// // IMEI intentionally clear nahi hoga.
// }
//
// void dispose() {
// imeiController.dispose();
// userIdController.dispose();
// mobileController.dispose();
// passwordController.dispose();
// }
// }
//



// debug wala test krne ke liye  console me
import 'package:flutter/material.dart';

import '../models/device_registration_model.dart';
import '../models/device_registration_response.dart';
import '../services/device_id_service.dart';
import '../services/preference_service.dart';
import '../services/device_registration_service.dart';

class DeviceRegistrationController {
  final TextEditingController imeiController =
  TextEditingController();

  final TextEditingController userIdController =
  TextEditingController();

  final TextEditingController mobileController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  Future<void> initialize() async {
    final imei =
    await DeviceIdService.getOrCreateDeviceId();

    imeiController.text = imei;
  }

  bool validate() {
    if (userIdController.text.trim().isEmpty) {
      return false;
    }

    if (mobileController.text.trim().isEmpty) {
      return false;
    }

    if (passwordController.text.isEmpty) {
      return false;
    }

    return true;
  }

  DeviceRegistrationModel get registrationData {
    return DeviceRegistrationModel(
      imei: imeiController.text.trim(),
      userId: userIdController.text.trim(),
      mobileNumber: mobileController.text.trim(),
      password: passwordController.text,
    );
  }

  Future<DeviceRegistrationResponse?> submitRegistration() async {
    if (!validate()) {
      return null;
    }

    final data = registrationData;

    final baseUrl =
    await PreferenceService.getBaseUrl();

    if (baseUrl == null || baseUrl.isEmpty) {
      debugPrint(
        'DEVICE REGISTRATION: Base URL not found.',
      );

      return null;
    }

    // ==================================================
    // API CALL
    // ==================================================

    final response =
    await DeviceRegistrationService.registerDevice(
      baseUrl: baseUrl,
      imei: data.imei,
      mobileNumber: data.mobileNumber,
      userId: data.userId,
      password: data.password,
    );

    // ==================================================
    // API FAILED
    // ==================================================

    if (response == null) {
      debugPrint(
        'DEVICE REGISTRATION: API call failed.',
      );

      return null;
    }

    // ==================================================
    // EXPDATE IS NOT BLANK
    // ==================================================

    if (response.expDate.isNotEmpty) {
      // =================================================
      // MSG == Registered
      // =================================================

      if (response.msg == 'Registered') {
        debugPrint(
          'DEVICE REGISTRATION: Registered successfully.',
        );

        // ==============================================
        // SAVE REGISTRATION DATA
        // ==============================================

        await PreferenceService.saveRegistrationData(
          imei: data.imei,
          userId: data.userId,
          mobileNumber: data.mobileNumber,
          password: data.password,
          userType: response.userType,
        );

        // ==============================================
        // DEBUG SAVED DATA
        // ==============================================

        await PreferenceService
            .debugPrintRegistrationData();

        return response;
      }

      return response;
    }

    // ==================================================
    // EXPDATE IS BLANK
    // ERRORTYPE == OTP
    // ==================================================

    if (response.errType == 'OTP') {
      debugPrint(
        'DEVICE REGISTRATION: OTP verification required.',
      );

      return response;
    }

    // ==================================================
    // EXPDATE IS BLANK
    // ERRORTYPE != OTP
    // ==================================================

    debugPrint(
      'DEVICE REGISTRATION MESSAGE: ${response.msg}',
    );

    return response;
  }

  void reset() {
    mobileController.clear();
    userIdController.clear();
    passwordController.clear();

    // IMEI intentionally clear nahi hoga.
  }

  void dispose() {
    imeiController.dispose();
    userIdController.dispose();
    mobileController.dispose();
    passwordController.dispose();
  }
}