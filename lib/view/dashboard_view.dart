import 'package:flutter/material.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../mock/mock_users.dart';
import '../model/account_model.dart';
import '../model/transaction_model.dart';
import '../model/user_model.dart';
import '../service/account_service.dart';
import '../service/mock_auth_service.dart';
import '../viewModel/dashboard_view_model.dart';
import '../widget/account_card.dart';
import '../widget/dashboard_bottom_nav.dart';
import '../widget/dashboard_header.dart';
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

  UserModel get _currentUser =>
      MockAuthService.currentUser ?? MockUsers.currentUser;

  @override
  void initState() {
    super.initState();

    _viewModel = DashboardViewModel(AccountService());

    _viewModel.loadDashboard(_currentUser.id);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  // Obtener la cuenta seleccionada.
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

  // Seleccionar una cuenta.
  void _selectAccount(String accountId) {
    setState(() {
      _selectedAccountId = accountId;
    });
  }

  // Mostrar u ocultar saldos y números de cuenta.
  void _toggleBalanceVisibility() {
    setState(() {
      _showBalance = !_showBalance;
    });
  }

  // Buscar una cuenta por su ID.
  AccountModel? _getAccountById(String accountId) {
    for (final account in _viewModel.accounts) {
      if (account.id == accountId) {
        return account;
      }
    }

    return null;
  }

  // Cambiar de Inicio a la pestaña Movimientos.
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

  // Abrir el detalle de una transacción.
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

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature estará disponible próximamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: 0,
        onItemSelected: (index) {
          // Inicio
          if (index == 0) {
            return;
          }

          // Movimientos
          if (index == 1) {
            _openMovements();
            return;
          }

          // Pagos
          if (index == 2) {
            _showComingSoon('Pagos');
            return;
          }

          // Perfil
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
            if (_viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_viewModel.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _viewModel.errorMessage!,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final selectedAccount = _getSelectedAccount();

            return RefreshIndicator(
              onRefresh: () {
                return _viewModel.loadDashboard(_currentUser.id);
              },
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // ENCABEZADO
                  DashboardHeader(
                    user: _currentUser,
                    totalBalance: _viewModel.totalBalance,
                    accountCount: _viewModel.accounts.length,
                    showBalance: _showBalance,
                    onToggleBalance: _toggleBalanceVisibility,
                  ),

                  const SizedBox(height: 24),

                  // MIS CUENTAS
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

                  // TARJETAS BANCARIAS
                  if (_viewModel.accounts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('No tienes cuentas registradas'),
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
                        itemCount: _viewModel.accounts.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(width: 14);
                        },
                        itemBuilder: (context, index) {
                          final account = _viewModel.accounts[index];

                          final isSelected = selectedAccount?.id == account.id;

                          return SizedBox(
                            width: 315,
                            child: AccountCard(
                              key: ValueKey(account.id),
                              account: account,
                              isSelected: isSelected,
                              showBalance: _showBalance,
                              onTap: () {
                                _selectAccount(account.id);
                              },
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 24),

                  // ÚLTIMOS MOVIMIENTOS
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
