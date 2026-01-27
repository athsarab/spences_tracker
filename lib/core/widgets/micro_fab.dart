import 'package:flutter/material.dart';

class MicroFab extends StatefulWidget {
  const MicroFab({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  @override
  State<MicroFab> createState() => _MicroFabState();
}

class _MicroFabState extends State<MicroFab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    // Why this micro-interaction:
    // - A subtle scale + shadow change makes the primary action feel “alive”.
    // - It’s lightweight (implicit animation) and doesn’t distract.
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _pressed ? 0.18 : 0.28),
                blurRadius: _pressed ? 10 : 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: widget.onPressed,
            icon: Icon(widget.icon),
            label: Text(widget.label),
          ),
        ),
      ),
    );
  }
}
