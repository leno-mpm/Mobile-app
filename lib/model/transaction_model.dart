
class TransactionModel {
  final String id;
  final String accountId;
  final String description;
  final double amount;
  final DateTime date;
  final String category;
  final String type;

  const TransactionModel({
    required this.id,
    required this.accountId,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
  });
}
