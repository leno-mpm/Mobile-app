import 'package:flutter/material.dart';

import '../model/transaction_model.dart';
import '../core/theme/app_colors.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionTile({super.key, required this.transaction});

  // Formatear el monto con separadores de miles
  String _formatMoney(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');

    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );

    return '\$$integerPart.${parts[1]}';
  }

  // Elegir ícono según la categoría
  IconData _getCategoryIcon() {
    switch (transaction.category.toLowerCase()) {
      case 'alimentación':
      case 'comida':
        return Icons.restaurant_rounded;

      case 'salud':
        return Icons.favorite_border_rounded;

      case 'ocio':
      case 'entretenimiento':
        return Icons.local_activity_outlined;

      case 'servicios':
        return Icons.receipt_long_outlined;

      case 'transferencias':
        return Icons.south_west_rounded;

      case 'ingresos':
        return Icons.account_balance_wallet_outlined;

      default:
        return Icons.swap_horiz_rounded;
    }
  }

  // Elegir color del ícono según la categoría
  Color _getIconColor() {
    switch (transaction.category.toLowerCase()) {
      case 'alimentación':
      case 'comida':
        return const Color(0xFFA85D1B);

      case 'salud':
        return const Color(0xFF1E7F64);

      case 'ocio':
      case 'entretenimiento':
        return const Color(0xFF7950B5);

      case 'transferencias':
        return const Color(0xFF3D70CC);

      case 'servicios':
        return AppColors.primary;

      case 'ingresos':
        return AppColors.secondary;

      default:
        return AppColors.textSecondary;
    }
  }

  // Elegir color de fondo del ícono
  Color _getIconBackground() {
    switch (transaction.category.toLowerCase()) {
      case 'alimentación':
      case 'comida':
        return const Color(0xFFFFF0E1);

      case 'salud':
        return const Color(0xFFE3F4EE);

      case 'ocio':
      case 'entretenimiento':
        return const Color(0xFFEEE7FA);

      case 'transferencias':
        return const Color(0xFFE4EDFF);

      case 'servicios':
        return const Color(0xFFE8EEF8);

      case 'ingresos':
        return const Color(0xFFE3F4EE);

      default:
        return AppColors.background;
    }
  }

  // Formatear la fecha
  String _formatDate() {
    final date = transaction.date;

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isIncome = transaction.type == 'ingreso';

    final String formattedAmount =
        '${isIncome ? '+' : '-'}${_formatMoney(transaction.amount)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Ícono de la categoría
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _getIconBackground(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getCategoryIcon(), color: _getIconColor(), size: 19),
          ),

          const SizedBox(width: 10),

          // Información del movimiento
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  '${transaction.category} · ${_formatDate()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Monto
          Text(
            formattedAmount,
            style: TextStyle(
              color: isIncome ? AppColors.secondary : AppColors.text,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
