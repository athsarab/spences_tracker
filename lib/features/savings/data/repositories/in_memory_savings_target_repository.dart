import '../../domain/entities/savings_target.dart';
import '../../domain/repositories/savings_target_repository.dart';

class InMemorySavingsTargetRepository implements SavingsTargetRepository {
  final List<SavingsTarget> _targets = <SavingsTarget>[
    const SavingsTarget(
      id: 't1',
      name: 'Emergency fund',
      targetAmountLkr: 30000,
      currentAmountLkr: 8200,
      isPaused: false,
    ),
    const SavingsTarget(
      id: 't2',
      name: 'Laptop upgrade',
      targetAmountLkr: 180000,
      currentAmountLkr: 24000,
      isPaused: false,
    ),
    const SavingsTarget(
      id: 't3',
      name: 'Trip with friends',
      targetAmountLkr: 25000,
      currentAmountLkr: 6000,
      isPaused: true,
    ),
  ];

  @override
  Future<List<SavingsTarget>> listTargets() async {
    return List.unmodifiable(_targets);
  }

  @override
  Future<void> upsertTarget(SavingsTarget target) async {
    final index = _targets.indexWhere((t) => t.id == target.id);
    if (index == -1) {
      _targets.insert(0, target);
      return;
    }
    _targets[index] = target;
  }

  @override
  Future<void> setPaused(String id, bool paused) async {
    final index = _targets.indexWhere((t) => t.id == id);
    if (index == -1) return;
    _targets[index] = _targets[index].copyWith(isPaused: paused);
  }
}
