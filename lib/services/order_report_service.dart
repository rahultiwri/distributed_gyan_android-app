
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/application_constant.dart';
import '../models/order_report_model.dart';
import '../models/customer_model.dart';
import 'preference_service.dart';

class OrderReportService {
OrderReportService._();

// --------------------------------------------------------
// SYNC ORDER REPORT API
// --------------------------------------------------------

static Future<OrderReportModel?> syncReport({
required CustomerModel customer,
required String orderDate,
required String shift,
}) async {
try {
// ------------------------------------------------------
// 1. Get registered IMEI from SharedPreferences
// ------------------------------------------------------

final imei = await PreferenceService.getDeviceImei();

if (imei == null || imei.trim().isEmpty) {
debugPrint('================================');
debugPrint('ORDER REPORT API');
debugPrint('IMEI NOT FOUND');
debugPrint('Something went wrong from server');
debugPrint('================================');

return null;
}

// ------------------------------------------------------
// 2. Create API URL
//
// Java:
// url + ApplicationConstant.SYNC_DATA_ASP
// ------------------------------------------------------

final url = Uri.parse(
'${ApplicationConstant.defaultBaseUrl}'
'${ApplicationConstant.syncDataAsp}',
);

// ------------------------------------------------------
// 3. Prepare request parameters
//
// Java:
// cmd     = orderreport
// orddate = editTextOrderDate
// imei    = registered IMEI
// accode  = distributor/customer code
// shift   = M / E
// ------------------------------------------------------

final requestBody = {
'cmd': 'orderreport',
'orddate': orderDate,
'imei': imei,
 'accode': customer.custcode.toString(),
'shift': shift,
};

// ------------------------------------------------------
// 4. Print request details
// ------------------------------------------------------

debugPrint('================================');
debugPrint('ORDER REPORT API REQUEST');
debugPrint('================================');
debugPrint('URL: $url');
debugPrint('METHOD: POST');
debugPrint('CMD: orderreport');
debugPrint('ORDER DATE: $orderDate');
debugPrint('IMEI: $imei');
debugPrint('ACCODE: ${customer.custcode}');
debugPrint('SHIFT: $shift');
debugPrint('================================');

// ------------------------------------------------------
// 5. Call API
// ------------------------------------------------------

final response = await http
    .post(
url,
headers: {
'Content-Type': 'application/x-www-form-urlencoded',
},
body: requestBody,
)
    .timeout(
ApplicationConstant.volleyTimeout,
);

// ------------------------------------------------------
// 6. Print API response
// ------------------------------------------------------

debugPrint('================================');
debugPrint('ORDER REPORT API RESPONSE');
debugPrint('URL: $url');
debugPrint('STATUS CODE: ${response.statusCode}');
debugPrint('RESPONSE:');
debugPrint(response.body);
debugPrint('================================');

// ------------------------------------------------------
// 7. Status code check
// ------------------------------------------------------

if (response.statusCode != 200) {
debugPrint(
'ORDER REPORT API FAILED: '
'STATUS CODE ${response.statusCode}',
);
debugPrint('Something went wrong from server');

return null;
}

// ------------------------------------------------------
// 8. Empty response check
// ------------------------------------------------------

if (response.body.trim().isEmpty) {
debugPrint('ORDER REPORT API RESPONSE IS EMPTY');
debugPrint('Something went wrong from server');

return null;
}

// ------------------------------------------------------
// 9. Error response check
//
// Java checks:
// !response.startsWith("Error")
// && !response.equalsIgnoreCase("EOF")
// ------------------------------------------------------

final responseBody = response.body.trim();

if (responseBody.startsWith('Error')) {
debugPrint('ORDER REPORT SERVER ERROR: $responseBody');
debugPrint('Something went wrong from server');

return null;
}

if (responseBody.toUpperCase() == 'EOF') {
debugPrint('ORDER REPORT SERVER RESPONSE: EOF');
debugPrint('Something went wrong from server');

return null;
}

// ------------------------------------------------------
// 10. Convert response into JSON
// ------------------------------------------------------

final decoded = jsonDecode(responseBody);

if (decoded is! Map) {
debugPrint('ORDER REPORT RESPONSE IS NOT A JSON OBJECT');
debugPrint('Something went wrong from server');

return null;
}

final json = Map<String, dynamic>.from(decoded);

// ------------------------------------------------------
// 11. Check server message
//
// Java:
// if (msg.equalsIgnoreCase("Success"))
//
// Sample response:
// "msg": "SUCCESS"
// ------------------------------------------------------

  final serverMessage =
      json['msg']?.toString().trim() ?? '';

  debugPrint(
    'ORDER REPORT SERVER MESSAGE: $serverMessage',
  );

  final normalizedMessage =
  serverMessage.replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

// ------------------------------------------------------
// NO ORDER FOUND
// ------------------------------------------------------

  if (normalizedMessage == 'no order found') {
    debugPrint('================================');
    debugPrint('ORDER REPORT: NO ORDER FOUND');
    debugPrint('MESSAGE: $serverMessage');
    debugPrint('================================');

    final report = OrderReportModel.fromJson(json);

    return report;
  }

// ------------------------------------------------------
// OTHER SERVER MESSAGE
// ------------------------------------------------------

  if (normalizedMessage != 'success') {
    debugPrint(
      'ORDER REPORT FAILED: '
          'SERVER MESSAGE = $serverMessage',
    );

    debugPrint(
      'Server message: '
          '${serverMessage.isEmpty ? 'No message' : serverMessage}',
    );

    return null;
  }

// ------------------------------------------------------
// 12. Convert JSON into OrderReportModel
// ------------------------------------------------------

final report = OrderReportModel.fromJson(json);

// ------------------------------------------------------
// 13. Print parsed report details
// ------------------------------------------------------

debugPrint('================================');
debugPrint('ORDER REPORT PARSED SUCCESSFULLY');
debugPrint('================================');

debugPrint('MESSAGE: ${report.msg}');
debugPrint('ACCODE: ${report.accode}');
debugPrint('ORDER SHIFT: ${report.ordershift}');
debugPrint('ORDER STATUS: ${report.orderstatus}');
debugPrint('ORDER DATE: ${report.orderdate}');
debugPrint('ORDER VALUE: ${report.ordervalue}');
debugPrint('CRATE: ${report.crate}');
debugPrint('JAALI: ${report.jaali}');
debugPrint('IMAGE URL: ${report.imgurl}');
debugPrint('REMARKS: ${report.remarks}');
debugPrint('NARRATION: ${report.ovnarr}');

debugPrint('TOP GROUPS: ${report.topgroups}');

// ------------------------------------------------------
// 14. Print dynamic product groups
// ------------------------------------------------------

for (final groupName in report.topgroups) {
final products = report.products[groupName] ?? [];

debugPrint('--------------------------------');
debugPrint('GROUP: $groupName');
debugPrint('PRODUCT COUNT: ${products.length}');

for (final product in products) {
debugPrint('PRODUCT NAME: ${product.prdname}');
debugPrint('PRODUCT CODE: ${product.prdcode}');
debugPrint('QUANTITY: ${product.qty}');
debugPrint('--------------------------------');
}
}

debugPrint('================================');

// ------------------------------------------------------
// 15. Return parsed report
// ------------------------------------------------------

return report;
} catch (e, stackTrace) {
// ------------------------------------------------------
// API / JSON / Network / Timeout error
// ------------------------------------------------------

debugPrint('================================');
debugPrint('ORDER REPORT API ERROR');
debugPrint('ERROR: $e');
debugPrint('STACK TRACE:');
debugPrint('$stackTrace');
debugPrint('================================');

return null;
}
}
}

