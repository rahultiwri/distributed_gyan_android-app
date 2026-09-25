import '../services/preference_service.dart';

class SplashController {
  Future<bool> hasSavedUrl() async {
    return PreferenceService.hasSavedBaseUrl();
  }

  Future<bool> isRegistrationCompleted() async {
    return PreferenceService.isRegistrationCompleted();
  }
}