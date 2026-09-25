import '../models/login_model.dart';
import 'preference_service.dart';

class LoginService {
  Future<bool> login(
      LoginModel model,
      ) async {
    return PreferenceService.checkLogin(
      model.userId,
      model.password,
    );
  }
}