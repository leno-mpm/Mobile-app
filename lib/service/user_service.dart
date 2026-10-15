
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/user_model.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==========================================
  // OBTENER USUARIO DESDE SUPABASE
  // ==========================================

  Future<UserModel?> getUserById(String userId) async {
    final currentUser = _supabase.auth.currentUser;

    if (currentUser == null || currentUser.id != userId) {
      throw StateError('No hay una sesión válida');
    }

    final data = await _supabase
        .from('profiles')
        .select(
      'id, username, first_name, last_name, '
          'email, phone, identification',
    )
        .eq('id', userId)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return UserModel(
      id: data['id'] as String,
      username: data['username'] as String,
      firstName: data['first_name'] as String,
      lastName: data['last_name'] as String,
      email: data['email'] as String,
      phone: data['phone'] as String,
      identification: data['identification'] as String,
    );
  }

  // ==========================================
  // ACTUALIZAR USUARIO EN SUPABASE
  // ==========================================

  Future<UserModel> updateUser(UserModel updatedUser) async {
    final currentUser = _supabase.auth.currentUser;

    if (currentUser == null ||
        currentUser.id != updatedUser.id) {
      throw StateError('No hay una sesión válida');
    }

    // El correo se administra mediante Supabase Auth.
    // No se modifica directamente en profiles.
    if (updatedUser.email.trim().toLowerCase() !=
        (currentUser.email ?? '').trim().toLowerCase()) {
      throw StateError(
        'El cambio de correo requiere verificación independiente',
      );
    }

    final data = await _supabase
        .from('profiles')
        .update({
      'first_name': updatedUser.firstName.trim(),
      'last_name': updatedUser.lastName.trim(),
      'phone': updatedUser.phone.trim(),
    })
        .eq('id', currentUser.id)
        .select(
      'id, username, first_name, last_name, '
          'email, phone, identification',
    )
        .single();

    return UserModel(
      id: data['id'] as String,
      username: data['username'] as String,
      firstName: data['first_name'] as String,
      lastName: data['last_name'] as String,
      email: data['email'] as String,
      phone: data['phone'] as String,
      identification: data['identification'] as String,
    );
  }
}
