enum ExpenseCategory {
  food,
  transport,
  bills,
  shopping,
  other,
}

enum PaymentMethod {
  cash,
  bank,
  card,
}

class Expense {
  const Expense({
    required this.id,
    required this.amountLkr,
    required this.category,
    required this.paymentMethod,
    required this.occurredAt,
    this.note,
  });

  final String id;
  final int amountLkr;
  final ExpenseCategory category;
  final PaymentMethod paymentMethod;
  final DateTime occurredAt;
  final String? note;
}
