import 'package:flutter/material.dart';

class SectionLabel extends StatelessWidget {
  final String title;
  final String? hint;
  const SectionLabel({super.key, required this.title, this.hint});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Text(title, style: t.textTheme.titleLarge)),
        if (hint != null)
          Text(
            hint!,
            style: t.textTheme.labelMedium?.copyWith(
              color: t.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
