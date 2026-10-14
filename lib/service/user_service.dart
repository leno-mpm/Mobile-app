import '../model/user_model.dart';
import 'mock_auth_service.dart';

class UserService {
  Future<UserModel?> getUserById(String userId) async {
    for (final user in MockAuthService.registeredUsers) {
      if (user.id == userId) {
        return user;
      }
    }

    return null;
  }

  Future<UserModel> updateUser(UserModel updatedUser) async {
    final index = MockAuthService.registeredUsers.indexWhere(
          (user) => user.id == updatedUser.id,
    );

    if (index == -1) {
      throw ArgumentError('Usuario no encontrado');
    }

    MockAuthService.registeredUsers[index] = updatedUser;

    return updatedUser;
  }
}