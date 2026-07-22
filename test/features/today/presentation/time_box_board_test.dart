import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_boxing_pomodoro/features/focus/application/pomodoro_controller.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/entities/pomodoro.dart';
import 'package:time_boxing_pomodoro/features/today/presentation/widgets/time_box_board.dart';
import 'package:time_boxing_pomodoro/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('renders and edits a 15-minute card without overflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final pomodoro = Pomodoro.initial().copyWith(
      timeBoxes: const [
        TimeBox(
          id: 'quick-review',
          title: 'Quick review',
          timeRange: '07:00-07:15',
          durationSeconds: 15 * 60,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pomodoroControllerProvider.overrideWith(
            () => _TestPomodoroController(pomodoro),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            backgroundColor: const Color(0xFF080808),
            body: SingleChildScrollView(
              child: Consumer(
                builder: (context, ref, child) {
                  return TimeBoxBoard(
                    pomodoro: ref.watch(pomodoroControllerProvider),
                    notifier: ref.read(pomodoroControllerProvider.notifier),
                    now: DateTime(2026, 7, 23, 7, 7),
                    awakeStartMinutes: 7 * 60,
                    awakeEndMinutes: 9 * 60,
                    slotMinutes: 15,
                    onDragStarted: () {},
                    onDragUpdate: (_) {},
                    onDragEnd: () {},
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Quick review'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Quick review'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
    expect(find.byIcon(Icons.unfold_more_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.unfold_more_rounded));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('does not treat a partially occupied 1-hour slot as empty', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final pomodoro = Pomodoro.initial().copyWith(
      timeBoxes: const [
        TimeBox(
          id: 'half-hour',
          title: 'Existing plan',
          timeRange: '09:30-10:00',
          durationSeconds: 30 * 60,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pomodoroControllerProvider.overrideWith(
            () => _TestPomodoroController(pomodoro),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            backgroundColor: const Color(0xFF080808),
            body: Consumer(
              builder: (context, ref, child) {
                return TimeBoxBoard(
                  pomodoro: ref.watch(pomodoroControllerProvider),
                  notifier: ref.read(pomodoroControllerProvider.notifier),
                  now: DateTime(2026, 7, 23, 9, 45),
                  awakeStartMinutes: 9 * 60,
                  awakeEndMinutes: 11 * 60,
                  slotMinutes: 60,
                  onDragStarted: () {},
                  onDragUpdate: (_) {},
                  onDragEnd: () {},
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('timebox_slot_540')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('timebox_save')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

class _TestPomodoroController extends PomodoroController {
  final Pomodoro initialState;

  _TestPomodoroController(this.initialState);

  @override
  Pomodoro build() => initialState;
}
