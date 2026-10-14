import 'package:flutter/material.dart';

import '../model/user_model.dart';
import '../service/mock_auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  String? errorMessage;

  // Compatibilidad con el RegisterViewModel actual.
  static final List<UserModel> registeredUsers =
      MockAuthService.registeredUsers;

  static const String mockPassword = MockAuthService.defaultPassword;

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
    final inputUser = userController.text.trim();
    final inputPass = passwordController.text;

    if (inputUser.isEmpty || inputPass.isEmpty) {
      errorMessage = 'Ingresa tu usuario y contraseña';
      notifyListeners();
      return false;
    }

    final success = MockAuthService.login(inputUser, inputPass);

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
    final user = MockAuthService.findUser(userController.text);

    if (user == null) return false;

    return MockAuthService.isFingerprintEnabled(user.id);
  }

  bool loginWithFingerprint({required bool isRecognized}) {
    final inputUser = userController.text.trim();

    if (inputUser.isEmpty) {
      errorMessage = 'Ingresa tu usuario o cédula primero';
      notifyListeners();
      return false;
    }

    final user = MockAuthService.findUser(inputUser);

    if (user == null) {
      errorMessage = 'Usuario no encontrado';
      notifyListeners();
      return false;
    }

    if (!MockAuthService.isFingerprintEnabled(user.id)) {
      errorMessage =
      'El ingreso con huella está desactivado para este usuario';
      notifyListeners();
      return false;
    }

    if (!isRecognized) {
      errorMessage = 'Huella no reconocida';
      notifyListeners();
      return false;
    }

    final success = MockAuthService.loginWithFingerprint(
      input: inputUser,
      isRecognized: true,
    );

    errorMessage = success ? null : 'No se pudo iniciar sesión';
    notifyListeners();

    return success;
  }

  @override
  void dispose() {
    userController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}