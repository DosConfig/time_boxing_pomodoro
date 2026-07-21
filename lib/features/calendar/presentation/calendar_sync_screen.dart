import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_boxing_pomodoro/l10n/l10n.dart';

import '../../focus/application/pomodoro_controller.dart';
import '../../focus/domain/entities/pomodoro.dart';
import '../../focus/presentation/time_box_title_display.dart';
import '../application/calendar_export_controller.dart';
import '../domain/entities/calendar_export.dart';

class CalendarSyncScreen extends ConsumerWidget {
  const CalendarSyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomodoro = ref.watch(pomodoroControllerProvider);

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
                    const SizedBox(height: 22),
                    _ProviderSection(
                      onOpen: (provider) =>
                          _CalendarNavigation.openProvider(context, provider),
                    ),
                    const SizedBox(height: 16),
                    _TodayQueuePanel(pomodoro: pomodoro),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarNavigation {
  static Future<void> openProvider(
    BuildContext context,
    CalendarProvider provider,
  ) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _CalendarProviderExportScreen(provider: provider),
      ),
    );
  }
}

class _CalendarProviderExportScreen extends ConsumerWidget {
  final CalendarProvider provider;

  const _CalendarProviderExportScreen({required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomodoro = ref.watch(pomodoroControllerProvider);
    final exportState = ref.watch(calendarExportControllerProvider(provider));

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080808),
        foregroundColor: const Color(0xFFF6F3EC),
        elevation: 0,
        title: Text(
          _CalendarProviderCopy.title(context, provider),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ScrollConfiguration(
          behavior: const _CalendarScrollBehavior(),
          child: ListView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            children: [
              _ProviderGuidePanel(provider: provider),
              const SizedBox(height: 16),
              _TodayQueuePanel(
                pomodoro: pomodoro,
                exportProvider: provider,
                exporting: exportState.isLoading,
                onExport: () => _CalendarExportCoordinator.exportToday(
                  context: context,
                  ref: ref,
                  pomodoro: pomodoro,
                  provider: provider,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarExportCoordinator {
  static Future<void> exportToday({
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
      _CalendarSnackBar.show(context, context.l10n.calendarExportEmpty);
      return;
    }

    HapticFeedback.mediumImpact();
    try {
      final controller = ref.read(
        calendarExportControllerProvider(provider).notifier,
      );
      final result = await controller.exportToday(request);
      if (!context.mounted) {
        return;
      }
      _CalendarSnackBar.showExportResult(
        context: context,
        result: result,
        onOpenCalendar: result.isSuccess
            ? () => openCalendar(context: context, ref: ref, provider: provider)
            : null,
      );
    } catch (_) {
      if (context.mounted) {
        _CalendarSnackBar.show(context, context.l10n.calendarExportFailed);
      }
    }
  }

  static Future<void> openCalendar({
    required BuildContext context,
    required WidgetRef ref,
    required CalendarProvider provider,
  }) async {
    final result = await ref
        .read(calendarExportControllerProvider(provider).notifier)
        .openCalendar();
    if (!context.mounted) {
      return;
    }
    if (result.status == CalendarAppOpenStatus.unavailable ||
        result.status == CalendarAppOpenStatus.failed) {
      _CalendarSnackBar.show(context, context.l10n.calendarOpenFailed);
    }
  }
}

class _CalendarSnackBar {
  static void show(BuildContext context, String message) {
    _show(context: context, message: message);
  }

  static void showExportResult({
    required BuildContext context,
    required CalendarExportResult result,
    required VoidCallback? onOpenCalendar,
  }) {
    _show(
      context: context,
      message: _CalendarExportMessage.fromResult(context, result),
      action: onOpenCalendar == null
          ? null
          : SnackBarAction(
              label: context.l10n.openCalendarAction,
              textColor: const Color(0xFF080808),
              onPressed: onOpenCalendar,
            ),
    );
  }

  static void _show({
    required BuildContext context,
    required String message,
    SnackBarAction? action,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFF6F3EC),
        action: action,
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
      title: _CalendarTimeBoxTitle.resolve(pomodoro, box),
      startAt: dayStart.add(Duration(minutes: startMinutes)),
      endAt: dayStart.add(Duration(minutes: endMinutes)),
      notes: context.l10n.appName,
    );
  }
}

class _CalendarTimeBoxTitle {
  static String resolve(Pomodoro pomodoro, TimeBox box) {
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

    return displayTimeBoxTitle(box);
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
      CalendarExportStatus.success when result.exportedCount == 0 =>
        l10n.calendarExportAlreadySynced,
      CalendarExportStatus.success => l10n.calendarExportSuccess(
        result.exportedCount,
      ),
      CalendarExportStatus.denied => l10n.calendarExportDenied,
      CalendarExportStatus.unavailable => l10n.calendarExportUnavailable,
      CalendarExportStatus.failed => l10n.calendarExportFailed,
      CalendarExportStatus.idle => l10n.calendarExportFailed,
    };
  }
}

class _CalendarProviderCopy {
  static String title(BuildContext context, CalendarProvider provider) {
    return switch (provider) {
      CalendarProvider.apple => context.l10n.providerAppleCalendar,
      CalendarProvider.google => context.l10n.providerGoogleCalendar,
    };
  }

  static String description(BuildContext context, CalendarProvider provider) {
    return switch (provider) {
      CalendarProvider.apple => context.l10n.appleCalendarExportDescription,
      CalendarProvider.google => context.l10n.googleCalendarExportDescription,
    };
  }

  static String status(BuildContext context, CalendarProvider provider) {
    return switch (provider) {
      CalendarProvider.apple => context.l10n.statusLocal,
      CalendarProvider.google => context.l10n.statusOAuth,
    };
  }

  static IconData icon(CalendarProvider provider) {
    return switch (provider) {
      CalendarProvider.apple => Icons.calendar_month_rounded,
      CalendarProvider.google => Icons.cloud_sync_rounded,
    };
  }

  static String exportAction(BuildContext context, CalendarProvider provider) {
    return switch (provider) {
      CalendarProvider.apple => context.l10n.exportAppleTodayAction,
      CalendarProvider.google => context.l10n.exportGoogleTodayAction,
    };
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.calendarTitle,
          style: const TextStyle(
            color: Color(0xFFF6F3EC),
            fontSize: 38,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          context.l10n.todayPlanSync,
          style: const TextStyle(
            color: Color(0xFF8A8A8A),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ProviderSection extends StatelessWidget {
  final ValueChanged<CalendarProvider> onOpen;

  const _ProviderSection({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final showApple = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(title: context.l10n.providersTitle),
        const SizedBox(height: 6),
        Text(
          context.l10n.calendarProviderSelectDescription,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.48),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        if (showApple) ...[
          _CalendarProviderPanel(
            provider: CalendarProvider.apple,
            onTap: () => onOpen(CalendarProvider.apple),
          ),
          const SizedBox(height: 12),
        ],
        _CalendarProviderPanel(
          provider: CalendarProvider.google,
          onTap: () => onOpen(CalendarProvider.google),
        ),
      ],
    );
  }
}

class _CalendarProviderPanel extends StatelessWidget {
  final CalendarProvider provider;
  final VoidCallback onTap;

  const _CalendarProviderPanel({required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.055),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _IconTile(icon: _CalendarProviderCopy.icon(provider)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _CalendarProviderCopy.title(context, provider),
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
                      _CalendarProviderCopy.description(context, provider),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
              _Badge(label: _CalendarProviderCopy.status(context, provider)),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF8A8A8A)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderGuidePanel extends StatelessWidget {
  final CalendarProvider provider;

  const _ProviderGuidePanel({required this.provider});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconTile(icon: _CalendarProviderCopy.icon(provider)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.calendarExport,
                  style: const TextStyle(
                    color: Color(0xFFF6F3EC),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _Badge(label: _CalendarProviderCopy.status(context, provider)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _CalendarProviderCopy.description(context, provider),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          _GuideRule(
            icon: Icons.copy_all_rounded,
            title: context.l10n.conflictCheck,
            description: context.l10n.calendarDuplicateProtectionDescription,
          ),
        ],
      ),
    );
  }
}

class _GuideRule extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _GuideRule({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFFF6F3EC)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFF6F3EC),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.48),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodayQueuePanel extends StatelessWidget {
  final Pomodoro pomodoro;
  final CalendarProvider? exportProvider;
  final bool exporting;
  final VoidCallback? onExport;

  const _TodayQueuePanel({
    required this.pomodoro,
    this.exportProvider,
    this.exporting = false,
    this.onExport,
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
                    title: _CalendarTimeBoxTitle.resolve(pomodoro, box),
                  ),
              ],
            ),
          if (exportProvider != null && onExport != null) ...[
            const SizedBox(height: 14),
            _ExportButton(
              exporting: exporting,
              icon: exportProvider == CalendarProvider.apple
                  ? Icons.ios_share_rounded
                  : Icons.cloud_upload_rounded,
              title: _CalendarProviderCopy.exportAction(
                context,
                exportProvider!,
              ),
              onPressed: onExport!,
            ),
          ],
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
      constraints: const BoxConstraints(maxWidth: 84),
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
