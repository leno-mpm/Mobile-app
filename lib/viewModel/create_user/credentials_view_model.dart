
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../model/registration_flow_data.dart';

class CredentialsViewModel extends ChangeNotifier {
  final RegistrationFlowData flowData;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final SupabaseClient _supabase = Supabase.instance.client;

  bool usernameTouched = false;
  bool passwordTouched = false;
  bool confirmPasswordTouched = false;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  bool isLoading = false;
  String? registrationError;

  CredentialsViewModel(this.flowData);

  void onUsernameChanged(String value) {
    usernameTouched = true;
    notifyListeners();
  }

  void onPasswordChanged(String value) {
    passwordTouched = true;
    notifyListeners();
  }

  void onConfirmPasswordChanged(String value) {
    confirmPasswordTouched = true;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  // ==========================================
  // VALIDACIONES
  // ==========================================

  String? get usernameError {
    final value = usernameController.text.trim();

    if (value.isEmpty) {
      return 'Ingresa un nombre de usuario';
    }

    if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9._]{3,19}$').hasMatch(value)) {
      return 'Usa de 4 a 20 caracteres: letras, números, punto o guion '
          'bajo. Debe comenzar con una letra';
    }

    return null;
  }

  bool get hasMinimumLength => passwordController.text.length >= 8;

  bool get hasUppercase => RegExp(r'[A-Z]').hasMatch(passwordController.text);

  bool get hasLowercase => RegExp(r'[a-z]').hasMatch(passwordController.text);

  bool get hasNumber => RegExp(r'[0-9]').hasMatch(passwordController.text);

  bool get isValidPassword =>
      hasMinimumLength && hasUppercase && hasLowercase && hasNumber;

  String? get passwordError {
    if (passwordController.text.isEmpty) {
      return 'Ingresa una contraseña';
    }

    if (!isValidPassword) {
      return 'La contraseña no cumple los requisitos';
    }

    return null;
  }

  String? get confirmPasswordError {
    if (confirmPasswordController.text.isEmpty) {
      return 'Confirma tu contraseña';
    }

    if (confirmPasswordController.text != passwordController.text) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  bool get isFormValid =>
      usernameError == null &&
      passwordError == null &&
      confirmPasswordError == null;

  // ==========================================
  // CREAR USUARIO CON SUPABASE
  // ==========================================

  Future<bool> createUser() async {
    if (isLoading) {
      return false;
    }

    usernameTouched = true;
    passwordTouched = true;
    confirmPasswordTouched = true;

    if (!isFormValid) {
      registrationError = 'Revisa los campos antes de continuar';
      notifyListeners();
      return false;
    }

    isLoading = true;
    registrationError = null;
    notifyListeners();

    try {
      final username = usernameController.text.trim().toLowerCase();
      final password = passwordController.text;

      final firstName =
          '${flowData.firstName} ${flowData.secondName}'.trim();
      final lastName =
          '${flowData.lastName} ${flowData.secondLastName}'.trim();

      final response = await _supabase.auth.signUp(
        email: flowData.email,
        password: password,
        data: {
          'username': username,
          'first_name': firstName,
          'last_name': lastName,
          'phone': flowData.phone,
          'identification': flowData.identification,
        },
      );

      if (response.user == null) {
        registrationError = 'No se pudo completar el registro';
        return false;
      }

      registrationError = null;
      return true;
    } on AuthException catch (error) {
      registrationError = _getAuthErrorMessage(error);
      return false;
    } on PostgrestException catch (_) {
      registrationError = 'No se pudo guardar el perfil. '
          'Verifica que el nombre de usuario, correo o cédula no estén '
          'registrados.';
      return false;
    } catch (_) {
      registrationError = 'Ocurrió un error al registrar la cuenta. '
          'Inténtalo nuevamente.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String get username => usernameController.text.trim().toLowerCase();

  String _getAuthErrorMessage(AuthException error) {
    final message = error.message.toLowerCase();

    if (message.contains('already registered') ||
        message.contains('already exists') ||
        message.contains('user already registered')) {
      return 'Este correo electrónico ya está registrado';
    }

    if (message.contains('duplicate') ||
        message.contains('unique constraint')) {
      return 'El nombre de usuario, correo o cédula ya se encuentra '
          'registrado';
    }

    if (message.contains('password')) {
      return 'La contraseña no cumple los requisitos de seguridad';
    }

    if (message.contains('invalid email') ||
        message.contains('email address is invalid')) {
      return 'El correo electrónico no es válido';
    }

    if (message.contains('email rate limit') ||
        message.contains('rate limit') ||
        message.contains('too many requests')) {
      return 'Demasiados intentos. Espera unos minutos e inténtalo '
          'nuevamente';
    }

    if (message.contains('database error')) {
      return 'No se pudo crear el perfil. Comprueba que el usuario, '
          'correo y cédula no estén registrados.';
    }

    return 'No se pudo completar el registro: ${error.message}';
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
