import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/formatters/lkr_format.dart';
import '../../../../core/widgets/animated_progress.dart';
import '../../domain/entities/savings_target.dart';
import '../providers/savings_targets_controller.dart';

class SavingsTargetsScreen extends ConsumerWidget {
  const SavingsTargetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(savingsTargetsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings'),
        actions: [
          IconButton(
            tooltip: 'Add target',
            onPressed: () => _showEditor(context, ref),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Small steps count.',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pause goals any time—no pressure.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.62),
                  ),
            ),
            const SizedBox(height: 14),
            if (state.isLoading)
              const LinearProgressIndicator(minHeight: 8)
            else
              Expanded(
                child: ListView.separated(
                  itemCount: state.targets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final t = state.targets[i];
                    return _TargetCard(
                      target: t,
                      onEdit: () => _showEditor(context, ref, existing: t),
                      onTogglePause: () => ref
                          .read(savingsTargetsControllerProvider.notifier)
                          .setPaused(t.id, !t.isPaused),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditor(
    BuildContext context,
    WidgetRef ref, {
    SavingsTarget? existing,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TargetEditorSheet(existing: existing),
    );
  }
}

class _TargetCard extends StatelessWidget {
  const _TargetCard({
    required this.target,
    required this.onEdit,
    required this.onTogglePause,
  });

  final SavingsTarget target;
  final VoidCallback onEdit;
  final VoidCallback onTogglePause;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final progress = target.progress;
    final tone = Color.lerp(AppColors.neutral, AppColors.savings, progress)!;

    // Why this design:
    // - Active vs paused is obvious via opacity + chip.
    // - Progress is encouraging, not “gamified”.
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: target.isPaused ? 0.55 : 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              tone.withValues(alpha: 0.18),
              const Color(0xFF101B34).withValues(alpha: 0.92),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedCircularProgress(
                  value: progress,
                  size: 52,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.10),
                  color: tone,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              target.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (target.isPaused)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                              ),
                              child: Text(
                                'Paused',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.72),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${LkrFormat.money(target.currentAmountLkr)} / ${LkrFormat.money(target.targetAmountLkr)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.64),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedLinearProgress(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.10),
              color: tone,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    progress >= 1 ? 'Goal reached. Keep it for next month?' : 'You’re building momentum.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.60),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Edit',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded),
                ),
                IconButton(
                  tooltip: target.isPaused ? 'Resume' : 'Pause',
                  onPressed: onTogglePause,
                  icon: Icon(target.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetEditorSheet extends ConsumerStatefulWidget {
  const _TargetEditorSheet({this.existing});

  final SavingsTarget? existing;

  @override
  ConsumerState<_TargetEditorSheet> createState() => _TargetEditorSheetState();
}

class _TargetEditorSheetState extends ConsumerState<_TargetEditorSheet> {
  late final TextEditingController _name;
  late final TextEditingController _target;
  late final TextEditingController _current;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _target = TextEditingController(text: widget.existing?.targetAmountLkr.toString() ?? '');
    _current = TextEditingController(text: widget.existing?.currentAmountLkr.toString() ?? '0');
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _current.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottom),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.existing == null ? 'New target' : 'Edit target',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _current,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Current (LKR)'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _target,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Target (LKR)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final target = int.tryParse(_target.text.trim());
    final current = int.tryParse(_current.text.trim()) ?? 0;

    if (name.isEmpty || target == null || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a name and a valid target.')),
      );
      return;
    }

    final id = widget.existing?.id ?? 't_${DateTime.now().microsecondsSinceEpoch}';
    final updated = SavingsTarget(
      id: id,
      name: name,
      targetAmountLkr: target,
      currentAmountLkr: current.clamp(0, target),
      isPaused: widget.existing?.isPaused ?? false,
    );

    await ref.read(savingsTargetsControllerProvider.notifier).upsert(updated);

    if (mounted) Navigator.of(context).pop();
  }
}
