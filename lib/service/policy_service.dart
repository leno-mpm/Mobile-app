
import '../mock/mock_policies.dart';
import '../model/policy_model.dart';

class PolicyService {
  Future<List<PolicyModel>> getPoliciesByUser(
      String userId,
      ) async {
    return MockPolicies.policies
        .where((policy) => policy.userId == userId)
        .toList();
  }
}
