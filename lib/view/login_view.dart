
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

  bool _welcomeBackHandled = false;

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  // ==========================================
  // BIENVENIDA AL VOLVER DESDE CREAR USUARIO
  // ==========================================

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_welcomeBackHandled) return;
    _welcomeBackHandled = true;

    final username = ModalRoute.of(context)?.settings.arguments;

    if (username is! String) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _viewModel.userController.text = username;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.secondary,
          content: Text(
            '¡Registro completado! Ahora inicia sesión con $username.',
          ),
        ),
      );
    });
  }

  // ==========================================
  // LOGIN CON SUPABASE
  // ==========================================

  Future<void> _onLoginPressed() async {
    if (_viewModel.isLoading) return;

    FocusScope.of(context).unfocus();

    final success = await _viewModel.login();

    if (!mounted) return;

    if (!success) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.dashboard,
          (route) => false,
    );
  }

  // ==========================================
  // CREAR USUARIO Y CONTRASEÑA / SOLICITAR PRODUCTO
  // ==========================================

  void _onCreateUserPressed() {
    if (_viewModel.isLoading) return;

    Navigator.pushNamed(context, AppRoutes.createUser);
  }

  void _onRequestProductPressed() {
    if (_viewModel.isLoading) return;

    Navigator.pushNamed(context, AppRoutes.requestProduct);
  }

  // ==========================================
  // DECORACIÓN DE LOS CAMPOS
  // ==========================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.textSecondary.withValues(
          alpha: 0.6,
        ),
      ),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(
        prefixIcon,
        color: AppColors.textSecondary,
      ),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade400,
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.accent,
          width: 2,
        ),
      ),
    );
  }

  // ==========================================
  // INTERFAZ
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 36,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // ==========================================
                  // LOGO
                  // ==========================================

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

                  const SizedBox(height: 20),

                  const Text(
                    'Bienvenido. Para comenzar, inicia sesión con tu '
                    'usuario y contraseña.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==========================================
                  // NOMBRE DE USUARIO
                  // ==========================================

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
                    enabled: !_viewModel.isLoading,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) {
                      _viewModel.clearError();
                    },
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.text,
                    ),
                    decoration: _inputDecoration(
                      hint: 'Ej: maria.gonzalez',
                      prefixIcon: Icons.person_outline,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==========================================
                  // CONTRASEÑA
                  // ==========================================

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
                    enabled: !_viewModel.isLoading,
                    obscureText: _viewModel.obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (!_viewModel.isLoading) {
                        _onLoginPressed();
                      }
                    },
                    onChanged: (_) {
                      _viewModel.clearError();
                    },
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.text,
                    ),
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
                        onPressed: _viewModel.isLoading
                            ? null
                            : _viewModel.togglePasswordVisibility,
                      ),
                    ),
                  ),

                  // ==========================================
                  // MENSAJES DE ERROR
                  // ==========================================

                  if (_viewModel.errorMessage != null) ...[
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.error,
                        ),
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

                  // ==========================================
                  // BOTÓN INGRESAR
                  // ==========================================

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor:
                        AppColors.primary.withValues(
                          alpha: 0.65,
                        ),
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _viewModel.isLoading
                          ? null
                          : _onLoginPressed,
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
                        'Ingresar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ==========================================
                  // INGRESO CON HUELLA
                  // ==========================================

                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        disabledForegroundColor: Colors.grey,
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: null,
                      icon: const Icon(
                        Icons.lock_outline,
                        size: 24,
                      ),
                      label: const Text(
                        'Ingreso con huella desactivado',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==========================================
                  // CREAR USUARIO / SOLICITAR PRODUCTO
                  // ==========================================

                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        disabledForegroundColor: Colors.grey,
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _viewModel.isLoading
                          ? null
                          : _onCreateUserPressed,
                      child: const Text(
                        'Crear usuario y contraseña',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        disabledForegroundColor: Colors.grey,
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _viewModel.isLoading
                          ? null
                          : _onRequestProductPressed,
                      child: const Text(
                        'Solicitar producto',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
}
