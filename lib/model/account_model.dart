class AccountModel {
  final String id;
  final String userId;
  final String accountNumber;
  final String accountType;
  final double balance;
  final String currency;

  const AccountModel({
    required this.id,
    required this.userId,
    required this.accountNumber,
    required this.accountType,
    required this.balance,
    required this.currency,
  });
}
