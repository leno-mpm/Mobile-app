
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../model/account_model.dart';
import '../model/transaction_model.dart';
import '../service/account_service.dart';
import '../service/payment_service.dart';
import '../widget/dashboard_bottom_nav.dart';
import 'movements_view.dart';

class _BillOption {
  final String name;
  final IconData icon;

  const _BillOption(this.name, this.icon);
}

const List<_BillOption> _billOptions = [
  _BillOption('Agua', Icons.water_drop_outlined),
  _BillOption('Luz', Icons.bolt_outlined),
  _BillOption('Internet', Icons.wifi_rounded),
  _BillOption('Netflix', Icons.movie_outlined),
];

class PaymentsView extends StatefulWidget {
  const PaymentsView({super.key});

  @override
  State<PaymentsView> createState() => _PaymentsViewState();
}

class _PaymentsViewState extends State<PaymentsView> {
  final AccountService _accountService = AccountService();
  final PaymentService _paymentService = PaymentService();
  final _amountController = TextEditingController();

  bool _loadingAccounts = true;
  List<AccountModel> _accounts = [];
  String? _loadError;

  _BillOption? _selectedService;
  String? _selectedAccountId;

  bool _amountTouched = false;
  bool _isPaying = false;
  String? _payError;
  double? _newBalance;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      setState(() {
        _loadingAccounts = false;
        _loadError = 'Debes iniciar sesión para continuar';
      });
      return;
    }

    setState(() {
      _loadingAccounts = true;
      _loadError = null;
    });

    try {
      final accounts = await _accountService.getAccountsByUser(userId);

      setState(() {
        _accounts = accounts;
        _loadingAccounts = false;
      });
    } catch (_) {
      setState(() {
        _loadError = 'No se pudieron cargar tus cuentas';
        _loadingAccounts = false;
      });
    }
  }

  // ==========================================
  // NAVEGACIÓN ENTRE PESTAÑAS PRINCIPALES
  // ==========================================

  void _onNavigationSelected(int index) {
    if (index == 2) return;

    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.dashboard,
        (route) => false,
      );
      return;
    }

    if (index == 1) {
      _openMovements();
      return;
    }

    if (index == 3) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.profile,
        (route) => false,
      );
    }
  }

  Future<void> _openMovements() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) return;

    final accounts = await _accountService.getAccountsByUser(userId);

    final List<TransactionModel> transactions = [];
    for (final account in accounts) {
      transactions.addAll(
        await _accountService.getTransactionsByAccount(account.id),
      );
    }
    transactions.sort((a, b) => b.date.compareTo(a.date));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MovementsView(
          transactions: transactions,
          accounts: accounts,
        ),
      ),
    );
  }

  // ==========================================
  // PAGO
  // ==========================================

  void _selectService(_BillOption service) {
    setState(() {
      _selectedService = service;
      _selectedAccountId = _accounts.isNotEmpty ? _accounts.first.id : null;
      _amountController.clear();
      _amountTouched = false;
      _payError = null;
      _newBalance = null;
    });
  }

  AccountModel? get _selectedAccount {
    for (final account in _accounts) {
      if (account.id == _selectedAccountId) return account;
    }
    return null;
  }

  double? get _amount => double.tryParse(_amountController.text.trim());

  String? get _amountError {
    if (_amountController.text.trim().isEmpty) {
      return 'Ingresa el monto a pagar';
    }

    final value = _amount;

    if (value == null || value <= 0) {
      return 'Ingresa un monto válido';
    }

    final account = _selectedAccount;

    if (account != null && value > account.balance) {
      return 'Saldo insuficiente '
          '(\$${account.balance.toStringAsFixed(2)} disponibles)';
    }

    return null;
  }

  Future<void> _onPayPressed() async {
    if (_isPaying) return;

    FocusScope.of(context).unfocus();
    setState(() => _amountTouched = true);

    final account = _selectedAccount;
    final service = _selectedService;
    final amount = _amount;

    if (account == null || service == null || _amountError != null) return;

    setState(() {
      _isPaying = true;
      _payError = null;
    });

    try {
      final newBalance = await _paymentService.payService(
        accountId: account.id,
        serviceName: service.name,
        amount: amount!,
      );

      if (!mounted) return;

      setState(() => _newBalance = newBalance);
    } on PaymentException catch (error) {
      setState(() => _payError = error.message);
    } catch (_) {
      setState(
        () => _payError = 'Ocurrió un error inesperado. Inténtalo nuevamente',
      );
    } finally {
      if (mounted) {
        setState(() => _isPaying = false);
      }
    }
  }

  void _onDonePressed() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.dashboard,
      (route) => false,
    );
  }

  // ==========================================
  // INTERFAZ
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Pagos',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: 2,
        onItemSelected: _onNavigationSelected,
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loadingAccounts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_loadError!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAccounts,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_accounts.isEmpty) {
      return const Center(
        child: Text(
          'No tienes cuentas disponibles para pagar',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    if (_newBalance != null) {
      return _buildSuccess();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Qué quieres pagar?',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 14),

          _buildServiceGrid(),

          if (_selectedService != null) ...[
            const SizedBox(height: 20),
            _buildPaymentCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceGrid() {
    return Column(
      children: [
        for (int i = 0; i < _billOptions.length; i += 2)
          Padding(
            padding: EdgeInsets.only(
              bottom: i + 2 < _billOptions.length ? 12 : 0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ServiceCard(
                    service: _billOptions[i],
                    isSelected: _selectedService == _billOptions[i],
                    onTap: () => _selectService(_billOptions[i]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: i + 1 < _billOptions.length
                      ? _ServiceCard(
                          service: _billOptions[i + 1],
                          isSelected:
                              _selectedService == _billOptions[i + 1],
                          onTap: () => _selectService(_billOptions[i + 1]),
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pagando ${_selectedService!.name}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'CUENTA DE ORIGEN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.4,
            ),
          ),

          const SizedBox(height: 8),

          RadioGroup<String>(
            groupValue: _selectedAccountId,
            onChanged: (value) {
              if (_isPaying) return;
              setState(() => _selectedAccountId = value);
            },
            child: Column(
              children: [
                for (int i = 0; i < _accounts.length; i++) ...[
                  _buildAccountRow(_accounts[i]),
                  if (i < _accounts.length - 1)
                    const Divider(height: 1, color: Color(0xFFEEF0F4)),
                ],
              ],
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'MONTO A PAGAR',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.4,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _amountController,
            enabled: !_isPaying,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            onChanged: (_) => setState(() => _amountTouched = true),
            style: const TextStyle(fontSize: 15, color: AppColors.text),
            decoration: InputDecoration(
              hintText: 'Ej: 25',
              prefixText: r'$ ',
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 1.6,
                ),
              ),
            ),
          ),

          if (_amountTouched && _amountError != null) ...[
            const SizedBox(height: 6),
            Text(
              _amountError!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],

          if (_payError != null) ...[
            const SizedBox(height: 12),
            Text(
              _payError!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: _isPaying ? null : _onPayPressed,
              child: _isPaying
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Pagar',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountRow(AccountModel account) {
    final isSelected = account.id == _selectedAccountId;

    return RadioListTile<String>(
      value: account.id,
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.primary,
      tileColor: isSelected ? AppColors.background : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Text(
        account.accountType,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: AppColors.text,
        ),
      ),
      subtitle: Text(
        '${account.accountNumber} • \$${account.balance.toStringAsFixed(2)}',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              '¡Pago de ${_selectedService?.name ?? ''} realizado!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Nuevo saldo: \$${_newBalance!.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
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
                onPressed: _onDonePressed,
                child: const Text(
                  'Listo',
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
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final _BillOption service;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
    required this.isSelected,
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
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  service.icon,
                  color: isSelected ? Colors.white : AppColors.primary,
                  size: 18,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                service.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? AppColors.primary : AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
