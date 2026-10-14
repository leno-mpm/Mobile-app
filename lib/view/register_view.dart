import 'package:flutter/material.dart';
import '../viewModel/register_view_model.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final RegisterViewModel _viewModel = RegisterViewModel();

  static const Color primaryColor = Color(0xFF173B6C);
  static const Color secondaryColor = Color(0xFF1E7F64);
  static const Color accentColor = Color(0xFF4C8DF6);
  static const Color backgroundColor = Color(0xFFF4F6FA);
  static const Color textColor = Color(0xFF0F1B2D);
  static const Color textSecondaryColor = Color(0xFF5A6577);
  static const Color errorColor = Color(0xFFC0392B);

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _onContinuePressed() {
    _viewModel.registerNewUser();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: secondaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: const Text(
          '¡Cuenta creada! Inicia sesión con tu cédula y clave Mint1234',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
    // Vuelve a la Pantalla Login como indica el Flujo 1
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Crea tu cuenta',
              style: TextStyle(
                color: textColor,
                fontSize: 22,
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
                    'Llena tus datos para registrarte en Mint.',
                    style: TextStyle(fontSize: 15, color: textSecondaryColor),
                  ),
                  const SizedBox(height: 24),

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

                  _buildField(
                    label: 'Cédula',
                    hint: '10 dígitos (Ej: 0123456789)',
                    icon: Icons.credit_card_outlined,
                    controller: _viewModel.identificationController,
                    keyboardType: TextInputType.number,
                    touched: _viewModel.identificationTouched,
                    errorText: _viewModel.identificationError,
                    onChanged: _viewModel.onIdentificationChanged,
                  ),
                  const SizedBox(height: 18),

                  _buildField(
                    label: 'Correo',
                    hint: 'maria@gmail.com',
                    icon: Icons.email_outlined,
                    controller: _viewModel.emailController,
                    keyboardType: TextInputType.emailAddress,
                    touched: _viewModel.emailTouched,
                    errorText: _viewModel.emailError,
                    onChanged: _viewModel.onEmailChanged,
                  ),
                  const SizedBox(height: 18),

                  _buildField(
                    label: 'Celular',
                    hint: 'Ej: 0991234567',
                    icon: Icons.phone_android_outlined,
                    controller: _viewModel.phoneController,
                    keyboardType: TextInputType.phone,
                    touched: _viewModel.phoneTouched,
                    errorText: _viewModel.phoneError,
                    onChanged: _viewModel.onPhoneChanged,
                  ),
                  const SizedBox(height: 32),

                  // Botón Continuar (Se habilita solo cuando los 4 campos son válidos)
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        disabledBackgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        disabledForegroundColor: textSecondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed:
                          _viewModel.isFormValid ? _onContinuePressed : null,
                      child: const Text(
                        'Continuar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿Deseas volver? ',
                        style: TextStyle(
                          color: textSecondaryColor,
                          fontSize: 15,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Inicia sesión',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required bool touched,
    required String? errorText,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final bool isValid = touched && errorText == null;
    final bool hasError = touched && errorText != null;

    Color borderColor = Colors.grey.shade400;
    if (isValid) borderColor = secondaryColor;
    if (hasError) borderColor = errorColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 15, color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: textSecondaryColor.withOpacity(0.6)),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(icon, color: textSecondaryColor),
            suffixIcon: isValid
                ? const Icon(Icons.check_circle, color: secondaryColor)
                : (hasError
                    ? const Icon(Icons.error_outline, color: errorColor)
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
                    ? errorColor
                    : (isValid ? secondaryColor : accentColor),
                width: 2.0,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            errorText,
            style: const TextStyle(
              color: errorColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}