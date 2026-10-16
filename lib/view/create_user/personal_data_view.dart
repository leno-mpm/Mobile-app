
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../model/registration_flow_data.dart';
import '../../viewModel/create_user/personal_data_view_model.dart';
import '../../widget/labeled_text_field.dart';
import 'employment_info_view.dart';

class PersonalDataView extends StatefulWidget {
  final RegistrationFlowData flowData;

  const PersonalDataView({super.key, required this.flowData});

  @override
  State<PersonalDataView> createState() => _PersonalDataViewState();
}

class _PersonalDataViewState extends State<PersonalDataView> {
  late final PersonalDataViewModel _viewModel = PersonalDataViewModel(
    widget.flowData,
  );

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _onContinuePressed() {
    FocusScope.of(context).unfocus();

    final updatedFlowData = _viewModel.saveAndContinue();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmploymentInfoView(flowData: updatedFlowData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
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
              'Confirma tus datos',
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
                    'Confirma tus nombres, apellidos y datos de contacto.',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  LabeledTextField(
                    label: 'Primer nombre',
                    hint: 'Ej: María',
                    icon: Icons.badge_outlined,
                    controller: _viewModel.firstNameController,
                    touched: _viewModel.firstNameTouched,
                    errorText: _viewModel.firstNameError,
                    onChanged: _viewModel.onFirstNameChanged,
                  ),

                  const SizedBox(height: 18),

                  LabeledTextField(
                    label: 'Segundo nombre (opcional)',
                    hint: 'Ej: Fernanda',
                    icon: Icons.badge_outlined,
                    controller: _viewModel.secondNameController,
                    touched: false,
                    errorText: null,
                    showValidationIcon: false,
                    onChanged: (_) {},
                  ),

                  const SizedBox(height: 18),

                  LabeledTextField(
                    label: 'Primer apellido',
                    hint: 'Ej: González',
                    icon: Icons.badge_outlined,
                    controller: _viewModel.lastNameController,
                    touched: _viewModel.lastNameTouched,
                    errorText: _viewModel.lastNameError,
                    onChanged: _viewModel.onLastNameChanged,
                  ),

                  const SizedBox(height: 18),

                  LabeledTextField(
                    label: 'Segundo apellido (opcional)',
                    hint: 'Ej: Pérez',
                    icon: Icons.badge_outlined,
                    controller: _viewModel.secondLastNameController,
                    touched: false,
                    errorText: null,
                    showValidationIcon: false,
                    onChanged: (_) {},
                  ),

                  const SizedBox(height: 18),

                  LabeledTextField(
                    label: 'Correo',
                    hint: 'ejemplo@gmail.com',
                    icon: Icons.email_outlined,
                    controller: _viewModel.emailController,
                    keyboardType: TextInputType.emailAddress,
                    touched: _viewModel.emailTouched,
                    errorText: _viewModel.emailError,
                    onChanged: _viewModel.onEmailChanged,
                  ),

                  const SizedBox(height: 18),

                  LabeledTextField(
                    label: 'Celular',
                    hint: 'Ej: 0991234567',
                    icon: Icons.phone_android_outlined,
                    controller: _viewModel.phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    touched: _viewModel.phoneTouched,
                    errorText: _viewModel.phoneError,
                    onChanged: _viewModel.onPhoneChanged,
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
                      onPressed:
                          _viewModel.isFormValid ? _onContinuePressed : null,
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
      },
    );
  }
}
