import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/formatters/lkr_format.dart';
import '../../../../core/widgets/hover_tilt.dart';
import '../../domain/entities/financial_account.dart';
import '../providers/bank_accounts_controller.dart';

class BankAccountsScreen extends ConsumerWidget {
  const BankAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bankAccountsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tag expenses by payment method.',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Balances are simulated (safe) — update manually.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.62),
              ),
            ),
            const SizedBox(height: 14),
            if (state.isLoading)
              const LinearProgressIndicator(minHeight: 8)
            else
              Expanded(
                child: ListView.separated(
                  itemCount: state.accounts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final a = state.accounts[i];
                    return _AccountCard(
                      account: a,
                      onUpdateBalance: () => _showBalanceSheet(context, ref, a),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBalanceSheet(
    BuildContext context,
    WidgetRef ref,
    FinancialAccount a,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BalanceUpdateSheet(account: a),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account, required this.onUpdateBalance});

  final FinancialAccount account;
  final VoidCallback onUpdateBalance;

  @override
  Widget build(BuildContext context) {
    final tone = switch (account.type) {
      FinancialAccountType.cashWallet => AppColors.neutral,
      FinancialAccountType.bankAccount => AppColors.neutral,
      FinancialAccountType.card => AppColors.savings,
    };

    final icon = switch (account.type) {
      FinancialAccountType.cashWallet => Icons.wallet_rounded,
      FinancialAccountType.bankAccount => Icons.account_balance_rounded,
      FinancialAccountType.card => Icons.credit_card_rounded,
    };

    // Why this design:
    // - Card layout feels familiar and quick to scan.
    // - Subtle hover tilt gives “premium” on web/desktop without being flashy.
    return HoverTilt(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              tone.withValues(alpha: 0.16),
              const Color(0xFF101B34).withValues(alpha: 0.92),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.nickname,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                      ),
                      Text(
                        account.institution,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.62),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Text(
                    account.paymentMethod.name.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.70),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Balance',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              LkrFormat.money(account.balanceLkr),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onUpdateBalance,
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceUpdateSheet extends ConsumerStatefulWidget {
  const _BalanceUpdateSheet({required this.account});

  final FinancialAccount account;

  @override
  ConsumerState<_BalanceUpdateSheet> createState() =>
      _BalanceUpdateSheetState();
}

class _BalanceUpdateSheetState extends ConsumerState<_BalanceUpdateSheet> {
  late final TextEditingController _balance;

  @override
  void initState() {
    super.initState();
    _balance = TextEditingController(
      text: widget.account.balanceLkr.toString(),
    );
  }

  @override
  void dispose() {
    _balance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottom),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Update balance',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _balance,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Balance (LKR)',
                prefixIcon: Icon(Icons.currency_exchange_rounded),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: _save, child: const Text('Save')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final value = int.tryParse(_balance.text.trim());
    if (value == null || value < 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid balance.')));
      return;
    }

    await ref
        .read(bankAccountsControllerProvider.notifier)
        .updateBalance(widget.account.id, value);

    if (mounted) Navigator.of(context).pop();
  }
}
