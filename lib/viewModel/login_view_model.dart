import 'package:flutter/material.dart';

import '../model/user_model.dart';
import '../service/mock_auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final TextEditingController userController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  String? errorMessage;

  static final List<UserModel> registeredUsers =
      MockAuthService.registeredUsers;

  static const String mockPassword = MockAuthService.defaultPassword;

  LoginViewModel() {
    userController.addListener(_onUserChanged);
  }

  void _onUserChanged() {
    notifyListeners();
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void clearError() {
    if (errorMessage != null) {
      errorMessage = null;
      notifyListeners();
    }
  }

  bool login() {
    final username = userController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      errorMessage = 'Ingresa tu usuario y contraseña';
      notifyListeners();
      return false;
    }

    final success = MockAuthService.login(username, password);

    if (!success) {
      errorMessage = 'Usuario o contraseña incorrectos';
      notifyListeners();
      return false;
    }

    errorMessage = null;
    notifyListeners();

    return true;
  }

  bool get canUseFingerprint {
    final username = userController.text.trim();

    final user = MockAuthService.findUser(username);

    if (user == null) return false;

    return MockAuthService.isFingerprintEnabled(user.id);
  }

  bool loginWithFingerprint({bool isRecognized = true}) {
    final username = userController.text.trim();

    if (!canUseFingerprint) {
      errorMessage = 'El ingreso con huella no está habilitado';
      notifyListeners();
      return false;
    }

    final success = MockAuthService.loginWithFingerprint(
      input: username,
      isRecognized: isRecognized,
    );

    if (!success) {
      errorMessage = 'No se pudo iniciar sesión con huella';
      notifyListeners();
      return false;
    }

    errorMessage = null;
    notifyListeners();

    return true;
  }

  @override
  void dispose() {
    userController.removeListener(_onUserChanged);
    userController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
