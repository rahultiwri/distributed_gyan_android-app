import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/application_constant.dart';
import '../services/preference_service.dart';
import '../models/payment_history_ent.dart';

import 'package:flutter/services.dart';

class BalanceResponse {
  final String balance;
  final String drcr;
  final String msg;

  const BalanceResponse({
    required this.balance,
    required this.drcr,
    required this.msg,
  });
}

class PaymentTokenResponse {
  final String status;
  final String msg;
  final String token;
  final String orderId;
  final String mid;
  final String merchantKey;
  final String websiteForWeb;
  final String websiteForApp;
  final String channelForWeb;
  final String channelForApp;
  final String industryTypeId;

  const PaymentTokenResponse({
    required this.status,
    required this.msg,
    required this.token,
    required this.orderId,
    required this.mid,
    required this.merchantKey,
    required this.websiteForWeb,
    required this.websiteForApp,
    required this.channelForWeb,
    required this.channelForApp,
    required this.industryTypeId,
  });
}

class PaymentService {
  PaymentService._();

  // ==========================================================
  // GET BALANCE
  // Java equivalent:
  // sync_balance()
  //
  // cmd      = getbalance
  // imei     = registered IMEI
  // distcode = distributor/customer code
  // ==========================================================

  static Future<BalanceResponse> getBalance({
    required String distCode,
  }) async {
    // --------------------------------------------------------
    // GET IMEI FROM SHARED PREFERENCES
    // --------------------------------------------------------

    final imei = await PreferenceService.getDeviceImei();

    if (imei == null || imei.trim().isEmpty) {
      throw Exception('Device IMEI not found.');
    }

    // --------------------------------------------------------
    // GET BASE URL
    // --------------------------------------------------------

    final savedBaseUrl =
    await PreferenceService.getBaseUrl();

    final baseUrl =
    (savedBaseUrl != null &&
        savedBaseUrl.trim().isNotEmpty)
        ? savedBaseUrl.trim()
        : ApplicationConstant.defaultBaseUrl;

    final url =
        '${baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'}'
        '${ApplicationConstant.syncDataAsp}';

    debugPrint('========== GET BALANCE ==========');
    debugPrint('URL: $url');
    debugPrint('CMD: getbalance');
    debugPrint('IMEI: $imei');
    debugPrint('DISTCODE: $distCode');

    // --------------------------------------------------------
    // POST REQUEST
    // --------------------------------------------------------

    final response = await http
        .post(
      Uri.parse(url),
      body: {
        'cmd': 'getbalance',
        'imei': imei.trim(),
        'distcode': distCode.trim(),
      },
    )
        .timeout(ApplicationConstant.volleyTimeout);

    debugPrint(
      'GET BALANCE STATUS CODE: ${response.statusCode}',
    );

    debugPrint(
      'GET BALANCE RESPONSE: ${response.body}',
    );

    // --------------------------------------------------------
    // HTTP VALIDATION
    // --------------------------------------------------------

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Server error (${response.statusCode}).',
      );
    }

    final responseBody = response.body.trim();

    // Java:
    // !Response.equals("")
    // !Response.startsWith("Error")
    // !Response.equals("EOF")
    if (responseBody.isEmpty) {
      throw Exception('No response from server.');
    }

    if (responseBody.startsWith('Error')) {
      throw Exception(responseBody);
    }

    if (responseBody == 'EOF') {
      throw Exception('No response from server.');
    }

    // --------------------------------------------------------
    // JSON PARSE
    // --------------------------------------------------------

    dynamic decodedResponse;

    try {
      decodedResponse = jsonDecode(responseBody);
    } catch (e) {
      debugPrint(
        'GET BALANCE JSON PARSE ERROR: $e',
      );

      throw Exception(
        'Invalid response from server.',
      );
    }

    if (decodedResponse is! Map<String, dynamic>) {
      throw Exception(
        'Invalid response from server.',
      );
    }

    final jsonObject = decodedResponse;

    // --------------------------------------------------------
    // JAVA:
    //
    // String balance = jsonObject.getString("balance")
    // String drcr    = jsonObject.getString("drcr")
    // String msg     = jsonObject.has("msg")
    // --------------------------------------------------------

    final balance =
        jsonObject['balance']?.toString() ?? '';

    final drcr =
        jsonObject['drcr']?.toString() ?? '';

    final msg =
        jsonObject['msg']?.toString() ?? '';

    debugPrint('BALANCE: $balance');
    debugPrint('DRCR: $drcr');
    debugPrint('MSG: $msg');

    // --------------------------------------------------------
    // REQUIRED RESPONSE VALIDATION
    // --------------------------------------------------------

    if (drcr.trim().isEmpty) {
      throw Exception(
        'Invalid balance response from server.',
      );
    }

    // Balance Java mein getString("balance") se aa raha hai,
    // isliye missing balance ko invalid response maanenge.
    if (balance.trim().isEmpty) {
      throw Exception(
        'Balance not received from server.',
      );
    }

    return BalanceResponse(
      balance: balance,
      drcr: drcr,
      msg: msg,
    );
  }
