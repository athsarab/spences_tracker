class SavingsTarget {
  const SavingsTarget({
    required this.id,
    required this.name,
    required this.targetAmountLkr,
    required this.currentAmountLkr,
    required this.isPaused,
  });

  final String id;
  final String name;
  final int targetAmountLkr;
  final int currentAmountLkr;
  final bool isPaused;

  double get progress {
    if (targetAmountLkr <= 0) return 0;
    return (currentAmountLkr / targetAmountLkr).clamp(0.0, 1.0).toDouble();
  }

  SavingsTarget copyWith({
    String? name,
    int? targetAmountLkr,
    int? currentAmountLkr,
    bool? isPaused,
  }) {
    return SavingsTarget(
      id: id,
      name: name ?? this.name,
      targetAmountLkr: targetAmountLkr ?? this.targetAmountLkr,
      currentAmountLkr: currentAmountLkr ?? this.currentAmountLkr,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}
