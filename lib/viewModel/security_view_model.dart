import 'package:flutter/material.dart';

import '../service/mock_auth_service.dart';

class SecurityViewModel extends ChangeNotifier {
  final String userId;

  SecurityViewModel(this.userId);

  bool get fingerprintEnabled {
    return MockAuthService.isFingerprintEnabled(userId);
  }

  void setFingerprintEnabled(bool enabled) {
    MockAuthService.setFingerprintEnabled(userId, enabled);
    notifyListeners();
  }

  String? changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      return 'Completa todos los campos';
    }

    if (newPassword.length < 8) {
      return 'La nueva contraseña debe tener al menos 8 caracteres';
    }

    if (!RegExp(r'[A-Z]').hasMatch(newPassword) ||
        !RegExp(r'[a-z]').hasMatch(newPassword) ||
        !RegExp(r'[0-9]').hasMatch(newPassword)) {
      return 'Usa mayúsculas, minúsculas y números';
    }

    if (newPassword != confirmPassword) {
      return 'Las contraseñas nuevas no coinciden';
    }

    if (newPassword == currentPassword) {
      return 'La nueva contraseña debe ser diferente';
    }

    final success = MockAuthService.changePassword(
      userId: userId,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    if (!success) {
      return 'La contraseña actual es incorrecta';
    }

    notifyListeners();
    return null;
  }
}