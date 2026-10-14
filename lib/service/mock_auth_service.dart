import '../mock/mock_users.dart';
import '../model/user_model.dart';

class MockAuthService {
  MockAuthService._();

  static const String defaultPassword = 'Mint1234';

  static final List<UserModel> registeredUsers = [
    MockUsers.currentUser,
  ];

  static final Map<String, String> _passwords = {};

  static final Map<String, bool> _fingerprintSettings = {};

  static String? currentUserId;

  static UserModel? get currentUser {
    for (final user in registeredUsers) {
      if (user.id == currentUserId) return user;
    }
    return null;
  }

  static UserModel? findUser(String input) {
    final value = input.trim().toLowerCase();

    for (final user in registeredUsers) {
      final emailPrefix = user.email.split('@').first.toLowerCase();

      if (user.identification == value ||
          user.email.toLowerCase() == value ||
          user.firstName.toLowerCase() == value ||
          emailPrefix == value) {
        return user;
      }
    }

    return null;
  }

  static bool login(String input, String password) {
    final user = findUser(input);

    if (user == null) return false;

    final savedPassword = _passwords[user.id] ?? defaultPassword;

    if (password != savedPassword) return false;

    currentUserId = user.id;
    return true;
  }

  static bool changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) {
    final savedPassword = _passwords[userId] ?? defaultPassword;

    if (currentPassword != savedPassword) return false;

    _passwords[userId] = newPassword;
    return true;
  }

  static bool isFingerprintEnabled(String userId) {
    return _fingerprintSettings[userId] ?? false;
  }

  static void setFingerprintEnabled(String userId, bool enabled) {
    _fingerprintSettings[userId] = enabled;
  }

  static bool loginWithFingerprint({
    required String input,
    required bool isRecognized,
  }) {
    final user = findUser(input);

    if (user == null ||
        !isFingerprintEnabled(user.id) ||
        !isRecognized) {
      return false;
    }

    currentUserId = user.id;
    return true;
  }

  static void logout() {
    currentUserId = null;
  }
}