import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/application_constant.dart';
import '../models/device_registration_response.dart';

class DeviceRegistrationService {
  DeviceRegistrationService._();

  static Future<DeviceRegistrationResponse?> registerDevice({
    required String baseUrl,
    required String imei,
    required String mobileNumber,
    required String userId,
    required String password,
  }) async {
    // ==========================================
    // CREATE URL
    // ==========================================

    final cleanBaseUrl = baseUrl.replaceFirst(
      RegExp(r'/+$'),
      '',
    );

    final url =
        '$cleanBaseUrl/${ApplicationConstant.qerpAppAsp}';

    try {
      // ==========================================
      // API CALL
      // ==========================================

      final response = await http
          .post(
        Uri.parse(url),
        body: {
          'reg': '1',
          'imei': imei,
          'mobileno': mobileNumber,
          'loginname': userId,
          'password': password,
        },
      )
          .timeout(
        ApplicationConstant.volleyTimeout,
      );

      // ==========================================
      // RESPONSE LOG
      // ==========================================

      debugPrint(
        '========== DEVICE REGISTRATION RESPONSE ==========',
      );

      debugPrint(
        'STATUS CODE: ${response.statusCode}',
      );

      debugPrint(
        'RESPONSE: ${response.body}',
      );

      debugPrint(
        '===================================================',
      );

      // ==========================================
      // STATUS CODE VALIDATION
      // ONLY HTTP 200 IS ALLOWED
      // ==========================================

      if (response.statusCode != 200) {
        return null;
      }

      // ==========================================
      // RESPONSE BODY
      // ==========================================

      final responseBody = response.body.trim();

      if (responseBody.isEmpty) {
        return null;
      }

      // ==========================================
      // JSON DECODE
      // ==========================================

      dynamic decodedResponse;

      try {
        decodedResponse = jsonDecode(responseBody);
      } catch (_) {
        // Invalid JSON
        return null;
      }

      // ==========================================
      // EMPTY OBJECT
      // {}
      // ==========================================

      if (decodedResponse is Map &&
          decodedResponse.isEmpty) {
        return null;
      }

      // ==========================================
      // EMPTY ARRAY
      // []
      // ==========================================

      if (decodedResponse is List &&
          decodedResponse.isEmpty) {
        return null;
      }

      // ==========================================
      // ARRAY CONTAINING EMPTY OBJECT
      // [{}]
      // ==========================================

      if (decodedResponse is List) {
        final containsEmptyObject =
        decodedResponse.any(
              (item) =>
          item is Map &&
              item.isEmpty,
        );

        if (containsEmptyObject) {
          return null;
        }
      }

      // ==========================================
      // USER MASTER RESPONSE
      // ==========================================

      if (decodedResponse is! Map) {
        return null;
      }

      final userMaster =
      decodedResponse['UserMaster'];

      // ==========================================
      // USERMASTER VALIDATION
      // ==========================================

      if (userMaster is! List ||
          userMaster.isEmpty) {
        return null;
      }

      // ==========================================
      // FIRST USERMASTER OBJECT
      // ==========================================

      final data = userMaster[0];

      if (data is! Map ||
          data.isEmpty) {
        return null;
      }

      // ==========================================
      // STORE RESPONSE VALUES
      // ==========================================

      final String expDate =
          data['expdate']?.toString().trim() ?? '';

      final String userType =
          data['usertype']?.toString().trim() ?? '';

      final String errType =
          data['errtype']?.toString().trim() ?? '';

      final String msg =
          data['msg']?.toString().trim() ?? '';

      final String title =
          data['title']?.toString().trim() ?? '';

      // ==========================================
      // VARIABLE LOG
      // ==========================================

      debugPrint(
        '========== DEVICE REGISTRATION DATA ==========',
      );

      debugPrint(
        'EXPDATE: [$expDate]',
      );

      debugPrint(
        'USERTYPE: [$userType]',
      );

      debugPrint(
        'ERRTYPE: [$errType]',
      );

      debugPrint(
        'MSG: [$msg]',
      );

      debugPrint(
        'TITLE: [$title]',
      );

      debugPrint(
        '==============================================',
      );

      // ==========================================
      // RETURN RESPONSE DATA
      // ==========================================

      return DeviceRegistrationResponse(
        expDate: expDate,
        userType: userType,
        errType: errType,
        msg: msg,
        title: title,
      );
    } catch (e) {
      // ==========================================
      // API / NETWORK ERROR
      // ==========================================

      debugPrint(
        'DEVICE REGISTRATION ERROR: $e',
      );

      return null;
    }
  }
}