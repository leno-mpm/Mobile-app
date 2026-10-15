import 'package:flutter/material.dart';

import '../model/user_model.dart';
import '../service/mock_auth_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final identificationController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool fullNameTouched = false;
  bool usernameTouched = false;
  bool identificationTouched = false;
  bool emailTouched = false;
  bool phoneTouched = false;
  bool passwordTouched = false;
  bool confirmPasswordTouched = false;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  String? registrationError;

  void onFullNameChanged(String value) {
    fullNameTouched = true;
    notifyListeners();
  }

  void onUsernameChanged(String value) {
    usernameTouched = true;
    notifyListeners();
  }

  void onIdentificationChanged(String value) {
    identificationTouched = true;
    notifyListeners();
  }

  void onEmailChanged(String value) {
    emailTouched = true;
    notifyListeners();
  }

  void onPhoneChanged(String value) {
    phoneTouched = true;
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

  String? get fullNameError {
    final value = fullNameController.text.trim();

    if (value.isEmpty) {
      return 'Ingresa tus nombres y apellidos';
    }

    if (!value.contains(' ') || value.length < 5) {
      return 'Ingresa al menos un nombre y un apellido';
    }

    return null;
  }

  String? get usernameError {
    final value = usernameController.text.trim();

    if (value.isEmpty) {
      return 'Ingresa un nombre de usuario';
    }

    if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9._]{3,19}$').hasMatch(value)) {
      return 'Usa de 4 a 20 caracteres: letras, números, punto o guion bajo. Debe comenzar con una letra';
    }

    if (MockAuthService.usernameExists(value)) {
      return 'Este nombre de usuario ya está registrado';
    }

    return null;
  }

  String? get identificationError {
    final value = identificationController.text.trim();

    if (value.isEmpty) {
      return 'Ingresa tu número de cédula';
    }

    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'La cédula debe tener 10 dígitos numéricos';
    }

    if (MockAuthService.identificationExists(value)) {
      return 'Esta cédula ya está registrada';
    }

    return null;
  }

  String? get emailError {
    final value = emailController.text.trim();

    if (value.isEmpty) {
      return 'Ingresa tu correo electrónico';
    }

    if (!RegExp(r'^[\w.+-]+@([\w-]+\.)+[a-zA-Z]{2,}$').hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }

    if (MockAuthService.emailExists(value)) {
      return 'Este correo ya está registrado';
    }

    return null;
  }

  String? get phoneError {
    final value = phoneController.text.trim();

    if (value.isEmpty) {
      return 'Ingresa tu número de celular';
    }

    if (!RegExp(r'^09\d{8}$').hasMatch(value)) {
      return 'El celular debe empezar con 09 y tener 10 dígitos';
    }

    return null;
  }

  bool get hasMinimumLength => passwordController.text.length >= 8;

  bool get hasUppercase => RegExp(r'[A-Z]').hasMatch(passwordController.text);

  bool get hasLowercase => RegExp(r'[a-z]').hasMatch(passwordController.text);

  bool get hasNumber => RegExp(r'[0-9]').hasMatch(passwordController.text);

  String? get passwordError {
    final value = passwordController.text;

    if (value.isEmpty) {
      return 'Ingresa una contraseña';
    }

    if (!MockAuthService.isValidPassword(value)) {
      return 'La contraseña no cumple los requisitos';
    }

    return null;
  }

  String? get confirmPasswordError {
    final value = confirmPasswordController.text;

    if (value.isEmpty) {
      return 'Confirma tu contraseña';
    }

    if (value != passwordController.text) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  bool get isFormValid {
    return fullNameError == null &&
        usernameError == null &&
        identificationError == null &&
        emailError == null &&
        phoneError == null &&
        passwordError == null &&
        confirmPasswordError == null;
  }

  bool registerNewUser() {
    if (!isFormValid) {
      registrationError = 'Revisa los campos antes de continuar';
      notifyListeners();
      return false;
    }

    final parts = fullNameController.text.trim().split(RegExp(r'\s+'));

    final firstName = parts.first;
    final lastName = parts.sublist(1).join(' ');

    final user = UserModel(
      id: 'user-${DateTime.now().microsecondsSinceEpoch}',
      username: usernameController.text.trim().toLowerCase(),
      firstName: firstName,
      lastName: lastName,
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      identification: identificationController.text.trim(),
    );

    final success = MockAuthService.registerUser(
      user: user,
      password: passwordController.text,
    );

    if (!success) {
      registrationError = 'No se pudo registrar. Revisa si el usuario, correo o cédula ya existen';
      notifyListeners();
      return false;
    }

    registrationError = null;
    notifyListeners();

    return true;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    usernameController.dispose();
    identificationController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
