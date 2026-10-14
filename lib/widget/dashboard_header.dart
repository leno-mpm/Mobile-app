
import 'package:flutter/material.dart';

import '../model/account_model.dart';
import '../model/user_model.dart';
import '../core/theme/app_colors.dart';

class DashboardHeader extends StatefulWidget {
  final UserModel user;
  final AccountModel account;
  final double totalBalance;
  final int accountCount;

  const DashboardHeader({
    super.key,
    required this.user,
    required this.account,
    required this.totalBalance,
    required this.accountCount,
  });

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  bool _showBalance = true;

  String _formatMoney(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0];

    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
    );

    return '\$$formattedInteger.${parts[1]}';
  }

  String get _initials {
    final first = widget.user.firstName.trim();
    final last = widget.user.lastName.trim();

    return '${first.isNotEmpty ? first[0] : ''}'
        '${last.isNotEmpty ? last[0] : ''}'
        .toUpperCase();
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 49,
            height: 49,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountNumber = widget.account.accountNumber;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
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
          // Avatar, saludo y notificaciones
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF42638D),
                child: Text(
                  _initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Buenos días,',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      widget.user.firstName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF365985),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Tarjeta del saldo y accesos rápidos
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF365985),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF6B87A8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Saldo disponible · '
                            '${widget.account.accountType} '
                            '$accountNumber',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showBalance = !_showBalance;
                        });
                      },
                      icon: Icon(
                        _showBalance
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  _showBalance
                      ? _formatMoney(widget.account.balance)
                      : '••••••',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  _showBalance
                      ? 'Total en tus ${widget.accountCount} cuentas: '
                      '${_formatMoney(widget.totalBalance)}'
                      : 'Total en tus ${widget.accountCount} cuentas: ••••••',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    _quickAction(
                      icon: Icons.swap_horiz_rounded,
                      label: 'Transferir',
                    ),
                    _quickAction(
                      icon: Icons.receipt_long_outlined,
                      label: 'Pagar',
                    ),
                    _quickAction(
                      icon: Icons.phone_android_rounded,
                      label: 'Recargar',
                    ),
                    _quickAction(
                      icon: Icons.more_horiz_rounded,
                      label: 'Más',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
