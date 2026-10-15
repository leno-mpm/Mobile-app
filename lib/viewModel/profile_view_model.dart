
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/user_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  UserModel? _user;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  // ==========================================
  // CARGAR PERFIL DESDE SUPABASE
  // ==========================================

  Future<void> loadProfile() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authUser = _supabase.auth.currentUser;

      if (authUser == null) {
        _user = null;
        _errorMessage = 'No hay una sesión activa';
        return;
      }

      final data = await _supabase
          .from('profiles')
          .select(
        'id, username, first_name, last_name, '
            'email, phone, identification',
      )
          .eq('id', authUser.id)
          .maybeSingle();

      if (data == null) {
        _user = null;
        _errorMessage = 'No se encontró tu perfil';
        return;
      }

      _user = UserModel(
        id: data['id'] as String,
        username: data['username'] as String,
        firstName: data['first_name'] as String,
        lastName: data['last_name'] as String,
        email: data['email'] as String,
        phone: data['phone'] as String,
        identification: data['identification'] as String,
      );
    } on PostgrestException catch (e) {
      _user = null;
      _errorMessage = 'No se pudo consultar tu perfil';
      debugPrint('Error de Supabase al cargar perfil: ${e.message}');
    } catch (e) {
      _user = null;
      _errorMessage = 'No se pudo cargar el perfil';
      debugPrint('Error al cargar perfil: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // ACTUALIZAR DATOS DEL PERFIL
  // ==========================================

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    if (_user == null || _isSaving) return false;

    final authUser = _supabase.auth.currentUser;

    if (authUser == null || authUser.id != _user!.id) {
      _errorMessage = 'No hay una sesión válida';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // El correo se administra mediante Supabase Auth.
      // No lo modificamos directamente en profiles,
      // para evitar inconsistencias con auth.users.

      if (email.trim().toLowerCase() !=
          _user!.email.trim().toLowerCase()) {
        _errorMessage =
        'El cambio de correo requiere un proceso '
            'de verificación independiente';
        return false;
      }

      final data = await _supabase
          .from('profiles')
          .update({
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'phone': phone.trim(),
      })
          .eq('id', authUser.id)
          .select(
        'id, username, first_name, last_name, '
            'email, phone, identification',
      )
          .single();

      _user = UserModel(
        id: data['id'] as String,
        username: data['username'] as String,
        firstName: data['first_name'] as String,
        lastName: data['last_name'] as String,
        email: data['email'] as String,
        phone: data['phone'] as String,
        identification: data['identification'] as String,
      );

      return true;
    } on PostgrestException catch (e) {
      _errorMessage = 'No se pudo actualizar el perfil';
      debugPrint('Error de Supabase: ${e.message}');
      return false;
    } catch (e) {
      _errorMessage = 'Ocurrió un error al actualizar el perfil';
      debugPrint('Error al actualizar perfil: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ==========================================
  // CERRAR SESIÓN REAL
  // ==========================================

  Future<bool> logout() async {
    try {
      await _supabase.auth.signOut();
      _user = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'No se pudo cerrar la sesión';
      debugPrint('Error al cerrar sesión: $e');
      notifyListeners();
      return false;
    }
  }
}
