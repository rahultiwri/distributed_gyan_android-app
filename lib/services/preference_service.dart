
// main working code h


// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../constants/application_constant.dart';
//
// class PreferenceService {
//   PreferenceService._();
//
//   // ==========================================================
//   // BASE URL
//   // ==========================================================
//
//   static Future<String?> getBaseUrl() async {
//     final preferences =
//     await SharedPreferences.getInstance();
//
//
//
//     return preferences.getString(
//       ApplicationConstant.savedBaseUrlKey,
//     );
//   }
//
//   static Future<bool> saveBaseUrl(String url) async {
//     final preferences =
//     await SharedPreferences.getInstance();
//
//     return preferences.setString(
//       ApplicationConstant.savedBaseUrlKey,
//       url,
//     );
//   }
//
//   static Future<bool> clearBaseUrl() async {
//     final preferences =
//     await SharedPreferences.getInstance();
//
//     return preferences.remove(
//       ApplicationConstant.savedBaseUrlKey,
//     );
//   }
//
//   static Future<bool> hasSavedBaseUrl() async {
//     final preferences =
//     await SharedPreferences.getInstance();
//
//     final url = preferences.getString(
//       ApplicationConstant.savedBaseUrlKey,
//     );
//
//     return url != null && url.trim().isNotEmpty;
//   }
//
//   // ==========================================================
//   // DEVICE IMEI / ID
//   // ==========================================================
//
//   static const String _deviceImeiKey =
//       'device_imei';
//
//   static Future<bool> saveDeviceImei(
//       String imei,
//       ) async {
//     final preferences =
//     await SharedPreferences.getInstance();
//
//     return preferences.setString(
//       _deviceImeiKey,
//       imei,
//     );
//   }
//
//   static Future<String?> getDeviceImei() async {
//     final preferences =
//     await SharedPreferences.getInstance();
//
//     return preferences.getString(
//       _deviceImeiKey,
//     );
//   }
//
//   // ==========================================================
//   // REGISTRATION DATA
//   // ==========================================================
//
//   static const String _userIdKey =
//       'user_id';
//
//   static const String _mobileNumberKey =
//       'mobile_number';
//
//   static const String _passwordKey =
//       'password';
//   static const String _userTypeKey = 'user_type';
//
//   static const String _registrationCompletedKey =
//       'registration_completed';
//
//   static Future<bool> saveRegistrationData({
//     required String imei,
//     required String userId,
//     required String mobileNumber,
//     required String password,
//     required String userType
//   }) async {
//     final preferences =
//     await SharedPreferences.getInstance();
//
//     await preferences.setString(
//       _deviceImeiKey,
//       imei,
//     );
//
//     await preferences.setString(
//       _userIdKey,
//       userId,
//     );
//
//     await preferences.setString(
//       _mobileNumberKey,
//       mobileNumber,
//     );
//
//     await preferences.setString(
//       _passwordKey,
//       password,
//     );
//
//     await preferences.setString(
//       _userTypeKey,
//       userType,
//     );
//
//     await preferences.setBool(
//       _registrationCompletedKey,
//       true,
//     );
//
//     return true;
//   }
//
//   // ==========================================================
//   // GET REGISTRATION DATA
//   // ==========================================================
//
//   static Future<String?> getUserId() async {
//     final preferences =
//     await SharedPreferences.getInstance();
//
//     return preferences.getString(
//       _userIdKey,
//     );
//   }
//
//   static Future<String?> getMobileNumber() async {
//     final preferences =
//     await SharedPreferences.getInstance();
//
//     return preferences.getString(
//       _mobileNumberKey,
//     );
//   }
//
//   static Future<String?> getPassword() async {
//     final preferences =
//     await SharedPreferences.getInstance();
//
//     return preferences.getString(
//       _passwordKey,
//     );
//   }
//   static Future<String?> getUserType() async {
//     final preferences =
//     await SharedPreferences.getInstance();
//
//     return preferences.getString(
//       _userTypeKey,
//     );
//   }
//   // ==========================================================
//   // REGISTRATION STATUS
//   // ==========================================================
//
//   static Future<bool> isRegistrationCompleted() async {
//     final preferences =
//     await SharedPreferences.getInstance();
//
//     return preferences.getBool(
//       _registrationCompletedKey,
//     ) ??
//         false;
//   }
//
//   // ==========================================================
//   // LOGIN MATCH
//   // ==========================================================
//
//   static Future<bool> checkLogin(
//       String userId,
//       String password,
//       ) async {
//     final preferences =
//     await SharedPreferences.getInstance();
//
//     final savedUserId =
//     preferences.getString(_userIdKey);
//
//     final savedPassword =
//     preferences.getString(_passwordKey);
//
//     return savedUserId == userId &&
//         savedPassword == password;
//   }
//
//
//
// // ==========================================================
// // DEVICE LOGIN VERIFICATION STATUS
// // ==========================================================
//
// static const String _deviceLoginVerifiedKey =
//     'device_login_verified';
//
// static Future<bool> saveDeviceLoginVerified(
// bool value,
// ) async {
// final preferences =
//     await SharedPreferences.getInstance();
//
// return preferences.setBool(
// _deviceLoginVerifiedKey,
// value,
// );
// }
//
// static Future<bool> isDeviceLoginVerified() async {
// final preferences =
//     await SharedPreferences.getInstance();
//
// return preferences.getBool(
// _deviceLoginVerifiedKey,
// ) ??
// false;
// }
//
//
//   // ==========================================================
//   // REMEMBER ME
//   // ==========================================================
//
//   static const String _rememberMeKey =
//       'remember_me';
//
//   static Future<bool> saveRememberMe(
//       bool value,
//       ) async {
//     final preferences =
//     await SharedPreferences.getInstance();
//
//     return preferences.setBool(
//       _rememberMeKey,
//       value,
//     );
//   }
//
//   static Future<bool> isRememberMe() async {
//     final preferences =
//     await SharedPreferences.getInstance();
//
//     return preferences.getBool(
//       _rememberMeKey,
//     ) ??
//         false;
//   }
//
//   static Future<bool> clearRememberedLogin() async {
//     final preferences =
//     await SharedPreferences.getInstance();
//
//     await preferences.remove(_userIdKey);
//     await preferences.remove(_passwordKey);
//     await preferences.remove(_rememberMeKey);
//
//     return true;
//   }
//
//   static Future<bool> saveLoginCredentials({
//     required String userId,
//     required String password,
//   }) async {
//     final preferences =
//     await SharedPreferences.getInstance();
//
//     await preferences.setString(
//       _userIdKey,
//       userId,
//     );
//
//     await preferences.setString(
//       _passwordKey,
//       password,
//     );
//
//     return true;
//   }
//
//
// }


