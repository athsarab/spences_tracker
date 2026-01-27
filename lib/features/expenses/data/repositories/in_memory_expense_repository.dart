import 'dart:math';

import '../../domain/entities/budget_plan.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/recurring_payment.dart';
import '../../domain/repositories/expense_repository.dart';

class InMemoryExpenseRepository implements ExpenseRepository {
  BudgetPlan _plan = const BudgetPlan(
    monthlyIncomeLkr: 80000,
    dailyBudgetLkr: 1500,
    monthlyBudgetLkr: 45000,
    monthlySavingsTargetLkr: 10000,
    savingsTargetName: 'Emergency fund',
  );

  final List<Expense> _expenses = <Expense>[];
  final List<RecurringPayment> _recurring = <RecurringPayment>[
    const RecurringPayment(
      id: 'rent',
      title: 'Rent',
      amountLkr: 25000,
      dayOfMonth: 1,
      autoDeductEnabled: true,
    ),
    const RecurringPayment(
      id: 'wifi',
      title: 'Internet',
      amountLkr: 5990,
      dayOfMonth: 6,
      autoDeductEnabled: true,
    ),
    const RecurringPayment(
      id: 'spotify',
      title: 'Music',
      amountLkr: 1090,
      dayOfMonth: 12,
      autoDeductEnabled: false,
    ),
  ];

  @override
  Future<BudgetPlan> getBudgetPlan() async => _plan;

  @override
  Future<void> saveBudgetPlan(BudgetPlan plan) async {
    _plan = plan;
  }

  @override
  Future<List<Expense>> listExpenses() async {
    _seedIfEmpty();
    return List.unmodifiable(_expenses);
  }

  @override
  Future<void> addExpense(Expense expense) async {
    _expenses.insert(0, expense);
  }

  @override
  Future<List<RecurringPayment>> listRecurringPayments() async => _recurring;

  @override
  Future<void> upsertRecurringPayment(RecurringPayment payment) async {
    final i = _recurring.indexWhere((p) => p.id == payment.id);
    if (i == -1) {
      _recurring.insert(0, payment);
      return;
    }
    _recurring[i] = payment;
  }

  @override
  Future<void> setRecurringAutoDeduct(String id, bool enabled) async {
    final i = _recurring.indexWhere((p) => p.id == id);
    if (i == -1) return;
    _recurring[i] = _recurring[i].copyWith(autoDeductEnabled: enabled);
  }

  @override
  Future<void> setRecurringActive(String id, bool active) async {
    final i = _recurring.indexWhere((p) => p.id == id);
    if (i == -1) return;
    _recurring[i] = _recurring[i].copyWith(isActive: active);
  }

  void _seedIfEmpty() {
    if (_expenses.isNotEmpty) return;

    final now = DateTime.now();
    final rng = Random(7);

    int pickAmount(int min, int max) => min + rng.nextInt(max - min + 1);

    _expenses.addAll([
      Expense(
        id: 'e1',
        amountLkr: pickAmount(250, 750),
        category: ExpenseCategory.food,
        paymentMethod: PaymentMethod.cash,
        occurredAt: now.subtract(const Duration(hours: 2)),
        note: 'Snack',
      ),
      Expense(
        id: 'e2',
        amountLkr: pickAmount(200, 600),
        category: ExpenseCategory.transport,
        paymentMethod: PaymentMethod.cash,
        occurredAt: now.subtract(const Duration(hours: 6)),
      ),
      Expense(
        id: 'e3',
        amountLkr: pickAmount(500, 1800),
        category: ExpenseCategory.shopping,
        paymentMethod: PaymentMethod.card,
        occurredAt: DateTime(now.year, now.month, max(1, now.day - 2), 18),
        note: 'Essentials',
      ),
    ]);
  }
}