//    testing purpose used
 // static const bool paymentHistoryTesting = true;  // testing
  static Future<List<PaymentHistoryEnt>> getPaymentHistory({
    required String distCode,
  }) async {


    // if (paymentHistoryTesting) {
    //   return [
    //     PaymentHistoryEnt(
    //       txndate: '24/09/2026 3:24:51 PM',
    //       txnamount: '4500',
    //       respmsg: 'Txn Success',
    //       erpmsg:
    //       'PAYMENT WILL BE REFLECTED IN LEDGER AFTER BANK SETTLEMENT',
    //     ),
    //
    //     PaymentHistoryEnt(
    //       txndate: '24/09/2026 3:03:34 PM',
    //       txnamount: '30000',
    //       respmsg: 'Txn Success',
    //       erpmsg:
    //       'PAYMENT WILL BE REFLECTED IN LEDGER AFTER BANK SETTLEMENT',
    //     ),
    //
    //     PaymentHistoryEnt(
    //       txndate: '24/09/2026 3:02:42 PM',
    //       txnamount: '30000',
    //       respmsg: 'We are processing your transaction.',
    //       erpmsg:
    //       'PAYMENT WILL BE REFLECTED IN LEDGER AFTER BANK SETTLEMENT',
    //     ),
    //
    //     PaymentHistoryEnt(
    //       txndate: '23/09/2026 3:31:01 PM',
    //       txnamount: '26000',
    //       respmsg: 'Txn Success',
    //       erpmsg:
    //       'PAYMENT WILL BE REFLECTED IN LEDGER AFTER BANK SETTLEMENT',
    //     ),
    //
    //     PaymentHistoryEnt(
    //       txndate: '23/09/2026 3:20:15 PM',
    //       txnamount: '15000',
    //       respmsg: 'Txn Success',
    //       erpmsg:
    //       'PAYMENT WILL BE REFLECTED IN LEDGER AFTER BANK SETTLEMENT',
    //     ),
    //
    //     PaymentHistoryEnt(
    //       txndate: '22/09/2026 4:10:25 PM',
    //       txnamount: '12000',
    //       respmsg: 'Txn Success',
    //       erpmsg:
    //       'PAYMENT WILL BE REFLECTED IN LEDGER AFTER BANK SETTLEMENT',
    //     ),
    //   ];
    // }


    // --------------------------------------------------------
    // GET IMEI FROM SHARED PREFERENCES
    // --------------------------------------------------------

    final imei = await PreferenceService.getDeviceImei();

    if (imei == null || imei.trim().isEmpty) {
      throw Exception('Device IMEI not found.');
    }

    // --------------------------------------------------------
    // GET BASE URL
    // --------------------------------------------------------

    final savedBaseUrl =
    await PreferenceService.getBaseUrl();

    final baseUrl =
    (savedBaseUrl != null &&
        savedBaseUrl.trim().isNotEmpty)
        ? savedBaseUrl.trim()
        : ApplicationConstant.defaultBaseUrl;

    final url =
        '${baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'}'
        '${ApplicationConstant.syncDataAsp}';

    debugPrint('========== PAYMENT HISTORY ==========');
    debugPrint('URL: $url');
    debugPrint('CMD: PGHISTORY');
    debugPrint('IMEI: $imei');
    debugPrint('DISTCODE: $distCode');

    // --------------------------------------------------------
    // POST REQUEST
    // --------------------------------------------------------

    final response = await http
        .post(
      Uri.parse(url),
      body: {
        'cmd': 'PGHISTORY',
        'imei': imei.trim(),
        'distcode': distCode.trim(),
      },
    )
        .timeout(ApplicationConstant.volleyTimeout);

    debugPrint(
      'PGHISTORY STATUS CODE: ${response.statusCode}',
    );

    debugPrint(
      'PGHISTORY RESPONSE: ${response.body}',
    );

    // --------------------------------------------------------
    // HTTP VALIDATION
    // --------------------------------------------------------

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Server error (${response.statusCode}).',
      );
    }

    final responseBody = response.body.trim();

    // Java:
    // !Response.equals("")
    // !Response.startsWith("Error")
    // !Response.equals("EOF")
    if (responseBody.isEmpty) {
      throw Exception('No response from server.');
    }

    if (responseBody.startsWith('Error')) {
      throw Exception(responseBody);
    }

    if (responseBody == 'EOF') {
      throw Exception('No response from server.');
    }

    // --------------------------------------------------------
    // JSON PARSE
    // --------------------------------------------------------

    dynamic decodedResponse;

    try {
      decodedResponse = jsonDecode(responseBody);
    } catch (e) {
      debugPrint(
        'PGHISTORY JSON PARSE ERROR: $e',
      );

      throw Exception(
        'Invalid response from server.',
      );
    }

    if (decodedResponse is! Map<String, dynamic>) {
      throw Exception(
        'Invalid response from server.',
      );
    }

    final jsonObject = decodedResponse;

    // --------------------------------------------------------
    // JAVA:
    //
    // String message = jsonObject.getString("msg")
    //
    // if(message.equalsIgnoreCase("Success"))
    // --------------------------------------------------------

    final message =
        jsonObject['msg']?.toString() ?? '';

    debugPrint(
      'PGHISTORY MSG: $message',
    );

    if (message.toLowerCase() != 'success') {
      return [];
    }

    // --------------------------------------------------------
    // HISTORY ARRAY
    // Java:
    // JSONArray jsonArray = jsonObject.getJSONArray("HISTORY");
    // --------------------------------------------------------

    final historyData = jsonObject['HISTORY'];

    if (historyData is! List) {
      throw Exception(
        'Payment history not received from server.',
      );
    }

    // --------------------------------------------------------
    // PARSE HISTORY
    // Java PaymentHistoryEnt equivalent
    // --------------------------------------------------------

    final List<PaymentHistoryEnt> history = [];

    for (final item in historyData) {
      if (item is! Map) {
        continue;
      }

      final paymentHistory = PaymentHistoryEnt(
        txndate:
        item['txndate']?.toString() ?? '',
        txnamount:
        item['txnamount']?.toString() ?? '',
        respmsg:
        item['respmsg']?.toString() ?? '',
        erpmsg:
        item['erpmsg']?.toString() ?? '',
      );

      history.add(paymentHistory);
    }

    debugPrint(
      'PGHISTORY COUNT: ${history.length}',
    );

    return history;
  }

  static Future<PaymentTokenResponse> getPaymentToken({
    required String amount,
    required String distCode,
  }) async {
    final imei = await PreferenceService.getDeviceImei();

    if (imei == null || imei.trim().isEmpty) {
      throw Exception('Device IMEI not found.');
    }

    final savedBaseUrl =
    await PreferenceService.getBaseUrl();

    final baseUrl =
    (savedBaseUrl != null &&
        savedBaseUrl.trim().isNotEmpty)
        ? savedBaseUrl.trim()
        : ApplicationConstant.defaultBaseUrl;

    final url =
        '${baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'}'
        '${ApplicationConstant.syncDataAsp}';

    // testing purpose  //
    // final url = 'https://demand.gyandairy.com/gyan/syncdata2.asp';

    debugPrint('========== GET PG TOKEN ==========');
    debugPrint('URL: $url');
    debugPrint('CMD: getpgtoken');
    debugPrint('IMEI: $imei');
    debugPrint('AMOUNT: $amount');
    debugPrint('DISTCODE: $distCode');

    final response = await http
        .post(
      Uri.parse(url),
      body: {
        'cmd': 'getpgtoken',
        'imei':  imei.trim(),      // production 'b4d3ad85-bbda-4fb1-a37e-0bac4e677d0a',
        'amount': amount.trim(),
       'distcode': distCode.trim(),
      },
    )
        .timeout(ApplicationConstant.volleyTimeout);

    debugPrint(
      'GET PG TOKEN STATUS CODE: ${response.statusCode}',
    );

    debugPrint(
      'GET PG TOKEN RESPONSE: ${response.body}',
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Server error (${response.statusCode}).',
      );
    }

    final responseBody = response.body.trim();

    if (responseBody.isEmpty) {
      throw Exception('No response from server.');
    }

    if (responseBody.startsWith('Error')) {
      throw Exception(responseBody);
    }

    if (responseBody == 'EOF') {
      throw Exception('No response from server.');
    }

    dynamic decodedResponse;

    try {
      decodedResponse = jsonDecode(responseBody);
    } catch (e) {
      debugPrint(
        'GET PG TOKEN JSON PARSE ERROR: $e',
      );

      throw Exception(
        'Invalid response from server.',
      );
    }

    if (decodedResponse is! Map<String, dynamic>) {
      throw Exception(
        'Invalid response from server.',
      );
    }

    final jsonObject = decodedResponse;

    final status =
        jsonObject['status']?.toString() ?? '';

    final msg =
        jsonObject['msg']?.toString() ?? '';

    final token =
        jsonObject['token']?.toString() ?? '';

    final orderId =
        jsonObject['orderid']?.toString() ?? '';

    final mid =
        jsonObject['mid']?.toString() ?? '';

    final merchantKey =
        jsonObject['merchantkey']?.toString() ?? '';

    final websiteForWeb =
        jsonObject['websiteforweb']?.toString() ?? '';

    final websiteForApp =
        jsonObject['websiteforapp']?.toString() ?? '';

    final channelForWeb =
        jsonObject['ChannelForweb']?.toString() ?? '';

    final channelForApp =
        jsonObject['ChannelForapp']?.toString() ?? '';

    final industryTypeId =
        jsonObject['Industrytypeid']?.toString() ?? '';

    debugPrint('PG TOKEN STATUS: $status');
    debugPrint('PG TOKEN MSG: $msg');
    debugPrint('PG TOKEN ORDER ID: $orderId');
    debugPrint('PG TOKEN MID: $mid');

    // ==========================================================
