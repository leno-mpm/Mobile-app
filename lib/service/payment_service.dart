
import 'package:supabase_flutter/supabase_flutter.dart';

// Error de negocio devuelto por la Edge Function `make-payment`.
class PaymentException implements Exception {
  final String message;
  final String? code;

  PaymentException(this.message, {this.code});
}

class PaymentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==========================================
  // PAGAR UN SERVICIO DESDE UNA CUENTA
  // ==========================================

  Future<double> payService({
    required String accountId,
    required String serviceName,
    required double amount,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'make-payment',
        body: {
          'accountId': accountId,
          'serviceName': serviceName,
          'amount': amount,
        },
      );

      final data = response.data;

      if (response.status != 200 || data is! Map) {
        throw PaymentException('No se pudo procesar el pago');
      }

      return (data['newBalance'] as num).toDouble();
    } on FunctionException catch (error) {
      final details = error.details;

      final message = details is Map && details['error'] is String
          ? details['error'] as String
          : null;

      final code = details is Map && details['code'] is String
          ? details['code'] as String
          : null;

      throw PaymentException(
        message ?? 'No se pudo procesar el pago',
        code: code,
      );
    }
  }
}
