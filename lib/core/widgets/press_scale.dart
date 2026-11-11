import 'package:flutter/material.dart';

/// Lightweight press feedback that respects reduced-motion accessibility.
class PressScale extends StatefulWidget {
  final Widget child;
  const PressScale({super.key, required this.child});
  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool pressed = false;
  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => setState(() => pressed = true),
    onPointerUp: (_) => setState(() => pressed = false),
    onPointerCancel: (_) => setState(() => pressed = false),
    child: AnimatedScale(
      scale: MediaQuery.disableAnimationsOf(context)
          ? 1
          : pressed
          ? .975
          : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOutCubic,
      child: widget.child,
    ),
  );
}