// STATUS VALIDATION
//
// HTTP 200 + status = fail
// -> exception nahi throw karna
// -> response screen ko return karna
// -> screen server msg show karegi
// -> Retry nahi hoga
// ==========================================================

    if (status.toLowerCase() == 'success') {
      // ========================================================
      // SUCCESS RESPONSE KE LIYE REQUIRED FIELDS
      // ========================================================

      if (token.trim().isEmpty) {
        throw Exception(
          'Payment token not received.',
        );
      }

      if (orderId.trim().isEmpty) {
        throw Exception(
          'Payment order ID not received.',
        );
      }

      if (mid.trim().isEmpty) {
        throw Exception(
          'Payment MID not received.',
        );
      }
    }

    return PaymentTokenResponse(
      status: status,
      msg: msg,
      token: token,
      orderId: orderId,
      mid: mid,
      merchantKey: merchantKey,
      websiteForWeb: websiteForWeb,
      websiteForApp: websiteForApp,
      channelForWeb: channelForWeb,
      channelForApp: channelForApp,
      industryTypeId: industryTypeId,
    );
  }
  // ==========================================================
  // START PAYTM TRANSACTION
  // Native Android Paytm SDK bridge
  // ==========================================================

  static const MethodChannel _paytmChannel =
  MethodChannel('gyan_milk/paytm');

  static Future<dynamic> startPaytmTransaction({
    required PaymentTokenResponse paymentToken,
    required String amount,
  }) async {
    try {
      final response =
      await _paytmChannel.invokeMethod(
        'startPaytmTransaction',
        {
          'orderId': paymentToken.orderId,
          'mid': paymentToken.mid,
          'token': paymentToken.token,
          'amount': amount,
        },
      );

      return response;
    } on PlatformException catch (e) {
      throw Exception(
        e.message ?? 'Unable to start Paytm transaction.',
      );
    } catch (e) {
      throw Exception(
        'Unable to start Paytm transaction: $e',
      );
    }
  }


}