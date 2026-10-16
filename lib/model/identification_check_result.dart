// Cuenta existente asociada a una cédula, devuelta por `check-identification`.
class IdentificationAccountSummary {
  final String id;
  final String accountNumber;
  final String accountType;
  final double balance;

  const IdentificationAccountSummary({
    required this.id,
    required this.accountNumber,
    required this.accountType,
    required this.balance,
  });

  factory IdentificationAccountSummary.fromJson(Map<String, dynamic> json) {
    return IdentificationAccountSummary(
      id: json['id'] as String,
      accountNumber: json['accountNumber'] as String,
      accountType: json['accountType'] as String,
      balance: (json['balance'] as num).toDouble(),
    );
  }
}

// Resultado de la Edge Function `check-identification`.
class IdentificationCheckResult {
  final bool hasProfile;
  final bool hasAnyProduct;
  final List<IdentificationAccountSummary> accounts;
  final int policiesCount;

  const IdentificationCheckResult({
    required this.hasProfile,
    required this.hasAnyProduct,
    required this.accounts,
    required this.policiesCount,
  });

  factory IdentificationCheckResult.fromJson(Map<String, dynamic> json) {
    final rawAccounts = json['accounts'] as List<dynamic>? ?? [];

    return IdentificationCheckResult(
      hasProfile: json['hasProfile'] as bool,
      hasAnyProduct: json['hasAnyProduct'] as bool,
      accounts: rawAccounts
          .map(
            (row) => IdentificationAccountSummary.fromJson(
              row as Map<String, dynamic>,
            ),
          )
          .toList(),
      policiesCount: json['policiesCount'] as int,
    );
  }
}
