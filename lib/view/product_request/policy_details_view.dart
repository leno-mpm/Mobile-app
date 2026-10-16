
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../model/product_request_flow_data.dart';
import '../../service/product_request_service.dart';
import 'product_success_view.dart';

// Tasa fija mostrada al usuario (no editable). Debe coincidir con el
// `annual_interest_rate` que la Edge Function `request-product` usa
// al crear la póliza.
const double _annualInterestRatePercent = 5;

const int _minTermMonths = 1;
const int _maxTermMonths = 36;

class PolicyDetailsView extends StatefulWidget {
  final ProductRequestFlowData flowData;
  final double sourceAccountBalance;

  const PolicyDetailsView({
    super.key,
    required this.flowData,
    required this.sourceAccountBalance,
  });

  @override
  State<PolicyDetailsView> createState() => _PolicyDetailsViewState();
}

class _PolicyDetailsViewState extends State<PolicyDetailsView> {
  final ProductRequestService _service = ProductRequestService();
  final _amountController = TextEditingController();

  double _termMonths = _minTermMonths.toDouble();
  bool _amountTouched = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double? get _amount => double.tryParse(_amountController.text.trim());

  String? get _amountError {
    if (_amountController.text.trim().isEmpty) {
      return 'Ingresa cuánto quieres invertir';
    }

    final value = _amount;

    if (value == null || value <= 0) {
      return 'Ingresa un monto válido';
    }

    if (value < AppConstants.minPolicyAmount) {
      return 'El monto mínimo para una póliza es '
          '\$${AppConstants.minPolicyAmount.toStringAsFixed(0)}';
    }

    if (value >= widget.sourceAccountBalance) {
      return 'El monto debe ser menor a tu saldo disponible '
          '(\$${widget.sourceAccountBalance.toStringAsFixed(2)})';
    }

    return null;
  }

  int get _termDays => (_termMonths * 30).round();

  double get _estimatedInterest {
    final amount = _amount;
    if (amount == null || amount <= 0) return 0;

    return amount * (_annualInterestRatePercent / 100) * (_termDays / 360);
  }

  String get _termLabel {
    final months = _termMonths.round();

    if (months < 12) {
      return months == 1 ? '1 mes' : '$months meses';
    }

    final years = months ~/ 12;
    final remainingMonths = months % 12;

    final yearsLabel = years == 1 ? '1 año' : '$years años';

    if (remainingMonths == 0) {
      return yearsLabel;
    }

    final monthsLabel =
        remainingMonths == 1 ? '1 mes' : '$remainingMonths meses';

    return '$yearsLabel y $monthsLabel';
  }

  Future<void> _onConfirmPressed() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();
    setState(() => _amountTouched = true);

    if (_amountError != null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _service.requestProduct(
        identification: widget.flowData.identification,
        productType: AppConstants.productTypePoliza,
        sourceAccountId: widget.flowData.sourceAccountId,
        amount: _amount,
        termDays: _termDays,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ProductSuccessView(
            result: result,
            identification: widget.flowData.identification,
          ),
        ),
      );
    } on ProductRequestException catch (error) {
      setState(() => _errorMessage = error.message);
    } catch (_) {
      setState(
        () => _errorMessage =
            'Ocurrió un error inesperado. Inténtalo nuevamente',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _amountTouched && _amountError == null;
    final hasError = _amountTouched && _amountError != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Detalles de tu póliza',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '¿Cuánto quieres invertir en tu póliza?',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Saldo disponible en tu cuenta: '
                '\$${widget.sourceAccountBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Monto a invertir',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _amountController,
                enabled: !_isLoading,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                onChanged: (_) => setState(() => _amountTouched = true),
                style: const TextStyle(fontSize: 15, color: AppColors.text),
                decoration: InputDecoration(
                  hintText: 'Ej: 200',
                  prefixText: r'$ ',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: hasError
                          ? AppColors.error
                          : (isValid
                              ? AppColors.secondary
                              : Colors.grey.shade400),
                      width: (isValid || hasError) ? 1.8 : 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: hasError ? AppColors.error : AppColors.accent,
                      width: 2,
                    ),
                  ),
                ),
              ),

              if (hasError) ...[
                const SizedBox(height: 6),
                Text(
                  _amountError!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              const Text(
                'Plazo de la póliza',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                _termLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              Slider(
                value: _termMonths,
                min: _minTermMonths.toDouble(),
                max: _maxTermMonths.toDouble(),
                divisions: _maxTermMonths - _minTermMonths,
                activeColor: AppColors.primary,
                label: _termLabel,
                onChanged: _isLoading
                    ? null
                    : (value) => setState(() => _termMonths = value),
              ),

              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '1 mes',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '3 años',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Ganarás un ${_annualInterestRatePercent.toStringAsFixed(0)}% '
                        'anual de interés. Con lo elegido, estimamos '
                        '\$${_estimatedInterest.toStringAsFixed(2)} al '
                        'finalizar el plazo.',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _onConfirmPressed,
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Confirmar póliza',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
