
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

  // Oculta todos los dígitos excepto los últimos cuatro.
  String _maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) {
      return accountNumber;
    }

    final hiddenCount = accountNumber.length - 4;
    final lastFour = accountNumber.substring(hiddenCount);

    return '${'*' * hiddenCount}$lastFour';
  }

  // Usa el mismo estado del ojito del Dashboard.
  String _getDisplayedAccountNumber() {
    final accountNumber = widget.account.accountNumber;

    if (widget.showBalance) {
      return accountNumber;
    }

    return _maskAccountNumber(accountNumber);
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
              ..setEntry(3, 2, 0.001)
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

  // PARTE FRONTAL
  Widget _buildFront() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.account.accountType.toLowerCase() == 'ahorros'
              ? [
            AppColors.primary,
            const Color(0xFF305E98),
          ]
              : [
            AppColors.secondary,
            const Color(0xFF145440),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isSelected
              ? const Color(0xFF8FB8FF)
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          // Decoración de fondo
          Positioned(
            right: -35,
            top: -45,
            child: Container(
              width: 155,
              height: 155,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10),
                  width: 20,
                ),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Text(
                        'Mint',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 7),
                      Icon(
                        Icons.spa_rounded,
                        color: Color(0xFF64D9A5),
                        size: 23,
                      ),
                    ],
                  ),

                  const Icon(
                    Icons.wifi_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ],
              ),

              const Spacer(),

              // Chip decorativo
              Container(
                width: 43,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFD5DDE8),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: const Color(0xFF9BAAC0),
                  ),
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: Color(0xFF637894),
                  size: 23,
                ),
              ),

              const SizedBox(height: 20),

              // Número de cuenta: completo u oculto.
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  _getDisplayedAccountNumber(),
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CUENTA ${widget.account.accountType.toUpperCase()}',
                    style: const TextStyle(
                      color: Color(0xFFE0E9F5),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Text(
                    widget.account.currency,
                    style: const TextStyle(
                      color: Colors.white,
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
    );
  }

  // PARTE POSTERIOR
  Widget _buildBack() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE6EDF7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isSelected
              ? AppColors.primary
              : const Color(0xFFC8D5E6),
          width: widget.isSelected ? 2 : 1,
        ),
      ),
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
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
