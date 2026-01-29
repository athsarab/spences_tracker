import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/formatters/lkr_format.dart';
import '../../domain/entities/expense.dart';
import '../providers/dashboard_controller.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  String _amountText = '';
  ExpenseCategory _category = ExpenseCategory.food;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  int get _amountLkr => int.tryParse(_amountText) ?? 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSave = _amountLkr > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Close'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              _AmountDisplay(amountLkr: _amountLkr),
              const SizedBox(height: 14),
              _CategoryPicker(
                value: _category,
                onChanged: (c) => setState(() => _category = c),
              ),
              const SizedBox(height: 12),
              _PaymentMethodPicker(
                value: _paymentMethod,
                onChanged: (m) => setState(() => _paymentMethod = m),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const Spacer(),
              _Keypad(
                onKey: _onKey,
                onBackspace: _onBackspace,
                onClear: _onClear,
              ),
              const SizedBox(height: 14),
              _SaveButton(
                enabled: canSave,
                label: canSave ? 'Save' : 'Enter amount',
                onPressed: canSave ? _onSave : null,
              ),
              const SizedBox(height: 6),
              Text(
                'Done in under 5 seconds.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onKey(String digit) {
    setState(() {
      if (_amountText.length >= 7)
        return; // keeps input fast + avoids huge numbers
      if (_amountText == '0') {
        _amountText = digit;
      } else {
        _amountText = '$_amountText$digit';
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_amountText.isEmpty) return;
      _amountText = _amountText.substring(0, _amountText.length - 1);
    });
  }

  void _onClear() {
    setState(() => _amountText = '');
  }

  Future<void> _onSave() async {
    HapticFeedback.mediumImpact();

    await ref
        .read(dashboardControllerProvider.notifier)
        .addExpense(
          amountLkr: _amountLkr,
          category: _category,
          paymentMethod: _paymentMethod,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );

    if (mounted) Navigator.of(context).pop();
  }
}

class _AmountDisplay extends StatelessWidget {
  const _AmountDisplay({required this.amountLkr});

  final int amountLkr;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Why this layout:
    // - Big, centered amount reduces errors and speeds completion.
    // - No text field focus/keyboard popups; keypad is always ready.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amount',
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.68),
            ),
          ),
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
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
              amountLkr == 0 ? 'LKR 0' : LkrFormat.money(amountLkr),
              key: ValueKey<int>(amountLkr),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({required this.value, required this.onChanged});

  final ExpenseCategory value;
  final ValueChanged<ExpenseCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <(ExpenseCategory, String, IconData)>[
      (ExpenseCategory.food, 'Food', Icons.restaurant_rounded),
      (ExpenseCategory.transport, 'Bus', Icons.directions_bus_rounded),
      (ExpenseCategory.bills, 'Bills', Icons.receipt_long_rounded),
      (ExpenseCategory.shopping, 'Shop', Icons.shopping_bag_rounded),
      (ExpenseCategory.other, 'Other', Icons.more_horiz_rounded),
    ];

    // Why chips:
    // - Fast one-tap selection; icons reduce reading time.
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          ChoiceChip(
            selected: value == item.$1,
            onSelected: (_) => onChanged(item.$1),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.$3, size: 16),
                const SizedBox(width: 6),
                Text(item.$2),
              ],
            ),
          ),
      ],
    );
  }
}

class _PaymentMethodPicker extends StatelessWidget {
  const _PaymentMethodPicker({required this.value, required this.onChanged});

  final PaymentMethod value;
  final ValueChanged<PaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<PaymentMethod>(
      segments: const [
        ButtonSegment(
          value: PaymentMethod.cash,
          label: Text('Cash'),
          icon: Icon(Icons.payments_rounded),
        ),
        ButtonSegment(
          value: PaymentMethod.bank,
          label: Text('Bank'),
          icon: Icon(Icons.account_balance_rounded),
        ),
        ButtonSegment(
          value: PaymentMethod.card,
          label: Text('Card'),
          icon: Icon(Icons.credit_card_rounded),
        ),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
      showSelectedIcon: false,
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          Colors.white.withValues(alpha: 0.06),
        ),
        side: WidgetStatePropertyAll(
          BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({
    required this.onKey,
    required this.onBackspace,
    required this.onClear,
  });

  final ValueChanged<String> onKey;
  final VoidCallback onBackspace;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final keys = <Widget>[
      for (final d in ['1', '2', '3', '4', '5', '6', '7', '8', '9'])
        _KeypadKey(label: d, onTap: () => onKey(d)),
      _KeypadKey(label: 'CLR', onTap: onClear, tint: AppColors.neutral),
      _KeypadKey(label: '0', onTap: () => onKey('0')),
      _KeypadKey(
        icon: Icons.backspace_rounded,
        onTap: onBackspace,
        tint: AppColors.overspend,
      ),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: keys,
    );
  }
}

class _KeypadKey extends StatefulWidget {
  const _KeypadKey({this.label, this.icon, this.tint, required this.onTap})
    : assert(label != null || icon != null);

  final String? label;
  final IconData? icon;
  final Color? tint;
  final VoidCallback onTap;

  @override
  State<_KeypadKey> createState() => _KeypadKeyState();
}

class _KeypadKeyState extends State<_KeypadKey> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final tint = widget.tint ?? Colors.white;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Center(
            child: widget.icon != null
                ? Icon(widget.icon, color: tint.withValues(alpha: 0.90))
                : Text(
                    widget.label!,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: tint.withValues(alpha: 0.92),
                      letterSpacing: -0.4,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatefulWidget {
  const _SaveButton({
    required this.enabled,
    required this.label,
    this.onPressed,
  });

  final bool enabled;
  final String label;
  final VoidCallback? onPressed;

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.99 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton.icon(
            onPressed: widget.onPressed,
            icon: const Icon(Icons.check_rounded),
            label: Text(widget.label),
          ),
        ),
      ),
    );
  }
}
