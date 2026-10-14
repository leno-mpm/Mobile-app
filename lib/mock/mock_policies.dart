
import '../model/policy_model.dart';

class MockPolicies {
  static final List<PolicyModel> policies = [
    PolicyModel(
      id: 'policy-001',
      userId: 'user-001',
      policyNumber: 'POL-2026-001',
      amount: 3000.00,
      annualInterestRate: 5.50,
      termDays: 180,
      startDate: DateTime(2026, 10, 1),
      endDate: DateTime(2027, 3, 30),
      currency: 'USD',
      status: 'Activa',
    ),
    PolicyModel(
      id: 'policy-002',
      userId: 'user-001',
      policyNumber: 'POL-2026-002',
      amount: 2000.00,
      annualInterestRate: 4.75,
      termDays: 90,
      startDate: DateTime(2026, 10, 17),
      endDate: DateTime(2027, 1, 15),
      currency: 'USD',
      status: 'Activa',
    ),
  ];
}
