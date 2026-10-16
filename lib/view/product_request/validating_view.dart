
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../model/product_request_flow_data.dart';
import '../../model/product_request_result.dart';
import '../../service/product_request_service.dart';
import 'account_picker_view.dart';
import 'policy_details_view.dart';
import 'product_success_view.dart';

// Simula la validación con buró crediticio (siempre aprueba) mientras,
// en paralelo, se resuelve la solicitud real contra Supabase.
class ValidatingView extends StatefulWidget {
  final ProductRequestFlowData flowData;

  const ValidatingView({super.key, required this.flowData});

  @override
  State<ValidatingView> createState() => _ValidatingViewState();
}

enum _Outcome {
  success,
  needsAccountPicker,
  needsPolicyDetails,
  blockedNoAccount,
  blockedZeroBalance,
  error,
}

class _ValidatingViewState extends State<ValidatingView> {
  final ProductRequestService _service = ProductRequestService();

  String? _errorMessage;
  ProductRequestResult? _pendingResult;
  double? _pendingSourceAccountBalance;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final results = await Future.wait([
      Future<void>.delayed(const Duration(milliseconds: 1600)),
      _resolve(),
    ]);

    if (!mounted) return;

    final outcome = results[1] as _Outcome;

    switch (outcome) {
      case _Outcome.success:
        _goToSuccess(_pendingResult!);
        break;
      case _Outcome.needsAccountPicker:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AccountPickerView(flowData: widget.flowData),
          ),
        );
        break;
      case _Outcome.needsPolicyDetails:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PolicyDetailsView(
              flowData: widget.flowData,
              sourceAccountBalance: _pendingSourceAccountBalance!,
            ),
          ),
        );
        break;
      case _Outcome.blockedNoAccount:
        _redirectWithMessage(
          'Primero debes tener una cuenta de ahorros o corriente '
          'para solicitar una póliza.',
        );
        break;
      case _Outcome.blockedZeroBalance:
        _redirectWithMessage(
          'Tu cuenta no tiene al menos '
          '\$${AppConstants.minPolicyAmount.toStringAsFixed(0)} '
          'disponibles para solicitar una póliza.',
        );
        break;
      case _Outcome.error:
        setState(() {});
        break;
    }
  }

  // Se captura el ScaffoldMessenger ANTES de navegar: una vez que esta
  // pantalla se quita del árbol, su propio `context` ya no sirve para
  // buscar ancestros.
  void _redirectWithMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.requestProduct,
      (route) => false,
    );

    messenger.showSnackBar(
      SnackBar(backgroundColor: AppColors.error, content: Text(message)),
    );
  }

  Future<_Outcome> _resolve() async {
    try {
      if (widget.flowData.productType != AppConstants.productTypePoliza) {
        final result = await _service.requestProduct(
          identification: widget.flowData.identification,
          productType: widget.flowData.productType,
        );

        _pendingResult = result;
        return _Outcome.success;
      }

      final check = await _service.checkIdentification(
        widget.flowData.identification,
      );

      if (check.accounts.isEmpty) {
        return _Outcome.blockedNoAccount;
      }

      widget.flowData.accounts = check.accounts;

      if (check.accounts.length == 1) {
        final account = check.accounts.first;

        if (account.balance < AppConstants.minPolicyAmount) {
          return _Outcome.blockedZeroBalance;
        }

        widget.flowData.sourceAccountId = account.id;
        _pendingSourceAccountBalance = account.balance;
        return _Outcome.needsPolicyDetails;
      }

      return _Outcome.needsAccountPicker;
    } on ProductRequestException catch (error) {
      _errorMessage = error.message;
      return _Outcome.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado. Inténtalo nuevamente';
      return _Outcome.error;
    }
  }

  void _goToSuccess(ProductRequestResult result) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ProductSuccessView(
          result: result,
          identification: widget.flowData.identification,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_errorMessage == null) ...[
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF42B883),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Validando con buró crediticio...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Esto puede tomar unos segundos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ] else ...[
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 48,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Volver',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
