import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class BalanceSummaryCard extends StatelessWidget {
  final double totalBalance;
  final int accountCount;
  final bool showBalance;
  final VoidCallback onToggleBalance;

  const BalanceSummaryCard({
    super.key,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 10, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saldo total disponible',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  showBalance ? _formatMoney(totalBalance) : '••••••••',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Distribuido en $accountCount '
                  '${accountCount == 1 ? 'cuenta' : 'cuentas'}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            tooltip: showBalance ? 'Ocultar saldos' : 'Mostrar saldos',
            onPressed: onToggleBalance,
            icon: Icon(
              showBalance
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
