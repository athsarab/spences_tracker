import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/budget_plan.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/recurring_payment.dart';
import 'expense_repository_provider.dart';

class DashboardState {
  const DashboardState({
    required this.plan,
    required this.expenses,
    required this.recurringPayments,
    required this.isLoading,
  });

  final BudgetPlan plan;
  final List<Expense> expenses;
  final List<RecurringPayment> recurringPayments;
  final bool isLoading;

  int get todaySpentLkr {
    final now = DateTime.now();
    return expenses
        .where((e) => _isSameDay(e.occurredAt, now))
        .fold(0, (sum, e) => sum + e.amountLkr);
  }

  int get monthSpentLkr {
    final now = DateTime.now();
    return expenses
        .where((e) => e.occurredAt.year == now.year && e.occurredAt.month == now.month)
        .fold(0, (sum, e) => sum + e.amountLkr);
  }

  int get todayRemainingLkr => plan.dailyBudgetLkr - todaySpentLkr;
  int get monthRemainingLkr => plan.monthlyBudgetLkr - monthSpentLkr;

  int get monthlyIncomeLkr => plan.monthlyIncomeLkr;
  int get remainingBalanceLkr => plan.monthlyIncomeLkr - monthSpentLkr;

  double get monthBudgetProgress {
    if (plan.monthlyBudgetLkr <= 0) return 0;
    return min(1, monthSpentLkr / plan.monthlyBudgetLkr);
  }

  double get savingsProgress {
    // Simple proxy: what’s left in the month budget is “potential savings”.
    final potentialSavings = max(0, plan.monthlyBudgetLkr - monthSpentLkr);
    if (plan.monthlySavingsTargetLkr <= 0) return 0;
    return min(1, potentialSavings / plan.monthlySavingsTargetLkr);
  }

  DashboardState copyWith({
    BudgetPlan? plan,
    List<Expense>? expenses,
    List<RecurringPayment>? recurringPayments,
    bool? isLoading,
  }) {
    return DashboardState(
      plan: plan ?? this.plan,
      expenses: expenses ?? this.expenses,
      recurringPayments: recurringPayments ?? this.recurringPayments,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DashboardState initial() {
    return const DashboardState(
      plan: BudgetPlan(
        monthlyIncomeLkr: 80000,
        dailyBudgetLkr: 1500,
        monthlyBudgetLkr: 45000,
        monthlySavingsTargetLkr: 10000,
        savingsTargetName: 'Emergency fund',
      ),
      expenses: <Expense>[],
      recurringPayments: <RecurringPayment>[],
      isLoading: true,
    );
  }
}

final dashboardControllerProvider =
    NotifierProvider<DashboardController, DashboardState>(DashboardController.new);

class DashboardController extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    state = DashboardState.initial();
    _load();
    return state;
  }

  Future<void> _load() async {
    final repo = ref.read(expenseRepositoryProvider);
    final plan = await repo.getBudgetPlan();
    final expenses = await repo.listExpenses();
    final recurring = await repo.listRecurringPayments();

    state = state.copyWith(
      plan: plan,
      expenses: expenses,
      recurringPayments: recurring,
      isLoading: false,
    );
  }

  Future<void> addExpense({
    required int amountLkr,
    required ExpenseCategory category,
    required PaymentMethod paymentMethod,
    String? note,
  }) async {
    final repo = ref.read(expenseRepositoryProvider);
    final now = DateTime.now();

    final expense = Expense(
      id: 'e_${now.microsecondsSinceEpoch}',
      amountLkr: amountLkr,
      category: category,
      paymentMethod: paymentMethod,
      occurredAt: now,
      note: note,
    );

    await repo.addExpense(expense);
    final updated = await repo.listExpenses();
    state = state.copyWith(expenses: updated);
  }
}
