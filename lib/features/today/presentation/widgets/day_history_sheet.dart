import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_boxing_pomodoro/l10n/l10n.dart';

import '../../../focus/application/pomodoro_controller.dart';
import '../../../focus/domain/entities/pomodoro.dart';
import '../../../focus/presentation/time_box_title_display.dart';

/// 특정 날짜의 저장된 플랜을 읽기 전용으로 보여주는 시트.
///
/// 주간 히스토리 스트립의 셀을 탭하면 열린다. 과거 일자의 우선순위,
/// 타임박스, 브레인 덤프, 기억할 것 원문을 그대로 보여준다.
/// doc: docs/architecture/DATA_LIFECYCLE.md
void showDayHistorySheet(BuildContext context, {required String dateKey}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF101010),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (context) {
      return _DayHistorySheet(dateKey: dateKey);
    },
  );
}

class _DayHistorySheet extends ConsumerWidget {
  final String dateKey;

  const _DayHistorySheet({required this.dateKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planForDateProvider(dateKey: dateKey));

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dateKey,
                        style: const TextStyle(
                          color: Color(0xFFF6F3EC),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: const Color(0xFFF6F3EC),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                switch (plan) {
                  AsyncData(:final value) => _DayHistoryBody(plan: value),
                  AsyncError() => _DayHistoryEmpty(),
                  _ => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Color(0xFFF6F3EC),
                        ),
                      ),
                    ),
                  ),
                },
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DayHistoryBody extends StatelessWidget {
  final Pomodoro? plan;

  const _DayHistoryBody({required this.plan});

  @override
  Widget build(BuildContext context) {
    final dayPlan = plan;
    final priorities = dayPlan?.topPriorities
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList() ??
        const <String>[];
    final boxes = [...?dayPlan?.timeBoxes]
      ..sort((a, b) {
        final startA = a.startMinutes ?? (24 * 60);
        final startB = b.startMinutes ?? (24 * 60);
        return startA.compareTo(startB);
      });
    final brainDump = dayPlan?.brainDump ?? const <String>[];
    final reminders = dayPlan?.reminders ?? const <String>[];

    if (dayPlan == null ||
        (priorities.isEmpty &&
            boxes.isEmpty &&
            brainDump.isEmpty &&
            reminders.isEmpty)) {
      return _DayHistoryEmpty();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (priorities.isNotEmpty)
          _DayHistorySection(
            title: context.l10n.topPrioritiesTitle,
            rows: [
              for (var i = 0; i < priorities.length; i += 1)
                _DayHistoryRowData(leading: '${i + 1}', text: priorities[i]),
            ],
          ),
        if (boxes.isNotEmpty)
          _DayHistorySection(
            title: context.l10n.timeBoxesTitle,
            rows: [
              for (final box in boxes)
                _DayHistoryRowData(
                  leading: box.timeRange,
                  text: displayTimeBoxTitle(box),
                ),
            ],
          ),
        if (brainDump.isNotEmpty)
          _DayHistorySection(
            title: context.l10n.brainDumpTitle,
            rows: [
              for (final item in brainDump) _DayHistoryRowData(text: item),
            ],
          ),
        if (reminders.isNotEmpty)
          _DayHistorySection(
            title: context.l10n.keepInMindTitle,
            rows: [
              for (final item in reminders) _DayHistoryRowData(text: item),
            ],
          ),
      ],
    );
  }
}

class _DayHistoryEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(
        context.l10n.noItemsForDay,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.62),
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DayHistoryRowData {
  final String? leading;
  final String text;

  const _DayHistoryRowData({required this.text, this.leading});
}

class _DayHistorySection extends StatelessWidget {
  final String title;
  final List<_DayHistoryRowData> rows;

  const _DayHistorySection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFF6F3EC),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          for (final row in rows)
            Container(
              margin: EdgeInsets.only(bottom: row == rows.last ? 0 : 6),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (row.leading != null) ...[
                    Text(
                      row.leading!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      row.text,
                      style: const TextStyle(
                        color: Color(0xFFF6F3EC),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
