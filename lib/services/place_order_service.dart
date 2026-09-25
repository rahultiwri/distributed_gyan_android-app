import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/application_constant.dart';
import '../models/customer_model.dart';
import 'preference_service.dart';

class PlaceOrderService {
  PlaceOrderService._();

  // --------------------------------------------------------
  // SYNC CUSTOMER API
  // --------------------------------------------------------

  static Future<Map<int, CustomerModel>> syncCustomers() async {
    try {
      // ------------------------------------------------------
      // 1. Get registered IMEI from SharedPreferences
      // ------------------------------------------------------

      final imei = await PreferenceService.getDeviceImei();

      if (imei == null || imei.trim().isEmpty) {
        debugPrint('================================');
        debugPrint('SYNC CUSTOMER API');
        debugPrint('IMEI NOT FOUND');
        debugPrint('Something went wrong from server');
        debugPrint('================================');

        return {};
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
         'cmd': 'synccust',
          'imei': imei,
          'verno': '3.4',
        },
      )
          .timeout(
        ApplicationConstant.volleyTimeout,
      );

      // ------------------------------------------------------
      // 4. Print API response in console
      // ------------------------------------------------------

      debugPrint('================================');
      debugPrint('SYNC CUSTOMER API RESPONSE');
      debugPrint('URL: $url');
      debugPrint('STATUS CODE: ${response.statusCode}');
      debugPrint('RESPONSE:');
      debugPrint(response.body);
      debugPrint('================================');

      // ------------------------------------------------------
      // 5. Status code check
      // ------------------------------------------------------

      if (response.statusCode != 200) {
        debugPrint('Something went wrong from server');
        return {};
      }

      // ------------------------------------------------------
      // 6. Empty response check
      // ------------------------------------------------------

      if (response.body.trim().isEmpty) {
        debugPrint('Something went wrong from server');
        return {};
      }

      // ------------------------------------------------------
      // 7. Convert response into JSON
      // ------------------------------------------------------

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        debugPrint('Something went wrong from server');
        return {};
      }

      // ------------------------------------------------------
      // 8. Check server message
      //
      // Place Order API expects:
      // "msg": "OK"
      // ------------------------------------------------------

      final serverMessage =
      decoded['msg']?.toString().trim();

      if (serverMessage != 'OK') {
        debugPrint(
          'SERVER MESSAGE IS NOT OK: $serverMessage',
        );
        debugPrint('Something went wrong from server');
        return {};
      }

      // ------------------------------------------------------
      // 9. Get Customer array
      // ------------------------------------------------------

      final customer = decoded['Customer'];

      if (customer is! List) {
        debugPrint('Customer array not found');
        debugPrint('Something went wrong from server');
        return {};
      }

      // ------------------------------------------------------
      // 10. Customer array empty check
      // ------------------------------------------------------

      if (customer.isEmpty) {
        debugPrint('Customer array is empty');
        debugPrint('Something went wrong from server');
        return {};
      }

      // ------------------------------------------------------
      // 11. Convert Customer array
      //     custcode will be used as map key
      // ------------------------------------------------------

      final Map<int, CustomerModel> customers = {};

      for (final item in customer) {
        if (item is! Map) {
          continue;
        }

        final json = Map<String, dynamic>.from(item);

        final customerModel =
        CustomerModel.fromJson(json);

        // ----------------------------------------------------
        // Only valid custcode will be added
        // ----------------------------------------------------

        if (customerModel.custcode <= 0) {
          continue;
        }

        customers[customerModel.custcode] =
            customerModel;
      }

      // ------------------------------------------------------
      // 12. Parsed customer empty check
      // ------------------------------------------------------

      if (customers.isEmpty) {
        debugPrint(
          'No valid customers found in Customer array',
        );
        debugPrint('Something went wrong from server');
        return {};
      }

      // ------------------------------------------------------
      // 13. Print parsed customers
      // ------------------------------------------------------

      debugPrint('================================');
      debugPrint('CUSTOMERS');
      debugPrint('================================');

      for (final entry in customers.entries) {
        final customer = entry.value;

        debugPrint('CUSTCODE: ${customer.custcode}');
        debugPrint('CUSTNAME: ${customer.custname}');
        debugPrint('ADDRESS: ${customer.address}');
        debugPrint('CITY: ${customer.city}');
        debugPrint('MOBILE: ${customer.mobile}');
        debugPrint('--------------------------------');
      }

      debugPrint('TOTAL CUSTOMERS: ${customers.length}');
      debugPrint('================================');

      // ------------------------------------------------------
      // 14. Return customers mapped by custcode
      // ------------------------------------------------------

      return customers;
    } catch (e, stackTrace) {
      // ------------------------------------------------------
      // API / JSON / Network error
      // ------------------------------------------------------

      debugPrint('================================');
      debugPrint('SYNC CUSTOMER API ERROR');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE:');
      debugPrint('$stackTrace');
      debugPrint('================================');

      return {};
    }
  }
}