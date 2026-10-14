
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../model/account_model.dart';

class AccountCard extends StatefulWidget {
  final AccountModel account;
  final bool isSelected;
  final bool showBalance;
  final VoidCallback onTap;

  const AccountCard({
    super.key,
    required this.account,
    required this.isSelected,
    required this.showBalance,
    required this.onTap,
  });

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get _isSavings =>
      widget.account.accountType.toLowerCase() == 'ahorros';

  Color get _cardTextColor =>
      _isSavings ? AppColors.primary : Colors.white;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_controller.isAnimating) return;

    widget.onTap();

    if (_controller.value < 0.5) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  String _formatMoney(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');

    final formatted = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
    );

    return '\$$formatted.${parts[1]}';
  }

  // Ocultar todos los dígitos excepto los últimos cuatro.
  String _maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) {
      return accountNumber;
    }

    final hiddenCount = accountNumber.length - 4;
    final lastFour = accountNumber.substring(hiddenCount);

    return '${'*' * hiddenCount}$lastFour';
  }

  // El ojito del Dashboard controla los números de cuenta.
  String _getDisplayedAccountNumber() {
    final accountNumber = widget.account.accountNumber;

    return widget.showBalance
        ? accountNumber
        : _maskAccountNumber(accountNumber);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * math.pi;
          final isBack = angle >= math.pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0005)
              ..rotateY(angle),
            child: isBack
                ? Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
              child: _buildBack(),
            )
                : _buildFront(),
          );
        },
      ),
    );
  }

  // ============================
  // PARTE FRONTAL
  // ============================

  Widget _buildFront() {
    final textColor = _cardTextColor;

    return Container(
      // La sombra permanece fuera del área recortada.
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      // Recorta el círculo decorativo a los límites
      // redondeados de la tarjeta.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: _isSavings
              ? Colors.white
              : AppColors.secondary,
          padding: const EdgeInsets.all(20),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Círculo decorativo
              Positioned(
                right: -35,
                top: -45,
                child: Container(
                  width: 155,
                  height: 155,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isSavings
                          ? AppColors.primary.withValues(alpha: 0.04)
                          : Colors.white.withValues(alpha: 0.08),
                      width: 20,
                    ),
                  ),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo Mint y símbolo contactless
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Mint',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(width: 7),

                          Icon(
                            Icons.spa_rounded,
                            color: _isSavings
                                ? AppColors.secondary
                                : const Color(0xFF8EF0C4),
                            size: 23,
                          ),
                        ],
                      ),

                      Icon(
                        Icons.wifi_rounded,
                        color: textColor,
                        size: 26,
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Chip de la tarjeta
                  Container(
                    width: 43,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _isSavings
                          ? const Color(0xFFE1E8F0)
                          : const Color(0xFFD4F3E8),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(
                      Icons.grid_view_rounded,
                      color: _isSavings
                          ? const Color(0xFF7189A7)
                          : AppColors.secondary,
                      size: 23,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Número de cuenta
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _getDisplayedAccountNumber(),
                      maxLines: 1,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 22,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tipo de cuenta y moneda
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CUENTA ${widget.account.accountType.toUpperCase()}',
                        style: TextStyle(
                          color: _isSavings
                              ? AppColors.textSecondary
                              : const Color(0xFFE0F6EE),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      Text(
                        widget.account.currency,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================
  // PARTE POSTERIOR
  // ============================

  Widget _buildBack() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: const Color(0xFFE6EDF7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Banda magnética decorativa
              Container(
                width: double.infinity,
                height: 30,
                color: const Color(0xFF25354C),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    10,
                    20,
                    10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SALDO DISPONIBLE',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        widget.showBalance
                            ? _formatMoney(widget.account.balance)
                            : '••••••••',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      Row(
                        children: [
                          Expanded(
                            child: _info(
                              'TIPO DE CUENTA',
                              widget.account.accountType,
                            ),
                          ),

                          _info(
                            'MONEDA',
                            widget.account.currency,
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      const Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mint · Banca móvil',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),

                          Icon(
                            Icons.flip_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          value,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
