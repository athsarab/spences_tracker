import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/financial_account.dart';
import 'financial_account_repository_provider.dart';

class BankAccountsState {
  const BankAccountsState({required this.accounts, required this.isLoading});

  final List<FinancialAccount> accounts;
  final bool isLoading;

  BankAccountsState copyWith({
    List<FinancialAccount>? accounts,
    bool? isLoading,
  }) {
    return BankAccountsState(
      accounts: accounts ?? this.accounts,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  static const initial = BankAccountsState(
    accounts: <FinancialAccount>[],
    isLoading: true,
  );
}

final bankAccountsControllerProvider =
    NotifierProvider<BankAccountsController, BankAccountsState>(
      BankAccountsController.new,
    );

class BankAccountsController extends Notifier<BankAccountsState> {
  @override
  BankAccountsState build() {
    state = BankAccountsState.initial;
    _load();
    return state;
  }

  Future<void> _load() async {
    final repo = ref.read(financialAccountRepositoryProvider);
    final accounts = await repo.listAccounts();
    state = state.copyWith(accounts: accounts, isLoading: false);
  }

  Future<void> updateBalance(String id, int newBalanceLkr) async {
    final repo = ref.read(financialAccountRepositoryProvider);
    await repo.updateBalance(id, newBalanceLkr);
    await _load();
  }
}
