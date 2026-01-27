import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/formatters/lkr_format.dart';
import '../../../../core/widgets/animated_progress.dart';
import '../../../../core/widgets/app_page_route.dart';
import '../../../../core/widgets/micro_fab.dart';
import '../../../accounts/presentation/screens/bank_accounts_screen.dart';
import '../../../savings/presentation/screens/savings_targets_screen.dart';
import '../../domain/entities/recurring_payment.dart';
import '../providers/dashboard_controller.dart';
import 'add_expense_screen.dart';
import 'recurring_payments_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Spences'),
        actions: [
          IconButton(
            tooltip: 'Recurring payments',
            onPressed: () {
              Navigator.of(context).push(
                AppPageRoute<void>(
                  builder: (_) => const RecurringPaymentsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.calendar_month_rounded),
          ),
          IconButton(
            tooltip: 'Accounts',
            onPressed: () {
              Navigator.of(context).push(
                AppPageRoute<void>(builder: (_) => const BankAccountsScreen()),
              );
            },
            icon: const Icon(Icons.account_balance_wallet_rounded),
          ),
          IconButton(
            tooltip: 'Savings targets',
            onPressed: () {
              Navigator.of(context).push(
                AppPageRoute<void>(
                  builder: (_) => const SavingsTargetsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.savings_rounded),
          ),
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
              _TopSummaryCard(state: state),
              const SizedBox(height: 14),
              _DailyBudgetCard(state: state),
              const SizedBox(height: 14),
              _SavingsPreviewCard(state: state),
              const SizedBox(height: 14),
              _UpcomingRecurringCard(state: state),
            ],
          ),
        ),
      ),
      floatingActionButton: MicroFab(
        icon: Icons.add_rounded,
        label: 'Add Expense',
        onPressed: () {
          Navigator.of(
            context,
          ).push(AppPageRoute<void>(builder: (_) => const AddExpenseScreen()));
        },
      ),
    );
  }
}

class _TopSummaryCard extends StatefulWidget {
  const _TopSummaryCard({required this.state});

  final DashboardState state;

  @override
  State<_TopSummaryCard> createState() => _TopSummaryCardState();
}

class _TopSummaryCardState extends State<_TopSummaryCard> {
  bool _flip = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final income = widget.state.monthlyIncomeLkr;
    final balance = widget.state.remainingBalanceLkr;

    final balanceColor = balance >= 0 ? AppColors.savings : AppColors.overspend;

    // Why this design:
    // - Income + remaining balance is the fastest mental model for students.
    // - A slow animated gradient adds warmth without visual noise.
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: _flip ? 1 : 0),
      duration: const Duration(seconds: 8),
      curve: Curves.easeInOut,
      onEnd: () => setState(() => _flip = !_flip),
      builder: (context, t, _) {
        final begin = Alignment.lerp(Alignment.topLeft, Alignment.topRight, t)!;
        final end = Alignment.lerp(
          Alignment.bottomRight,
          Alignment.bottomLeft,
          t,
        )!;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              begin: begin,
              end: end,
              colors: [
                const Color(0xFF203A7A).withValues(alpha: 0.55),
                const Color(0xFF1E6B5C).withValues(alpha: 0.35),
                const Color(0xFF101B34).withValues(alpha: 0.75),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.30),
                blurRadius: 22,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This month',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.70),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      label: 'Income',
                      value: LkrFormat.money(income),
                      color: AppColors.neutral,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniStat(
                      label: 'Balance',
                      value: LkrFormat.money(balance.abs()),
                      color: balanceColor,
                      prefix: balance < 0 ? '-' : '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'No guilt—just clarity.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.62),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
    this.prefix,
  });

  final String label;
  final String value;
  final Color color;
  final String? prefix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.30),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${prefix ?? ''}$value',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyBudgetCard extends StatelessWidget {
  const _DailyBudgetCard({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final allowed = max(0, state.plan.dailyBudgetLkr);
    final spent = max(0, state.todaySpentLkr);
    final double progress = allowed <= 0
        ? 0.0
        : (spent / allowed).clamp(0.0, 1.0).toDouble();
    final remaining = state.todayRemainingLkr;

    final color = remaining >= 0 ? AppColors.neutral : AppColors.overspend;

    // Why this design:
    // - Daily budget is the core habit loop.
    // - The progress bar gives instant feedback without judgment.
    return _RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily budget',
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  LkrFormat.money(allowed),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
              Text(
                '${LkrFormat.money(remaining.abs())} ${remaining >= 0 ? 'left' : 'over'}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedLinearProgress(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.white.withValues(alpha: 0.10),
            color: color,
          ),
        ],
      ),
    );
  }
}

class _SavingsPreviewCard extends StatelessWidget {
  const _SavingsPreviewCard({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // We’re reusing the same “potential savings” proxy from DashboardState.
    final progress = state.savingsProgress;

    // Why this design:
    // - Green/blue tones encourage without guilt.
    // - A circle feels like a gentle “you’re on track” cue.
    return _RoundedCard(
      child: Row(
        children: [
          AnimatedCircularProgress(
            value: progress,
            size: 62,
            strokeWidth: 9,
            backgroundColor: Colors.white.withValues(alpha: 0.10),
            color: Color.lerp(AppColors.neutral, AppColors.savings, progress),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.plan.savingsTargetName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).round()}% of target',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Even LKR 100/day adds up.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white),
        ],
      ),
    );
  }
}

class _UpcomingRecurringCard extends StatelessWidget {
  const _UpcomingRecurringCard({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final upcoming = _nextRecurring(
      state.recurringPayments,
    ).take(4).toList(growable: false);

    return _RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming payments',
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 10),
          if (upcoming.isEmpty)
            Text(
              'No recurring payments yet.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.62),
              ),
            )
          else
            ...upcoming.map((p) => _RecurringRow(item: p)),
        ],
      ),
    );
  }

  Iterable<_RecurringNext> _nextRecurring(List<RecurringPayment> items) {
    final now = DateTime.now();

    final mapped = items
        .where((p) => p.isActive)
        .map((p) => _RecurringNext(p, _nextDue(now, p.dayOfMonth)))
        .toList(growable: false);

    mapped.sort((a, b) => a.due.compareTo(b.due));
    return mapped;
  }

  DateTime _nextDue(DateTime now, int dayOfMonth) {
    final safeDay = dayOfMonth.clamp(1, 28);
    final thisMonth = DateTime(now.year, now.month, safeDay);
    if (!thisMonth.isBefore(DateTime(now.year, now.month, now.day))) {
      return thisMonth;
    }
    return DateTime(now.year, now.month + 1, safeDay);
  }
}

class _RecurringRow extends StatelessWidget {
  const _RecurringRow({required this.item});

  final _RecurringNext item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final days = item.due
        .difference(
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          ),
        )
        .inDays;
    final dueText = days == 0 ? 'Today' : 'In $days d';

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
            child: Icon(
              Icons.calendar_month_rounded,
              color: Colors.white.withValues(alpha: 0.85),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.payment.title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  dueText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.60),
                  ),
                ),
              ],
            ),
          ),
          Text(
            LkrFormat.money(item.payment.amountLkr),
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundedCard extends StatelessWidget {
  const _RoundedCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RecurringNext {
  const _RecurringNext(this.payment, this.due);

  final RecurringPayment payment;
  final DateTime due;
}
