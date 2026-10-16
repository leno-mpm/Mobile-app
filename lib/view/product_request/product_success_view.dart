
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../model/product_request_result.dart';
import '../../model/registration_flow_data.dart';
import '../create_user/personal_data_view.dart';

class ProductSuccessView extends StatelessWidget {
  final ProductRequestResult result;
  final String identification;

  const ProductSuccessView({
    super.key,
    required this.result,
    required this.identification,
  });

  String get _productLabel {
    switch (result.productType) {
      case AppConstants.productTypeAhorro:
        return 'Cuenta de ahorros';
      case AppConstants.productTypeCorriente:
        return 'Cuenta corriente';
      default:
        return 'Póliza';
    }
  }

  void _onContinuePressed(BuildContext context) {
    if (result.hasProfile) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => PersonalDataView(
          flowData: RegistrationFlowData(
            identification: identification,
            skipIdentityStep: true,
          ),
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  '¡$_productLabel creada!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Tu número de producto es:',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  result.productNumber,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => _onContinuePressed(context),
                    child: Text(
                      result.hasProfile
                          ? 'Ir a iniciar sesión'
                          : 'Continuar y crear tu usuario',
                      style: const TextStyle(
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
      ),
    );
  }
}
