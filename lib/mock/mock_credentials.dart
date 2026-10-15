import '../model/user_credential_model.dart';
import 'mock_users.dart';

class MockCredentials {
  MockCredentials._();

  // Contraseña inicial del usuario de prueba María.
  static const String mariaInitialPassword = 'Mint1234';

  // Credenciales mockeadas de los usuarios.
  static final List<UserCredentialModel> credentials = [
    UserCredentialModel(
      userId: MockUsers.currentUser.id,
      password: mariaInitialPassword,
    ),
  ];
}
