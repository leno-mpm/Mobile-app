
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/account_model.dart';
import '../model/transaction_model.dart';

class AccountService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==========================================
  // OBTENER CUENTAS DEL USUARIO AUTENTICADO
  // ==========================================

  Future<List<AccountModel>> getAccountsByUser(
      String userId,
      ) async {
    final currentUser = _supabase.auth.currentUser;

    if (currentUser == null || currentUser.id != userId) {
      throw StateError('No hay una sesión válida');
    }

    final data = await _supabase
        .from('accounts')
        .select(
      'id, user_id, account_number, '
          'account_type, balance, currency',
    )
        .eq('user_id', userId)
        .order('created_at', ascending: true);

    return data.map((row) {
      return AccountModel(
        id: row['id'] as String,
        userId: row['user_id'] as String,
        accountNumber: row['account_number'] as String,
        accountType: row['account_type'] as String,
        balance: (row['balance'] as num).toDouble(),
        currency: row['currency'] as String,
      );
    }).toList();
  }

  // ==========================================
  // OBTENER MOVIMIENTOS DE UNA CUENTA
  // ==========================================

  Future<List<TransactionModel>> getTransactionsByAccount(
      String accountId,
      ) async {
    final currentUser = _supabase.auth.currentUser;

    if (currentUser == null) {
      throw StateError('Debes iniciar sesión');
    }

    final data = await _supabase
        .from('transactions')
        .select(
      'id, account_id, description, amount, '
          'date, category, type',
    )
        .eq('account_id', accountId)
        .eq('user_id', currentUser.id)
        .order('date', ascending: false);

    return data.map((row) {
      return TransactionModel(
        id: row['id'] as String,
        accountId: row['account_id'] as String,
        description: row['description'] as String,
        amount: (row['amount'] as num).toDouble(),
        date: DateTime.parse(row['date'] as String),
        category: row['category'] as String,
        type: row['type'] as String,
      );
    }).toList();
  }
}
