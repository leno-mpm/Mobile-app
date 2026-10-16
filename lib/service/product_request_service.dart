
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/identification_check_result.dart';
import '../model/product_request_result.dart';

// Error de negocio devuelto por las Edge Functions de solicitud de producto.
class ProductRequestException implements Exception {
  final String message;
  final String? code;

  ProductRequestException(this.message, {this.code});
}

class ProductRequestService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==========================================
  // VERIFICAR CÉDULA (usuario y productos existentes)
  // ==========================================

  Future<IdentificationCheckResult> checkIdentification(
    String identification,
  ) async {
    try {
      final response = await _supabase.functions.invoke(
        'check-identification',
        body: {'identification': identification},
      );

      final data = response.data;

      if (response.status != 200 || data is! Map) {
        throw ProductRequestException(
          'No se pudo verificar la cédula',
        );
      }

      return IdentificationCheckResult.fromJson(
        Map<String, dynamic>.from(data),
      );
    } on FunctionException catch (error) {
      throw ProductRequestException(
        _extractMessage(error) ?? 'No se pudo verificar la cédula',
      );
    }
  }

  // ==========================================
  // SOLICITAR PRODUCTO (cuenta o póliza)
  // ==========================================

  Future<ProductRequestResult> requestProduct({
    required String identification,
    required String productType,
    String? sourceAccountId,
    double? amount,
    int? termDays,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'request-product',
        body: {
          'identification': identification,
          'productType': productType,
          'sourceAccountId': ?sourceAccountId,
          'amount': ?amount,
          'termDays': ?termDays,
        },
      );

      final data = response.data;

      if (response.status != 200 || data is! Map) {
        throw ProductRequestException(
          (data is Map ? data['error'] as String? : null) ??
              'No se pudo completar la solicitud del producto',
          code: data is Map ? data['code'] as String? : null,
        );
      }

      return ProductRequestResult.fromJson(
        Map<String, dynamic>.from(data),
      );
    } on FunctionException catch (error) {
      final message = _extractMessage(error);
      final code = _extractCode(error);

      throw ProductRequestException(
        message ?? 'No se pudo completar la solicitud del producto',
        code: code,
      );
    }
  }

  // ==========================================
  // EXTRAER MENSAJE/CÓDIGO DE ERROR DE LA EDGE FUNCTION
  // ==========================================

  String? _extractMessage(FunctionException error) {
    final details = error.details;

    if (details is Map && details['error'] is String) {
      return details['error'] as String;
    }

    return null;
  }

  String? _extractCode(FunctionException error) {
    final details = error.details;

    if (details is Map && details['code'] is String) {
      return details['code'] as String;
    }

    return null;
  }
}
