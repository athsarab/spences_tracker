import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/in_memory_savings_target_repository.dart';
import '../../domain/repositories/savings_target_repository.dart';

final savingsRepositoryProvider = Provider<SavingsTargetRepository>((ref) {
  return InMemorySavingsTargetRepository();
});
