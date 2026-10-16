import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../main.dart';

// Pantalla de bienvenida: el mismo logo de inicio de sesión
// (el brote de 3 hojas) se revela de abajo hacia arriba, como
// si creciera, mientras se prepara la app.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _boxAnimation;
  late final Animation<double> _revealAnimation;
  late final Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _boxAnimation = _interval(0.0, 0.18, curve: Curves.easeOutBack);
    _revealAnimation = _interval(0.16, 0.82, curve: Curves.easeOutCubic);
    _textAnimation = _interval(0.8, 1.0, curve: Curves.easeOut);

    _controller.addStatusListener(_onAnimationStatusChanged);
    _controller.forward();
  }

  Animation<double> _interval(double begin, double end, {required Curve curve}) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, end, curve: curve),
    );
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthGate()),
    );
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onAnimationStatusChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ==========================================
            // LOGO: mismo ícono, contenedor y colores
            // que en inicio de sesión.
            // ==========================================
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final boxValue = _boxAnimation.value.clamp(0.0, 1.0);
                final revealValue = _revealAnimation.value.clamp(0.0, 1.0);

                return Opacity(
                  opacity: boxValue,
                  child: Transform.scale(
                    scale: boxValue,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Center(
                        child: ClipRect(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            heightFactor: revealValue,
                            child: const Icon(
                              Icons.spa_rounded,
                              color: Color(0xFF42B883),
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            AnimatedBuilder(
              animation: _textAnimation,
              builder: (context, child) {
                final value = _textAnimation.value.clamp(0.0, 1.0);

                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * 8),
                    child: Column(
                      children: const [
                        Text(
                          'Mint',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),

                        SizedBox(height: 6),

                        Text(
                          'Banca móvil',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
