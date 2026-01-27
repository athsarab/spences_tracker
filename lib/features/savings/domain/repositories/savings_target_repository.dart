import '../entities/savings_target.dart';

abstract class SavingsTargetRepository {
  Future<List<SavingsTarget>> listTargets();
  Future<void> upsertTarget(SavingsTarget target);
  Future<void> setPaused(String id, bool paused);
}
