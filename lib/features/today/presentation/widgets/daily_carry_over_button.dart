import 'package:flutter/material.dart';

/// 섹션이 비어 있을 때 노출되는 "이전 것 가져오기" 진입 버튼.
///
/// 비동기 작업의 소유자는 상위 화면이며, 이 위젯은 전달받은 [isLoading]을
/// 표시하고 중복 입력만 차단하는 controlled component다.
class DailyCarryOverButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const DailyCarryOverButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox.square(
              key: ValueKey('dailyCarryOverLoading'),
              dimension: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.history_rounded, size: 16),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        visualDensity: VisualDensity.compact,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }
}
