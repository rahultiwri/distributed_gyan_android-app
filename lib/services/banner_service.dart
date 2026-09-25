
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/application_constant.dart';
import '../models/banner_model.dart';
import 'preference_service.dart';

class BannerService {
BannerService._();

static Future<List<BannerModel>> getBanner() async {
try {
// --------------------------------------------------------
// Get registered IMEI
// --------------------------------------------------------

final imei = await PreferenceService.getDeviceImei();

// --------------------------------------------------------
// Create API URL
// --------------------------------------------------------

final url = Uri.parse(
'${ApplicationConstant.defaultBaseUrl}'
'${ApplicationConstant.syncDataAsp}',
);

// --------------------------------------------------------
// Call GET BANNER API
// --------------------------------------------------------

final response = await http
    .post(
url,
headers: {
'Content-Type': 'application/x-www-form-urlencoded',
},
body: {
'cmd': 'getbanner',
'imei': imei ,
'verno': '3.4',
},
)
    .timeout(
ApplicationConstant.volleyTimeout,
);

// --------------------------------------------------------
// Print API response
// --------------------------------------------------------

debugPrint('================================');
debugPrint('GET BANNER API RESPONSE');
debugPrint('URL: $url');
debugPrint('STATUS CODE: ${response.statusCode}');
debugPrint('RESPONSE:');
debugPrint(response.body);
debugPrint('================================');

// --------------------------------------------------------
// Convert response
// --------------------------------------------------------

final decoded = jsonDecode(response.body);

final bannerList = decoded['BANNER'];

// --------------------------------------------------------
// Convert BANNER array to models
// --------------------------------------------------------

final List<BannerModel> banners = [];

for (final item in bannerList) {
banners.add(
BannerModel.fromJson(
Map<String, dynamic>.from(item),
),
);
}

// --------------------------------------------------------
// Print banners
// --------------------------------------------------------

debugPrint('================================');
debugPrint('BANNER ITEMS');
debugPrint('================================');

for (final banner in banners) {
debugPrint('ID: ${banner.id}');
debugPrint('DESC: ${banner.desc}');
debugPrint('IMAGE URL: ${banner.imgurl}');
debugPrint('ONCLICK: ${banner.onclick}');
debugPrint('--------------------------------');
}

return banners;
} catch (e, stackTrace) {
debugPrint('================================');
debugPrint('GET BANNER API ERROR');
debugPrint('ERROR: $e');
debugPrint('STACK TRACE:');
debugPrint('$stackTrace');
debugPrint('================================');

return [];
}
}
}

