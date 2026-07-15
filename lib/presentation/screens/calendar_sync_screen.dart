import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/pomodoro.dart';
import '../providers/pomodoro_provider.dart';

enum _SyncMode { manual, automatic }

class CalendarSyncScreen extends ConsumerStatefulWidget {
  const CalendarSyncScreen({super.key});

  @override
  ConsumerState<CalendarSyncScreen> createState() => _CalendarSyncScreenState();
}

class _CalendarSyncScreenState extends ConsumerState<CalendarSyncScreen> {
  _SyncMode _syncMode = _SyncMode.manual;
  bool _topPrioritiesOnly = false;
  bool _conflictCheck = true;
  bool _dedicatedCalendar = true;
  bool _includeBreaks = false;

  @override
  Widget build(BuildContext context) {
    final pomodoro = ref.watch(pomodoroProvider);

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
                    _SyncModePanel(
                      mode: _syncMode,
                      onModeChanged: (mode) => setState(() {
                        _syncMode = mode;
                      }),
                    ),
                    const SizedBox(height: 14),
                    _ProviderSection(onPending: _showPendingConnection),
                    const SizedBox(height: 14),
                    _ExportRulesPanel(
                      topPrioritiesOnly: _topPrioritiesOnly,
                      conflictCheck: _conflictCheck,
                      dedicatedCalendar: _dedicatedCalendar,
                      includeBreaks: _includeBreaks,
                      onTopPrioritiesOnlyChanged: (value) => setState(() {
                        _topPrioritiesOnly = value;
                      }),
                      onConflictCheckChanged: (value) => setState(() {
                        _conflictCheck = value;
                      }),
                      onDedicatedCalendarChanged: (value) => setState(() {
                        _dedicatedCalendar = value;
                      }),
                      onIncludeBreaksChanged: (value) => setState(() {
                        _includeBreaks = value;
                      }),
                    ),
                    const SizedBox(height: 14),
                    _TodayQueuePanel(
                      pomodoro: pomodoro,
                      onExport: () => _showPendingConnection('Calendar export'),
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

  void _showPendingConnection(String provider) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFF6F3EC),
        content: Text(
          '$provider setup is queued.',
          style: const TextStyle(
            color: Color(0xFF080808),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Calendar',
          style: TextStyle(
            color: Color(0xFFF6F3EC),
            fontSize: 38,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Today plan sync',
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

class _SyncModePanel extends StatelessWidget {
  final _SyncMode mode;
  final ValueChanged<_SyncMode> onModeChanged;

  const _SyncModePanel({required this.mode, required this.onModeChanged});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(title: 'Sync mode'),
          const SizedBox(height: 14),
          SegmentedButton<_SyncMode>(
            segments: const [
              ButtonSegment(
                value: _SyncMode.manual,
                label: Text('Manual'),
                icon: Icon(Icons.touch_app_rounded),
              ),
              ButtonSegment(
                value: _SyncMode.automatic,
                label: Text('Auto'),
                icon: Icon(Icons.sync_rounded),
              ),
            ],
            selected: {mode},
            onSelectionChanged: (selection) => onModeChanged(selection.first),
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? const Color(0xFF080808)
                    : const Color(0xFFF6F3EC);
              }),
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? const Color(0xFFF6F3EC)
                    : Colors.transparent;
              }),
              side: WidgetStatePropertyAll(
                BorderSide(color: Colors.white.withValues(alpha: 0.15)),
              ),
              textStyle: const WidgetStatePropertyAll(
                TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderSection extends StatelessWidget {
  final ValueChanged<String> onPending;

  const _ProviderSection({required this.onPending});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 680;
        final cards = [
          _ProviderCard(
            icon: Icons.calendar_month_rounded,
            title: 'Apple Calendar',
            badge: 'Free',
            status: 'Local',
            actionLabel: 'Set up',
            onTap: () => onPending('Apple Calendar'),
          ),
          _ProviderCard(
            icon: Icons.cloud_rounded,
            title: 'Google Calendar',
            badge: 'Pro',
            status: 'Firebase',
            actionLabel: 'Connect',
            onTap: () => onPending('Google Calendar'),
          ),
          _ProviderCard(
            icon: Icons.apartment_rounded,
            title: 'Outlook',
            badge: 'Pro',
            status: 'OAuth',
            actionLabel: 'Connect',
            onTap: () => onPending('Outlook'),
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionTitle(title: 'Providers'),
            const SizedBox(height: 10),
            if (twoColumns)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final card in cards)
                    SizedBox(
                      width: (constraints.maxWidth - 10) / 2,
                      child: card,
                    ),
                ],
              )
            else
              Column(
                children: [
                  for (final card in cards) ...[
                    card,
                    if (card != cards.last) const SizedBox(height: 10),
                  ],
                ],
              ),
          ],
        );
      },
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String badge;
  final String status;
  final String actionLabel;
  final VoidCallback onTap;

