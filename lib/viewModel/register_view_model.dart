
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterViewModel extends ChangeNotifier {
  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final identificationController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final SupabaseClient _supabase = Supabase.instance.client;

  bool fullNameTouched = false;
  bool usernameTouched = false;
  bool identificationTouched = false;
  bool emailTouched = false;
  bool phoneTouched = false;
  bool passwordTouched = false;
  bool confirmPasswordTouched = false;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  bool isLoading = false;
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

  // ==========================================
  // VALIDACIONES DE DATOS PERSONALES
  // ==========================================

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

    if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9._]{3,19}$')
        .hasMatch(value)) {
      return 'Usa de 4 a 20 caracteres: letras, números, punto o guion bajo. Debe comenzar con una letra';
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

    return null;
  }

  String? get emailError {
    final value = emailController.text.trim();

    if (value.isEmpty) {
      return 'Ingresa tu correo electrónico';
    }

    if (!RegExp(
      r'^[\w.+-]+@([\w-]+\.)+[a-zA-Z]{2,}$',
    ).hasMatch(value)) {
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

  // ==========================================
  // VALIDACIONES DE CONTRASEÑA
  // ==========================================

  bool get hasMinimumLength =>
      passwordController.text.length >= 8;

  bool get hasUppercase =>
      RegExp(r'[A-Z]').hasMatch(passwordController.text);

  bool get hasLowercase =>
      RegExp(r'[a-z]').hasMatch(passwordController.text);

  bool get hasNumber =>
      RegExp(r'[0-9]').hasMatch(passwordController.text);

  bool get isValidPassword =>
      hasMinimumLength &&
          hasUppercase &&
          hasLowercase &&
          hasNumber;

  String? get passwordError {
    final value = passwordController.text;

    if (value.isEmpty) {
      return 'Ingresa una contraseña';
    }

    if (!isValidPassword) {
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

  // ==========================================
  // VALIDACIÓN GENERAL DEL FORMULARIO
  // ==========================================

  bool get isFormValid {
    return fullNameError == null &&
        usernameError == null &&
        identificationError == null &&
        emailError == null &&
        phoneError == null &&
        passwordError == null &&
        confirmPasswordError == null;
  }

  // ==========================================
  // REGISTRO CON SUPABASE
  // ==========================================

  Future<bool> registerNewUser() async {
    if (isLoading) {
      return false;
    }

    if (!isFormValid) {
      registrationError =
      'Revisa los campos antes de continuar';
      notifyListeners();
      return false;
    }

    isLoading = true;
    registrationError = null;
    notifyListeners();

    try {
      final username =
      usernameController.text.trim().toLowerCase();

      final email =
      emailController.text.trim().toLowerCase();

      final identification =
      identificationController.text.trim();

      final phone =
      phoneController.text.trim();

      final password =
          passwordController.text;

      final parts = fullNameController.text
          .trim()
          .split(RegExp(r'\s+'));

      final firstName = parts.first;
      final lastName = parts.sublist(1).join(' ');

      // Supabase Auth administra la contraseña.
      // Los demás datos se envían como metadatos.
      //
      // El trigger handle_new_user() insertará
      // estos datos en public.profiles.

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'identification': identification,
        },
      );

      if (response.user == null) {
        registrationError =
        'No se pudo completar el registro';
        return false;
      }

      registrationError = null;
      return true;
    } on AuthException catch (error) {
      registrationError =
          _getAuthErrorMessage(error);
      return false;
    } on PostgrestException catch (_) {
      registrationError =
      'No se pudo guardar el perfil. '
          'Verifica que el nombre de usuario, '
          'correo o cédula no estén registrados.';
      return false;
    } catch (_) {
      registrationError =
      'Ocurrió un error al registrar la cuenta. '
          'Inténtalo nuevamente.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // MENSAJES DE ERROR DE SUPABASE
  // ==========================================

  String _getAuthErrorMessage(AuthException error) {
    final message = error.message.toLowerCase();

    if (message.contains('already registered') ||
        message.contains('already exists') ||
        message.contains('user already registered')) {
      return 'Este correo electrónico ya está registrado';
    }

    if (message.contains('duplicate') ||
        message.contains('unique constraint')) {
      return 'El nombre de usuario, correo o cédula '
          'ya se encuentra registrado';
    }

    if (message.contains('password')) {
      return 'La contraseña no cumple los requisitos '
          'de seguridad';
    }

    if (message.contains('invalid email') ||
        message.contains('email address is invalid')) {
      return 'El correo electrónico no es válido';
    }

    if (message.contains('email rate limit') ||
        message.contains('rate limit') ||
        message.contains('too many requests')) {
      return 'Demasiados intentos. '
          'Espera unos minutos e inténtalo nuevamente';
    }

    if (message.contains('database error')) {
      return 'No se pudo crear el perfil. '
          'Comprueba que el usuario, correo y cédula '
          'no estén registrados.';
    }

    return 'No se pudo completar el registro: '
        '${error.message}';
  }

  // ==========================================
  // LIBERAR RECURSOS
  // ==========================================

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
