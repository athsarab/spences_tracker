import '../../domain/entities/financial_account.dart';
import '../../domain/repositories/financial_account_repository.dart';
import '../../../expenses/domain/entities/expense.dart';

class InMemoryFinancialAccountRepository implements FinancialAccountRepository {
  final List<FinancialAccount> _accounts = <FinancialAccount>[
    const FinancialAccount(
      id: 'acc_cash',
      nickname: 'Wallet',
      institution: 'Cash',
      type: FinancialAccountType.cashWallet,
      balanceLkr: 4200,
      paymentMethod: PaymentMethod.cash,
    ),
    const FinancialAccount(
      id: 'acc_bank',
      nickname: 'Daily account',
      institution: 'Bank',
      type: FinancialAccountType.bankAccount,
      balanceLkr: 18500,
      paymentMethod: PaymentMethod.bank,
    ),
    const FinancialAccount(
      id: 'acc_card',
      nickname: 'Main card',
      institution: 'Card',
      type: FinancialAccountType.card,
      balanceLkr: 9200,
      paymentMethod: PaymentMethod.card,
    ),
  ];

  @override
  Future<List<FinancialAccount>> listAccounts() async =>
      List.unmodifiable(_accounts);

  @override
  Future<void> upsertAccount(FinancialAccount account) async {
    final i = _accounts.indexWhere((a) => a.id == account.id);
    if (i == -1) {
      _accounts.insert(0, account);
      return;
    }
    _accounts[i] = account;
  }

  @override
  Future<void> updateBalance(String id, int newBalanceLkr) async {
    final i = _accounts.indexWhere((a) => a.id == id);
    if (i == -1) return;
    _accounts[i] = _accounts[i].copyWith(balanceLkr: newBalanceLkr);
  }
}
