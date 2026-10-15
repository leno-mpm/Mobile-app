import '../model/transaction_model.dart';

class MockTransactions {
  static final List<TransactionModel> transactions = [
    TransactionModel(
      id: 'tx-001',
      accountId: 'acc-001',
      description: 'Depósito de sueldo',
      amount: 850.00,
      date: DateTime(2026, 10, 12),
      category: 'Ingresos',
      type: 'ingreso',
    ),
    TransactionModel(
      id: 'tx-002',
      accountId: 'acc-001',
      description: 'Compra en supermercado',
      amount: 45.50,
      date: DateTime(2026, 10, 11),
      category: 'Alimentación',
      type: 'egreso',
    ),
    TransactionModel(
      id: 'tx-003',
      accountId: 'acc-001',
      description: 'Pago de internet',
      amount: 35.00,
      date: DateTime(2026, 10, 10),
      category: 'Servicios',
      type: 'egreso',
    ),
    TransactionModel(
      id: 'tx-004',
      accountId: 'acc-002',
      description: 'Transferencia recibida',
      amount: 120.00,
      date: DateTime(2026, 10, 9),
      category: 'Transferencias',
      type: 'ingreso',
    ),
    TransactionModel(
      id: 'tx-005',
      accountId: 'acc-002',
      description: 'Compra en cafetería',
      amount: 6.75,
      date: DateTime(2026, 10, 8),
      category: 'Alimentación',
      type: 'egreso',
    ),
  ];
}
