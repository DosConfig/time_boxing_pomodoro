import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_boxing_pomodoro/l10n/l10n.dart';

import '../../../../shared/presentation/app_snack.dart';
import 'package:time_boxing_pomodoro/features/focus/presentation/controllers/pomodoro_controller.dart';
import '../../../focus/domain/entities/daily_plan_item_category.dart';
import '../../../focus/domain/entities/pomodoro.dart';
import '../../../focus/presentation/time_box_title_display.dart';

/// 선택형 가져오기가 다루는 섹션.
enum CarryOverSection { topPriority, brainDump, reminder, timeBox }

/// 이전 일자 플랜의 카드를 보여주고 골라서 가져오는 공용 시트.
///
/// 데이터 조회는 호출 화면이 담당한다. 이 함수는 전달받은 플랜을 표시하고
/// 선택 결과를 현재 플랜에 반영하는 presentation 책임만 가진다.
/// doc: docs/architecture/DATA_LIFECYCLE.md
Future<void> showCarryOverPickerSheet(
  BuildContext context, {
  required PomodoroController notifier,
  required CarryOverSection section,
  required Pomodoro? sourcePlan,
}) async {
  final l10n = context.l10n;
  final entries = _entriesForSection(sourcePlan, section);
  if (entries.isEmpty) {
    showAppSnack(context, l10n.noPreviousDailyItems);
    return;
  }

  final title = switch (section) {
    CarryOverSection.topPriority => l10n.carryOverPreviousPriorities,
    CarryOverSection.brainDump => l10n.carryOverPreviousBrainDump,
    CarryOverSection.reminder => l10n.carryOverPreviousReminders,
    CarryOverSection.timeBox => l10n.carryOverPreviousSchedule,
  };

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.82,
    ),
    builder: (sheetContext) {
      return _CarryOverPickerSheet(
        title: title,
        entries: entries,
        initiallySelected: section != CarryOverSection.timeBox,
        onImport: (selected) {
          final imported = _importSelection(notifier, section, selected);
          Navigator.of(sheetContext).pop();
          if (!imported) {
            showAppSnack(context, l10n.nothingToImport);
          } else {
            HapticFeedback.lightImpact();
          }
        },
      );
    },
  );
}

class _CarryOverEntry {
  final String label;
  final String? trailing;
  final String textValue;
  final TimeBox? timeBox;

  const _CarryOverEntry({
    required this.label,
    required this.textValue,
    this.trailing,
    this.timeBox,
  });
}

List<_CarryOverEntry> _entriesForSection(
  Pomodoro? previous,
  CarryOverSection section,
) {
  if (previous == null) {
    return const [];
  }

  switch (section) {
    case CarryOverSection.topPriority:
      return previous.topPriorities
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .take(3)
          .map((item) => _CarryOverEntry(label: item, textValue: item))
          .toList();
    case CarryOverSection.brainDump:
      return previous.brainDump
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .map((item) => _CarryOverEntry(label: item, textValue: item))
          .toList();
    case CarryOverSection.reminder:
      return previous.reminders
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .map((item) => _CarryOverEntry(label: item, textValue: item))
          .toList();
    case CarryOverSection.timeBox:
      final boxes = [
        ...previous.timeBoxes,
      ]..sort((a, b) => (a.startMinutes ?? -1).compareTo(b.startMinutes ?? -1));
      return boxes
          .map(
            (box) => _CarryOverEntry(
              label: displayTimeBoxTitle(box),
              trailing: box.timeRange,
              textValue: box.title,
              timeBox: box,
            ),
          )
          .toList();
  }
}

bool _importSelection(
  PomodoroController notifier,
  CarryOverSection section,
  List<_CarryOverEntry> selected,
) {
  switch (section) {
    case CarryOverSection.topPriority:
      return notifier.importDailyPlanItems(
        DailyPlanItemCategory.topPriority,
        selected.map((entry) => entry.textValue).toList(),
      );
    case CarryOverSection.brainDump:
      return notifier.importDailyPlanItems(
        DailyPlanItemCategory.brainDump,
        selected.map((entry) => entry.textValue).toList(),
      );
    case CarryOverSection.reminder:
      return notifier.importDailyPlanItems(
        DailyPlanItemCategory.reminder,
        selected.map((entry) => entry.textValue).toList(),
      );
    case CarryOverSection.timeBox:
      return notifier.importTimeBoxes(
        selected.map((entry) => entry.timeBox).whereType<TimeBox>().toList(),
      );
  }
}

class _CarryOverPickerSheet extends StatefulWidget {
  final String title;
  final List<_CarryOverEntry> entries;
  final ValueChanged<List<_CarryOverEntry>> onImport;
  final bool initiallySelected;

  const _CarryOverPickerSheet({
    required this.title,
    required this.entries,
    required this.onImport,
    required this.initiallySelected,
  });

  @override
  State<_CarryOverPickerSheet> createState() => _CarryOverPickerSheetState();
}

class _CarryOverPickerSheetState extends State<_CarryOverPickerSheet> {
  late final List<bool> _checked;

  @override
  void initState() {
    super.initState();
    _checked = List<bool>.filled(
      widget.entries.length,
      widget.initiallySelected,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selectedCount = _checked.where((checked) => checked).length;

    return SafeArea(
      key: const ValueKey('carryOverPickerSheet'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: colors.onSurface,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.entries.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final entry = widget.entries[index];
                  final checked = _checked[index];
                  return Material(
                    color: colors.onSurface.withValues(
                      alpha: checked ? 0.07 : 0.035,
                    ),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: checked
                            ? colors.onSurface.withValues(alpha: 0.5)
                            : colors.onSurface.withValues(alpha: 0.1),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() => _checked[index] = !checked);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: Row(
                          children: [
                            Icon(
                              checked
                                  ? Icons.check_box_rounded
                                  : Icons.check_box_outline_blank_rounded,
                              size: 20,
                              color: checked
                                  ? colors.onSurface
                                  : colors.onSurface.withValues(alpha: 0.4),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                entry.label,
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
                            if (entry.trailing != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                entry.trailing!,
                                maxLines: 1,
                                style: TextStyle(
                                  color: colors.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const ValueKey('carryOverImportSelected'),
              onPressed: selectedCount == 0
                  ? null
                  : () {
                      final selected = <_CarryOverEntry>[
                        for (var i = 0; i < widget.entries.length; i += 1)
                          if (_checked[i]) widget.entries[i],
                      ];
                      widget.onImport(selected);
                    },
              icon: const Icon(Icons.download_rounded),
              label: Text(
                '${context.l10n.importSelected} ($selectedCount)',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
