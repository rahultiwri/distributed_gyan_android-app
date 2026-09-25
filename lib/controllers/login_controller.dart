import '../models/login_model.dart';
import '../services/login_service.dart';

class LoginController {
  final LoginService _service =
  LoginService();

  Future<bool> login({
    required String userId,
    required String password,
  }) async {
    if (userId.trim().isEmpty ||
        password.isEmpty) {
      return false;
    }

    final model = LoginModel(
      userId: userId.trim(),
      password: password,
    );

    return _service.login(model);
  }
}