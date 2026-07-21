import 'package:flutter/material.dart';

class DailyCarryOverButton extends StatelessWidget {
  final String label;
  final Future<bool> Function() onPressed;
  final VoidCallback onMissing;

  const DailyCarryOverButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.onMissing,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () async {
          final carried = await onPressed();
          if (!context.mounted || carried) {
            return;
          }
          onMissing();
        },
        icon: const Icon(Icons.history_rounded, size: 16),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFF6F3EC),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          visualDensity: VisualDensity.compact,
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
