import 'package:flutter/cupertino.dart';
import 'package:mobile_app/model/account_model.dart';
import 'package:mobile_app/model/transaction_model.dart';
import 'package:mobile_app/service/account_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final AccountService _accountService;
  DashboardViewModel(this._accountService);

  List<AccountModel> _accounts= [];
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AccountModel> get accounts => List.unmodifiable(_accounts);
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  //Calcular el saldo total
  double get totalBalance {
    return _accounts.fold<double>(0.0, (total, account) => total + account.balance);
  }


  // Cargar la información del Dashboard
  Future<void> loadDashboard(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _accounts = await _accountService.getAccountsByUser(userId);
      final List<TransactionModel> allTransactions = [];

      for (final account in _accounts) {
        final accountTransactions = await _accountService.getTransactionsByAccount(account.id);
        allTransactions.addAll(accountTransactions);
      }

      allTransactions.sort((a, b) => b.date.compareTo(a.date));
      _transactions = allTransactions;

    } catch (e) {
      _accounts = [];
      _transactions = [];
      _errorMessage = 'No se pudo cargar el Dashboard';
      debugPrint('Error al cargar Dashboard: $e');

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}