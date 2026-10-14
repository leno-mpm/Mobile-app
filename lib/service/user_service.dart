import 'package:mobile_app/mock/mock_users.dart';
import 'package:mobile_app/model/user_model.dart';

class UserService {

  //Usuario almacenado temporamente en memoria
  UserModel _currentUser = MockUsers.currentUser;

  //Obtener los datos de un usuario
  Future<UserModel?> getUserById(String userId) async {
    if(_currentUser.id == userId){
      return _currentUser;
    }
    return null;
  }

  //Actualizar los datos del usuario
  Future<UserModel> updateUser (UserModel updateUser) async{
    if(_currentUser.id != updateUser.id){
      throw ArgumentError('El usuario no existe');
    }

    _currentUser = updateUser;
    return _currentUser;
  }
}