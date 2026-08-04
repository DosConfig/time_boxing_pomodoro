import 'package:flutter/material.dart';

/// 섹션이 비어 있을 때 노출되는 "이전 것 가져오기" 진입 버튼.
///
/// 탭하면 선택형 가져오기 시트(showCarryOverPickerSheet)가 열린다.
class DailyCarryOverButton extends StatefulWidget {
  final String label;
  final Future<void> Function() onPressed;

  const DailyCarryOverButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  State<DailyCarryOverButton> createState() => _DailyCarryOverButtonState();
}

class _DailyCarryOverButtonState extends State<DailyCarryOverButton> {
  bool _loading = false;

  Future<void> _handlePressed() async {
    if (_loading) {
      return;
    }
    setState(() => _loading = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: _loading ? null : _handlePressed,
        icon: _loading
            ? const SizedBox.square(
                key: ValueKey('dailyCarryOverLoading'),
                dimension: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.history_rounded, size: 16),
        label: Text(widget.label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFF6F3EC),
          disabledForegroundColor: const Color(
            0xFFF6F3EC,
          ).withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          visualDensity: VisualDensity.compact,
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
