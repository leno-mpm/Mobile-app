
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../model/registration_flow_data.dart';
import 'credentials_view.dart';

// Paso simulado: nada de lo que se captura aquí se envía ni se guarda
// en Supabase. Es solo informativo para completar la experiencia.
class EmploymentInfoView extends StatefulWidget {
  final RegistrationFlowData flowData;

  const EmploymentInfoView({super.key, required this.flowData});

  @override
  State<EmploymentInfoView> createState() => _EmploymentInfoViewState();
}

class _EmploymentInfoViewState extends State<EmploymentInfoView> {
  late String? _jobSituation =
      widget.flowData.jobSituation.isEmpty ? null : widget.flowData.jobSituation;

  late String? _accountUsage =
      widget.flowData.accountUsage.isEmpty ? null : widget.flowData.accountUsage;

  final _incomeController = TextEditingController();
  final _expensesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _incomeController.text = widget.flowData.monthlyIncome;
    _expensesController.text = widget.flowData.monthlyExpenses;
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _expensesController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _jobSituation != null &&
      _accountUsage != null &&
      _incomeController.text.trim().isNotEmpty &&
      _expensesController.text.trim().isNotEmpty;

  void _onContinuePressed() {
    FocusScope.of(context).unfocus();

    widget.flowData.jobSituation = _jobSituation!;
    widget.flowData.accountUsage = _accountUsage!;
    widget.flowData.monthlyIncome = _incomeController.text.trim();
    widget.flowData.monthlyExpenses = _expensesController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CredentialsView(flowData: widget.flowData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Casi terminamos',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Cuéntanos un poco más sobre tu situación financiera.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              _buildDropdown(
                label: 'Situación laboral',
                value: _jobSituation,
                options: AppConstants.jobSituationOptions,
                onChanged: (value) => setState(() => _jobSituation = value),
              ),

              const SizedBox(height: 18),

              _buildDropdown(
                label: 'Uso de la cuenta',
                value: _accountUsage,
                options: AppConstants.accountUsageOptions,
                onChanged: (value) => setState(() => _accountUsage = value),
              ),

              const SizedBox(height: 18),

              _buildAmountField(
                label: 'Ingresos mensuales',
                hint: 'Ej: 800',
                controller: _incomeController,
                onChanged: () => setState(() {}),
              ),

              const SizedBox(height: 18),

              _buildAmountField(
                label: 'Gastos mensuales',
                hint: 'Ej: 500',
                controller: _expensesController,
                onChanged: () => setState(() {}),
              ),

              const SizedBox(height: 28),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isFormValid ? _onContinuePressed : null,
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
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

        DropdownButtonFormField<String>(
          initialValue: value,
          items: options
              .map(
                (option) => DropdownMenuItem(
                  value: option,
                  child: Text(option),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required VoidCallback onChanged,
  }) {
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
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            prefixText: r'$ ',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.accent, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
