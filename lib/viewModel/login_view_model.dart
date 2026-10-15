
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginViewModel extends ChangeNotifier {
  final TextEditingController userController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final SupabaseClient _supabase = Supabase.instance.client;

  bool obscurePassword = true;
  bool isLoading = false;

  String? errorMessage;

  LoginViewModel() {
    userController.addListener(_onUserChanged);
  }

  // ==========================================
  // CAMBIOS EN EL CAMPO DE USUARIO
  // ==========================================

  void _onUserChanged() {
    clearError();
    notifyListeners();
  }

  // ==========================================
  // MOSTRAR / OCULTAR CONTRASEÑA
  // ==========================================

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  // ==========================================
  // LIMPIAR MENSAJES DE ERROR
  // ==========================================

  void clearError() {
    if (errorMessage != null) {
      errorMessage = null;
      notifyListeners();
    }
  }

  // ==========================================
  // INICIAR SESIÓN CON SUPABASE
  // ==========================================

  Future<bool> login() async {
    if (isLoading) {
      return false;
    }

    final username =
    userController.text.trim().toLowerCase();

    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      errorMessage = 'Ingresa tu usuario y contraseña';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // La Edge Function recibe username y password.
      //
      // Internamente:
      // 1. Busca el correo asociado al username.
      // 2. Valida la contraseña con Supabase Auth.
      // 3. Devuelve los tokens de sesión.

      final response = await _supabase.functions.invoke(
        'login-with-username',
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.status != 200) {
        errorMessage = 'Usuario o contraseña incorrectos';
        return false;
      }

      final data = response.data;

      if (data is! Map) {
        errorMessage =
        'No se recibió una respuesta válida del servidor';
        return false;
      }

      final accessToken = data['access_token'];
      final refreshToken = data['refresh_token'];

      if (accessToken is! String ||
          refreshToken is! String ||
          accessToken.isEmpty ||
          refreshToken.isEmpty) {
        errorMessage =
        'No se pudo establecer la sesión';
        return false;
      }

      // Guardar la sesión autenticada en Supabase.
      //
      // A partir de este momento:
      // _supabase.auth.currentUser
      // _supabase.auth.currentSession
      //
      // estarán disponibles para consultar
      // el perfil, las cuentas y los movimientos.

      final authResponse = await _supabase.auth.setSession(
        refreshToken,
      );

      if (authResponse.session == null ||
          authResponse.user == null) {
        errorMessage =
        'No se pudo iniciar sesión';
        return false;
      }

      errorMessage = null;
      return true;
    } on FunctionException catch (error) {
      final status = error.status;

      if (status == 401 || status == 400) {
        errorMessage =
        'Usuario o contraseña incorrectos';
      } else {
        errorMessage =
        'No se pudo conectar con el servicio de inicio de sesión';
      }

      return false;
    } on AuthException catch (_) {
      errorMessage =
      'No se pudo establecer la sesión de usuario';
      return false;
    } catch (_) {
      errorMessage =
      'Ocurrió un error inesperado. Inténtalo nuevamente';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // HUELLA DIGITAL
  // ==========================================

  // Temporalmente deshabilitada.
  //
  // Antes se utilizaba MockAuthService para
  // simular una huella reconocida.
  //
  // Ahora no debemos permitir que una huella
  // simulada inicie sesión sin validar
  // credenciales reales.

  bool get canUseFingerprint => false;

  Future<bool> loginWithFingerprint({
    bool isRecognized = true,
  }) async {
    errorMessage =
    'El ingreso con huella estará disponible '
        'cuando configuremos la autenticación biométrica segura';

    notifyListeners();
    return false;
  }

  // ==========================================
  // LIBERAR RECURSOS
  // ==========================================

  @override
  void dispose() {
    userController.removeListener(_onUserChanged);
    userController.dispose();
    passwordController.dispose();

    super.dispose();
  }
}
