
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/policy_model.dart';

class PolicyService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<PolicyModel>> getPoliciesByUser(String userId) async {
    final currentUser = _supabase.auth.currentUser;

    if (currentUser == null || currentUser.id != userId) {
      throw StateError('No hay una sesión válida');
    }

    final data = await _supabase
        .from('policies')
        .select(
      'id, user_id, policy_number, amount, annual_interest_rate, '
          'term_days, start_date, end_date, currency, status',
    )
        .eq('user_id', userId)
        .order('start_date', ascending: false);

    return data.map((row) {
      return PolicyModel(
        id: row['id'] as String,
        userId: row['user_id'] as String,
        policyNumber: row['policy_number'] as String,
        amount: (row['amount'] as num).toDouble(),
        annualInterestRate:
        (row['annual_interest_rate'] as num).toDouble(),
        termDays: row['term_days'] as int,
        startDate: DateTime.parse(row['start_date'] as String),
        endDate: DateTime.parse(row['end_date'] as String),
        currency: row['currency'] as String,
        status: row['status'] as String,
      );
    }).toList();
  }
}
