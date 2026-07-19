import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pomodoro_method_channel/l10n/l10n.dart';

import '../../../focus/application/pomodoro_controller.dart';
import '../../../focus/domain/entities/pomodoro.dart';
import '../../../focus/presentation/time_box_title_l10n.dart';
import 'today_section_card.dart';

class TimeBoxBoard extends StatelessWidget {
  final Pomodoro pomodoro;
  final PomodoroController notifier;
  final DateTime now;
  final int awakeStartMinutes;
  final int awakeEndMinutes;
  final VoidCallback onDragStarted;
  final ValueChanged<DragUpdateDetails> onDragUpdate;
  final VoidCallback onDragEnd;

  const TimeBoxBoard({
    super.key,
    required this.pomodoro,
    required this.notifier,
    required this.now,
    required this.awakeStartMinutes,
    required this.awakeEndMinutes,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  static const _slotMinutes = 30;
  static const _slotHeight = 70.0;
  static const _timelineWidth = 58.0;

  @override
  Widget build(BuildContext context) {
    final dayStart = _dayStartMinutes();
    final dayEnd = _dayEndMinutes(dayStart);
    final slotCount = ((dayEnd - dayStart) / _slotMinutes).ceil();
    final boardHeight = slotCount * _slotHeight;
    final nowMinutes = _nowMinutes();

    return TodaySectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.timeBoxesTitle,
            style: TextStyle(
              color: Color(0xFFF6F3EC),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.timeBoxesHint,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.42),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: boardHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ...List.generate(slotCount, (index) {
                    final slotStart = dayStart + (index * _slotMinutes);
                    final isCurrentSlot =
                        nowMinutes >= slotStart &&
                        nowMinutes < slotStart + _slotMinutes;
                    final occupied = _slotOccupied(slotStart);

                    return Positioned(
                      top: index * _slotHeight,
                      left: 0,
                      right: 0,
                      height: _slotHeight,
                      child: DragTarget<String>(
                        onAcceptWithDetails: (details) {
                          HapticFeedback.mediumImpact();
                          notifier.moveTimeBoxToStart(details.data, slotStart);
                        },
                        builder: (context, candidates, rejected) {
                          final isTargeted = candidates.isNotEmpty;
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: occupied
                                ? null
                                : () =>
                                      _openNewTimeBoxEditor(context, slotStart),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 140),
                              curve: Curves.easeOutCubic,
                              color: isTargeted
                                  ? const Color(
                                      0xFFF6F3EC,
                                    ).withValues(alpha: 0.12)
                                  : isCurrentSlot
                                  ? Colors.white.withValues(alpha: 0.055)
                                  : Colors.transparent,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: _timelineWidth,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 7),
                                      child: Text(
                                        _formatClock(slotStart),
                                        style: TextStyle(
                                          color: isCurrentSlot
                                              ? const Color(0xFFF6F3EC)
                                              : Colors.white.withValues(
                                                  alpha: 0.36,
                                                ),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 13),
                                      height: 1,
                                      color: Colors.white.withValues(
                                        alpha: isCurrentSlot ? 0.2 : 0.08,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  ...pomodoro.timeBoxes.map(
                    (box) => _PositionedTimeBox(
                      box: box,
                      title: localizedTimeBoxTitle(context, box),
                      activeTimeBoxId: pomodoro.activeTimeBox?.id,
                      dayStart: dayStart,
                      dayEnd: dayEnd,
                      current: _containsNow(box),
                      onDragStarted: onDragStarted,
                      onDragUpdate: onDragUpdate,
                      onDragEnd: onDragEnd,
                      onTap: () => _openTimeBoxEditor(context, box),
                    ),
                  ),
                  if (nowMinutes >= dayStart && nowMinutes <= dayEnd)
                    Positioned(
                      top:
                          ((nowMinutes - dayStart) / _slotMinutes) *
                          _slotHeight,
                      left: _timelineWidth - 4,
                      right: 0,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF6F3EC),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: const Color(0xFFF6F3EC),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openNewTimeBoxEditor(BuildContext context, int slotStart) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF101010),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return _TimeBoxEditorSheet(
          notifier: notifier,
          startMinutes: slotStart,
          timeRange: _formatTimeRange(slotStart),
          fallbackTitle: context.l10n.newTimeBoxDefaultTitle,
        );
      },
    );
  }

  void _openTimeBoxEditor(BuildContext context, TimeBox box) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF101010),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return _TimeBoxEditorSheet(
          box: box,
          notifier: notifier,
          timeRange: box.timeRange,
          fallbackTitle: context.l10n.newTimeBoxDefaultTitle,
        );
      },
    );
  }

