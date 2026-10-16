
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

import 'view/login_view.dart';
import 'view/register_view.dart';
import 'view/dashboard_view.dart';
import 'view/profile_view.dart';
import 'view/splash_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  if (supabaseKey.isEmpty) {
    throw StateError(
      'Falta SUPABASE_PUBLISHABLE_KEY. '
          'Ejecuta Flutter con --dart-define.',
    );
  }

  await Supabase.initialize(
    url: 'https://mfoonkofzdhtgdbfxjzd.supabase.co',
    publishableKey: supabaseKey,
  );

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

      home: const SplashView(),

      routes: {
        AppRoutes.login: (context) => const LoginView(),
        AppRoutes.register: (context) => const RegisterView(),

        AppRoutes.dashboard: (context) =>
        const ProtectedRoute(
          child: DashboardView(),
        ),

        AppRoutes.profile: (context) =>
        const ProtectedRoute(
          child: ProfileView(),
        ),
      },
    );
  }
}

// Determina qué pantalla mostrar al abrir Mint.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session =
            Supabase.instance.client.auth.currentSession;

        if (session == null) {
          return const LoginView();
        }

        return const DashboardView();
      },
    );
  }
}

// Impide mostrar una ruta protegida sin sesión.
class ProtectedRoute extends StatelessWidget {
  final Widget child;

  const ProtectedRoute({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session =
            Supabase.instance.client.auth.currentSession;

        if (session == null) {
          return const LoginView();
        }

        return child;
      },
    );
  }
}
