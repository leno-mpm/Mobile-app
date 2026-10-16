import 'package:flutter/material.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../model/account_model.dart';
import '../model/transaction_model.dart';
import '../widget/dashboard_bottom_nav.dart';
import '../widget/transaction_tile.dart';
import 'payments_view.dart';
import 'transaction_detail_view.dart';

class MovementsView extends StatefulWidget {
  final List<TransactionModel> transactions;
  final List<AccountModel> accounts;

  const MovementsView({
    super.key,
    required this.transactions,
    required this.accounts,
  });

  @override
  State<MovementsView> createState() => _MovementsViewState();
}

class _MovementsViewState extends State<MovementsView> {
  String _selectedFilter = 'Todos';

  AccountModel? _getAccountById(String accountId) {
    for (final account in widget.accounts) {
      if (account.id == accountId) {
        return account;
      }
    }

    return null;
  }

  // Determina si un movimiento es ingreso.
  // Se utiliza el tipo de transacción, sin depender de mayúsculas.
  bool _isIncome(TransactionModel transaction) {
    final type = transaction.type.trim().toLowerCase();

    return type == 'ingreso' ||
        type == 'income' ||
        type == 'credit' ||
        type == 'credito' ||
        type == 'crédito';
  }

  // Determina si un movimiento es gasto.
  bool _isExpense(TransactionModel transaction) {
    final type = transaction.type.trim().toLowerCase();

    return type == 'egreso' ||
        type == 'gasto' ||
        type == 'expense' ||
        type == 'debit' ||
        type == 'debito' ||
        type == 'débito';
  }

  List<TransactionModel> get _filteredTransactions {
    final transactions = widget.transactions.where((transaction) {
      if (_selectedFilter == 'Todos') {
        return true;
      }

      if (_selectedFilter == 'Ingresos') {
        return _isIncome(transaction);
      }

      if (_selectedFilter == 'Gastos') {
        return _isExpense(transaction);
      }

      return true;
    }).toList();

    transactions.sort((a, b) => b.date.compareTo(a.date));

    return transactions;
  }

  // Navegación entre las pestañas principales.
  void _onNavigationSelected(int index) {
    if (index == 1) {
      return;
    }

    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.dashboard,
        (route) => false,
      );
      return;
    }

    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PaymentsView()),
      );
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

  Widget _filterChip(String label) {
    final selected = _selectedFilter == label;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = label;
        });
      },
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.text,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: selected ? AppColors.primary : const Color(0xFFDDE3EB),
      ),
      showCheckmark: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  void _openTransactionDetail(TransactionModel transaction) {
    final account = _getAccountById(transaction.accountId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TransactionDetailView(transaction: transaction, account: account),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _filteredTransactions;

    return Scaffold(
      backgroundColor: AppColors.background,

      // La barra inferior siempre estará visible.
      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: 1,
        onItemSelected: _onNavigationSelected,
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
          children: [
            // Título sin flecha de regreso.
            const Center(
              child: Text(
                'Mis movimientos',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Historial de transacciones',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Consulta los movimientos de tus cuentas.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),

            const SizedBox(height: 22),

            // FILTROS
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _filterChip('Todos'),
                _filterChip('Ingresos'),
                _filterChip('Gastos'),
              ],
            ),

            const SizedBox(height: 22),

            Text(
              '${transactions.length} '
              '${transactions.length == 1 ? 'movimiento' : 'movimientos'}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 14),

            // LISTADO DE MOVIMIENTOS
            if (transactions.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 45,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      color: AppColors.textSecondary,
                      size: 46,
                    ),

                    SizedBox(height: 14),

                    Text(
                      'No hay movimientos',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      'No encontramos transacciones '
                      'para este filtro.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...transactions.map((transaction) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        _openTransactionDetail(transaction);
                      },
                      child: TransactionTile(transaction: transaction),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
