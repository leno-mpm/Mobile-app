import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../model/user_model.dart';

class DashboardHeader extends StatelessWidget {
  final UserModel user;
  final double totalBalance;
  final int accountCount;
  final bool showBalance;
  final VoidCallback onToggleBalance;

  const DashboardHeader({
    super.key,
    required this.user,
    required this.totalBalance,
    required this.accountCount,
    required this.showBalance,
    required this.onToggleBalance,
  });

  String _formatMoney(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');

    final formatted = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );

    return '\$$formatted.${parts[1]}';
  }

  String _getInitials() {
    final first = user.firstName.trim();
    final last = user.lastName.trim();

    return '${first.isNotEmpty ? first[0] : ''}'
            '${last.isNotEmpty ? last[0] : ''}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saludo y avatar
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF41638F),
                child: Text(
                  _getInitials(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Buenos días,',
                      style: TextStyle(color: Color(0xFFD5E2F2), fontSize: 12),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      user.firstName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Resumen general del dinero
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF365C89),
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: const Color(0xFF7290B5), width: 0.7),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Saldo total disponible',
                        style: TextStyle(
                          color: Color(0xFFDCE8F7),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    IconButton(
                      tooltip: showBalance
                          ? 'Ocultar saldos'
                          : 'Mostrar saldos',
                      onPressed: onToggleBalance,
                      icon: Icon(
                        showBalance
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  showBalance ? _formatMoney(totalBalance) : '••••••••',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Distribuido en $accountCount '
                  '${accountCount == 1 ? 'cuenta' : 'cuentas'}',
                  style: const TextStyle(
                    color: Color(0xFFDCE8F7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
