import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/application_constant.dart';
import 'preference_service.dart';

class MenuService {
  MenuService._();

  static Future<List<String>> getUserApps() async {
    try {
      // --------------------------------------------------------
      // 1. Get registered IMEI from SharedPreferences
      // --------------------------------------------------------

      final imei = await PreferenceService.getDeviceImei();

      if (imei == null || imei.trim().isEmpty) {
        debugPrint('================================');
        debugPrint('GET USER APPS API');
        debugPrint('IMEI NOT FOUND');
        debugPrint('Something went wrong from server');
        debugPrint('================================');

        return [];
      }

      // --------------------------------------------------------
      // 2. Create API URL
      // --------------------------------------------------------

      final url = Uri.parse(
        '${ApplicationConstant.defaultBaseUrl}'
            '${ApplicationConstant.syncDataAsp}',
      );

      // --------------------------------------------------------
      // 3. Call API
      // --------------------------------------------------------

      final response = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'cmd': 'getuserapps',
           'imei': imei,
          'verno': '3.4',
        },
      )
          .timeout(
        ApplicationConstant.volleyTimeout,
      );

      // --------------------------------------------------------
      // 4. Print API response in console
      // --------------------------------------------------------

      debugPrint('================================');
      debugPrint('GET USER APPS API RESPONSE');
      debugPrint('URL: $url');
      debugPrint('STATUS CODE: ${response.statusCode}');
      debugPrint('RESPONSE:');
      debugPrint(response.body);
      debugPrint('================================');

      // --------------------------------------------------------
      // 5. Status code check
      // --------------------------------------------------------

      if (response.statusCode != 200) {
        debugPrint('Something went wrong from server');
        return [];
      }

      // --------------------------------------------------------
      // 6. Empty response check
      // --------------------------------------------------------

      if (response.body.trim().isEmpty) {
        debugPrint('Something went wrong from server');
        return [];
      }

      // --------------------------------------------------------
      // 7. Convert response into JSON
      // --------------------------------------------------------

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        debugPrint('Something went wrong from server');
        return [];
      }

      // --------------------------------------------------------
      // 8. Check server message
      // --------------------------------------------------------

      if (decoded['msg'] != 'SUCCESS') {
        debugPrint('Something went wrong from server');
        return [];
      }

      // --------------------------------------------------------
      // 9. Get Menu array
      // --------------------------------------------------------

      final menu = decoded['Menu'];

      if (menu is! List) {
        debugPrint('Something went wrong from server');
        return [];
      }

      // --------------------------------------------------------
      // 10. Extract appmenu from Menu
      // --------------------------------------------------------

      final List<String> menuItems = [];

      for (final item in menu) {
        if (item is Map && item['appmenu'] is String) {
          final appMenu = item['appmenu'].toString().trim();

          if (appMenu.isNotEmpty) {
            menuItems.add(appMenu);
          }
        }
      }

      // --------------------------------------------------------
      // 11. Menu empty check
      // --------------------------------------------------------

      if (menuItems.isEmpty) {
        debugPrint('Something went wrong from server');
        return [];
      }

      // --------------------------------------------------------
      // 12. Print parsed menu items
      // --------------------------------------------------------

      debugPrint('================================');
      debugPrint('MENU ITEMS');
      debugPrint('================================');

      for (final item in menuItems) {
        debugPrint(item);
      }

      debugPrint('================================');

      // --------------------------------------------------------
      // 13. Return menu items to MenuScreen
      // --------------------------------------------------------

      return menuItems;
    } catch (e, stackTrace) {
      // --------------------------------------------------------
      // API / JSON / Network error
      // --------------------------------------------------------

      debugPrint('================================');
      debugPrint('GET USER APPS API ERROR');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE:');
      debugPrint('$stackTrace');
      debugPrint('================================');

      return [];
    }
  }
}