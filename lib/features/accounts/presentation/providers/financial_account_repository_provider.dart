import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/in_memory_financial_account_repository.dart';
import '../../domain/repositories/financial_account_repository.dart';

final financialAccountRepositoryProvider = Provider<FinancialAccountRepository>((ref) {
  return InMemoryFinancialAccountRepository();
});
