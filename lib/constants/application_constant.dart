class ApplicationConstant {
  ApplicationConstant._();

  // ==========================================================
  // SERVER
  // ==========================================================

  static const String defaultBaseUrl =
      'https://demand.gyandairy.com/gyantest/';

  static const String savedBaseUrlKey =
      'base_url';

  // ==========================================================
  // API
  // ==========================================================

  static const String qerpAppAsp =
      'qerpapp.asp';

  static const String syncDataAsp =
      'syncdata2.asp';

  static const String urlCheck =
      'qerpapp.asp?urlok=1';

  static const String imeiCheck =
      'qerpapp.asp?imei=';

  static const String registration =
      'qerpapp.asp?reg=1';

  static const String deviceLogin =
      'qerpapp.asp?login=1';

  static const String deviceLoginSuccess =
      'Successfull';

  // ==========================================================
  // RESPONSE
  // ==========================================================

  static const String successResponse =
      'OK';

  static const String imeiNotFound =
      'Not Found';

  // ==========================================================
  // TIMEOUT
  // Java: VOLLEY_TIME_OUT = 60000
  // ==========================================================

  static const Duration volleyTimeout =
  Duration(seconds: 60);
}