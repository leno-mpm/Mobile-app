
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../model/product_request_flow_data.dart';
import 'identification_view.dart';

class SelectProductView extends StatelessWidget {
  final String? prefilledIdentification;

  const SelectProductView({super.key, this.prefilledIdentification});

  void _selectProduct(BuildContext context, String productType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IdentificationView(
          flowData: ProductRequestFlowData(
            productType: productType,
            identification: prefilledIdentification ?? '',
          ),
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
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            }
          },
        ),
        title: const Text(
          'Solicitar producto',
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
                '¿Qué producto quieres solicitar?',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              _ProductOptionCard(
                icon: Icons.savings_outlined,
                title: 'Cuenta de ahorros',
                subtitle: 'Guarda tu dinero y gana intereses',
                onTap: () => _selectProduct(
                  context,
                  AppConstants.productTypeAhorro,
                ),
              ),

              const SizedBox(height: 14),

              _ProductOptionCard(
                icon: Icons.account_balance_outlined,
                title: 'Cuenta corriente',
                subtitle: 'Para tus movimientos del día a día',
                onTap: () => _selectProduct(
                  context,
                  AppConstants.productTypeCorriente,
                ),
              ),

              const SizedBox(height: 14),

              _ProductOptionCard(
                icon: Icons.shield_outlined,
                title: 'Póliza',
                subtitle: 'Protege tu patrimonio (requiere una cuenta)',
                onTap: () => _selectProduct(
                  context,
                  AppConstants.productTypePoliza,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProductOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
