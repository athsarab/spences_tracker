import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/formatters/lkr_format.dart';
import '../../domain/entities/expense.dart';
import '../providers/dashboard_controller.dart';
import '../widgets/glass_card.dart';
import '../widgets/metric_tile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon.')),
              );
            },
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            children: [
              _HeroBudgetCard(state: state),
              const SizedBox(height: 16),
              _MonthlyCard(state: state),
              const SizedBox(height: 16),
              _RecentExpensesCard(state: state),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickAdd(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add expense'),
      ),
    );
  }

  Future<void> _showQuickAdd(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _QuickAddSheet(),
    );
  }
}

class _HeroBudgetCard extends StatelessWidget {
  const _HeroBudgetCard({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = state.todayRemainingLkr;

    final color = remaining >= 0 ? AppColors.savings : AppColors.overspend;
    final headline = remaining >= 0 ? 'Left for today' : 'Over today';

    // Why this design:
    // - Big number first = faster daily logging and less mental load.
    // - No guilt language; just neutral status + color.
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headline,
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.70),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.98, end: 1).animate(anim),
                child: child,
              ),
            ),
            child: Text(
              LkrFormat.money(remaining.abs()),
              key: ValueKey<int>(remaining),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1.2,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: state.plan.dailyBudgetLkr <= 0
                      ? 0
                      : (state.todaySpentLkr / state.plan.dailyBudgetLkr).clamp(0, 1),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(999),
                  backgroundColor: Colors.white.withValues(alpha: 0.10),
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${LkrFormat.money(state.todaySpentLkr)} spent',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthlyCard extends StatelessWidget {
  const _MonthlyCard({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final remaining = state.monthRemainingLkr;

    final monthColor = remaining >= 0 ? AppColors.neutral : AppColors.overspend;

    return GlassCard(
      child: Column(
        children: [
          MetricTile(
            label: 'This month',
            value: LkrFormat.money(state.monthSpentLkr),
            color: monthColor,
            subLabel: '${LkrFormat.money(remaining.abs())} ${remaining >= 0 ? 'left' : 'over'}',
            trailing: Text(
              '${(state.monthBudgetProgress * 100).round()}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: state.monthBudgetProgress,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(999),
                  backgroundColor: Colors.white.withValues(alpha: 0.10),
                  color: monthColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Budget ${LkrFormat.money(state.plan.monthlyBudgetLkr)}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.62)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Pill(
                  label: 'Savings target',
                  value: '${(state.savingsProgress * 100).round()}%',
                  color: AppColors.savings,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Pill(
                  label: 'Recurring',
                  value: '${state.recurringPayments.where((p) => p.isActive).length}',
                  color: AppColors.neutral,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 12),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: Colors.white.withValues(alpha: 0.70)),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentExpensesCard extends StatelessWidget {
  const _RecentExpensesCard({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final items = state.expenses.take(6).toList(growable: false);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          if (state.isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: LinearProgressIndicator(
                minHeight: 8,
                borderRadius: BorderRadius.circular(999),
              ),
            )
          else if (items.isEmpty)
            Text(
              'No expenses yet. Add one — quick and guilt-free.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.68)),
            )
          else
            ...items.map((e) => _ExpenseRow(expense: e)),
        ],
      ),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = switch (expense.category) {
      ExpenseCategory.food => Icons.restaurant_rounded,
      ExpenseCategory.transport => Icons.directions_bus_rounded,
      ExpenseCategory.bills => Icons.receipt_long_rounded,
      ExpenseCategory.shopping => Icons.shopping_bag_rounded,
      ExpenseCategory.other => Icons.more_horiz_rounded,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _label(expense.category),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (expense.note != null && expense.note!.trim().isNotEmpty)
                  Text(
                    expense.note!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.60),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            LkrFormat.money(expense.amountLkr),
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  static String _label(ExpenseCategory c) => switch (c) {
        ExpenseCategory.food => 'Food',
        ExpenseCategory.transport => 'Transport',
        ExpenseCategory.bills => 'Bills',
        ExpenseCategory.shopping => 'Shopping',
        ExpenseCategory.other => 'Other',
      };
}

class _QuickAddSheet extends ConsumerStatefulWidget {
  const _QuickAddSheet();

  @override
  ConsumerState<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<_QuickAddSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  ExpenseCategory _category = ExpenseCategory.food;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    // Why bottom sheet:
    // - Keeps “add expense” one-tap away (core goal: speed).
    // - Modal focus reduces cognitive load and prevents clutter on main screen.
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottom),
      child: GlassCard(
        borderRadius: 28,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Add expense',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
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
            const SizedBox(height: 6),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Amount (LKR)',
                prefixIcon: Icon(Icons.currency_exchange_rounded),
              ),
            ),
            const SizedBox(height: 10),
            _CategoryChips(
              value: _category,
              onChanged: (c) => setState(() => _category = c),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _onSave,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    final raw = _amountController.text.trim();
    final amount = int.tryParse(raw);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount.')),
      );
      return;
    }

    await ref.read(dashboardControllerProvider.notifier).addExpense(
          amountLkr: amount,
          category: _category,
          paymentMethod: PaymentMethod.cash,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        );

    if (mounted) Navigator.of(context).pop();
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.value, required this.onChanged});

  final ExpenseCategory value;
  final ValueChanged<ExpenseCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <(ExpenseCategory, String, IconData)>[
      (ExpenseCategory.food, 'Food', Icons.restaurant_rounded),
      (ExpenseCategory.transport, 'Transport', Icons.directions_bus_rounded),
      (ExpenseCategory.bills, 'Bills', Icons.receipt_long_rounded),
      (ExpenseCategory.shopping, 'Shopping', Icons.shopping_bag_rounded),
      (ExpenseCategory.other, 'Other', Icons.more_horiz_rounded),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          ChoiceChip(
            selected: value == item.$1,
            onSelected: (_) => onChanged(item.$1),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.$3, size: 16),
                const SizedBox(width: 6),
                Text(item.$2),
              ],
            ),
          ),
      ],
    );
  }
}
