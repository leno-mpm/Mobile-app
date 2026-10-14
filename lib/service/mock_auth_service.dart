import '../mock/mock_users.dart';
import '../model/user_model.dart';

class MockAuthService {
  MockAuthService._();

  static const String defaultPassword = 'Mint1234';

  // Usuarios registrados durante la ejecución.
  static final List<UserModel> registeredUsers = [MockUsers.currentUser];

  // Contraseñas simuladas por usuario.
  static final Map<String, String> _passwords = {};

  // Configuración de huella simulada por usuario.
  static final Map<String, bool> _fingerprintSettings = {};

  // Identificador del usuario que inició sesión.
  static String? currentUserId;

  static UserModel? get currentUser {
    for (final user in registeredUsers) {
      if (user.id == currentUserId) {
        return user;
      }
    }

    return null;
  }

  // Buscar usuario por cédula, correo, nombre
  // o la parte inicial del correo.
  static UserModel? findUser(String input) {
    final value = input.trim().toLowerCase();

    if (value.isEmpty) return null;

    for (final user in registeredUsers) {
      final emailPrefix = user.email.split('@').first.toLowerCase();

      if (user.identification.toLowerCase() == value ||
          user.email.toLowerCase() == value ||
          user.firstName.toLowerCase() == value ||
          emailPrefix == value) {
        return user;
      }
    }

    return null;
  }

  // Inicio de sesión tradicional.
  static bool login(String input, String password) {
    final user = findUser(input);

    if (user == null) {
      return false;
    }

    final savedPassword = _passwords[user.id] ?? defaultPassword;

    if (password != savedPassword) {
      return false;
    }

    currentUserId = user.id;
    return true;
  }

  // Cambiar contraseña del usuario.
  static bool changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) {
    final savedPassword = _passwords[userId] ?? defaultPassword;

    if (currentPassword != savedPassword) {
      return false;
    }

    _passwords[userId] = newPassword;
    return true;
  }

  // Consultar el estado del switch de huella.
  static bool isFingerprintEnabled(String userId) {
    return _fingerprintSettings[userId] ?? false;
  }

  // Activar o desactivar la huella simulada.
  static void setFingerprintEnabled(String userId, bool enabled) {
    _fingerprintSettings[userId] = enabled;
  }

  // Inicio de sesión con huella simulada.
  //
  // No utiliza sensores reales. Solo comprueba
  // si la opción está habilitada para el usuario.
  static bool loginWithFingerprint({
    required String input,
    bool isRecognized = true,
  }) {
    final user = findUser(input);

    if (user == null) {
      return false;
    }

    if (!isFingerprintEnabled(user.id)) {
      return false;
    }

    if (!isRecognized) {
      return false;
    }

    currentUserId = user.id;
    return true;
  }

  // Cerrar sesión sin borrar la configuración.
  static void logout() {
    currentUserId = null;
  }
}
