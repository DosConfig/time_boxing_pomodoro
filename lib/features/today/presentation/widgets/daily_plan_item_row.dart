import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../focus/application/pomodoro_controller.dart';
import '../../../focus/domain/entities/daily_plan_item_category.dart';
import 'time_box_board.dart';

/// 데일리 플랜 카드(최우선/브레인덤프/기억할 것) 공용 행.
///
/// 세 카테고리가 같은 모양·같은 탭 동작(탭 → 편집 시트)을 공유하도록
/// 하는 단일 행 위젯이다. 최우선 항목은 [leadingIndex]로 순번만 덧붙인다.
class DailyPlanItemRow extends StatelessWidget {
  final String text;
  final int? leadingIndex;
  final VoidCallback onTap;

  const DailyPlanItemRow({
    super.key,
    required this.text,
    required this.onTap,
    this.leadingIndex,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.onSurface.withValues(alpha: 0.045),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.onSurface.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
          child: Row(
            children: [
              if (leadingIndex != null) ...[
                Text(
                  '${leadingIndex! + 1}',
                  style: TextStyle(
                    color: colors.onSurface.withValues(alpha: 0.46),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 같은 카테고리 행 위로 드래그해 순서를 바꾸는 드롭 타겟.
///
/// 행을 감싸며, 같은 카테고리의 [DraftTimeBoxDragPayload]만 수락해
/// [PomodoroController.reorderDailyPlanItem]을 호출한다. 다른 카테고리
/// 페이로드는 무시되어 패널 레벨의 이동 드롭 타겟으로 흘러간다.
class DailyPlanReorderTarget extends StatelessWidget {
  final DailyPlanItemCategory category;
  final int rowIndex;
  final PomodoroController notifier;
  final Widget child;

  const DailyPlanReorderTarget({
    super.key,
    required this.category,
    required this.rowIndex,
    required this.notifier,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DragTarget<TimeBoxBoardDragPayload>(
      onWillAcceptWithDetails: (details) {
        final payload = details.data;
        return payload is DraftTimeBoxDragPayload &&
            payload.source == category &&
            payload.index != rowIndex;
      },
      onAcceptWithDetails: (details) {
        final payload = details.data as DraftTimeBoxDragPayload;
        final reordered = notifier.reorderDailyPlanItem(
          category: category,
          fromIndex: payload.index,
          toIndex: rowIndex,
        );
        if (reordered) {
          HapticFeedback.mediumImpact();
        }
      },
      builder: (context, candidates, rejected) {
        final targeted = candidates.isNotEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              height: 2,
              margin: EdgeInsets.only(bottom: targeted ? 4 : 0),
              decoration: BoxDecoration(
                color: targeted ? colors.onSurface : Colors.transparent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            child,
          ],
        );
      },
    );
  }
}
