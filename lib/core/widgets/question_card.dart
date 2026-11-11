import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  final Widget child;
  final Color tint;
  final bool isHandoff;
  const QuestionCard({
    super.key,
    required this.child,
    required this.tint,
    this.isHandoff = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 280),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: isHandoff
            ? scheme.secondaryContainer
            : (dark ? const Color(0xFF25252D) : Colors.white),
        border: Border.all(
          color: tint.withValues(alpha: dark ? .32 : .20),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: dark ? .12 : .055),
            blurRadius: 32,
            offset: const Offset(0, 13),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -42,
            left: -40,
            child: IgnorePointer(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tint.withValues(alpha: .055),
                ),
              ),
            ),
          ),
          Center(child: child),
        ],
      ),
    );
  }
}