  int _dayStartMinutes() {
    return (awakeStartMinutes ~/ _slotMinutes) * _slotMinutes;
  }

  int _dayEndMinutes(int dayStart) {
    final end =
        ((awakeEndMinutes + _slotMinutes - 1) ~/ _slotMinutes) * _slotMinutes;
    if (end <= dayStart) {
      return dayStart + (4 * 60);
    }
    return end.clamp(dayStart + _slotMinutes, 24 * 60);
  }

  int _nowMinutes() => (now.hour * 60) + now.minute;

  bool _containsNow(TimeBox box) {
    final start = box.startMinutes;
    final end = box.endMinutes;
    if (start == null || end == null) {
      return false;
    }

    var nowMinutes = _nowMinutes();
    if (end >= 24 * 60 && nowMinutes < start) {
      nowMinutes += 24 * 60;
    }
    return nowMinutes >= start && nowMinutes < end;
  }

  String _formatClock(int minutes) {
    final normalized = minutes % (24 * 60);
    final hour = normalized ~/ 60;
    final minute = normalized % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String _formatTimeRange(int startMinutes) {
    return '${_formatClock(startMinutes)}-${_formatClock(startMinutes + _slotMinutes)}';
  }

  bool _slotOccupied(int slotStart) {
    return pomodoro.timeBoxes.any((box) => box.startMinutes == slotStart);
  }
}

class _PositionedTimeBox extends StatelessWidget {
  final TimeBox box;
  final String title;
  final String? activeTimeBoxId;
  final int dayStart;
  final int dayEnd;
  final bool current;
  final VoidCallback onDragStarted;
  final ValueChanged<DragUpdateDetails> onDragUpdate;
  final VoidCallback onDragEnd;
  final VoidCallback onTap;

  const _PositionedTimeBox({
    required this.box,
    required this.title,
    required this.activeTimeBoxId,
    required this.dayStart,
    required this.dayEnd,
    required this.current,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final start = box.startMinutes;
    final end = box.endMinutes;
    if (start == null || end == null || end <= dayStart || start >= dayEnd) {
      return const SizedBox.shrink();
    }

    final visibleStart = start < dayStart ? dayStart : start;
    final visibleEnd = end > dayEnd ? dayEnd : end;
    final top =
        ((visibleStart - dayStart) / TimeBoxBoard._slotMinutes) *
            TimeBoxBoard._slotHeight +
        4;
    final rawHeight =
        ((visibleEnd - visibleStart) / TimeBoxBoard._slotMinutes) *
            TimeBoxBoard._slotHeight -
        8;
    final height = rawHeight < 58 ? 58.0 : rawHeight;

    return Positioned(
      top: top,
      left: TimeBoxBoard._timelineWidth,
      right: 0,
      height: height,
      child: _TimeBoxBoardCard(
        box: box,
        title: title,
        selected: box.id == activeTimeBoxId,
        current: current,
        onDragStarted: onDragStarted,
        onDragUpdate: onDragUpdate,
        onDragEnd: onDragEnd,
        onTap: onTap,
      ),
    );
  }
}

class _TimeBoxBoardCard extends StatelessWidget {
  final TimeBox box;
  final String title;
  final bool selected;
  final bool current;
  final VoidCallback onDragStarted;
  final ValueChanged<DragUpdateDetails> onDragUpdate;
  final VoidCallback onDragEnd;
  final VoidCallback onTap;

