import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/application_constant.dart';
import '../services/preference_service.dart';

class UrlValidationController {
  final TextEditingController urlController;

  UrlValidationController()
      : urlController = TextEditingController(
    text: ApplicationConstant.defaultBaseUrl,
  );

  String get currentUrl => urlController.text.trim();

  // ==========================================================
  // URL FORMAT VALIDATION
  // ==========================================================

  bool validateUrlFormat() {
    final url = currentUrl;

    if (url.isEmpty) {
      return false;
    }

    final uri = Uri.tryParse(url);

    if (uri == null) {
      return false;
    }

    if (uri.scheme != 'http' &&
        uri.scheme != 'https') {
      return false;
    }

    if (uri.host.isEmpty) {
      return false;
    }

    return true;
  }

  // ==========================================================
  // RESET
  // ==========================================================

  void resetUrl() {
    urlController.clear();
  }

  // ==========================================================
  // URL VALIDATION API
  // ==========================================================

  Future<UrlValidationResult> submitUrl() async {
    if (!validateUrlFormat()) {
      return UrlValidationResult.failure(
        'Please enter a valid server URL.',
      );
    }

    final baseUrl = currentUrl;

    // Remove trailing slash so that:
    //
    // https://example.com/
    //
    // becomes:
    //
    // https://example.com/qerpapp.asp
    //
    final cleanBaseUrl =
    baseUrl.replaceFirst(
      RegExp(r'/+$'),
      '',
    );

    final apiUrl =
        '$cleanBaseUrl/${ApplicationConstant.qerpAppAsp}';

    try {
      // ========================================================
      // JAVA EQUIVALENT:
      //
      // Volley POST
      // URL + QERP_APP_ASP
      //
      // getParams():
      // urlok = 1
      // ========================================================

      final response = await http
          .post(
        Uri.parse(apiUrl),
        body: {
          'urlok': '1',
        },
      )
          .timeout(
        ApplicationConstant.volleyTimeout,
      );

      debugPrint('========================================');
      debugPrint('URL VALIDATION API');
      debugPrint('API URL: $apiUrl');
      debugPrint('POST BODY: urlok=1');
      debugPrint('STATUS CODE: ${response.statusCode}');
      debugPrint('SERVER RESPONSE: ${response.body}');
      debugPrint('========================================');

      // Keep original response for displaying
      // the exact server response.
      final serverResponse =
          response.body;

      // For comparison only.
      final trimmedResponse =
      serverResponse.trim();

      // ========================================================
      // EMPTY RESPONSE
      // ========================================================

      if (trimmedResponse.isEmpty) {
        return UrlValidationResult.failure(
          'No response server',
        );
      }

      // ========================================================
      // SUCCESS
      //
      // Java:
      // if(Response.equals("OK"))
      // ========================================================

      if (trimmedResponse == 'OK') {
        final saved =
        await PreferenceService.saveBaseUrl(
          baseUrl,
        );

        if (!saved) {
          return UrlValidationResult.failure(
            'Unable to save server URL.',
          );
        }

        return UrlValidationResult.success();
      }

      // ========================================================
      // ANY OTHER SERVER RESPONSE
      //
      // User requirement:
      // Exact server response display karna hai.
      // ========================================================

      return UrlValidationResult.failure(
        serverResponse,
      );
    } on TimeoutException {
      return UrlValidationResult.failure(
        'Server request timed out.',
      );
    } catch (e) {
      return UrlValidationResult.failure(
        'URL Error',
      );
    }
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  void dispose() {
    urlController.dispose();
  }
}

// ============================================================
// URL VALIDATION RESULT
// ============================================================

class UrlValidationResult {
  final bool success;
  final String? message;

  const UrlValidationResult({
    required this.success,
    this.message,
  });

  factory UrlValidationResult.success() {
    return const UrlValidationResult(
      success: true,
    );
  }

  factory UrlValidationResult.failure(
      String message,
      ) {
    return UrlValidationResult(
      success: false,
      message: message,
    );
  }
}