import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/application_constant.dart';
import 'preference_service.dart';

class DemandOrderService {
  DemandOrderService._();

  // --------------------------------------------------------
  // SYNC PRODUCTS API
  // --------------------------------------------------------

  static Future<Map<String, dynamic>?> syncProducts() async {
    try {
      // ------------------------------------------------------
      // 1. Get registered IMEI from SharedPreferences
      // ------------------------------------------------------

      final imei = await PreferenceService.getDeviceImei();

      if (imei == null || imei.trim().isEmpty) {
        debugPrint('================================');
        debugPrint('SYNC PRODUCTS API');
        debugPrint('IMEI NOT FOUND');
        debugPrint('Something went wrong from server');
        debugPrint('================================');

        return null;
      }

      // ------------------------------------------------------
      // 2. Create API URL
      // ------------------------------------------------------

      final url = Uri.parse(
        '${ApplicationConstant.defaultBaseUrl}'
        '${ApplicationConstant.syncDataAsp}',
      );

      // ------------------------------------------------------
      // 3. Call API
      // ------------------------------------------------------

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {
             'cmd': 'SYNCPRODUCTS',
              'imei': imei,
              'verno': '3.4'
            },
          )
          .timeout(ApplicationConstant.volleyTimeout);

      // ------------------------------------------------------
      // 4. Print API response
      // ------------------------------------------------------

      debugPrint('================================');
      debugPrint('SYNC PRODUCTS API RESPONSE');
      debugPrint('URL: $url');
      debugPrint('STATUS CODE: ${response.statusCode}');
      debugPrint('RESPONSE:');
      debugPrint(response.body);
      debugPrint('================================');

      // ------------------------------------------------------
      // 5. HTTP status validation
      // ------------------------------------------------------

      if (response.statusCode != 200) {
        debugPrint('Something went wrong from server');
        return null;
      }

      // ------------------------------------------------------
      // 6. Empty response validation
      // ------------------------------------------------------

      if (response.body.trim().isEmpty) {
        debugPrint('Something went wrong from server');
        return null;
      }

      // ------------------------------------------------------
      // 7. Convert response into JSON
      // ------------------------------------------------------

      final decoded = jsonDecode(response.body);

      // ------------------------------------------------------
      // 8. Response must be an object
      // ------------------------------------------------------

      if (decoded is! Map) {
        debugPrint('Invalid product response format');
        debugPrint('Something went wrong from server');
        return null;
      }

      final data = Map<String, dynamic>.from(decoded);

      // ------------------------------------------------------
      // 9. Basic response validation
      //
      // Expected:
      // Products       -> Array
      // ProductGroups  -> Array
      // ------------------------------------------------------

      final products = data['Products'];
      final productGroups = data['ProductGroups'];

      if (products is! List) {
        debugPrint('Products array not found');
        debugPrint('Something went wrong from server');
        return null;
      }

      if (productGroups is! List) {
        debugPrint('ProductGroups array not found');
        debugPrint('Something went wrong from server');
        return null;
      }

      // ------------------------------------------------------
      // 10. Print basic response information
      // ------------------------------------------------------

      debugPrint('================================');
      debugPrint('SYNC PRODUCTS VALIDATION SUCCESS');
      debugPrint('TOTAL PRODUCTS: ${products.length}');
      debugPrint('TOTAL PRODUCT GROUPS: ${productGroups.length}');
      debugPrint('================================');

      // ------------------------------------------------------
      // 11. Return parsed response
      // ------------------------------------------------------

      return data;
    } catch (e, stackTrace) {
      // ------------------------------------------------------
      // API / Network / JSON error
      // ------------------------------------------------------

      debugPrint('================================');
      debugPrint('SYNC PRODUCTS API ERROR');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE:');
      debugPrint('$stackTrace');
      debugPrint('================================');

      return null;
    }
  }

  // --------------------------------------------------------
  // ASM ORDERS API
  // --------------------------------------------------------

  static Future<String?> asmOrders({
    required String distCode,
    required String shift,
  }) async {
    try {
      // ------------------------------------------------------
      // 1. Get registered IMEI from SharedPreferences
      // ------------------------------------------------------

      final imei = await PreferenceService.getDeviceImei();

      if (imei == null || imei.trim().isEmpty) {
        debugPrint('================================');
        debugPrint('ASM ORDERS API');
        debugPrint('IMEI NOT FOUND');
        debugPrint('Something went wrong from server');
        debugPrint('================================');

        return null;
      }

      // ------------------------------------------------------
      // 2. Create API URL
      // ------------------------------------------------------

      final url = Uri.parse(
        '${ApplicationConstant.defaultBaseUrl}'
        '${ApplicationConstant.syncDataAsp}',
      );

      // ------------------------------------------------------
      // 3. Call API
      // ------------------------------------------------------

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {
              'cmd': 'ASMORDERS',
              'imei': imei,
              'distcode': distCode,
              'shift': shift,
            },
          )
          .timeout(ApplicationConstant.volleyTimeout);

      // ------------------------------------------------------
      // 4. Print request + response
      // ------------------------------------------------------

      debugPrint('================================');
      debugPrint('ASM ORDERS API');
      debugPrint('URL: $url');
      debugPrint('CMD: ASMORDERS');
      debugPrint('IMEI: $imei');
      debugPrint('DISTCODE: $distCode');
      debugPrint('SHIFT: $shift');
      debugPrint('STATUS CODE: ${response.statusCode}');
      debugPrint('RESPONSE:');
      debugPrint(response.body);
      debugPrint('================================');

      // ------------------------------------------------------
      // 5. Status validation
      // ------------------------------------------------------

      if (response.statusCode != 200) {
        debugPrint('ASM ORDERS API FAILED');
        debugPrint('Something went wrong from server');

        return null;
      }

      // ------------------------------------------------------
      // 6. Empty response validation
      // ------------------------------------------------------

      if (response.body.trim().isEmpty) {
        debugPrint('ASM ORDERS API EMPTY RESPONSE');
        debugPrint('Something went wrong from server');

        return null;
      }

      // ------------------------------------------------------
      // 7. Return response
      // ------------------------------------------------------

      return response.body;
    } catch (e, stackTrace) {
      debugPrint('================================');
      debugPrint('ASM ORDERS API ERROR');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE:');
      debugPrint('$stackTrace');
      debugPrint('================================');

      return null;
    }
  }


  // --------------------------------------------------------
  // REPEAT YESTERDAY API
  // --------------------------------------------------------

  static Future<String?> repeatYesterday({
    required String distCode,
    required String shift,
  }) async {
    try {
      // ------------------------------------------------------
      // 1. Get registered IMEI
      // ------------------------------------------------------

      final imei = await PreferenceService.getDeviceImei();

      if (imei == null || imei.trim().isEmpty) {
        debugPrint('================================');
        debugPrint('REPEAT YESTERDAY API');
        debugPrint('IMEI NOT FOUND');
        debugPrint('Something went wrong from server');
        debugPrint('================================');

        return null;
      }

      // ------------------------------------------------------
      // 2. Create API URL
      // ------------------------------------------------------

      final url = Uri.parse(
        '${ApplicationConstant.defaultBaseUrl}'
            '${ApplicationConstant.syncDataAsp}',
      );

      // ------------------------------------------------------
      // 3. Call API
      // ------------------------------------------------------

      final response = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'cmd': 'yesterorder',
          'imei': imei,
          'shift': shift,
          'distcode': distCode,
        },
      )
          .timeout(ApplicationConstant.volleyTimeout);

      // ------------------------------------------------------
      // 4. Print request + response
      // ------------------------------------------------------

      debugPrint('================================');
      debugPrint('REPEAT YESTERDAY API');
      debugPrint('URL: $url');
      debugPrint('CMD: yesterorder');
      debugPrint('IMEI: $imei');
      debugPrint('SHIFT: $shift');
      debugPrint('DISTCODE: $distCode');
      debugPrint('STATUS CODE: ${response.statusCode}');
      debugPrint('RESPONSE:');
      debugPrint(response.body);
      debugPrint('================================');

      // ------------------------------------------------------
      // 5. HTTP status validation
      // ------------------------------------------------------

      if (response.statusCode != 200) {
        debugPrint('REPEAT YESTERDAY API FAILED');
        debugPrint('Something went wrong from server');

        return null;
      }

      // ------------------------------------------------------
      // 6. Empty response validation
      // ------------------------------------------------------

      if (response.body.trim().isEmpty) {
        debugPrint('REPEAT YESTERDAY API EMPTY RESPONSE');
        debugPrint('Something went wrong from server');

        return null;
      }

      // ------------------------------------------------------
      // 7. Return raw JSON response
      // ------------------------------------------------------

      return response.body;
    } catch (e, stackTrace) {
      debugPrint('================================');
      debugPrint('REPEAT YESTERDAY API ERROR');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE:');
      debugPrint('$stackTrace');
      debugPrint('================================');

      return null;
    }
  }

  // --------------------------------------------------------
  // SUBMIT ORDER API
  // --------------------------------------------------------

  static Future<Map<String, dynamic>?> submitOrder({
    required String xmlstr,
  }) async {
    try {
      // ------------------------------------------------------
      // 1. Get registered IMEI from SharedPreferences
      // ------------------------------------------------------

      final imei = await PreferenceService.getDeviceImei();

      if (imei == null || imei.trim().isEmpty) {
        debugPrint('================================');
        debugPrint('SUBMIT ORDER API');
        debugPrint('IMEI NOT FOUND');
        debugPrint('================================');

        return {
          'success': false,
          'statusCode': null,
          'message': 'IMEI not found',
          'body': '',
        };
      }

      // ------------------------------------------------------
      // 2. Create API URL
      // ------------------------------------------------------

      final url = Uri.parse(
        '${ApplicationConstant.defaultBaseUrl}'
            'syncdata2.asp',
      );

      // ------------------------------------------------------
      // 3. Call API
      // ------------------------------------------------------

      final response = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'cmd': 'syncordernew1',
          'ver': '3.5',
          'imei': imei,
          'xmlstr': xmlstr,
        },
      )
          .timeout(ApplicationConstant.volleyTimeout);

      // ------------------------------------------------------
      // 4. Print request + response
      // ------------------------------------------------------

      debugPrint('================================');
      debugPrint('SUBMIT ORDER API');
      debugPrint('URL: $url');
      debugPrint('CMD: syncordernew1');
      debugPrint('VER: 3.5');
      debugPrint('IMEI: $imei');
      debugPrint('XML LENGTH: ${xmlstr.length}');
      debugPrint('STATUS CODE: ${response.statusCode}');
      debugPrint('RESPONSE:');
      debugPrint(response.body);
      debugPrint('================================');

      // ------------------------------------------------------
      // 5. Return API result
      // ------------------------------------------------------

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'message': '',
        'body': response.body,
      };
    } catch (e, stackTrace) {
      debugPrint('================================');
      debugPrint('SUBMIT ORDER API ERROR');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE:');
      debugPrint('$stackTrace');
      debugPrint('================================');

      return {
        'success': false,
        'statusCode': null,
        'message': e.toString(),
        'body': '',
      };
    }


  }
  // --------------------------------------------------------
  // CHECK TARGET API
  // --------------------------------------------------------

  static Future<Map<String, dynamic>?> checkTarget({
    required int distCode,
    required String odate,
  }) async {
    try {
      // ------------------------------------------------------
      // 1. Get registered IMEI from SharedPreferences
      // ------------------------------------------------------

      final imei = await PreferenceService.getDeviceImei();

      if (imei == null || imei.trim().isEmpty) {
        debugPrint('================================');
        debugPrint('CHECK TARGET API');
        debugPrint('IMEI NOT FOUND');
        debugPrint('Something went wrong from server');
        debugPrint('================================');

        return null;
      }

      // ------------------------------------------------------
      // 2. Create API URL
      // ------------------------------------------------------

      final url = Uri.parse(
        '${ApplicationConstant.defaultBaseUrl}'
            '${ApplicationConstant.syncDataAsp}',
      );

      // ------------------------------------------------------
      // 3. Call API
      // ------------------------------------------------------

      final response = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'cmd': 'TARGETSUMMARY',
          'distcode': distCode.toString(),
          'imei': imei,
          'ver': '3.5',
          'odate': odate,
        },
      )
          .timeout(ApplicationConstant.volleyTimeout);

      // ------------------------------------------------------
      // 4. Print request + response
      // ------------------------------------------------------

      debugPrint('================================');
      debugPrint('CHECK TARGET API');
      debugPrint('URL: $url');
      debugPrint('CMD: TARGETSUMMARY');
      debugPrint('DISTCODE: $distCode');
      debugPrint('IMEI: $imei');
      debugPrint('VER: 3.5');
      debugPrint('ODATE: $odate');
      debugPrint('STATUS CODE: ${response.statusCode}');
      debugPrint('RESPONSE:');
      debugPrint(response.body);
      debugPrint('================================');

      // ------------------------------------------------------
      // 5. HTTP status validation
      // ------------------------------------------------------

      if (response.statusCode != 200) {
        debugPrint('CHECK TARGET API FAILED');
        debugPrint('Something went wrong from server');

        return null;
      }

      // ------------------------------------------------------
      // 6. Empty response validation
      // ------------------------------------------------------

      if (response.body.trim().isEmpty) {
        debugPrint('CHECK TARGET API EMPTY RESPONSE');
        debugPrint('Something went wrong from server');

        return null;
      }

      // ------------------------------------------------------
      // 7. Convert response into JSON
      // ------------------------------------------------------

      final decoded = jsonDecode(response.body);

      // ------------------------------------------------------
      // 8. Response must be an object
      // ------------------------------------------------------

      if (decoded is! Map) {
        debugPrint('Invalid target response format');
        debugPrint('Something went wrong from server');

        return null;
      }

      // ------------------------------------------------------
      // 9. Return parsed response
      // ------------------------------------------------------

      return Map<String, dynamic>.from(decoded);
    } catch (e, stackTrace) {
      debugPrint('================================');
      debugPrint('CHECK TARGET API ERROR');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE:');
      debugPrint('$stackTrace');
      debugPrint('================================');

      return null;
    }
  }


}
