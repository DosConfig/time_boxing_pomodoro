import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_boxing_pomodoro/l10n/l10n.dart';

import '../../../../shared/presentation/app_snack.dart';
import 'package:time_boxing_pomodoro/features/focus/presentation/controllers/pomodoro_controller.dart';
import '../../../focus/domain/entities/daily_plan_item_category.dart';

/// 데일리 플랜 카드(최우선/브레인덤프/기억할 것) 공용 시트.
///
/// 모든 카드 타입이 "탭 → 같은 편집 시트"로 동작하게 하는 단일 진입점이다.
/// 텍스트 수정, 다른 카테고리로 이동, 삭제를 카테고리와 무관하게 동일한
/// UI로 제공한다.
Future<void> showDailyPlanItemSheet(
  BuildContext context, {
  required PomodoroController notifier,
  required DailyPlanItemCategory category,
  required int index,
  required String value,
}) {
  final l10n = context.l10n;
  final title = switch (category) {
    DailyPlanItemCategory.topPriority => l10n.editPriorityTitle,
    DailyPlanItemCategory.brainDump => l10n.editBrainDumpTitle,
    DailyPlanItemCategory.reminder => l10n.editReminderTitle,
  };
  final fieldLabel = switch (category) {
    DailyPlanItemCategory.topPriority => l10n.priorityLabel(index + 1),
    DailyPlanItemCategory.brainDump => l10n.captureLabel,
    DailyPlanItemCategory.reminder => l10n.reminderLabel,
  };

  void save(String nextValue) {
    notifier.updateDailyPlanItem(category, index, nextValue);
    HapticFeedback.lightImpact();
  }

  void delete() {
    switch (category) {
      case DailyPlanItemCategory.topPriority:
        notifier.setTopPriority(index, '');
      case DailyPlanItemCategory.brainDump:
        notifier.removeBrainDumpItem(index);
      case DailyPlanItemCategory.reminder:
        notifier.removeReminder(index);
    }
    HapticFeedback.lightImpact();
  }

  DailyPlanSheetAction moveAction(DailyPlanItemCategory target) {
    final label = switch (target) {
      DailyPlanItemCategory.topPriority => l10n.makePriority,
      DailyPlanItemCategory.brainDump => l10n.moveToBrainDump,
      DailyPlanItemCategory.reminder => l10n.moveToReminder,
    };
    final icon = switch (target) {
      DailyPlanItemCategory.topPriority => Icons.flag_rounded,
      DailyPlanItemCategory.brainDump => Icons.psychology_rounded,
      DailyPlanItemCategory.reminder => Icons.event_note_rounded,
    };
    return DailyPlanSheetAction(
      icon: icon,
      label: label,
      onTap: (sheetContext) {
        HapticFeedback.selectionClick();
        final moved = notifier.moveDailyPlanItem(
          source: category,
          index: index,
          target: target,
        );
        Navigator.of(sheetContext).pop();
        if (!moved && target == DailyPlanItemCategory.topPriority) {
          showAppSnack(context, l10n.threePrioritiesAlreadySet);
        }
      },
    );
  }

  final moveTargets = DailyPlanItemCategory.values
      .where((target) => target != category)
      .map(moveAction)
      .toList();

  return showDailyPlanTextSheet(
    context,
    title: title,
    fieldLabel: fieldLabel,
    initialValue: value,
    onSave: save,
    actions: [
      ...moveTargets,
      DailyPlanSheetAction(
        icon: Icons.delete_outline_rounded,
        label: l10n.deleteAction,
        destructive: true,
        onTap: (sheetContext) {
          delete();
          Navigator.of(sheetContext).pop();
        },
      ),
    ],
  );
}

/// 공용 시트에 표시되는 보조 액션(이동/삭제 등).
class DailyPlanSheetAction {
  final IconData icon;
  final String label;
  final bool destructive;
  final ValueChanged<BuildContext> onTap;

  const DailyPlanSheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });
}

/// 텍스트 입력 + 보조 액션을 갖춘 공용 바텀 시트.
///
/// 추가 플로우(액션 없음)와 편집 플로우(이동/삭제 액션 포함)가 같은
/// 위젯을 공유한다.
Future<void> showDailyPlanTextSheet(
  BuildContext context, {
  required String title,
  required String fieldLabel,
  required ValueChanged<String> onSave,
  String initialValue = '',
  List<DailyPlanSheetAction> actions = const [],
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return _DailyPlanTextSheet(
        title: title,
        fieldLabel: fieldLabel,
        initialValue: initialValue,
        onSave: onSave,
        actions: actions,
      );
    },
  );
}

class _DailyPlanTextSheet extends StatefulWidget {
  final String title;
  final String fieldLabel;
  final String initialValue;
  final ValueChanged<String> onSave;
  final List<DailyPlanSheetAction> actions;

  const _DailyPlanTextSheet({
    required this.title,
    required this.fieldLabel,
    required this.initialValue,
    required this.onSave,
    required this.actions,
  });

  @override
  State<_DailyPlanTextSheet> createState() => _DailyPlanTextSheetState();
}

class _DailyPlanTextSheetState extends State<_DailyPlanTextSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 18, 20, bottomInset + 20),
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
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey('dailyPlanSheetField'),
              controller: _controller,
              autofocus: true,
              cursorColor: colors.onSurface,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
              minLines: 1,
              maxLines: 3,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                isDense: true,
                labelText: widget.fieldLabel,
                labelStyle: TextStyle(
                  color: colors.onSurface.withValues(alpha: 0.46),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: colors.onSurface.withValues(alpha: 0.14),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colors.onSurface),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const ValueKey('dailyPlanSheetSave'),
              onPressed: _save,
              icon: const Icon(Icons.check_rounded),
              label: Text(
                context.l10n.saveAction,
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
            for (final action in widget.actions) ...[
              const SizedBox(height: 8),
              _SheetActionButton(action: action),
            ],
          ],
        ),
      ),
    );
  }

  void _save() {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      showAppSnack(context, context.l10n.enterSomethingFirst);
      return;
    }

    widget.onSave(value);
    Navigator.of(context).pop();
  }
}

class _SheetActionButton extends StatelessWidget {
  final DailyPlanSheetAction action;

  const _SheetActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = action.destructive ? colors.error : colors.onSurface;

    return Material(
      color: colors.onSurface.withValues(alpha: 0.055),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => action.onTap(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(action.icon, color: foreground, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  action.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
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
