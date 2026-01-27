import '../entities/financial_account.dart';

abstract class FinancialAccountRepository {
  Future<List<FinancialAccount>> listAccounts();
  Future<void> upsertAccount(FinancialAccount account);
  Future<void> updateBalance(String id, int newBalanceLkr);
}
