import 'identification_check_result.dart';

// Datos que viajan entre las pantallas del flujo "Solicitar producto".
class ProductRequestFlowData {
  final String productType;

  String identification;
  List<IdentificationAccountSummary> accounts;
  String? sourceAccountId;

  ProductRequestFlowData({
    required this.productType,
    this.identification = '',
    this.accounts = const [],
    this.sourceAccountId,
  });
}
