
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../model/product_request_flow_data.dart';
import '../../widget/labeled_text_field.dart';
import 'validating_view.dart';

class IdentificationView extends StatefulWidget {
  final ProductRequestFlowData flowData;

  const IdentificationView({super.key, required this.flowData});

  @override
  State<IdentificationView> createState() => _IdentificationViewState();
}

class _IdentificationViewState extends State<IdentificationView> {
  final _controller = TextEditingController();
  late bool _touched = widget.flowData.identification.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.flowData.identification;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? get _error {
    final value = _controller.text.trim();

    if (value.isEmpty) {
      return 'Ingresa tu número de cédula';
    }

    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'La cédula debe tener 10 dígitos numéricos';
    }

    return null;
  }

  void _onContinuePressed() {
    FocusScope.of(context).unfocus();
    setState(() => _touched = true);

    if (_error != null) return;

    widget.flowData.identification = _controller.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ValidatingView(flowData: widget.flowData),
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
                'Ingresa tu número de cédula para continuar.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              LabeledTextField(
                label: 'Cédula',
                hint: '10 dígitos',
                icon: Icons.credit_card_outlined,
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                touched: _touched,
                errorText: _error,
                onChanged: (_) => setState(() => _touched = true),
              ),

              const SizedBox(height: 28),

              SizedBox(
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
                  onPressed: _onContinuePressed,
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
}
