class BudgetPlan {
  const BudgetPlan({
    required this.monthlyIncomeLkr,
    required this.dailyBudgetLkr,
    required this.monthlyBudgetLkr,
    required this.monthlySavingsTargetLkr,
    this.savingsTargetName = 'Emergency fund',
  });

  /// Monthly income/allowance/salary used for “remaining balance”.
  /// We keep it explicit (instead of inferring from budget) because many Sri
  /// Lankan students have variable allowances and want a simple mental model.
  final int monthlyIncomeLkr;

  final int dailyBudgetLkr;
  final int monthlyBudgetLkr;
  final int monthlySavingsTargetLkr;

  final String savingsTargetName;
}
