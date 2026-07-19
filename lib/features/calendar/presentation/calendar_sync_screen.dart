import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_method_channel/l10n/l10n.dart';

import '../../focus/application/pomodoro_controller.dart';
import '../../focus/domain/entities/pomodoro.dart';
import '../../focus/presentation/time_box_title_l10n.dart';
import '../application/calendar_export_controller.dart';
import '../domain/entities/calendar_export.dart';

class CalendarSyncScreen extends ConsumerWidget {
  const CalendarSyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomodoro = ref.watch(pomodoroControllerProvider);
    final exportState = ref.watch(calendarExportControllerProvider);
    final exporting = exportState.isLoading;

    return SafeArea(
      child: ScrollConfiguration(
        behavior: const _CalendarScrollBehavior(),
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 32),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _ScreenHeader(),
                    const SizedBox(height: 20),
                    const _AppleCalendarPanel(),
                    const SizedBox(height: 14),
                    const _GoogleCalendarPanel(),
                    const SizedBox(height: 14),
                    _TodayQueuePanel(
                      pomodoro: pomodoro,
                      exporting: exporting,
                      onExportApple: () => _exportToday(
                        context: context,
                        ref: ref,
                        pomodoro: pomodoro,
                        provider: CalendarProvider.apple,
                      ),
                      onExportGoogle: () => _exportToday(
                        context: context,
                        ref: ref,
                        pomodoro: pomodoro,
                        provider: CalendarProvider.google,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportToday({
    required BuildContext context,
    required WidgetRef ref,
    required Pomodoro pomodoro,
    required CalendarProvider provider,
  }) async {
    final request = _CalendarExportRequestFactory.build(
      context,
      pomodoro,
      DateTime.now(),
      provider,
    );
    if (request.items.isEmpty) {
      _showExportSnack(context, context.l10n.calendarExportEmpty);
      return;
    }

    HapticFeedback.mediumImpact();
    final controller = ref.read(calendarExportControllerProvider.notifier);
    final result = switch (provider) {
      CalendarProvider.apple => await controller.exportAppleToday(request),
      CalendarProvider.google => await controller.exportGoogleToday(request),
    };
    if (!context.mounted) {
      return;
    }
    _showExportSnack(
      context,
      _CalendarExportMessage.fromResult(context, result),
    );
  }
}

class _CalendarExportRequestFactory {
  static CalendarExportRequest build(
    BuildContext context,
    Pomodoro pomodoro,
    DateTime date,
    CalendarProvider provider,
  ) {
    final items = <CalendarExportItem>[];
    for (final box in pomodoro.timeBoxes) {
      final item = _CalendarExportItemFactory.build(
        context,
        pomodoro,
        box,
        date,
      );
      if (item != null) {
        items.add(item);
      }
    }

    return CalendarExportRequest(
      provider: provider,
      dateKey: _CalendarDateKey.format(date),
      items: items,
    );
  }
}

class _CalendarExportItemFactory {
  static CalendarExportItem? build(
    BuildContext context,
    Pomodoro pomodoro,
    TimeBox box,
    DateTime date,
  ) {
    final startMinutes = box.startMinutes;
    final endMinutes = box.endMinutes;
    if (startMinutes == null || endMinutes == null) {
      return null;
    }

    final dayStart = DateTime(date.year, date.month, date.day);
    return CalendarExportItem(
      timeBoxId: box.id,
      title: _CalendarTimeBoxTitle.resolve(context, pomodoro, box),
      startAt: dayStart.add(Duration(minutes: startMinutes)),
      endAt: dayStart.add(Duration(minutes: endMinutes)),
      notes: context.l10n.appName,
    );
  }
}

class _CalendarTimeBoxTitle {
  static String resolve(BuildContext context, Pomodoro pomodoro, TimeBox box) {
    if (box.id == 'box-0900' && pomodoro.topPriorities.isNotEmpty) {
      final priority = pomodoro.topPriorities[0].trim();
      if (priority.isNotEmpty) {
        return priority;
      }
    }

    if (box.id == 'box-1330' && pomodoro.topPriorities.length > 1) {
      final priority = pomodoro.topPriorities[1].trim();
      if (priority.isNotEmpty) {
        return priority;
      }
    }

    return localizedTimeBoxTitle(context, box);
  }
}

class _CalendarDateKey {
  static String format(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

class _CalendarExportMessage {
  static String fromResult(BuildContext context, CalendarExportResult result) {
    final l10n = context.l10n;
    return switch (result.status) {
      CalendarExportStatus.success => l10n.calendarExportSuccess(
        result.mappings.length,
      ),
      CalendarExportStatus.denied => l10n.calendarExportDenied,
      CalendarExportStatus.unavailable => l10n.calendarExportUnavailable,
      CalendarExportStatus.failed => l10n.calendarExportFailed,
      CalendarExportStatus.idle => l10n.calendarExportFailed,
    };
  }
}

void _showExportSnack(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFFF6F3EC),
      content: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF080808),
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.calendarTitle,
          style: TextStyle(
            color: Color(0xFFF6F3EC),
            fontSize: 38,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        SizedBox(height: 10),
        Text(
          l10n.todayPlanSync,
          style: TextStyle(
            color: Color(0xFF8A8A8A),
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _AppleCalendarPanel extends StatelessWidget {
  const _AppleCalendarPanel();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        children: [
          const _IconTile(icon: Icons.calendar_month_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.providerAppleCalendar,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF6F3EC),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  context.l10n.appleCalendarExportDescription,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.52),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _Badge(label: context.l10n.statusLocal),
        ],
      ),
    );
  }
}

class _GoogleCalendarPanel extends StatelessWidget {
  const _GoogleCalendarPanel();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        children: [
          const _IconTile(icon: Icons.cloud_sync_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.providerGoogleCalendar,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF6F3EC),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  context.l10n.googleCalendarExportDescription,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.52),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _Badge(label: context.l10n.statusOAuth),
        ],
      ),
    );
  }
}

