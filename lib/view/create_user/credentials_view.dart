
import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../model/registration_flow_data.dart';
import '../../viewModel/create_user/credentials_view_model.dart';
import '../../widget/labeled_text_field.dart';
import '../../widget/password_requirement_row.dart';

class CredentialsView extends StatefulWidget {
  final RegistrationFlowData flowData;

  const CredentialsView({super.key, required this.flowData});

  @override
  State<CredentialsView> createState() => _CredentialsViewState();
}

class _CredentialsViewState extends State<CredentialsView> {
  late final CredentialsViewModel _viewModel = CredentialsViewModel(
    widget.flowData,
  );

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _onCreatePressed() async {
    if (_viewModel.isLoading) return;

    FocusScope.of(context).unfocus();

    final success = await _viewModel.createUser();

    if (!mounted) return;

    if (!success) return;

    // Vuelve al Login sin importar cuántos pasos se recorrieron antes
    // (puede venir directo de "Crear usuario" o desde "Solicitar
    // producto"), pasando el username como argumento de la ruta.
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
      arguments: _viewModel.username,
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
              onPressed: _viewModel.isLoading
                  ? null
                  : () => Navigator.pop(context),
            ),
            title: const Text(
              'Elige tu usuario y contraseña',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 20,
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
                  LabeledTextField(
                    label: 'Nombre de usuario',
                    hint: 'Ej: maria.gonzalez',
                    icon: Icons.person_outline,
                    controller: _viewModel.usernameController,
                    enabled: !_viewModel.isLoading,
                    touched: _viewModel.usernameTouched,
                    errorText: _viewModel.usernameError,
                    onChanged: _viewModel.onUsernameChanged,
                    helperText:
                        'De 4 a 20 caracteres, debe comenzar con una letra',
                  ),

                  const SizedBox(height: 18),

                  LabeledTextField(
                    label: 'Contraseña',
                    hint: 'Crea tu contraseña',
                    icon: Icons.lock_outline,
                    controller: _viewModel.passwordController,
                    enabled: !_viewModel.isLoading,
                    touched: _viewModel.passwordTouched,
                    errorText: _viewModel.passwordError,
                    onChanged: _viewModel.onPasswordChanged,
                    obscureText: _viewModel.obscurePassword,
                    showValidationIcon: false,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _viewModel.obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.secondary,
                      ),
                      onPressed: _viewModel.isLoading
                          ? null
                          : _viewModel.togglePasswordVisibility,
                    ),
                  ),

                  if (_viewModel.passwordTouched) ...[
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tu contraseña debe contener:',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          PasswordRequirementRow(
                            label: 'Al menos 8 caracteres',
                            fulfilled: _viewModel.hasMinimumLength,
                          ),

                          PasswordRequirementRow(
                            label: 'Una letra mayúscula',
                            fulfilled: _viewModel.hasUppercase,
                          ),

                          PasswordRequirementRow(
                            label: 'Una letra minúscula',
                            fulfilled: _viewModel.hasLowercase,
                          ),

                          PasswordRequirementRow(
                            label: 'Un número',
                            fulfilled: _viewModel.hasNumber,
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),

                  LabeledTextField(
                    label: 'Confirmar contraseña',
                    hint: 'Repite tu contraseña',
                    icon: Icons.lock_reset_outlined,
                    controller: _viewModel.confirmPasswordController,
                    enabled: !_viewModel.isLoading,
                    touched: _viewModel.confirmPasswordTouched,
                    errorText: _viewModel.confirmPasswordError,
                    onChanged: _viewModel.onConfirmPasswordChanged,
                    obscureText: _viewModel.obscureConfirmPassword,
                    showValidationIcon: false,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _viewModel.obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.secondary,
                      ),
                      onPressed: _viewModel.isLoading
                          ? null
                          : _viewModel.toggleConfirmPasswordVisibility,
                    ),
                  ),

                  if (_viewModel.registrationError != null) ...[
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
                              _viewModel.registrationError!,
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

                  const SizedBox(height: 32),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        disabledForegroundColor: AppColors.textSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _viewModel.isFormValid && !_viewModel.isLoading
                          ? _onCreatePressed
                          : null,
                      child: _viewModel.isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            )
                          : const Text(
                              'Crear cuenta',
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
      },
    );
  }
}
