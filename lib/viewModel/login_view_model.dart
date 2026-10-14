import 'package:flutter/material.dart';

import '../model/user_model.dart';
import '../service/mock_auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final TextEditingController userController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  String? errorMessage;

  // Compatibilidad con el registro actual.
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

  // =====================================================
  // LOGIN CON CONTRASEÑA
  // =====================================================

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

  // =====================================================
  // VERIFICAR SI EL BOTÓN DE HUELLA DEBE HABILITARSE
  // =====================================================

  bool get canUseFingerprint {
    final inputUser = userController.text.trim();

    if (inputUser.isEmpty) {
      return false;
    }

    final user = MockAuthService.findUser(inputUser);

    if (user == null) {
      return false;
    }

    return MockAuthService.isFingerprintEnabled(user.id);
  }

  // =====================================================
  // LOGIN DIRECTO CON HUELLA SIMULADA
  // =====================================================

  bool loginWithFingerprint({bool isRecognized = true}) {
    final inputUser = userController.text.trim();

    if (!canUseFingerprint) {
      errorMessage = 'El ingreso con huella no está habilitado';
      notifyListeners();
      return false;
    }

    final success = MockAuthService.loginWithFingerprint(
      input: inputUser,
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
