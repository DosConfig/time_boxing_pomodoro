import 'package:flutter/material.dart';

/// 섹션이 비어 있을 때 노출되는 "이전 것 가져오기" 진입 버튼.
///
/// 탭하면 선택형 가져오기 시트(showCarryOverPickerSheet)가 열린다.
class DailyCarryOverButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const DailyCarryOverButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onPressed,
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
