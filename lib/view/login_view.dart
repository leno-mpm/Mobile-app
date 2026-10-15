import 'package:flutter/material.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../viewModel/login_view_model.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginViewModel _viewModel = LoginViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  // =====================================================
  // LOGIN CON USUARIO Y CONTRASEÑA
  // =====================================================

  void _onLoginPressed() {
    final success = _viewModel.login();

    if (success) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.dashboard,
        (route) => false,
      );
    }
  }

  // =====================================================
  // LOGIN CON HUELLA SIMULADA
  // =====================================================

  void _onFingerprintPressed() {
    if (!_viewModel.canUseFingerprint) {
      return;
    }

    final success = _viewModel.loginWithFingerprint();

    if (success) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.dashboard,
        (route) => false,
      );
    }
  }

  // =====================================================
  // NAVEGAR AL REGISTRO Y RECIBIR EL NUEVO USUARIO
  // =====================================================

  Future<void> _onRegisterPressed() async {
    debugPrint('SE PRESIONÓ CREAR CUENTA');

    final result = await Navigator.pushNamed(
      context,
      AppRoutes.register,
    );

    final username = result as String?;

    if (!mounted) return;

    if (username != null) {
      _viewModel.userController.text = username;
      _viewModel.passwordController.clear();
      _viewModel.clearError();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.secondary,
          content: Text(
            '¡Cuenta creada! Inicia sesión con $username',
          ),
        ),
      );
    }
  }

  // =====================================================
  // DECORACIÓN DE LOS CAMPOS
  // =====================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.textSecondary.withValues(alpha: 0.6),
      ),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.accent, width: 2),
      ),
    );
  }

  // =====================================================
  // INTERFAZ
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        final fingerprintEnabled = _viewModel.canUseFingerprint;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // =====================================================
                  // LOGO
                  // =====================================================
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.spa_rounded,
                        color: Color(0xFF42B883),
                        size: 48,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Mint',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Banca móvil',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondary,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // =====================================================
                  // NOMBRE DE USUARIO
                  // =====================================================
                  const Text(
                    'Nombre de usuario',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: _viewModel.userController,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) {
                      _viewModel.clearError();
                    },
                    style: const TextStyle(fontSize: 15, color: AppColors.text),
                    decoration: _inputDecoration(
                      hint: 'Ej: maria.gonzalez',
                      prefixIcon: Icons.person_outline,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =====================================================
                  // CONTRASEÑA
                  // =====================================================
                  const Text(
                    'Contraseña',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: _viewModel.passwordController,
                    obscureText: _viewModel.obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _onLoginPressed(),
                    onChanged: (_) {
                      _viewModel.clearError();
                    },
                    style: const TextStyle(fontSize: 15, color: AppColors.text),
                    decoration: _inputDecoration(
                      hint: 'Ingresa tu contraseña',
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _viewModel.obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.secondary,
                        ),
                        onPressed: _viewModel.togglePasswordVisibility,
                      ),
                    ),
                  ),

                  // =====================================================
                  // MENSAJES DE ERROR
                  // =====================================================
                  if (_viewModel.errorMessage != null) ...[
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              _viewModel.errorMessage!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // =====================================================
                  // BOTÓN INGRESAR
                  // =====================================================
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _onLoginPressed,
                      child: const Text(
                        'Ingresar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // =====================================================
                  // BOTÓN INGRESAR CON HUELLA SIMULADA
                  // =====================================================
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        disabledForegroundColor: Colors.grey,
                        side: BorderSide(
                          color: fingerprintEnabled
                              ? AppColors.primary
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),

                      // Desactivado cuando el usuario no tiene
                      // habilitada la huella simulada.
                      onPressed: fingerprintEnabled
                          ? _onFingerprintPressed
                          : null,

                      icon: Icon(
                        fingerprintEnabled
                            ? Icons.fingerprint
                            : Icons.lock_outline,
                        size: 24,
                      ),

                      label: Text(
                        fingerprintEnabled
                            ? 'Ingresar con huella'
                            : 'Ingreso con huella desactivado',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // =====================================================
                  // REGISTRO DE NUEVOS USUARIOS
                  // =====================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿No tienes cuenta? ',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 15,
                        ),
                      ),

                      GestureDetector(
                        onTap: _onRegisterPressed,
                        child: const Text(
                          'Crea tu cuenta',
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

                  // =====================================================
                  // INFORMACIÓN DEL USUARIO DE PRUEBA
                  // =====================================================
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Text(
                      'Usuario de prueba:\n'
                      'Usuario: maria.gonzalez\n'
                      'Contraseña: Mint1234\n\n'
                      'El ingreso con huella es simulado.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
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
