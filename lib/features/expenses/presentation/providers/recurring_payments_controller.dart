import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/recurring_payment.dart';
import 'expense_repository_provider.dart';

class RecurringPaymentsState {
  const RecurringPaymentsState({required this.items, required this.isLoading});

  final List<RecurringPayment> items;
  final bool isLoading;

  RecurringPaymentsState copyWith({
    List<RecurringPayment>? items,
    bool? isLoading,
  }) {
    return RecurringPaymentsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  static const initial = RecurringPaymentsState(
    items: <RecurringPayment>[],
    isLoading: true,
  );
}

final recurringPaymentsControllerProvider =
    NotifierProvider<RecurringPaymentsController, RecurringPaymentsState>(
      RecurringPaymentsController.new,
    );

class RecurringPaymentsController extends Notifier<RecurringPaymentsState> {
  @override
  RecurringPaymentsState build() {
    state = RecurringPaymentsState.initial;
    _load();
    return state;
  }

  Future<void> _load() async {
    final repo = ref.read(expenseRepositoryProvider);
    final items = await repo.listRecurringPayments();
    state = state.copyWith(items: items, isLoading: false);
  }

  Future<void> toggleAutoDeduct(String id, bool enabled) async {
    final repo = ref.read(expenseRepositoryProvider);
    await repo.setRecurringAutoDeduct(id, enabled);
    await _load();
  }

  Future<void> toggleActive(String id, bool active) async {
    final repo = ref.read(expenseRepositoryProvider);
    await repo.setRecurringActive(id, active);
    await _load();
  }

  Future<void> upsert(RecurringPayment payment) async {
    final repo = ref.read(expenseRepositoryProvider);
    await repo.upsertRecurringPayment(payment);
    await _load();
  }
}
