
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../model/registration_flow_data.dart';
import '../../viewModel/create_user/identity_verification_view_model.dart';
import '../../widget/labeled_text_field.dart';
import '../product_request/select_product_view.dart';
import 'personal_data_view.dart';

class IdentityVerificationView extends StatefulWidget {
  const IdentityVerificationView({super.key});

  @override
  State<IdentityVerificationView> createState() =>
      _IdentityVerificationViewState();
}

class _IdentityVerificationViewState extends State<IdentityVerificationView> {
  final IdentityVerificationViewModel _viewModel =
      IdentityVerificationViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _onContinuePressed() async {
    FocusScope.of(context).unfocus();

    final success = await _viewModel.verifyIdentity();

    if (!mounted) return;

    if (!success) return;

    final identification = _viewModel.identificationController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonalDataView(
          flowData: RegistrationFlowData(identification: identification),
        ),
      ),
    );
  }

  void _goToRequestProduct() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SelectProductView(
          prefilledIdentification:
              _viewModel.identificationController.text.trim(),
        ),
      ),
    );
  }

  void _goToLogin() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.text),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Verificar identidad',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Ingresa tu número de cédula para comenzar a crear '
                    'tu usuario y contraseña.',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  LabeledTextField(
                    label: 'Cédula',
                    hint: '10 dígitos',
                    icon: Icons.credit_card_outlined,
                    controller: _viewModel.identificationController,
                    keyboardType: TextInputType.number,
                    enabled: !_viewModel.isLoading,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    touched: _viewModel.identificationTouched,
                    errorText: _viewModel.identificationError,
                    onChanged: _viewModel.onIdentificationChanged,
                  ),

                  if (_viewModel.blockReason != null) ...[
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
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
                                  _viewModel.blockReason ==
                                          IdentityBlockReason.noProduct
                                      ? 'Primero debes solicitar un '
                                          'producto (cuenta o póliza) con '
                                          'esta cédula.'
                                      : 'Ya tienes una cuenta creada con '
                                          'esta cédula. Inicia sesión.',
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed:
                                  _viewModel.blockReason ==
                                          IdentityBlockReason.noProduct
                                      ? _goToRequestProduct
                                      : _goToLogin,
                              child: Text(
                                _viewModel.blockReason ==
                                        IdentityBlockReason.noProduct
                                    ? 'Solicitar producto'
                                    : 'Ir a iniciar sesión',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          if (_viewModel.blockReason ==
                              IdentityBlockReason.noProduct) ...[
                            const SizedBox(height: 8),

                            SizedBox(
                              height: 44,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(
                                    color: AppColors.error,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _goToLogin,
                                child: const Text(
                                  'Finalizar',
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
                  ],

                  if (_viewModel.errorMessage != null) ...[
                    const SizedBox(height: 16),

                    Text(
                      _viewModel.errorMessage!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

                  // Mientras haya un bloqueo activo (sin producto / ya
                  // tiene usuario), solo se muestran los botones del
                  // bloqueo. "Continuar" vuelve a aparecer si el
                  // usuario edita la cédula (eso limpia blockReason).
                  if (_viewModel.blockReason == null) ...[
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
                        onPressed:
                            _viewModel.isLoading ? null : _onContinuePressed,
                        child: _viewModel.isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Continuar',
                                style: TextStyle(
                                  fontSize: 15,
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
        );
      },
    );
  }
}
