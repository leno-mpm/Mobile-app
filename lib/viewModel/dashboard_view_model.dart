
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/account_model.dart';
import '../model/transaction_model.dart';
import '../model/user_model.dart';
import '../service/account_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final AccountService _accountService;
  final SupabaseClient _supabase = Supabase.instance.client;

  DashboardViewModel(this._accountService);

  List<AccountModel> _accounts = [];
  List<TransactionModel> _transactions = [];
  UserModel? _user;
  String? _avatarUrl;

  bool _isLoading = false;
  String? _errorMessage;

  List<AccountModel> get accounts =>
      List.unmodifiable(_accounts);

  List<TransactionModel> get transactions =>
      List.unmodifiable(_transactions);

  UserModel? get user => _user;

  String? get avatarUrl => _avatarUrl;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // ==========================================
  // CALCULAR SALDO TOTAL
  // ==========================================

  double get totalBalance {
    return _accounts.fold<double>(
      0.0,
          (total, account) => total + account.balance,
    );
  }

  // ==========================================
  // CARGAR DASHBOARD DESDE SUPABASE
  // ==========================================

  Future<void> loadDashboard(String userId) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authUser = _supabase.auth.currentUser;

      if (authUser == null || authUser.id != userId) {
        throw StateError('No hay una sesión válida');
      }

      // Obtener el perfil real del usuario.
      final profile = await _supabase
          .from('profiles')
          .select(
        'id, username, first_name, last_name, '
            'email, phone, identification, avatar_path',
      )
          .eq('id', userId)
          .maybeSingle();

      if (profile == null) {
        throw StateError('No se encontró el perfil');
      }

      _user = UserModel(
        id: profile['id'] as String,
        username: profile['username'] as String,
        firstName: profile['first_name'] as String,
        lastName: profile['last_name'] as String,
        email: profile['email'] as String,
        phone: profile['phone'] as String,
        identification: profile['identification'] as String,
      );

      await _loadAvatar(profile['avatar_path'] as String?);

      // Obtener las cuentas bancarias reales.
      _accounts =
      await _accountService.getAccountsByUser(userId);

      // Obtener las transacciones de cada cuenta.
      final List<TransactionModel> allTransactions = [];

      for (final account in _accounts) {
        final accountTransactions = await _accountService
            .getTransactionsByAccount(account.id);

        allTransactions.addAll(accountTransactions);
      }

      // Ordenar los movimientos del más reciente al antiguo.
      allTransactions.sort(
            (a, b) => b.date.compareTo(a.date),
      );

      _transactions = allTransactions;
    } catch (e) {
      _user = null;
      _accounts = [];
      _transactions = [];
      _avatarUrl = null;

      _errorMessage = 'No se pudo cargar el Dashboard';

      debugPrint('Error al cargar Dashboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAvatar(String? path) async {
    _avatarUrl = null;

    if (path == null || path.isEmpty) {
      return;
    }

    try {
      _avatarUrl = await _supabase.storage
          .from('profile-photos')
          .createSignedUrl(path, 3600);
    } catch (e) {
      debugPrint('Error al recuperar la foto: $e');
    }
  }
}
