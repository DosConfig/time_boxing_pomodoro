import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_boxing_pomodoro/features/focus/presentation/controllers/pomodoro_controller.dart';
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
                    // A 15-minute card on a coarser grid is the smallest card
                    // the board can render and exercises the compact layout.
                    slotMinutes: 30,
                    loadingCarryOverSection: null,
                    onCarryOverPressed: (_) {},
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

  testWidgets('card body stays draggable while resize mode is active', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var dragStarted = false;
    final pomodoro = Pomodoro.initial().copyWith(
      timeBoxes: const [
        TimeBox(
          id: 'deep-work',
          title: 'Deep work',
          timeRange: '07:00-09:00',
          durationSeconds: 120 * 60,
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
                builder: (context, ref, child) => TimeBoxBoard(
                  pomodoro: ref.watch(pomodoroControllerProvider),
                  notifier: ref.read(pomodoroControllerProvider.notifier),
                  now: DateTime(2026, 7, 23, 7, 30),
                  awakeStartMinutes: 7 * 60,
                  awakeEndMinutes: 10 * 60,
                  slotMinutes: 30,
                  loadingCarryOverSection: null,
                  onCarryOverPressed: (_) {},
                  onDragStarted: () => dragStarted = true,
                  onDragUpdate: (_) {},
                  onDragEnd: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Deep work'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.unfold_more_rounded));
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Deep work')),
    );
    await tester.pump(const Duration(milliseconds: 260));
    await gesture.moveBy(const Offset(0, 30));
    await tester.pump();

    expect(dragStarted, isTrue);
    final feedbackRect = tester.getRect(
      find.byKey(const ValueKey('timeBoxDragFeedback-deep-work')),
    );
    final pointerPosition =
        tester.getCenter(find.text('Deep work').first) + const Offset(0, 30);
    expect(
      feedbackRect.contains(pointerPosition),
      isTrue,
      reason: 'the compact drag preview should stay under the thumb',
    );
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets(
    'tall card moves one slot while the pointer stays inside its old bounds',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final pomodoro = Pomodoro.initial().copyWith(
        timeBoxes: const [
          TimeBox(
            id: 'deep-work',
            title: 'Deep work',
            timeRange: '07:00-09:00',
            durationSeconds: 120 * 60,
          ),
        ],
      );
      final controller = _TestPomodoroController(pomodoro);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pomodoroControllerProvider.overrideWith(() => controller),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              backgroundColor: const Color(0xFF080808),
              body: Consumer(
                builder: (context, ref, child) => TimeBoxBoard(
                  pomodoro: ref.watch(pomodoroControllerProvider),
                  notifier: ref.read(pomodoroControllerProvider.notifier),
                  now: DateTime(2026, 7, 23, 7, 30),
                  awakeStartMinutes: 7 * 60,
                  awakeEndMinutes: 11 * 60,
                  slotMinutes: 30,
                  loadingCarryOverSection: null,
                  onCarryOverPressed: (_) {},
                  onDragStarted: () {},
                  onDragUpdate: (_) {},
                  onDragEnd: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final originalRect = tester.getRect(
        find.byKey(const ValueKey('deep-work')),
      );
      final start = originalRect.center;
      final gesture = await tester.startGesture(start);
      await tester.pump(const Duration(milliseconds: 260));

      // 한 칸(30분)만 내리면 포인터는 여전히 높이가 큰 원래 카드 안에 있다.
      // childWhenDragging이 hit test를 가로막으면 아래 DragTarget이 drop을
      // 받지 못해 이 이동이 무시된다.
      const oneSlot = Offset(0, 70);
      final dropPosition = start + oneSlot;
      expect(originalRect.contains(dropPosition), isTrue);
      await gesture.moveBy(oneSlot);
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(controller.movedId, 'deep-work');
      expect(controller.movedStartMinutes, 7 * 60 + 30);
    },
  );

  test('wraps early-morning minutes into a past-midnight window', () {
    // 창이 09:00~26:00일 때 01:00(60분)은 25:00(1500분)으로 보정된다.
    expect(wrapMinutesForWindow(60, 26 * 60), 25 * 60);
    // 창 밖 이른 아침(06:00)은 그대로 둔다.
    expect(wrapMinutesForWindow(6 * 60, 26 * 60), 6 * 60);
    // 자정을 넘지 않는 창에서는 아무것도 바꾸지 않는다.
    expect(wrapMinutesForWindow(60, 23 * 60), 60);
  });

  testWidgets('renders an after-midnight card inside an extended window', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final pomodoro = Pomodoro.initial().copyWith(
      timeBoxes: const [
        TimeBox(
          id: 'late-night',
          title: 'Night review',
          timeRange: '01:00-01:30',
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
            body: SingleChildScrollView(
              child: Consumer(
                builder: (context, ref, child) {
                  return TimeBoxBoard(
                    pomodoro: ref.watch(pomodoroControllerProvider),
                    notifier: ref.read(pomodoroControllerProvider.notifier),
                    now: DateTime(2026, 7, 23, 23, 30),
                    awakeStartMinutes: 22 * 60,
                    awakeEndMinutes: 26 * 60,
                    slotMinutes: 30,
                    loadingCarryOverSection: null,
                    onCarryOverPressed: (_) {},
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

    expect(find.text('Night review'), findsOneWidget);
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
                  loadingCarryOverSection: null,
                  onCarryOverPressed: (_) {},
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
  String? movedId;
  int? movedStartMinutes;

  _TestPomodoroController(this.initialState);

  @override
  Pomodoro build() => initialState;

  @override
  void moveTimeBoxToStart(String id, int startMinutes) {
    movedId = id;
    movedStartMinutes = startMinutes;
  }
}