// debug in console krne ke liye code h testing purpose .

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/application_constant.dart';

class PreferenceService {
  PreferenceService._();

  // ==========================================================
  // BASE URL
  // ==========================================================

  static Future<String?> getBaseUrl() async {
    final preferences =
    await SharedPreferences.getInstance();

    return preferences.getString(
      ApplicationConstant.savedBaseUrlKey,
    );
  }

  static Future<bool> saveBaseUrl(String url) async {
    final preferences =
    await SharedPreferences.getInstance();

    return preferences.setString(
      ApplicationConstant.savedBaseUrlKey,
      url,
    );
  }

  static Future<bool> clearBaseUrl() async {
    final preferences =
    await SharedPreferences.getInstance();

    return preferences.remove(
      ApplicationConstant.savedBaseUrlKey,
    );
  }

  static Future<bool> hasSavedBaseUrl() async {
    final preferences =
    await SharedPreferences.getInstance();

    final url = preferences.getString(
      ApplicationConstant.savedBaseUrlKey,
    );

    return url != null && url.trim().isNotEmpty;
  }

  // ==========================================================
  // DEVICE IMEI / ID
  // ==========================================================

  static const String _deviceImeiKey =
      'device_imei';

  static Future<bool> saveDeviceImei(
      String imei,
      ) async {
    final preferences =
    await SharedPreferences.getInstance();

    return preferences.setString(
      _deviceImeiKey,
      imei,
    );
  }

  static Future<String?> getDeviceImei() async {
    final preferences =
    await SharedPreferences.getInstance();

    return preferences.getString(
      _deviceImeiKey,
    );
  }

  // ==========================================================
  // REGISTRATION DATA
  // ==========================================================

  static const String _userIdKey =
      'user_id';

  static const String _mobileNumberKey =
      'mobile_number';

  static const String _passwordKey =
      'password';

  static const String _userTypeKey =
      'user_type';

  static const String _registrationCompletedKey =
      'registration_completed';

  static Future<bool> saveRegistrationData({
    required String imei,
    required String userId,
    required String mobileNumber,
    required String password,
    required String userType,
  }) async {
    final preferences =
    await SharedPreferences.getInstance();

    await preferences.setString(
      _deviceImeiKey,
      imei,
    );

    await preferences.setString(
      _userIdKey,
      userId,
    );

    await preferences.setString(
      _mobileNumberKey,
      mobileNumber,
    );

    await preferences.setString(
      _passwordKey,
      password,
    );

    await preferences.setString(
      _userTypeKey,
      userType,
    );

    await preferences.setBool(
      _registrationCompletedKey,
      true,
    );

    return true;
  }

