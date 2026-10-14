import 'package:flutter/material.dart';
import '../model/user_model.dart';
import 'login_view_model.dart';

class RegisterViewModel extends ChangeNotifier {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController identificationController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool fullNameTouched = false;
  bool identificationTouched = false;
  bool emailTouched = false;
  bool phoneTouched = false;

  void onFullNameChanged(String value) {
    fullNameTouched = true;
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

  // Validaciones en tiempo real (Flujo 1)
  String? get fullNameError {
    final v = fullNameController.text.trim();
    if (v.isEmpty) return 'Ingresa tus nombres y apellidos';
    if (!v.contains(' ') || v.length < 5) {
      return 'Ingresa al menos un nombre y un apellido';
    }
    return null;
  }

  String? get identificationError {
    final v = identificationController.text.trim();
    if (v.isEmpty) return 'Ingresa tu número de cédula';
    if (!RegExp(r'^\d{10}$').hasMatch(v)) {
      return 'La cédula debe tener 10 dígitos numéricos';
    }
    return null;
  }

  String? get emailError {
    final v = emailController.text.trim();
    if (v.isEmpty) return 'Ingresa tu correo electrónico';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  String? get phoneError {
    final v = phoneController.text.trim();
    if (v.isEmpty) return 'Ingresa tu número de celular';
    if (!RegExp(r'^09\d{8}$').hasMatch(v)) {
      return 'El celular debe empezar con 09 y tener 10 dígitos';
    }
    return null;
  }

  // ¿Los 4 campos son válidos?
  bool get isFormValid {
    return fullNameError == null &&
        identificationError == null &&
        emailError == null &&
        phoneError == null;
  }

  // Guarda el nuevo usuario usando el UserModel de tu compañera
  void registerNewUser() {
    final parts = fullNameController.text.trim().split(RegExp(r'\s+'));
    final firstName = parts.first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final newUser = UserModel(
      id: 'user-00${LoginViewModel.registeredUsers.length + 1}',
      firstName: firstName,
      lastName: lastName,
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      identification: identificationController.text.trim(),
    );

    LoginViewModel.registeredUsers.add(newUser);
  }

  @override
  void dispose() {
    fullNameController.dispose();
    identificationController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}