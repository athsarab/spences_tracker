import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/in_memory_expense_repository.dart';
import '../../domain/repositories/expense_repository.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return InMemoryExpenseRepository();
});
