import 'package:flutter/material.dart';
import '../core/routes/app_routes.dart';
import '../viewModel/login_view_model.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginViewModel _viewModel = LoginViewModel();

  // Paleta de colores del documento Mint
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

  void _onLoginPressed() {
    if (_viewModel.login()) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    }
  }

  // Flujo 3: Modal de validación de huella simulada
  void _showFingerprintModal() {
    _viewModel.clearError();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Column(
            children: [
              Icon(Icons.fingerprint, size: 64, color: primaryColor),
              SizedBox(height: 12),
              Text(
                'Ingreso con huella',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: const Text(
            'Coloca tu huella (validación simulada).\n\nSelecciona qué escenario deseas probar:',
            textAlign: TextAlign.center,
            style: TextStyle(color: textSecondaryColor, fontSize: 15),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: errorColor,
                side: const BorderSide(color: errorColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _viewModel.loginWithFingerprint(isRecognized: false);
              },
              child: const Text('No reconocida'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                if (_viewModel.loginWithFingerprint(isRecognized: true)) {
                  Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
                }
              },
              child: const Text('Reconocida'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // Logo Mint
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: primaryColor,
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
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Banca móvil',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Etiqueta Usuario o cédula
                  const Text(
                    'Usuario o cédula',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _viewModel.userController,
                    onChanged: (_) => _viewModel.clearError(),
                    style: const TextStyle(fontSize: 15, color: textColor),
                    decoration: _inputDecoration(
                      hint: 'Ej: 0123456789 o maria@gmail.com',
                      prefixIcon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Etiqueta Contraseña
                  const Text(
                    'Contraseña',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _viewModel.passwordController,
                    obscureText: _viewModel.obscurePassword,
                    onChanged: (_) => _viewModel.clearError(),
                    style: const TextStyle(fontSize: 15, color: textColor),
                    decoration: _inputDecoration(
                      hint: 'Ingresa tu contraseña',
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _viewModel.obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: textSecondaryColor,
                        ),
                        onPressed: _viewModel.togglePasswordVisibility,
                      ),
                    ),
                  ),

                  // Mensaje de error (Flujos 2 y 3)
                  if (_viewModel.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: errorColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: errorColor),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _viewModel.errorMessage!,
                              style: const TextStyle(
                                color: errorColor,
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

                  // Botón Principal: Ingresar (Flujo 2)
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
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

                  // Botón Secundario: Ingresar con huella (Flujo 3)
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: const BorderSide(color: primaryColor, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _showFingerprintModal,
                      icon: const Icon(Icons.fingerprint, size: 24),
                      label: const Text(
                        'Ingresar con huella',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Ir a Crea tu cuenta (Flujo 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿No tienes cuenta? ',
                        style: TextStyle(
                          color: textSecondaryColor,
                          fontSize: 15,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                        child: const Text(
                          'Crea tu cuenta',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  // Ayuda con los datos de María González creados por tu compañera
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Text(
                      'Datos mockeados (MockUsers):\nCédula: 0123456789  |  Usuario: maria@gmail.com\nContraseña: Mint1234',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: textSecondaryColor),
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

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: textSecondaryColor.withOpacity(0.6)),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(prefixIcon, color: textSecondaryColor),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: accentColor, width: 2.0),
      ),
    );
  }
}