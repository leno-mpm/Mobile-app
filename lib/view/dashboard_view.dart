import 'package:flutter/material.dart';

import '../widget/dashboard_bottom_nav.dart';
import '../core/theme/app_colors.dart';
import '../mock/mock_users.dart';
import '../model/account_model.dart';
import '../service/account_service.dart';
import '../viewModel/dashboard_view_model.dart';
import '../widget/account_card.dart';
import '../widget/dashboard_header.dart';
import '../widget/transaction_tile.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final DashboardViewModel _viewModel;

  // Identificador de la cuenta seleccionada
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();

    _viewModel = DashboardViewModel(AccountService());

    _viewModel.loadDashboard(MockUsers.currentUser.id);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  // Obtener la cuenta seleccionada
  AccountModel? _getSelectedAccount() {
    if (_viewModel.accounts.isEmpty) {
      return null;
    }

    for (final account in _viewModel.accounts) {
      if (account.id == _selectedAccountId) {
        return account;
      }
    }

    // Si no hay selección, usar la primera cuenta
    return _viewModel.accounts.first;
  }

  // Cambiar la cuenta seleccionada
  void _selectAccount(String accountId) {
    setState(() {
      _selectedAccountId = accountId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // Barra de navegación inferior
      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: 0,
        onItemSelected: (index) {
          if (index == 0) {
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Esta sección estará disponible próximamente'),
            ),
          );
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
              onRefresh: () =>
                  _viewModel.loadDashboard(MockUsers.currentUser.id),

              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Encabezado azul
                  if (selectedAccount != null)
                    DashboardHeader(
                      user: MockUsers.currentUser,
                      account: selectedAccount,
                      totalBalance: _viewModel.totalBalance,
                      accountCount: _viewModel.accounts.length,
                    ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sección de cuentas
                        Row(
                          children: [
                            const Text(
                              'Mis cuentas',
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const Spacer(),

                            const Flexible(
                              child: Text(
                                'Toca una para operar con ella',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Cuentas en horizontal
                        if (_viewModel.accounts.isEmpty)
                          const Text('No tienes cuentas registradas')
                        else
                          SizedBox(
                            height: 108,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _viewModel.accounts.length,
                              separatorBuilder: (context, index) {
                                return const SizedBox(width: 12);
                              },
                              itemBuilder: (context, index) {
                                final account = _viewModel.accounts[index];

                                final isSelected =
                                    selectedAccount?.id == account.id;

                                return SizedBox(
                                  width: 170,
                                  child: AccountCard(
                                    account: account,
                                    isSelected: isSelected,
                                    onTap: () {
                                      _selectAccount(account.id);
                                    },
                                  ),
                                );
                              },
                            ),
                          ),

                        const SizedBox(height: 28),

                        // Encabezado de movimientos
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
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'La pantalla de movimientos '
                                      'se implementará próximamente',
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Ver todo'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Movimientos bancarios
                        if (_viewModel.transactions.isEmpty)
                          const Text('No tienes movimientos recientes')
                        else
                          ..._viewModel.transactions.map(
                            (transaction) =>
                                TransactionTile(transaction: transaction),
                          ),

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
