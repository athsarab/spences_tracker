import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/savings_target.dart';
import 'savings_repository_provider.dart';

class SavingsTargetsState {
  const SavingsTargetsState({required this.targets, required this.isLoading});

  final List<SavingsTarget> targets;
  final bool isLoading;

  SavingsTargetsState copyWith({List<SavingsTarget>? targets, bool? isLoading}) {
    return SavingsTargetsState(
      targets: targets ?? this.targets,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  static const initial = SavingsTargetsState(targets: <SavingsTarget>[], isLoading: true);
}

final savingsTargetsControllerProvider =
    NotifierProvider<SavingsTargetsController, SavingsTargetsState>(SavingsTargetsController.new);

class SavingsTargetsController extends Notifier<SavingsTargetsState> {
  @override
  SavingsTargetsState build() {
    state = SavingsTargetsState.initial;
    _load();
    return state;
  }

  Future<void> _load() async {
    final repo = ref.read(savingsRepositoryProvider);
    final targets = await repo.listTargets();
    state = state.copyWith(targets: targets, isLoading: false);
  }

  Future<void> upsert(SavingsTarget target) async {
    final repo = ref.read(savingsRepositoryProvider);
    await repo.upsertTarget(target);
    await _load();
  }

  Future<void> setPaused(String id, bool paused) async {
    final repo = ref.read(savingsRepositoryProvider);
    await repo.setPaused(id, paused);
    await _load();
  }
}
