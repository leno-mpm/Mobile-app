// Resultado de la Edge Function `request-product`.
class ProductRequestResult {
  final String productNumber;
  final String productType;
  final String? accountId;
  final String? sourceAccountId;
  final bool hasProfile;

  const ProductRequestResult({
    required this.productNumber,
    required this.productType,
    required this.hasProfile,
    this.accountId,
    this.sourceAccountId,
  });

  factory ProductRequestResult.fromJson(Map<String, dynamic> json) {
    return ProductRequestResult(
      productNumber: json['productNumber'] as String,
      productType: json['productType'] as String,
      accountId: json['accountId'] as String?,
      sourceAccountId: json['sourceAccountId'] as String?,
      hasProfile: json['hasProfile'] as bool,
    );
  }
}