  const _ProviderCard({
    required this.icon,
    required this.title,
    required this.badge,
    required this.status,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.055),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _IconTile(icon: icon),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFF6F3EC),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF8A8A8A),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _Badge(label: badge),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      actionLabel,
                      style: const TextStyle(
                        color: Color(0xFFF6F3EC),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFFF6F3EC),
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExportRulesPanel extends StatelessWidget {
  final bool topPrioritiesOnly;
  final bool conflictCheck;
  final bool dedicatedCalendar;
  final bool includeBreaks;
  final ValueChanged<bool> onTopPrioritiesOnlyChanged;
  final ValueChanged<bool> onConflictCheckChanged;
  final ValueChanged<bool> onDedicatedCalendarChanged;
  final ValueChanged<bool> onIncludeBreaksChanged;

  const _ExportRulesPanel({
    required this.topPrioritiesOnly,
    required this.conflictCheck,
    required this.dedicatedCalendar,
    required this.includeBreaks,
    required this.onTopPrioritiesOnlyChanged,
    required this.onConflictCheckChanged,
    required this.onDedicatedCalendarChanged,
    required this.onIncludeBreaksChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(title: 'Export rules'),
          const SizedBox(height: 6),
          _RuleSwitch(
            label: 'Top priorities only',
            value: topPrioritiesOnly,
            onChanged: onTopPrioritiesOnlyChanged,
          ),
          _RuleSwitch(
            label: 'Conflict check',
            value: conflictCheck,
            onChanged: onConflictCheckChanged,
          ),
          _RuleSwitch(
            label: 'Dedicated calendar',
            value: dedicatedCalendar,
            onChanged: onDedicatedCalendarChanged,
          ),
          _RuleSwitch(
            label: 'Include breaks',
            value: includeBreaks,
            onChanged: onIncludeBreaksChanged,
          ),
        ],
      ),
    );
  }
}

class _TodayQueuePanel extends StatelessWidget {
  final Pomodoro pomodoro;
  final VoidCallback onExport;

  const _TodayQueuePanel({required this.pomodoro, required this.onExport});

  @override
  Widget build(BuildContext context) {
    final boxes = pomodoro.timeBoxes.take(4).toList();

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: _SectionTitle(title: 'Today queue')),
              _Badge(label: '${pomodoro.timeBoxes.length} boxes'),
            ],
          ),
          const SizedBox(height: 12),
          if (boxes.isEmpty)
            Text(
              'No boxes',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.48),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            Column(children: [for (final box in boxes) _QueueRow(box: box)]),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onExport,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF6F3EC),
              foregroundColor: const Color(0xFF080808),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.ios_share_rounded),
            label: const Text(
              'Export selected',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueRow extends StatelessWidget {
  final TimeBox box;

  const _QueueRow({required this.box});

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
              box.title,
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

class _RuleSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _RuleSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFF6F3EC),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      value: value,
      activeTrackColor: const Color(0xFFF6F3EC),
      activeThumbColor: const Color(0xFF0A0A0A),
      inactiveTrackColor: Colors.white.withValues(alpha: 0.18),
      inactiveThumbColor: const Color(0xFFF6F3EC),
      onChanged: onChanged,
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
