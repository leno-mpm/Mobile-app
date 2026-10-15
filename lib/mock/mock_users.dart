import '../model/user_model.dart';

class MockUsers {
  static const UserModel currentUser = UserModel(
    id: 'user-001',
    username: 'maria.gonzalez',
    firstName: 'María',
    lastName: 'González',
    email: 'maria@gmail.com',
    phone: '0991234567',
    identification: '0123456789',
  );
}
