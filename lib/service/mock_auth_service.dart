import '../mock/mock_credentials.dart';
import '../mock/mock_users.dart';
import '../model/user_credential_model.dart';
import '../model/user_model.dart';

class MockAuthService {
  MockAuthService._();

  // Contraseña inicial del usuario de prueba María.
  // Se conserva por compatibilidad con el Login actual.
  static const String defaultPassword = MockCredentials.mariaInitialPassword;

  // =====================================================
  // USUARIOS REGISTRADOS
  // =====================================================

  static final List<UserModel> registeredUsers = [MockUsers.currentUser];

  // Credenciales independientes por usuario.
  static final List<UserCredentialModel> credentials =
      MockCredentials.credentials;

  // Configuración individual de huella simulada.
  static final Map<String, bool> _fingerprintSettings = {};

  // Usuario que tiene una sesión activa.
  static String? currentUserId;

  // =====================================================
  // USUARIO AUTENTICADO
  // =====================================================

  static UserModel? get currentUser {
    final id = currentUserId;

    if (id == null) return null;

    for (final user in registeredUsers) {
      if (user.id == id) {
        return user;
      }
    }

    return null;
  }

  // =====================================================
  // BUSCAR USUARIO EXCLUSIVAMENTE POR USERNAME
  // =====================================================

  static UserModel? findUser(String username) {
    final normalized = username.trim().toLowerCase();

    if (normalized.isEmpty) return null;

    for (final user in registeredUsers) {
      if (user.username.toLowerCase() == normalized) {
        return user;
      }
    }

    return null;
  }

  static bool usernameExists(String username) {
    return findUser(username) != null;
  }

  static bool identificationExists(String identification) {
    final normalized = identification.trim();

    return registeredUsers.any((user) => user.identification == normalized);
  }

  static bool emailExists(String email) {
    final normalized = email.trim().toLowerCase();

    return registeredUsers.any(
      (user) => user.email.toLowerCase() == normalized,
    );
  }

  // =====================================================
  // BUSCAR CREDENCIALES POR USER ID
  // =====================================================

  static UserCredentialModel? findCredentials(String userId) {
    for (final credential in credentials) {
      if (credential.userId == userId) {
        return credential;
      }
    }

    return null;
  }

  // =====================================================
  // VALIDAR REQUISITOS DE CONTRASEÑA
  // =====================================================

  static bool isValidPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  // =====================================================
  // REGISTRAR NUEVO USUARIO
  // =====================================================

  static bool registerUser({
    required UserModel user,
    required String password,
  }) {
    // Validar usuario, correo y cédula únicos.
    if (usernameExists(user.username) ||
        identificationExists(user.identification) ||
        emailExists(user.email)) {
      return false;
    }

    // Validar que no se repita el identificador.
    if (registeredUsers.any((registered) => registered.id == user.id)) {
      return false;
    }

    // Validar contraseña.
    if (!isValidPassword(password)) {
      return false;
    }

    // Guardar información personal.
    registeredUsers.add(user);

    // Guardar credenciales independientes.
    credentials.add(UserCredentialModel(userId: user.id, password: password));

    // La huella comienza desactivada.
    _fingerprintSettings[user.id] = false;

    return true;
  }

  // =====================================================
  // INICIO DE SESIÓN CON USERNAME Y CONTRASEÑA
  // =====================================================

  static bool login(String username, String password) {
    final user = findUser(username);

    if (user == null) {
      return false;
    }

    final credential = findCredentials(user.id);

    if (credential == null) {
      return false;
    }

    if (credential.password != password) {
      return false;
    }

    currentUserId = user.id;

    return true;
  }

  // =====================================================
  // CAMBIAR CONTRASEÑA
  // =====================================================

  static bool changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) {
    final index = credentials.indexWhere(
      (credential) => credential.userId == userId,
    );

    if (index == -1) {
      return false;
    }

    final currentCredential = credentials[index];

    // Verificar contraseña actual.
    if (currentCredential.password != currentPassword) {
      return false;
    }

    // Verificar requisitos de la nueva contraseña.
    if (!isValidPassword(newPassword)) {
      return false;
    }

    // Evitar utilizar la misma contraseña.
    if (currentPassword == newPassword) {
      return false;
    }

    // Actualizar únicamente las credenciales
    // del usuario correspondiente.
    credentials[index] = currentCredential.copyWith(password: newPassword);

    return true;
  }

  // =====================================================
  // CONFIGURACIÓN DE HUELLA SIMULADA
  // =====================================================

  static bool isFingerprintEnabled(String userId) {
    return _fingerprintSettings[userId] ?? false;
  }

  static void setFingerprintEnabled(String userId, bool enabled) {
    final userExists = registeredUsers.any((user) => user.id == userId);

    if (!userExists) return;

    _fingerprintSettings[userId] = enabled;
  }

  // =====================================================
  // LOGIN CON HUELLA SIMULADA
  // =====================================================

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

    // También debe existir una credencial registrada.
    if (findCredentials(user.id) == null) {
      return false;
    }

    currentUserId = user.id;

    return true;
  }

  // =====================================================
  // CERRAR SESIÓN
  // =====================================================

  static void logout() {
    currentUserId = null;
  }
}
