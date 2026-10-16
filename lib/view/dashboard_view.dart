import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';

import '../model/account_model.dart';
import '../model/transaction_model.dart';

import '../service/account_service.dart';
import '../service/policy_service.dart';
import '../viewModel/dashboard_view_model.dart';

import '../widget/account_card.dart';
import '../widget/balance_summary_card.dart';
import '../widget/dashboard_bottom_nav.dart';
import '../widget/dashboard_header.dart';
import '../widget/policy_account_card.dart';
import '../widget/transaction_tile.dart';

import 'movements_view.dart';
import 'transaction_detail_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final DashboardViewModel _viewModel;

  String? _selectedAccountId;
  bool _showBalance = true;

  // ==========================================
  // USUARIO AUTENTICADO
  // ==========================================

  String? get _currentUserId => Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();

    _viewModel = DashboardViewModel(AccountService(), PolicyService());

    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final userId = _currentUserId;

    if (userId == null) {
      return;
    }

    await _viewModel.loadDashboard(userId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  // ==========================================
  // CUENTA SELECCIONADA
  // ==========================================

  AccountModel? _getSelectedAccount() {
    if (_viewModel.accounts.isEmpty) {
      return null;
    }

    for (final account in _viewModel.accounts) {
      if (account.id == _selectedAccountId) {
        return account;
      }
    }

    return _viewModel.accounts.first;
  }

  void _selectAccount(String accountId) {
    setState(() {
      _selectedAccountId = accountId;
    });
  }

  // ==========================================
  // VISIBILIDAD DE SALDOS
  // ==========================================

  void _toggleBalanceVisibility() {
    setState(() {
      _showBalance = !_showBalance;
    });
  }

  // ==========================================
  // BUSCAR CUENTA POR ID
  // ==========================================

  AccountModel? _getAccountById(String accountId) {
    for (final account in _viewModel.accounts) {
      if (account.id == accountId) {
        return account;
      }
    }

    return null;
  }

  // ==========================================
  // ABRIR MOVIMIENTOS
  // ==========================================

  void _openMovements() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MovementsView(
          transactions: _viewModel.transactions,
          accounts: _viewModel.accounts,
        ),
      ),
    );
  }

  // ==========================================
  // DETALLE DE TRANSACCIÓN
  // ==========================================

  void _openTransactionDetail(TransactionModel transaction) {
    final transactionAccount = _getAccountById(transaction.accountId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailView(
          transaction: transaction,
          account: transactionAccount,
        ),
      ),
    );
  }

  // ==========================================
  // FUNCIONALIDADES PRÓXIMAS
  // ==========================================

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature estará disponible próximamente')),
    );
  }

  // ==========================================
  // PANTALLA
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: 0,
        onItemSelected: (index) {
          if (index == 0) {
            return;
          }

          if (index == 1) {
            _openMovements();
            return;
          }

          if (index == 2) {
            _showComingSoon('Pagos');
            return;
          }

          if (index == 3) {
            Navigator.pushNamed(context, AppRoutes.profile);
            return;
          }
        },
      ),

      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            // ==========================================
            // CARGANDO
            // ==========================================

            if (_viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // ==========================================
            // SESIÓN NO DISPONIBLE
            // ==========================================

            if (_currentUserId == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Debes iniciar sesión para continuar'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                        );
                      },
                      child: const Text('Ir al inicio de sesión'),
                    ),
                  ],
                ),
              );
            }

            // ==========================================
            // ERROR DE CARGA
            // ==========================================

            if (_viewModel.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _viewModel.errorMessage!,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDashboard,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ==========================================
            // PERFIL REAL
            // ==========================================

            final currentUser = _viewModel.user;

            if (currentUser == null) {
              return Center(
                child: ElevatedButton(
                  onPressed: _loadDashboard,
                  child: const Text('Cargar Dashboard'),
                ),
              );
            }

            final selectedAccount = _getSelectedAccount();

            return RefreshIndicator(
              onRefresh: _loadDashboard,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // ==========================================
                  // ENCABEZADO
                  // ==========================================

                  DashboardHeader(
                    user: currentUser,
                    avatarUrl: _viewModel.avatarUrl,
                  ),

                  const SizedBox(height: 24),

                  // ==========================================
                  // MIS CUENTAS
                  // ==========================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mis cuentas',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          'Toca una tarjeta para ver sus detalles',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ==========================================
                  // TARJETAS BANCARIAS Y PÓLIZAS
                  // ==========================================
                  if (_viewModel.accounts.isEmpty &&
                      _viewModel.policies.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Center(
                        child: Text(
                          'No tienes cuentas registradas',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 215,
                      child: ListView.separated(
                        clipBehavior: Clip.none,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        itemCount: _viewModel.accounts.length +
                            _viewModel.policies.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(width: 14);
                        },
                        itemBuilder: (context, index) {
                          if (index < _viewModel.accounts.length) {
                            final account = _viewModel.accounts[index];

                            final isSelected =
                                selectedAccount?.id == account.id;

                            return SizedBox(
                              width: 315,
                              child: AccountCard(
                                key: ValueKey(account.id),
                                account: account,
                                isSelected: isSelected,
                                showBalance: _showBalance,
                                userEmail: currentUser.email,
                                userIdentification:
                                    currentUser.identification,
                                onTap: () {
                                  _selectAccount(account.id);
                                },
                              ),
                            );
                          }

                          final policy = _viewModel.policies[
                              index - _viewModel.accounts.length];

                          return SizedBox(
                            width: 315,
                            child: PolicyAccountCard(
                              key: ValueKey(policy.id),
                              policy: policy,
                              showBalance: _showBalance,
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 24),

                  // ==========================================
                  // SALDO TOTAL
                  // ==========================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: BalanceSummaryCard(
                      totalBalance: _viewModel.totalBalance,
                      accountCount: _viewModel.accounts.length,
                      showBalance: _showBalance,
                      onToggleBalance: _toggleBalanceVisibility,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==========================================
                  // ÚLTIMOS MOVIMIENTOS
                  // ==========================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Últimos movimientos',
                                style: TextStyle(
                                  color: AppColors.text,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            TextButton(
                              onPressed: _openMovements,
                              child: const Text(
                                'Ver todo',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        if (_viewModel.transactions.isEmpty)
                          const Text('No tienes movimientos recientes')
                        else
                          ..._viewModel.transactions.map((transaction) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    _openTransactionDetail(transaction);
                                  },
                                  child: TransactionTile(
                                    transaction: transaction,
                                  ),
                                ),
                              ),
                            );
                          }),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
