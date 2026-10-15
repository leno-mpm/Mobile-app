
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import '../viewModel/register_view_model.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final RegisterViewModel _viewModel = RegisterViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  // ==========================================
  // REGISTRAR USUARIO EN SUPABASE
  // ==========================================

  Future<void> _onContinuePressed() async {
    if (_viewModel.isLoading) return;

    FocusScope.of(context).unfocus();

    final username =
    _viewModel.usernameController.text.trim().toLowerCase();

    final success = await _viewModel.registerNewUser();

    if (!mounted) return;

    if (!success) return;

    // Registro completado.
    // Regresamos al Login con el nombre de usuario.
    Navigator.pop(context, username);
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
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.text,
              ),
              onPressed: _viewModel.isLoading
                  ? null
                  : () => Navigator.pop(context),
            ),
            title: const Text(
              'Crea tu cuenta',
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
                    'Llena tus datos para registrarte en Mint.',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==========================================
                  // NOMBRES Y APELLIDOS
                  // ==========================================

                  _buildField(
                    label: 'Nombres y apellidos',
                    hint: 'Ej: María González',
                    icon: Icons.badge_outlined,
                    controller: _viewModel.fullNameController,
                    touched: _viewModel.fullNameTouched,
                    errorText: _viewModel.fullNameError,
                    onChanged: _viewModel.onFullNameChanged,
                  ),

                  const SizedBox(height: 18),

                  // ==========================================
                  // NOMBRE DE USUARIO
                  // ==========================================

                  _buildField(
                    label: 'Nombre de usuario',
                    hint: 'Ej: maria.gonzalez',
                    icon: Icons.person_outline,
                    controller: _viewModel.usernameController,
                    touched: _viewModel.usernameTouched,
                    errorText: _viewModel.usernameError,
                    onChanged: _viewModel.onUsernameChanged,
                    helperText:
                    'De 4 a 20 caracteres. Debe comenzar con una letra.',
                  ),

                  const SizedBox(height: 18),

                  // ==========================================
                  // CÉDULA
                  // ==========================================

                  _buildField(
                    label: 'Cédula',
                    hint: '10 dígitos',
                    icon: Icons.credit_card_outlined,
                    controller: _viewModel.identificationController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    touched: _viewModel.identificationTouched,
                    errorText: _viewModel.identificationError,
                    onChanged: _viewModel.onIdentificationChanged,
                  ),

                  const SizedBox(height: 18),

                  // ==========================================
                  // CORREO ELECTRÓNICO
                  // ==========================================

                  _buildField(
                    label: 'Correo',
                    hint: 'ejemplo@gmail.com',
                    icon: Icons.email_outlined,
                    controller: _viewModel.emailController,
                    keyboardType: TextInputType.emailAddress,
                    touched: _viewModel.emailTouched,
                    errorText: _viewModel.emailError,
                    onChanged: _viewModel.onEmailChanged,
                  ),

                  const SizedBox(height: 18),

                  // ==========================================
                  // CELULAR
                  // ==========================================

                  _buildField(
                    label: 'Celular',
                    hint: 'Ej: 0991234567',
                    icon: Icons.phone_android_outlined,
                    controller: _viewModel.phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    touched: _viewModel.phoneTouched,
                    errorText: _viewModel.phoneError,
                    onChanged: _viewModel.onPhoneChanged,
                  ),

                  const SizedBox(height: 24),

                  const Divider(),

                  const SizedBox(height: 16),

                  const Text(
                    'Seguridad de tu cuenta',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==========================================
                  // CONTRASEÑA
                  // ==========================================

                  _buildField(
                    label: 'Contraseña',
                    hint: 'Crea tu contraseña',
                    icon: Icons.lock_outline,
                    controller: _viewModel.passwordController,
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

                  // ==========================================
                  // REQUISITOS DE CONTRASEÑA
                  // ==========================================

                  if (_viewModel.passwordTouched) ...[
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
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

                          _passwordRequirement(
                            'Al menos 8 caracteres',
                            _viewModel.hasMinimumLength,
                          ),

                          _passwordRequirement(
                            'Una letra mayúscula',
                            _viewModel.hasUppercase,
                          ),

                          _passwordRequirement(
                            'Una letra minúscula',
                            _viewModel.hasLowercase,
                          ),

                          _passwordRequirement(
                            'Un número',
                            _viewModel.hasNumber,
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),

                  // ==========================================
                  // CONFIRMAR CONTRASEÑA
                  // ==========================================

                  _buildField(
                    label: 'Confirmar contraseña',
                    hint: 'Repite tu contraseña',
                    icon: Icons.lock_reset_outlined,
                    controller:
                    _viewModel.confirmPasswordController,
                    touched:
                    _viewModel.confirmPasswordTouched,
                    errorText:
                    _viewModel.confirmPasswordError,
                    onChanged:
                    _viewModel.onConfirmPasswordChanged,
                    obscureText:
                    _viewModel.obscureConfirmPassword,
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
                          : _viewModel
                          .toggleConfirmPasswordVisibility,
                    ),
                  ),

                  // ==========================================
                  // ERROR DE REGISTRO
                  // ==========================================

                  if (_viewModel.registrationError != null) ...[
                    const SizedBox(height: 18),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(
                          alpha: 0.08,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.error.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
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

                  // ==========================================
                  // BOTÓN CREAR CUENTA
                  // ==========================================

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor:
                        Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        disabledForegroundColor:
                        AppColors.textSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed:
                      _viewModel.isFormValid &&
                          !_viewModel.isLoading
                          ? _onContinuePressed
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

                  const SizedBox(height: 20),

                  // ==========================================
                  // REGRESAR AL LOGIN
                  // ==========================================

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿Ya tienes cuenta? ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),

                      GestureDetector(
                        onTap: _viewModel.isLoading
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text(
                          'Inicia sesión',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // INDICADOR DE REQUISITO DE CONTRASEÑA
  // ==========================================

  Widget _passwordRequirement(
      String label,
      bool fulfilled,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(
            fulfilled
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: fulfilled
                ? AppColors.secondary
                : AppColors.textSecondary,
            size: 18,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: fulfilled
                    ? AppColors.secondary
                    : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: fulfilled
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CAMPO REUTILIZABLE
  // ==========================================

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required bool touched,
    required String? errorText,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool showValidationIcon = true,
    Widget? suffixIcon,
    String? helperText,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final isValid = touched && errorText == null;
    final hasError = touched && errorText != null;

    Color borderColor = Colors.grey.shade400;

    if (isValid) {
      borderColor = AppColors.secondary;
    }

    if (hasError) {
      borderColor = AppColors.error;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          autocorrect: false,
          enabled: !_viewModel.isLoading,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.text,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(
                alpha: 0.6,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(
              icon,
              color: AppColors.textSecondary,
            ),
            suffixIcon: suffixIcon ??
                (showValidationIcon
                    ? (isValid
                    ? const Icon(
                  Icons.check_circle,
                  color: AppColors.secondary,
                )
                    : (hasError
                    ? const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                )
                    : null))
                    : null),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: borderColor,
                width: (isValid || hasError) ? 1.8 : 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.error
                    : (isValid
                    ? AppColors.secondary
                    : AppColors.accent),
                width: 2,
              ),
            ),
          ),
        ),

        if (helperText != null) ...[
          const SizedBox(height: 6),

          Text(
            helperText,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],

        if (hasError) ...[
          const SizedBox(height: 6),

          Text(
            errorText,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}
