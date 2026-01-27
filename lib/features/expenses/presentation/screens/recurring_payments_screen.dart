import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/formatters/lkr_format.dart';
import '../../../../core/widgets/app_page_route.dart';
import '../../domain/entities/recurring_payment.dart';
import '../providers/recurring_payments_controller.dart';

class RecurringPaymentsScreen extends ConsumerStatefulWidget {
  const RecurringPaymentsScreen({super.key});

  @override
  ConsumerState<RecurringPaymentsScreen> createState() => _RecurringPaymentsScreenState();
}

class _RecurringPaymentsScreenState extends ConsumerState<RecurringPaymentsScreen> {
  late final Stream<DateTime> _ticker;

  @override
  void initState() {
    super.initState();
    // Why: a single screen-level ticker updates countdowns smoothly
    // without per-row timers (more scalable and predictable).
    _ticker = Stream<DateTime>.periodic(const Duration(seconds: 1), (_) => DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recurringPaymentsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring'),
        actions: [
          IconButton(
            tooltip: 'Add recurring',
            onPressed: () => _showEditor(context),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: StreamBuilder<DateTime>(
        stream: _ticker,
        builder: (context, snap) {
          final now = snap.data ?? DateTime.now();

          if (state.isLoading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(minHeight: 8),
            );
          }

          final sorted = [...state.items]..sort((a, b) => _nextDue(now, a.dayOfMonth).compareTo(_nextDue(now, b.dayOfMonth)));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Predictable bills = calmer month.',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Toggle auto-deduction to simulate a planned month.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.62),
                    ),
              ),
              const SizedBox(height: 14),
              if (sorted.isEmpty)
                _EmptyState(onAdd: () => _showEditor(context))
              else
                ...List.generate(
                  sorted.length,
                  (i) => _Appear(
                    index: i,
                    child: _RecurringCard(
                      payment: sorted[i],
                      now: now,
                      onToggleAuto: (v) => ref
                          .read(recurringPaymentsControllerProvider.notifier)
                          .toggleAutoDeduct(sorted[i].id, v),
                      onToggleActive: (v) => ref
                          .read(recurringPaymentsControllerProvider.notifier)
                          .toggleActive(sorted[i].id, v),
                      onEdit: () => _showEditor(context, existing: sorted[i]),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showEditor(BuildContext context, {RecurringPayment? existing}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RecurringEditorSheet(existing: existing),
    );
  }

  static DateTime _nextDue(DateTime now, int dayOfMonth) {
    final safeDay = dayOfMonth.clamp(1, 28);
    final today = DateTime(now.year, now.month, now.day);
    final thisMonth = DateTime(now.year, now.month, safeDay);
    if (!thisMonth.isBefore(today)) return thisMonth;
    return DateTime(now.year, now.month + 1, safeDay);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month_rounded, color: Colors.white),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Add rent, internet, subscriptions…',
              style: TextStyle(color: Colors.white),
            ),
          ),
          FilledButton(onPressed: onAdd, child: const Text('Add')),
        ],
      ),
    );
  }
}

class _RecurringCard extends StatelessWidget {
  const _RecurringCard({
    required this.payment,
    required this.now,
    required this.onToggleAuto,
    required this.onToggleActive,
    required this.onEdit,
  });

  final RecurringPayment payment;
  final DateTime now;
  final ValueChanged<bool> onToggleAuto;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final due = _nextDue(now, payment.dayOfMonth);
    final diff = due.difference(DateTime(now.year, now.month, now.day));
    final days = diff.inDays;

    // Due date warning: subtle, neutral, non-anxious.
    final isSoon = days <= 3;
    final tone = isSoon ? AppColors.warning : AppColors.neutral;

