import 'package:mobile_app/mock/mock_accounts.dart';
import 'package:mobile_app/mock/mock_transactions.dart';
import 'package:mobile_app/model/account_model.dart';
import 'package:mobile_app/model/transaction_model.dart';

class AccountService {
  //Obtener todas as cuentas de un usuario
  Future<List<AccountModel>> getAccountsByUser(String userId,) async{
    return MockAccounts.accounts
        .where((account) => account.userId == userId)
        .toList();
  }
  
  //Obtener las transacciones de una cuenta
  Future<List<TransactionModel>> getTransactionsByAccount(String accountId,) async{
      return MockTransactions.transactions
          .where((transaction)=> transaction.accountId == accountId)
          .toList();
  }
}