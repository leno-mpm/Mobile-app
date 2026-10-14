
class PolicyModel {
  final String id;
  final String userId;
  final String policyNumber;
  final double amount;
  final double annualInterestRate;
  final int termDays;
  final DateTime startDate;
  final DateTime endDate;
  final String currency;
  final String status;

  const PolicyModel({
    required this.id,
    required this.userId,
    required this.policyNumber,
    required this.amount,
    required this.annualInterestRate,
    required this.termDays,
    required this.startDate,
    required this.endDate,
    required this.currency,
    required this.status,
  });

  // Interés simple estimado con año comercial de 360 días.
  // Es ilustrativo: el cálculo real depende del contrato bancario.
  double get estimatedInterest {
    return amount * (annualInterestRate / 100) * (termDays / 360);
  }

  double get estimatedMaturityAmount {
    return amount + estimatedInterest;
  }
}