class _TodayQueuePanel extends StatelessWidget {
  final Pomodoro pomodoro;
  final bool exporting;
  final VoidCallback onExportApple;
  final VoidCallback onExportGoogle;

  const _TodayQueuePanel({
    required this.pomodoro,
    required this.exporting,
    required this.onExportApple,
    required this.onExportGoogle,
  });

  @override
  Widget build(BuildContext context) {
    final boxes = pomodoro.timeBoxes;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _SectionTitle(title: context.l10n.todayQueueTitle),
              ),
              _Badge(label: context.l10n.boxesCount(boxes.length)),
            ],
          ),
          const SizedBox(height: 12),
          if (boxes.isEmpty)
            Text(
              context.l10n.noBoxes,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.48),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            Column(
              children: [
                for (final box in boxes)
                  _QueueRow(
                    box: box,
                    title: _CalendarTimeBoxTitle.resolve(
                      context,
                      pomodoro,
                      box,
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 14),
          _ExportButton(
            exporting: exporting,
            icon: Icons.ios_share_rounded,
            title: context.l10n.exportAppleTodayAction,
            onPressed: onExportApple,
          ),
          const SizedBox(height: 10),
          _ExportButton(
            exporting: exporting,
            icon: Icons.cloud_upload_rounded,
            title: context.l10n.exportGoogleTodayAction,
            onPressed: onExportGoogle,
          ),
        ],
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final bool exporting;
  final IconData icon;
  final String title;
  final VoidCallback onPressed;

  const _ExportButton({
    required this.exporting,
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: exporting ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFF6F3EC),
        foregroundColor: const Color(0xFF080808),
        disabledBackgroundColor: Colors.white.withValues(alpha: 0.18),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.42),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: exporting
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon),
      label: Text(
        exporting ? context.l10n.calendarExporting : title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _QueueRow extends StatelessWidget {
  final TimeBox box;
  final String title;

  const _QueueRow({required this.box, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              box.timeRange,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.48),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFF6F3EC),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFFF6F3EC),
        fontSize: 15,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class _IconTile extends StatelessWidget {
  final IconData icon;

  const _IconTile({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3EC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: const Color(0xFF080808), size: 22),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;

  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFFF6F3EC),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CalendarScrollBehavior extends MaterialScrollBehavior {
  const _CalendarScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
