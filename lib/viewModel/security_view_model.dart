
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecurityViewModel extends ChangeNotifier {
  final String userId;

  SecurityViewModel(this.userId);

  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isChangingPassword = false;

  bool get isChangingPassword => _isChangingPassword;

  // ==========================================
  // HUELLA DIGITAL
  // ==========================================

  // La autenticación biométrica real todavía
  // no está implementada: el switch solo
  // simula el estado, no activa huella real.
  bool _fingerprintEnabled = false;

  bool get fingerprintEnabled => _fingerprintEnabled;

  void setFingerprintEnabled(bool enabled) {
    _fingerprintEnabled = enabled;
    notifyListeners();
  }

  // ==========================================
  // CAMBIAR CONTRASEÑA CON SUPABASE AUTH
  // ==========================================

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (_isChangingPassword) {
      return 'Ya se está procesando un cambio de contraseña';
    }

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

    final authUser = _supabase.auth.currentUser;

    if (authUser == null) {
      return 'Debes iniciar sesión nuevamente';
    }

    if (userId.isNotEmpty && authUser.id != userId) {
      return 'La sesión no corresponde al usuario actual';
    }

    final email = authUser.email;

    if (email == null || email.isEmpty) {
      return 'No se encontró el correo de la cuenta';
    }

    _isChangingPassword = true;
    notifyListeners();

    try {
      // Verificar la contraseña actual.
      // Supabase Auth realiza la validación.
      final verification = await _supabase.auth
          .signInWithPassword(
        email: email,
        password: currentPassword,
      );

      if (verification.user == null ||
          verification.user!.id != authUser.id) {
        return 'No se pudo verificar la contraseña actual';
      }

      // Actualizar la contraseña en Supabase Auth.
      await _supabase.auth.updateUser(
        UserAttributes(
          password: newPassword,
          currentPassword: currentPassword,
        ),
      );

      return null;
    } on AuthException catch (e) {
      debugPrint('Error de Supabase Auth: ${e.message}');

      final message = e.message.toLowerCase();

      if (message.contains('invalid login credentials') ||
          message.contains('invalid credentials')) {
        return 'La contraseña actual es incorrecta';
      }

      if (message.contains('same password') ||
          message.contains('different from the old')) {
        return 'La nueva contraseña debe ser diferente';
      }

      if (message.contains('password')) {
        return 'No se pudo actualizar la contraseña: ${e.message}';
      }

      return 'No se pudo cambiar la contraseña. Inténtalo nuevamente';
    } catch (e) {
      debugPrint('Error al cambiar contraseña: $e');

      return 'Ocurrió un error al cambiar la contraseña';
    } finally {
      _isChangingPassword = false;
      notifyListeners();
    }
  }
}
