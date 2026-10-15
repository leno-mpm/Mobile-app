import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../model/account_model.dart';
import '../model/transaction_model.dart';

class TransactionDetailView extends StatelessWidget {
  final TransactionModel transaction;
  final AccountModel? account;

  const TransactionDetailView({
    super.key,
    required this.transaction,
    this.account,
  });

  bool get _isIncome => transaction.type == 'ingreso';

  String _formatMoney(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final number = parts[0];

    final formatted = number.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );

    return '\$$formatted.${parts[1]}';
  }

  String get _formattedAmount {
    final sign = _isIncome ? '+' : '-';
    return '$sign${_formatMoney(transaction.amount)}';
  }

  String get _formattedDate {
    const months = [
      'ene.',
      'feb.',
      'mar.',
      'abr.',
      'may.',
      'jun.',
      'jul.',
      'ago.',
      'sept.',
      'oct.',
      'nov.',
      'dic.',
    ];

    final date = transaction.date;

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _detailRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amountColor = _isIncome ? AppColors.secondary : AppColors.error;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          children: [
            // Encabezado
            Row(
              children: [
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const Expanded(
                  child: Text(
                    'Detalle del movimiento',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 48),
              ],
            ),

            const SizedBox(height: 48),

            // Icono del movimiento
            Center(
              child: Container(
                width: 82,
                height: 82,
                decoration: const BoxDecoration(
                  color: Color(0xFFE7EFFC),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isIncome
                      ? Icons.south_west_rounded
                      : Icons.north_east_rounded,
                  color: AppColors.primary,
                  size: 38,
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Descripción
            Text(
              transaction.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 15),

            // Monto
            Text(
              _formattedAmount,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: amountColor,
                fontSize: 38,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 17),

            // Fecha
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.textSecondary,
                  size: 17,
                ),

                const SizedBox(width: 8),

                Text(
                  _formattedDate,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Información del movimiento
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (account != null) ...[
                    _detailRow(
                      label: 'Cuenta',
                      value:
                          '${account!.accountType} '
                          '${account!.accountNumber}',
                    ),

                    const Divider(color: Color(0xFFEEF0F4)),
                  ],

                  _detailRow(label: 'Categoría', value: transaction.category),

                  const Divider(color: Color(0xFFEEF0F4)),

                  _detailRow(
                    label: 'Tipo de movimiento',
                    value: _isIncome ? 'Ingreso' : 'Egreso',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ID de transacción
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: _detailRow(
                label: 'ID de transacción',
                value: transaction.id,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
