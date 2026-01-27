import 'package:flutter/material.dart';

/// Subtle hover/parallax feel for desktop/web.
/// Why: makes cards feel premium without heavy animation.
class HoverTilt extends StatefulWidget {
  const HoverTilt({super.key, required this.child, this.maxTilt = 0.035});

  final Widget child;

  /// Radians.
  final double maxTilt;

  @override
  State<HoverTilt> createState() => _HoverTiltState();
}

class _HoverTiltState extends State<HoverTilt> {
  Offset _pos = Offset.zero;
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final tiltX = _hover ? (_pos.dy * widget.maxTilt) : 0.0;
    final tiltY = _hover ? (-_pos.dx * widget.maxTilt) : 0.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _pos = Offset.zero;
      }),
      onHover: (e) {
        final box = context.findRenderObject();
        if (box is! RenderBox) return;
        final local = box.globalToLocal(e.position);
        final center = box.size.center(Offset.zero);
        final dx = (local.dx - center.dx) / (box.size.width / 2);
        final dy = (local.dy - center.dy) / (box.size.height / 2);
        setState(() => _pos = Offset(dx.clamp(-1, 1), dy.clamp(-1, 1)));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(tiltX)
          ..rotateY(tiltY)
          ..translateByDouble(0.0, _hover ? -2.0 : 0.0, 0.0, 1.0),
        child: widget.child,
      ),
    );
  }
}
