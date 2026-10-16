
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_lifecycle_guard.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

import 'view/login_view.dart';
import 'view/create_user/identity_verification_view.dart';
import 'view/product_request/select_product_view.dart';
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
    // La sesión vive solo en memoria: si el usuario quita la app de
    // recientes (o el sistema mata el proceso), al volver a abrirla
    // no hay sesión guardada y debe iniciar sesión de nuevo. Cambiar
    // de app sin que el proceso muera no afecta: la sesión sigue en
    // memoria mientras el proceso esté vivo.
    authOptions: const FlutterAuthClientOptions(persistSession: false),
  );

  runApp(const MintApp());
}

class MintApp extends StatefulWidget {
  const MintApp({super.key});

  @override
  State<MintApp> createState() => _MintAppState();
}

class _MintAppState extends State<MintApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Cierra la sesión en cuanto el usuario sale de la app (pasa a
  // segundo plano), no solo cuando la elimina de recientes. Se omite
  // si el propio pausado lo causó una UI del sistema que la app abrió
  // (selector de foto, hoja de compartir) — ver AppLifecycleGuard.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && !AppLifecycleGuard.isSuppressed) {
      Supabase.instance.client.auth.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mint',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      home: const SplashView(),

      routes: {
        AppRoutes.login: (context) => const LoginView(),
        AppRoutes.createUser: (context) => const IdentityVerificationView(),
        AppRoutes.requestProduct: (context) => const SelectProductView(),

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