  const _TimeBoxBoardCard({
    required this.box,
    required this.title,
    required this.selected,
    required this.current,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surface = _TimeBoxBoardCardSurface(
      box: box,
      title: title,
      selected: selected,
      current: current,
    );

    return LongPressDraggable<String>(
      data: box.id,
      delay: const Duration(milliseconds: 220),
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width - 110,
          child: _TimeBoxBoardCardSurface(
            box: box,
            title: title,
            selected: selected,
            current: current,
            feedback: true,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.28,
        child: _TimeBoxBoardCardGesture(onTap: onTap, child: surface),
      ),
      onDragStarted: onDragStarted,
      onDragUpdate: onDragUpdate,
      onDragEnd: (_) => onDragEnd(),
      onDragCompleted: onDragEnd,
      onDraggableCanceled: (_, _) => onDragEnd(),
      child: _TimeBoxBoardCardGesture(onTap: onTap, child: surface),
    );
  }
}

class _TimeBoxBoardCardGesture extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _TimeBoxBoardCardGesture({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }
}

class _TimeBoxBoardCardSurface extends StatelessWidget {
  final TimeBox box;
  final String title;
  final bool selected;
  final bool current;
  final bool feedback;

  const _TimeBoxBoardCardSurface({
    required this.box,
    required this.title,
    required this.selected,
    required this.current,
    this.feedback = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFF6F3EC)
            : current
            ? Colors.white.withValues(alpha: 0.16)
            : const Color(0xFF202020),
        border: Border.all(
          color: selected
              ? const Color(0xFFF6F3EC)
              : current
              ? const Color(0xFFF6F3EC).withValues(alpha: 0.46)
              : Colors.white.withValues(alpha: feedback ? 0.3 : 0.14),
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: feedback
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.38),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            box.timeRange,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected
                  ? const Color(0xFF080808)
                  : Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (current && !selected) ...[
            const SizedBox(height: 3),
            Text(
              context.l10n.nowBadge,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.54),
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected
                  ? const Color(0xFF080808)
                  : const Color(0xFFF6F3EC),
              fontSize: 15,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeBoxEditorSheet extends StatefulWidget {
  final TimeBox? box;
  final PomodoroController notifier;
  final int? startMinutes;
  final String timeRange;
  final String fallbackTitle;

  const _TimeBoxEditorSheet({
    this.box,
    required this.notifier,
    this.startMinutes,
    required this.timeRange,
    required this.fallbackTitle,
  });

  @override
  State<_TimeBoxEditorSheet> createState() => _TimeBoxEditorSheetState();
}

class _TimeBoxEditorSheetState extends State<_TimeBoxEditorSheet> {
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.box?.title ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    widget.box == null
                        ? context.l10n.newTimeBoxTitle
                        : context.l10n.editTimeBoxTitle,
                    style: const TextStyle(
                      color: Color(0xFFF6F3EC),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
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
            const SizedBox(height: 12),
            _TimeBoxTextField(
              controller: _titleController,
              label: context.l10n.titleLabel,
              textInputAction: TextInputAction.done,
              autofocus: true,
              onSubmitted: (_) => _save(context),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(
                context.l10n.timeBoxRange(widget.timeRange),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.52),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _save(context),
              icon: const Icon(Icons.check_rounded),
              label: Text(context.l10n.saveAction),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF6F3EC),
                foregroundColor: const Color(0xFF080808),
                minimumSize: const Size.fromHeight(50),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save(BuildContext context) {
    HapticFeedback.lightImpact();
    final box = widget.box;
    if (box == null) {
      final startMinutes = widget.startMinutes;
      if (startMinutes != null) {
        widget.notifier.addTimeBoxAtStart(
          startMinutes,
          title: _titleController.text.trim().isEmpty
              ? widget.fallbackTitle
              : _titleController.text,
        );
      }
    } else {
      widget.notifier.updateTimeBox(box.id, title: _titleController.text);
    }
    Navigator.of(context).pop();
  }
}

class _TimeBoxTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputAction textInputAction;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;

  const _TimeBoxTextField({
    required this.controller,
    required this.label,
    required this.textInputAction,
    this.autofocus = false,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorColor: const Color(0xFFF6F3EC),
      textInputAction: textInputAction,
      autofocus: autofocus,
      onSubmitted: onSubmitted,
      maxLines: 1,
      style: const TextStyle(
        color: Color(0xFFF6F3EC),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.46),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFF6F3EC)),
        ),
      ),
    );
  }
}
