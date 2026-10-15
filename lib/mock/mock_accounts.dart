import '../model/account_model.dart';

class MockAccounts {
  static const List<AccountModel> accounts = [
    AccountModel(
      id: 'acc-001',
      userId: 'user-001',
      accountNumber: '1234564582',
      accountType: 'Ahorros',
      currency: 'USD',
      balance: 3310.95,
    ),
    AccountModel(
      id: 'acc-002',
      userId: 'user-001',
      accountNumber: '9876548921',
      accountType: 'Corriente',
      currency: 'USD',
      balance: 1250.75,
    ),
  ];
}
