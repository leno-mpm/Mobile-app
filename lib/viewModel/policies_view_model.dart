import 'package:flutter/material.dart';

import '../model/policy_model.dart';
import '../service/policy_service.dart';

class PoliciesViewModel extends ChangeNotifier {
  final PolicyService _policyService;

  PoliciesViewModel(this._policyService);

  List<PolicyModel> _policies = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PolicyModel> get policies => List.unmodifiable(_policies);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  int get policyCount => _policies.length;

  double get totalInvested {
    return _policies.fold<double>(
      0.0,
      (total, policy) => total + policy.amount,
    );
  }

  Future<void> loadPolicies(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _policies = await _policyService.getPoliciesByUser(userId);
    } catch (e) {
      _errorMessage = 'No se pudieron cargar las pólizas';
      _policies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