    final countdown = _countdownText(now, due);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: payment.isActive ? 1 : 0.55,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: Colors.white.withValues(alpha: 0.06),
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
          children: [
            Row(
              children: [
                _CalendarCue(day: payment.dayOfMonth, tone: tone, warn: isSoon),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.12),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: Text(
                          countdown,
                          key: ValueKey<String>(countdown),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.66),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  LkrFormat.money(payment.amountLkr),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ToggleRow(
                    label: 'Auto-deduct',
                    value: payment.autoDeductEnabled,
                    onChanged: payment.isActive ? onToggleAuto : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ToggleRow(
                    label: payment.isActive ? 'Active' : 'Paused',
                    value: payment.isActive,
                    onChanged: onToggleActive,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Edit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static DateTime _nextDue(DateTime now, int dayOfMonth) {
    final safeDay = dayOfMonth.clamp(1, 28);
    final today = DateTime(now.year, now.month, now.day);
    final thisMonth = DateTime(now.year, now.month, safeDay);
    if (!thisMonth.isBefore(today)) return thisMonth;
    return DateTime(now.year, now.month + 1, safeDay);
  }

  static String _countdownText(DateTime now, DateTime due) {
    final end = DateTime(due.year, due.month, due.day, 23, 59, 59);
    final diff = end.difference(now);

    if (diff.isNegative) return 'Due now';

    final d = diff.inDays;
    final h = diff.inHours.remainder(24);
    final m = diff.inMinutes.remainder(60);

    if (d >= 1) return 'Due in ${d}d ${h}h';
    if (h >= 1) return 'Due in ${h}h ${m}m';
    return 'Due in ${m}m';
  }
}

class _CalendarCue extends StatelessWidget {
  const _CalendarCue({required this.day, required this.tone, required this.warn});

  final int day;
  final Color tone;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tone.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '${day.clamp(1, 28)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.4,
              ),
            ),
          ),
          if (warn)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: tone,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: tone.withValues(alpha: 0.30), blurRadius: 10),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.72), fontWeight: FontWeight.w700),
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _Appear extends StatelessWidget {
  const _Appear({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Smooth list animation without heavy libs.
    final delay = Duration(milliseconds: 30 * index);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      delay: delay,
      builder: (context, t, _) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 10),
            child: child,
          ),
        );
      },
    );
  }
}

class _RecurringEditorSheet extends ConsumerStatefulWidget {
  const _RecurringEditorSheet({this.existing});

  final RecurringPayment? existing;

  @override
  ConsumerState<_RecurringEditorSheet> createState() => _RecurringEditorSheetState();
}

class _RecurringEditorSheetState extends ConsumerState<_RecurringEditorSheet> {
  late final TextEditingController _title;
  late final TextEditingController _amount;
  late final TextEditingController _day;

  bool _auto = false;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.existing?.title ?? '');
    _amount = TextEditingController(text: widget.existing?.amountLkr.toString() ?? '');
    _day = TextEditingController(text: widget.existing?.dayOfMonth.toString() ?? '1');
    _auto = widget.existing?.autoDeductEnabled ?? false;
    _active = widget.existing?.isActive ?? true;
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _day.dispose();
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
                    widget.existing == null ? 'New recurring' : 'Edit recurring',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amount,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Amount (LKR)'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _day,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Due day (1-28)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ToggleRow(
                    label: 'Auto-deduct',
                    value: _auto,
                    onChanged: (v) => setState(() => _auto = v),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ToggleRow(
                    label: _active ? 'Active' : 'Paused',
                    value: _active,
                    onChanged: (v) => setState(() => _active = v),
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
    final title = _title.text.trim();
    final amount = int.tryParse(_amount.text.trim());
    final day = int.tryParse(_day.text.trim());

    if (title.isEmpty || amount == null || amount <= 0 || day == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter title, amount, and day.')),
      );
      return;
    }

    final safeDay = day.clamp(1, 28);
    final id = widget.existing?.id ?? 'r_${DateTime.now().microsecondsSinceEpoch}';

    final payment = RecurringPayment(
      id: id,
      title: title,
      amountLkr: amount,
      dayOfMonth: safeDay,
      autoDeductEnabled: _auto,
      isActive: _active,
    );

    await ref.read(recurringPaymentsControllerProvider.notifier).upsert(payment);

    if (mounted) Navigator.of(context).pop();
  }
}
