
import 'package:flutter/material.dart';

import '../../service/product_request_service.dart';

enum IdentityBlockReason { noProduct, hasProfile }

class IdentityVerificationViewModel extends ChangeNotifier {
  final TextEditingController identificationController =
      TextEditingController();

  final ProductRequestService _productRequestService =
      ProductRequestService();

  bool identificationTouched = false;
  bool isLoading = false;

  IdentityBlockReason? blockReason;
  String? errorMessage;

  void onIdentificationChanged(String value) {
    identificationTouched = true;
    blockReason = null;
    errorMessage = null;
    notifyListeners();
  }

  String? get identificationError {
    final value = identificationController.text.trim();

    if (value.isEmpty) {
      return 'Ingresa tu número de cédula';
    }

    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'La cédula debe tener 10 dígitos numéricos';
    }

    return null;
  }

  // ==========================================
  // VERIFICAR CÉDULA
  // ==========================================

  Future<bool> verifyIdentity() async {
    if (isLoading) {
      return false;
    }

    identificationTouched = true;

    if (identificationError != null) {
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    blockReason = null;
    notifyListeners();

    try {
      final identification = identificationController.text.trim();

      final result = await _productRequestService.checkIdentification(
        identification,
      );

      if (result.hasProfile) {
        blockReason = IdentityBlockReason.hasProfile;
        return false;
      }

      if (!result.hasAnyProduct) {
        blockReason = IdentityBlockReason.noProduct;
        return false;
      }

      return true;
    } on ProductRequestException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Ocurrió un error inesperado. Inténtalo nuevamente';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    identificationController.dispose();
    super.dispose();
  }
}
