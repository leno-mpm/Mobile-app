import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../model/policy_model.dart';
import 'policy_card.dart' show showPolicyDetails;

// Mismo tamaño y ritmo visual que AccountCard dentro del carrusel,
// pero sin la metáfora de tarjeta bancaria (una póliza no tiene
// chip, contactless ni un número que "revelar" al voltearla).
class PolicyAccountCard extends StatelessWidget {
  final PolicyModel policy;
  final bool showBalance;

  const PolicyAccountCard({
    super.key,
    required this.policy,
    required this.showBalance,
  });

  String _formatMoney(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');

    final formatted = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );

    return '\$$formatted.${parts[1]}';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  // Oculta todos los dígitos excepto los últimos cuatro.
  String _maskPolicyNumber(String policyNumber) {
    if (policyNumber.length <= 4) {
      return policyNumber;
    }

    final hiddenCount = policyNumber.length - 4;
    final lastFour = policyNumber.substring(hiddenCount);

    return '${'*' * hiddenCount}$lastFour';
  }

  String _getDisplayedPolicyNumber() {
    return showBalance ? policy.policyNumber : _maskPolicyNumber(policy.policyNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => showPolicyDetails(context, policy),
        child: Container(
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              color: AppColors.accent,
              padding: const EdgeInsets.all(20),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: -35,
                    top: -45,
                    child: Container(
                      width: 155,
                      height: 155,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                          width: 20,
                        ),
                      ),
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado: tipo de inversión y plazo
                      Row(
                        children: [
                          const Icon(
                            Icons.lock_clock_rounded,
                            color: Colors.white,
                            size: 26,
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Inversión a plazo fijo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 2),

                                Text(
                                  'Póliza ${_getDisplayedPolicyNumber()}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFFE0ECFF),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Text(
                            '${policy.termDays} días',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Capital invertido
                      const Text(
                        'CAPITAL INVERTIDO',
                        style: TextStyle(
                          color: Color(0xFFE0ECFF),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        showBalance ? _formatMoney(policy.amount) : '••••••••',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Tasa anual y vencimiento
                      Row(
                        children: [
                          Expanded(
                            child: _info(
                              'TASA ANUAL',
                              '${policy.annualInterestRate.toStringAsFixed(2)} %',
                            ),
                          ),

                          _info(
                            'VENCIMIENTO',
                            _formatDate(policy.endDate),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
            color: Color(0xFFE0ECFF),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
