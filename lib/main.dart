
import 'package:flutter/material.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

import 'view/login_view.dart';
import 'view/register_view.dart';
import 'view/dashboard_view.dart';
import 'view/profile_view.dart';

void main() {
  runApp(const MintApp());
}

class MintApp extends StatelessWidget {
  const MintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mint',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // Pantalla inicial de la aplicación
      initialRoute: AppRoutes.login,

      // Rutas disponibles
      routes: {
        AppRoutes.login: (context) => const LoginView(),
        AppRoutes.register: (context) => const RegisterView(),
        AppRoutes.dashboard: (context) => const DashboardView(),
        AppRoutes.profile: (context) => const ProfileView(),
      },
    );
  }
}
