import '../../../expenses/domain/entities/expense.dart';

enum FinancialAccountType { bankAccount, card, cashWallet }

class FinancialAccount {
  const FinancialAccount({
    required this.id,
    required this.nickname,
    required this.institution,
    required this.type,
    required this.balanceLkr,
    required this.paymentMethod,
  });

  final String id;
  final String nickname;

  /// For safety, we treat this as a display label only (no API integration).
  final String institution;

  final FinancialAccountType type;
  final int balanceLkr;

  /// Links account/card to expense tagging.
  final PaymentMethod paymentMethod;

  FinancialAccount copyWith({
    String? nickname,
    String? institution,
    FinancialAccountType? type,
    int? balanceLkr,
    PaymentMethod? paymentMethod,
  }) {
    return FinancialAccount(
      id: id,
      nickname: nickname ?? this.nickname,
      institution: institution ?? this.institution,
      type: type ?? this.type,
      balanceLkr: balanceLkr ?? this.balanceLkr,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
