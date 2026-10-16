
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../model/product_request_flow_data.dart';
import 'policy_details_view.dart';

// Se muestra solo cuando la cédula tiene más de una cuenta (ahorro y
// corriente): el usuario elige de cuál se debita la prima de la póliza.
class AccountPickerView extends StatefulWidget {
  final ProductRequestFlowData flowData;

  const AccountPickerView({super.key, required this.flowData});

  @override
  State<AccountPickerView> createState() => _AccountPickerViewState();
}

class _AccountPickerViewState extends State<AccountPickerView> {
  String? _selectedAccountId;
  String? _errorMessage;

  void _onConfirmPressed() {
    if (_selectedAccountId == null) return;

    final selected = widget.flowData.accounts.firstWhere(
      (a) => a.id == _selectedAccountId,
    );

    if (selected.balance < AppConstants.minPolicyAmount) {
      setState(
        () => _errorMessage =
            'Esa cuenta no tiene al menos '
            '\$${AppConstants.minPolicyAmount.toStringAsFixed(0)} '
            'disponibles para solicitar una póliza.',
      );
      return;
    }

    widget.flowData.sourceAccountId = selected.id;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PolicyDetailsView(
          flowData: widget.flowData,
          sourceAccountBalance: selected.balance,
        ),
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
          'Cuenta de origen',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '¿De cuál cuenta se debitará la prima de tu póliza?',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 20),

              RadioGroup<String>(
                groupValue: _selectedAccountId,
                onChanged: (value) => setState(() => _selectedAccountId = value),
                child: Column(
                  children: [
                    for (final account in widget.flowData.accounts)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          child: RadioListTile<String>(
                            value: account.id,
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            title: Text(
                              account.accountType,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                            subtitle: Text(
                              '${account.accountNumber} • '
                              '\$${account.balance.toStringAsFixed(2)}',
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 8),

                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: 20),

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
                  onPressed:
                      _selectedAccountId != null ? _onConfirmPressed : null,
                  child: const Text(
                    'Confirmar',
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
}