  // ==========================================================
  // GET REGISTRATION DATA
  // ==========================================================

  static Future<String?> getUserId() async {
    final preferences =
    await SharedPreferences.getInstance();

    return preferences.getString(
      _userIdKey,
    );
  }

  static Future<String?> getMobileNumber() async {
    final preferences =
    await SharedPreferences.getInstance();

    return preferences.getString(
      _mobileNumberKey,
    );
  }

  static Future<String?> getPassword() async {
    final preferences =
    await SharedPreferences.getInstance();

    return preferences.getString(
      _passwordKey,
    );
  }

  static Future<String?> getUserType() async {
    final preferences =
    await SharedPreferences.getInstance();

    return preferences.getString(
      _userTypeKey,
    );
  }

  // ==========================================================
  // DEBUG - CHECK SAVED REGISTRATION DATA
  // ==========================================================

  static Future<void> debugPrintRegistrationData() async {
    final preferences =
    await SharedPreferences.getInstance();

    debugPrint(
        '========== SHARED PREFERENCES =========='
    );

    debugPrint(
      'DEVICE IMEI: '
          '${preferences.getString(_deviceImeiKey)}',
    );

    debugPrint(
      'USER ID: '
          '${preferences.getString(_userIdKey)}',
    );

    debugPrint(
      'MOBILE NUMBER: '
          '${preferences.getString(_mobileNumberKey)}',
    );

    debugPrint(
      'PASSWORD: '
          '${preferences.getString(_passwordKey)}',
    );

    debugPrint(
      'USER TYPE: '
          '${preferences.getString(_userTypeKey)}',
    );

    debugPrint(
      'REGISTRATION COMPLETED: '
          '${preferences.getBool(_registrationCompletedKey)}',
    );

    debugPrint(
      'DEVICE LOGIN VERIFIED: '
          '${preferences.getBool(_deviceLoginVerifiedKey)}',
    );

    debugPrint(
      'REMEMBER ME: '
          '${preferences.getBool(_rememberMeKey)}',
    );

    debugPrint(
        '========================================='
    );
  }

  // ==========================================================
  // REGISTRATION STATUS
  // ==========================================================

  static Future<bool> isRegistrationCompleted() async {
    final preferences =
    await SharedPreferences.getInstance();

    return preferences.getBool(
      _registrationCompletedKey,
    ) ??
        false;
  }

  // ==========================================================
  // LOGIN MATCH
  // ==========================================================

  static Future<bool> checkLogin(
      String userId,
      String password,
      ) async {
    final preferences =
    await SharedPreferences.getInstance();

    final savedUserId =
    preferences.getString(_userIdKey);

    final savedPassword =
    preferences.getString(_passwordKey);

    return savedUserId == userId &&
        savedPassword == password;
  }

  // ==========================================================
  // DEVICE LOGIN VERIFICATION STATUS
  // ==========================================================

  static const String _deviceLoginVerifiedKey =
      'device_login_verified';

  static Future<bool> saveDeviceLoginVerified(
      bool value,
      ) async {
    final preferences =
    await SharedPreferences.getInstance();

    return preferences.setBool(
      _deviceLoginVerifiedKey,
      value,
    );
  }

  static Future<bool> isDeviceLoginVerified() async {
    final preferences =
    await SharedPreferences.getInstance();

    return preferences.getBool(
      _deviceLoginVerifiedKey,
    ) ??
        false;
  }

  // ==========================================================
  // REMEMBER ME
  // ==========================================================

  static const String _rememberMeKey =
      'remember_me';

  static Future<bool> saveRememberMe(
      bool value,
      ) async {
    final preferences =
    await SharedPreferences.getInstance();

    return preferences.setBool(
      _rememberMeKey,
      value,
    );
  }

  static Future<bool> isRememberMe() async {
    final preferences =
    await SharedPreferences.getInstance();

    return preferences.getBool(
      _rememberMeKey,
    ) ??
        false;
  }

  static Future<bool> clearRememberedLogin() async {
    final preferences =
    await SharedPreferences.getInstance();

    await preferences.remove(_userIdKey);
    await preferences.remove(_passwordKey);
    await preferences.remove(_rememberMeKey);

    return true;
  }

  static Future<bool> saveLoginCredentials({
    required String userId,
    required String password,
  }) async {
    final preferences =
    await SharedPreferences.getInstance();

    await preferences.setString(
      _userIdKey,
      userId,
    );

    await preferences.setString(
      _passwordKey,
      password,
    );

    return true;
  }
}