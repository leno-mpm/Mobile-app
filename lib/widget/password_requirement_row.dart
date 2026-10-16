
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

// Fila con ícono de check/vacío usada en la lista de requisitos de
// contraseña (mínimo de caracteres, mayúscula, minúscula, número).
class PasswordRequirementRow extends StatelessWidget {
  final String label;
  final bool fulfilled;

  const PasswordRequirementRow({
    super.key,
    required this.label,
    required this.fulfilled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(
            fulfilled ? Icons.check_circle : Icons.radio_button_unchecked,
            color: fulfilled ? AppColors.secondary : AppColors.textSecondary,
            size: 18,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: fulfilled ? AppColors.secondary : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: fulfilled ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
