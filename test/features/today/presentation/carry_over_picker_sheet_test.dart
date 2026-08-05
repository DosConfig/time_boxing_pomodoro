import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_boxing_pomodoro/features/focus/application/pomodoro_controller.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/entities/pomodoro.dart';
import 'package:time_boxing_pomodoro/features/today/presentation/widgets/carry_over_picker_sheet.dart';
import 'package:time_boxing_pomodoro/features/today/presentation/widgets/daily_carry_over_button.dart';
import 'package:time_boxing_pomodoro/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('rapid taps open only one carry-over sheet', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final loadCompleter = Completer<Pomodoro?>();
    final controller = _CarryOverTestController(
      loadPreviousDay: () => loadCompleter.future,
    );

    await tester.pumpWidget(_testApp(controller));

    await tester.tap(find.byType(TextButton));
    await tester.pump();

    final disabledButton = tester.widget<TextButton>(find.byType(TextButton));
    expect(disabledButton.onPressed, isNull);
    expect(find.byKey(const ValueKey('dailyCarryOverLoading')), findsOneWidget);

    await tester.tap(find.byType(TextButton), warnIfMissed: false);
    await tester.pump();
    expect(controller.previousDayLoadCalls, 1);

    loadCompleter.complete(_planWithTimeBoxes(4));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('어제 타임박스 불러오기'), findsOneWidget);
    expect(find.byKey(const ValueKey('carryOverPickerSheet')), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
  });

  testWidgets('a long card list stays inside the safe area and scrolls', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(top: 47, bottom: 34);
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      tester.view.resetPadding();
      tester.view.resetViewPadding();
    });

    final controller = _CarryOverTestController(
      loadPreviousDay: () async => _planWithTimeBoxes(24),
    );

    await tester.pumpWidget(_testApp(controller));
    await tester.tap(find.byType(TextButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final sheetRect = tester.getRect(
      find.byKey(const ValueKey('carryOverPickerSheet')),
    );
    final importButtonRect = tester.getRect(
      find.byKey(const ValueKey('carryOverImportSelected')),
    );
    final logicalTopInset =
        tester.view.padding.top / tester.view.devicePixelRatio;
    final logicalBottomInset =
        tester.view.padding.bottom / tester.view.devicePixelRatio;

    expect(sheetRect.top, greaterThanOrEqualTo(logicalTopInset));
    expect(sheetRect.height, lessThanOrEqualTo(844 * 0.82 + 1));
    expect(
      importButtonRect.bottom,
      lessThanOrEqualTo(844 - logicalBottomInset + 1),
    );
    expect(find.byType(ListView), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
  });
}

Widget _testApp(_CarryOverTestController controller) {
  return MaterialApp(
    locale: const Locale('ko'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: _CarryOverTestScreen(controller: controller),
  );
}

class _CarryOverTestScreen extends StatefulWidget {
  const _CarryOverTestScreen({required this.controller});

  final _CarryOverTestController controller;

  @override
  State<_CarryOverTestScreen> createState() => _CarryOverTestScreenState();
}

class _CarryOverTestScreenState extends State<_CarryOverTestScreen> {
  CarryOverSection? _loadingSection;

  Future<void> _openPicker() async {
    if (_loadingSection != null) {
      return;
    }
    setState(() => _loadingSection = CarryOverSection.timeBox);

    Pomodoro? sourcePlan;
    try {
      sourcePlan = await widget.controller.loadPreviousDayPlanSnapshot();
    } finally {
      if (mounted) {
        setState(() => _loadingSection = null);
      }
    }

    if (!mounted) {
      return;
    }
    await showCarryOverPickerSheet(
      context,
      notifier: widget.controller,
      section: CarryOverSection.timeBox,
      sourcePlan: sourcePlan,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.centerLeft,
        child: DailyCarryOverButton(
          key: const ValueKey('openCarryOver'),
          label: 'Open',
          isLoading: _loadingSection == CarryOverSection.timeBox,
          onPressed: _loadingSection == null ? _openPicker : null,
        ),
      ),
    );
  }
}

Pomodoro _planWithTimeBoxes(int count) {
  return Pomodoro.initial().copyWith(
    timeBoxes: List.generate(count, (index) {
      final startMinutes = 7 * 60 + index * 30;
      return TimeBox(
        id: 'box-$index',
        title: 'Task $index',
        timeRange: '${_clock(startMinutes)}-${_clock(startMinutes + 30)}',
        durationSeconds: 30 * 60,
      );
    }),
  );
}

String _clock(int minutes) {
  final normalized = minutes % (24 * 60);
  final hour = (normalized ~/ 60).toString().padLeft(2, '0');
  final minute = (normalized % 60).toString().padLeft(2, '0');
  return '$hour:$minute';
}

class _CarryOverTestController extends PomodoroController {
  final Future<Pomodoro?> Function() loadPreviousDay;
  int previousDayLoadCalls = 0;

  _CarryOverTestController({required this.loadPreviousDay});

  @override
  Pomodoro build() => Pomodoro.initial();

  @override
  Future<Pomodoro?> loadPreviousDayPlanSnapshot() {
    previousDayLoadCalls += 1;
    return loadPreviousDay();
  }

  @override
  bool importTimeBoxes(List<TimeBox> imported) => imported.isNotEmpty;
}
