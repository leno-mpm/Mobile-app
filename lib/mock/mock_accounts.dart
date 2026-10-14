
import '../model/account_model.dart';

class MockAccounts {
  static const List<AccountModel> accounts = [
    AccountModel(
      id: 'acc-001',
      userId: 'user-001',
      accountNumber: '**** 4582',
      accountType: 'Ahorros',
      balance: 3310.95,
      currency: 'USD',
    ),
    AccountModel(
      id: 'acc-002',
      userId: 'user-001',
      accountNumber: '**** 8921',
      accountType: 'Corriente',
      balance: 1250.75,
      currency: 'USD',
    ),
  ];
}
