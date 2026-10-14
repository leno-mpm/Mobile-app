
import 'package:flutter/material.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../mock/mock_users.dart';
import '../model/account_model.dart';
import '../service/account_service.dart';
import '../viewModel/dashboard_view_model.dart';
import '../widget/account_card.dart';
import '../widget/dashboard_bottom_nav.dart';
import '../widget/dashboard_header.dart';
import '../widget/transaction_tile.dart';

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

  @override
  void initState() {
    super.initState();

    _viewModel = DashboardViewModel(AccountService());

    _viewModel.loadDashboard(
      MockUsers.currentUser.id,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

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

  void _toggleBalanceVisibility() {
    setState(() {
      _showBalance = !_showBalance;
    });
  }

  AccountModel? _getAccountById(String accountId) {
    for (final account in _viewModel.accounts) {
      if (account.id == accountId) {
        return account;
      }
    }

    return null;
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature estará disponible próximamente',
        ),
      ),
    );
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

          if (index == 3) {
            Navigator.pushNamed(
              context,
              AppRoutes.profile,
            );
            return;
          }

          _showComingSoon(
            index == 1 ? 'Movimientos' : 'Pagos',
          );
        },
      ),

      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            if (_viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
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
                return _viewModel.loadDashboard(
                  MockUsers.currentUser.id,
                );
              },

              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Encabezado: saludo y saldo total
                  DashboardHeader(
                    user: MockUsers.currentUser,
                    totalBalance: _viewModel.totalBalance,
                    accountCount: _viewModel.accounts.length,
                    showBalance: _showBalance,
                    onToggleBalance: _toggleBalanceVisibility,
                  ),

                  const SizedBox(height: 24),

                  // Mis cuentas
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
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

                  // Tarjetas bancarias giratorias
                  if (_viewModel.accounts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Text(
                        'No tienes cuentas registradas',
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

                  // Últimos movimientos
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
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
                              onPressed: () {
                                _showComingSoon(
                                  'Pantalla de movimientos',
                                );
                              },
                              child: const Text('Ver todo'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        if (_viewModel.transactions.isEmpty)
                          const Text(
                            'No tienes movimientos recientes',
                          )
                        else
                          ..._viewModel.transactions.map(
                                (transaction) {
                              final transactionAccount =
                              _getAccountById(
                                transaction.accountId,
                              );

                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 8,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius:
                                    BorderRadius.circular(16),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TransactionDetailView(
                                                transaction: transaction,
                                                account: transactionAccount,
                                              ),
                                        ),
                                      );
                                    },
                                    child: TransactionTile(
                                      transaction: transaction,
                                    ),
                                  ),
                                ),
                              );
                            },
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
