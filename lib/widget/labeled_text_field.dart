
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';

// Campo de texto con etiqueta, validación visual (borde/ícono) y
// mensaje de error. Mismo patrón usado antes en el registro de un solo
// paso, ahora compartido entre las pantallas de los nuevos flujos.
class LabeledTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool touched;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool showValidationIcon;
  final Widget? suffixIcon;
  final String? helperText;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.touched,
    required this.errorText,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.showValidationIcon = true,
    this.suffixIcon,
    this.helperText,
    this.inputFormatters,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final isValid = touched && errorText == null;
    final hasError = touched && errorText != null;

    Color borderColor = Colors.grey.shade400;

    if (isValid) {
      borderColor = AppColors.secondary;
    }

    if (hasError) {
      borderColor = AppColors.error;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: textInputAction,
          autocorrect: false,
          enabled: enabled,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.text,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(
              icon,
              color: AppColors.textSecondary,
            ),
            suffixIcon: suffixIcon ??
                (showValidationIcon
                    ? (isValid
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.secondary,
                          )
                        : (hasError
                            ? const Icon(
                                Icons.error_outline,
                                color: AppColors.error,
                              )
                            : null))
                    : null),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: borderColor,
                width: (isValid || hasError) ? 1.8 : 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.error
                    : (isValid ? AppColors.secondary : AppColors.accent),
                width: 2,
              ),
            ),
          ),
        ),

        if (helperText != null) ...[
          const SizedBox(height: 6),

          Text(
            helperText!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],

        if (hasError) ...[
          const SizedBox(height: 6),

          Text(
            errorText!,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}
