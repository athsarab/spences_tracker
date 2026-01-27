class RecurringPayment {
  const RecurringPayment({
    required this.id,
    required this.title,
    required this.amountLkr,
    required this.dayOfMonth,
    this.autoDeductEnabled = false,
    this.isActive = true,
  });

  final String id;
  final String title;
  final int amountLkr;

  /// 1..28 recommended for simplicity.
  final int dayOfMonth;

  /// When enabled, we *simulate* an auto-deduction (no bank integration).
  /// UX reason: it reduces anxiety by making recurring expenses predictable.
  final bool autoDeductEnabled;

  final bool isActive;

  RecurringPayment copyWith({
    String? title,
    int? amountLkr,
    int? dayOfMonth,
    bool? autoDeductEnabled,
    bool? isActive,
  }) {
    return RecurringPayment(
      id: id,
      title: title ?? this.title,
      amountLkr: amountLkr ?? this.amountLkr,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      autoDeductEnabled: autoDeductEnabled ?? this.autoDeductEnabled,
      isActive: isActive ?? this.isActive,
    );
  }
}
