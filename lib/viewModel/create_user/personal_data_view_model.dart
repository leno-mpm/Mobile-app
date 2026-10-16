
import 'package:flutter/material.dart';

import '../../model/registration_flow_data.dart';

class PersonalDataViewModel extends ChangeNotifier {
  final RegistrationFlowData flowData;

  final firstNameController = TextEditingController();
  final secondNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final secondLastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  bool firstNameTouched = false;
  bool lastNameTouched = false;
  bool emailTouched = false;
  bool phoneTouched = false;

  PersonalDataViewModel(this.flowData) {
    firstNameController.text = flowData.firstName;
    secondNameController.text = flowData.secondName;
    lastNameController.text = flowData.lastName;
    secondLastNameController.text = flowData.secondLastName;
    emailController.text = flowData.email;
    phoneController.text = flowData.phone;
  }

  void onFirstNameChanged(String value) {
    firstNameTouched = true;
    notifyListeners();
  }

  void onLastNameChanged(String value) {
    lastNameTouched = true;
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

  // ==========================================
  // VALIDACIONES
  // ==========================================

  String? get firstNameError {
    if (firstNameController.text.trim().isEmpty) {
      return 'Ingresa tu primer nombre';
    }

    return null;
  }

  String? get lastNameError {
    if (lastNameController.text.trim().isEmpty) {
      return 'Ingresa tu primer apellido';
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

  bool get isFormValid {
    return firstNameError == null &&
        lastNameError == null &&
        emailError == null &&
        phoneError == null;
  }

  // ==========================================
  // GUARDAR EN EL FLUJO Y CONTINUAR
  // ==========================================

  RegistrationFlowData saveAndContinue() {
    flowData.firstName = firstNameController.text.trim();
    flowData.secondName = secondNameController.text.trim();
    flowData.lastName = lastNameController.text.trim();
    flowData.secondLastName = secondLastNameController.text.trim();
    flowData.email = emailController.text.trim().toLowerCase();
    flowData.phone = phoneController.text.trim();

    return flowData;
  }

  @override
  void dispose() {
    firstNameController.dispose();
    secondNameController.dispose();
    lastNameController.dispose();
    secondLastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
