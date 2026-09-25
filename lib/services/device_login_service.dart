
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'preference_service.dart';

class DeviceLoginService {
DeviceLoginService._();

static const String _loginUrl =
'https://demand.gyandairy.com/gyantest/qerpapp.asp';

static Future<String> verifyLogin({
required String userId,
required String password,
}) async {
try {
// IMEI already saved during Device Registration
final imei = await PreferenceService.getDeviceImei();

if (imei == null || imei.trim().isEmpty) {
return 'IMEI not found';
}

final uri = Uri.parse(_loginUrl).replace(
queryParameters: {
'login': '1',
'imei': imei,
'loginname': userId.trim(),
'password': password,
},
);

// Password is intentionally NOT printed.
debugPrint(
'Device Login API: ${uri.replace(queryParameters: {
'login': '1',
'imei': imei,
'loginname': userId.trim(),
'password': '********',
})}',
);

final response = await http.get(uri);

final responseBody = response.body.trim();

debugPrint(
'Device Login Response: $responseBody',
);

return responseBody;
} catch (e) {
debugPrint(
'Device Login Error: $e',
);

return 'Connection error: $e';
}
}
}
