import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../mock/mock_users.dart';
import '../service/mock_auth_service.dart';
import '../service/policy_service.dart';
import '../viewModel/policies_view_model.dart';
import '../widget/policy_card.dart';

class PoliciesView extends StatefulWidget {
  const PoliciesView({super.key});

  @override
  State<PoliciesView> createState() => _PoliciesViewState();
}

class _PoliciesViewState extends State<PoliciesView> {
  late final PoliciesViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = PoliciesViewModel(PolicyService());

    final userId = MockAuthService.currentUserId ?? MockUsers.currentUser.id;

    _viewModel.loadPolicies(userId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

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
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Mis pólizas',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            if (_viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_viewModel.errorMessage != null) {
              return Center(child: Text(_viewModel.errorMessage!));
            }

            if (_viewModel.policies.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.account_balance_outlined,
                        color: AppColors.textSecondary,
                        size: 56,
                      ),

                      SizedBox(height: 16),

                      Text(
                        'Aún no tienes pólizas',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 8),

                      Text(
                        'Cuando tengas una inversión a plazo '
                        'fijo, podrás consultar sus detalles aquí.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
              children: [
                const Text(
                  'Consulta tus inversiones a plazo fijo.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 20),

                // Resumen de inversiones
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total invertido',
                        style: TextStyle(
                          color: Color(0xFFDCE8F7),
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        _formatMoney(_viewModel.totalInvested),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        '${_viewModel.policyCount} '
                        '${_viewModel.policyCount == 1 ? 'póliza' : 'pólizas'} '
                        'de inversión',
                        style: const TextStyle(
                          color: Color(0xFFDCE8F7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                const Text(
                  'Tus inversiones',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Listado de pólizas
                ..._viewModel.policies.map(
                  (policy) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: PolicyCard(policy: policy),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
