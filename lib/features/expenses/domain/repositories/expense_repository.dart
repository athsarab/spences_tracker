import '../entities/budget_plan.dart';
import '../entities/expense.dart';
import '../entities/recurring_payment.dart';

abstract class ExpenseRepository {
  Future<BudgetPlan> getBudgetPlan();
  Future<void> saveBudgetPlan(BudgetPlan plan);

  Future<List<Expense>> listExpenses();
  Future<void> addExpense(Expense expense);

  Future<List<RecurringPayment>> listRecurringPayments();

  Future<void> upsertRecurringPayment(RecurringPayment payment);
  Future<void> setRecurringAutoDeduct(String id, bool enabled);
  Future<void> setRecurringActive(String id, bool active);
}
