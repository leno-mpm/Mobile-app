import 'package:flutter/material.dart';
import '../mock/mock_users.dart';
import '../model/user_model.dart';

class LoginViewModel extends ChangeNotifier {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  String? errorMessage;

  // Contraseña mockeada por defecto para el taller
  static String mockPassword = 'Mint1234';

  // Lista en memoria que incluye al usuario de tu compañera + los que se registren en Flujo 1
  static final List<UserModel> registeredUsers = [
    MockUsers.currentUser,
  ];

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

  // Flujo 2: Validar usuario (correo, nombre o cédula) y contraseña
  bool login() {
    final inputUser = userController.text.trim().toLowerCase();
    final inputPass = passwordController.text;

    if (inputUser.isEmpty || inputPass.isEmpty) {
      errorMessage = 'Usuario o contraseña incorrectos';
      notifyListeners();
      return false;
    }

    for (final user in registeredUsers) {
      final emailPrefix = user.email.split('@').first.toLowerCase();
      final matchesUser = user.identification == inputUser ||
          user.email.toLowerCase() == inputUser ||
          user.firstName.toLowerCase() == inputUser ||
          emailPrefix == inputUser;

      if (matchesUser && inputPass == mockPassword) {
        errorMessage = null;
        notifyListeners();
        return true;
      }
    }

    errorMessage = 'Usuario o contraseña incorrectos';
    notifyListeners();
    return false;
  }

  // Flujo 3: Simulación de ingreso con huella
  bool loginWithFingerprint({required bool isRecognized}) {
    if (isRecognized) {
      errorMessage = null;
      notifyListeners();
      return true;
    } else {
      errorMessage = 'Huella no reconocida';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    userController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}