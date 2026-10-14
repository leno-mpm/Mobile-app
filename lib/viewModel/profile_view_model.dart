
import 'package:flutter/foundation.dart';

import '../model/user_model.dart';
import '../service/user_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserService _userService;

  ProfileViewModel(this._userService);
  UserModel? _user;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  // Cargar la información del usuario
  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _userService.getUserById(userId);
      if (_user == null) {
        _errorMessage = 'No se encontró el usuario';
      }
    } catch (e) {
      _user = null;
      _errorMessage = 'No se pudo cargar el perfil';
      debugPrint('Error al cargar perfil: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar los datos del perfil
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    if (_user == null || _isSaving) {
      return false;
    }
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = _user!.copyWith(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
      );
      _user = await _userService.updateUser(updatedUser);
      return true;
    } catch (e) {
      _errorMessage = 'No se pudo actualizar el perfil';
      debugPrint('Error al actualizar perfil: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
