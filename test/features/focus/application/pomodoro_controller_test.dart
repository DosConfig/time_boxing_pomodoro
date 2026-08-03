import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_boxing_pomodoro/features/settings/application/app_preferences_controller.dart';
import 'package:time_boxing_pomodoro/features/focus/application/pomodoro_controller.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/entities/daily_plan_summary.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/entities/daily_plan_item_category.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/entities/native_timer_copy.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/entities/live_activity_push_registration.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/entities/pomodoro.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/repositories/pomodoro_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // 슬롯 휴식 정책이 앱 설정 provider를 읽으므로 모든 테스트에서 필요하다.
    SharedPreferences.setMockInitialValues({});
  });

  group('PomodoroController time box editing', () {
    test('creates boxes with 15-minute and 1-hour intervals', () async {
      final repository = _MemoryPomodoroRepository(Pomodoro.initial());
      final container = ProviderContainer(
        overrides: [pomodoroRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final controller = container.read(pomodoroControllerProvider.notifier);
      await _settleControllerRestore();

      final shortBox = controller.addTimeBoxAtStart(
        (9 * 60) + 15,
        title: 'Quick review',
        durationSeconds: 15 * 60,
        durationStepMinutes: 15,
      );
      final longBox = controller.addTimeBoxAtStart(
        11 * 60,
        title: 'Deep work',
        durationSeconds: 60 * 60,
        durationStepMinutes: 60,
      );

      expect(shortBox.timeRange, '09:15-09:30');
      expect(shortBox.durationSeconds, 15 * 60);
      expect(longBox.timeRange, '11:00-12:00');
      expect(longBox.durationSeconds, 60 * 60);
      expect(
        container.read(pomodoroControllerProvider).autoStartFocus,
        isTrue,
        reason: 'registering a card should enable schedule Live tracking',
      );
    });

    test('deleting a recurring card permanently cancels its series', () async {
      final repository = _MemoryPomodoroRepository(
        Pomodoro.initial().copyWith(
          timeBoxes: const [
            TimeBox(
              id: 'daily-card',
              title: 'Daily planning',
              timeRange: '09:00-09:30',
              durationSeconds: 30 * 60,
              repeatWeekdays: [1, 2, 3, 4, 5, 6, 7],
              recurrenceId: 'daily-planning-series',
            ),
          ],
        ),
      );
      final container = ProviderContainer(
        overrides: [pomodoroRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      final controller = container.read(pomodoroControllerProvider.notifier);
      await _settleControllerRestore();

      await controller.removeTimeBox('daily-card');

      final state = container.read(pomodoroControllerProvider);
      expect(state.timeBoxes, isEmpty);
      expect(
        state.cancelledRecurrenceKeys,
        contains('id:daily-planning-series'),
      );
    });

    test('loads at most 20 distinct recent time boxes newest first', () async {
      final now = DateTime.now();
      final plansByDate = <String, Pomodoro>{};
      final history = <DailyPlanSummary>[];
      for (var back = 1; back <= 25; back += 1) {
        final dateKey = _dateKeyForTest(now.subtract(Duration(days: back)));
        history.add(DailyPlanSummary(dateKey: dateKey, plannedBoxCount: 1));
        plansByDate[dateKey] = Pomodoro.initial().copyWith(
          timeBoxes: [
            TimeBox(
              id: 'box-$back',
              title: 'Task $back',
              timeRange: '09:00-09:30',
              durationSeconds: 30 * 60,
            ),
          ],
        );
      }
      final repository = _MemoryPomodoroRepository(
        Pomodoro.initial(),
        history: history,
        plansByDate: plansByDate,
      );
      final container = ProviderContainer(
        overrides: [pomodoroRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      final controller = container.read(pomodoroControllerProvider.notifier);
      await _settleControllerRestore();

      final recent = await controller.loadRecentTimeBoxes();

      expect(recent, hasLength(20));
      expect(recent.first.title, 'Task 1');
      expect(recent.last.title, 'Task 20');
    });

    test('resizes both edges using the selected interval', () async {
      final repository = _MemoryPomodoroRepository(
        Pomodoro.initial().copyWith(
          timeBoxes: const [
            TimeBox(
              id: 'target',
              title: 'Build',
              timeRange: '09:00-11:00',
              durationSeconds: 120 * 60,
            ),
          ],
        ),
      );
      final container = ProviderContainer(
        overrides: [pomodoroRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final controller = container.read(pomodoroControllerProvider.notifier);
      await _settleControllerRestore();

      controller.resizeTimeBoxStart('target', (9 * 60) + 15, stepMinutes: 15);
      controller.resizeTimeBoxEnd('target', 12 * 60, stepMinutes: 60);

      final box = container.read(pomodoroControllerProvider).timeBoxes.single;
      expect(box.timeRange, '09:15-12:00');
      expect(box.durationSeconds, 165 * 60);
    });

    test(
      'does not persist an empty state while cloud restore is pending',
      () async {
        final restoreCompleter = Completer<Pomodoro>();
        final cloudPlan = Pomodoro.initial().copyWith(
          topPriorities: const ['Keep the cloud plan', '', ''],
        );
        final repository = _MemoryPomodoroRepository(
          Pomodoro.initial(),
          restoreCompleter: restoreCompleter,
        );
        final container = ProviderContainer(
          overrides: [pomodoroRepositoryProvider.overrideWithValue(repository)],
        );
        addTearDown(container.dispose);

        final controller = container.read(pomodoroControllerProvider.notifier);
        await Future<void>.delayed(Duration.zero);

        controller.syncDayBoundaryAndFocus();

        expect(repository.updates, isEmpty);

        restoreCompleter.complete(cloudPlan);
        await _settleControllerRestore();

        expect(
          container.read(pomodoroControllerProvider).topPriorities,
          cloudPlan.topPriorities,
        );
        expect(repository.updates, isEmpty);
      },
    );

    test(
      'keeps existing boxes when another card is dropped into them',
      () async {
        final repository = _MemoryPomodoroRepository(
          Pomodoro.initial().copyWith(
            timeBoxes: const [
              TimeBox(
                id: 'long',
                title: 'Deep work',
                timeRange: '09:00-11:00',
                durationSeconds: 120 * 60,
              ),
              TimeBox(
                id: 'move',
                title: 'Review',
                timeRange: '14:00-14:30',
                durationSeconds: 30 * 60,
              ),
            ],
          ),
        );
        final container = ProviderContainer(
          overrides: [pomodoroRepositoryProvider.overrideWithValue(repository)],
        );
        addTearDown(container.dispose);

        final controller = container.read(pomodoroControllerProvider.notifier);
        await _settleControllerRestore();

        controller.moveTimeBoxToStart('move', (9 * 60) + 30);

        final boxes = container.read(pomodoroControllerProvider).timeBoxes;
        expect(boxes, hasLength(2));
        expect(boxes[0].id, 'long');
        expect(boxes[0].timeRange, '09:00-11:00');
        expect(boxes[1].id, 'move');
        expect(boxes[1].timeRange, '14:00-14:30');
      },
    );

    test('caps resizing at the next card instead of deleting it', () async {
      final repository = _MemoryPomodoroRepository(
        Pomodoro.initial().copyWith(
          timeBoxes: const [
            TimeBox(
              id: 'target',
              title: 'Build',
              timeRange: '09:00-09:30',
              durationSeconds: 30 * 60,
            ),
            TimeBox(
              id: 'next',
              title: 'Write',
              timeRange: '10:30-11:00',
              durationSeconds: 30 * 60,
            ),
          ],
        ),
      );
      final container = ProviderContainer(
        overrides: [pomodoroRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final controller = container.read(pomodoroControllerProvider.notifier);
      await _settleControllerRestore();

      controller.resizeTimeBoxEnd('target', 11 * 60);

      final boxes = container.read(pomodoroControllerProvider).timeBoxes;
      expect(boxes, hasLength(2));
      expect(boxes[0].id, 'target');
      expect(boxes[0].timeRange, '09:00-10:30');
      expect(boxes[1].id, 'next');
      expect(boxes[1].timeRange, '10:30-11:00');
    });

    test(
      'resizes the start edge without overlapping the previous card',
      () async {
        final repository = _MemoryPomodoroRepository(
          Pomodoro.initial().copyWith(
            timeBoxes: const [
              TimeBox(
                id: 'previous',
                title: 'Plan',
                timeRange: '08:30-09:30',
                durationSeconds: 60 * 60,
              ),
              TimeBox(
                id: 'target',
                title: 'Build',
                timeRange: '10:30-12:00',
                durationSeconds: 90 * 60,
              ),
            ],
          ),
        );
        final container = ProviderContainer(
          overrides: [pomodoroRepositoryProvider.overrideWithValue(repository)],
        );
        addTearDown(container.dispose);

        final controller = container.read(pomodoroControllerProvider.notifier);
        await _settleControllerRestore();

        controller.resizeTimeBoxStart('target', 9 * 60);

        final boxes = container.read(pomodoroControllerProvider).timeBoxes;
        expect(boxes, hasLength(2));
        expect(boxes[0].timeRange, '08:30-09:30');
        expect(boxes[1].timeRange, '09:30-12:00');
      },
    );

    test('moves daily cards between planning categories', () async {
      final repository = _MemoryPomodoroRepository(
        Pomodoro.initial().copyWith(brainDump: const ['Book review']),
      );
      final container = ProviderContainer(
        overrides: [pomodoroRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final controller = container.read(pomodoroControllerProvider.notifier);
      await _settleControllerRestore();

      final moved = controller.moveDailyPlanItem(
        source: DailyPlanItemCategory.brainDump,
        index: 0,
        target: DailyPlanItemCategory.reminder,
      );

      final state = container.read(pomodoroControllerProvider);
      expect(moved, isTrue);
      expect(state.brainDump, isEmpty);
      expect(state.reminders, ['Book review']);
    });

    test('edits brain dump and reminder text in place', () async {
      final repository = _MemoryPomodoroRepository(
        Pomodoro.initial().copyWith(
          brainDump: const ['Draft note'],
          reminders: const ['Water plants'],
        ),
      );
      final container = ProviderContainer(
        overrides: [pomodoroRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final controller = container.read(pomodoroControllerProvider.notifier);
      await _settleControllerRestore();

      controller.updateDailyPlanItem(
        DailyPlanItemCategory.brainDump,
        0,
        'Draft launch note',
      );
      controller.updateDailyPlanItem(
        DailyPlanItemCategory.reminder,
        0,
        'Water plants at noon',
      );
      controller.updateDailyPlanItem(DailyPlanItemCategory.brainDump, 0, '   ');
      controller.updateDailyPlanItem(
        DailyPlanItemCategory.reminder,
        5,
        'Out of range',
      );

      final state = container.read(pomodoroControllerProvider);
      expect(state.brainDump, ['Draft launch note']);
      expect(state.reminders, ['Water plants at noon']);
    });

    test('blocks brain dump promotion when three priorities are set', () async {
      final repository = _MemoryPomodoroRepository(
        Pomodoro.initial().copyWith(
          topPriorities: const ['One', 'Two', 'Three'],
          brainDump: const ['Fourth idea'],
        ),
      );
      final container = ProviderContainer(
        overrides: [pomodoroRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final controller = container.read(pomodoroControllerProvider.notifier);
      await _settleControllerRestore();

      final promoted = controller.promoteBrainDumpItem(0);

      final state = container.read(pomodoroControllerProvider);
      expect(promoted, isFalse);
      expect(state.topPriorities, ['One', 'Two', 'Three']);
      expect(state.brainDump, ['Fourth idea']);
    });

    test('promotes a brain dump item into the first empty slot', () async {
      final repository = _MemoryPomodoroRepository(
        Pomodoro.initial().copyWith(
          topPriorities: const ['One', '', 'Three'],
          brainDump: const ['New idea'],
        ),
      );
      final container = ProviderContainer(
        overrides: [pomodoroRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final controller = container.read(pomodoroControllerProvider.notifier);
      await _settleControllerRestore();

      final promoted = controller.promoteBrainDumpItem(0);

      final state = container.read(pomodoroControllerProvider);
      expect(promoted, isTrue);
      expect(state.topPriorities, ['One', 'New idea', 'Three']);
      expect(state.brainDump, isEmpty);
    });

    test('reorders items inside each planning category', () async {
      final repository = _MemoryPomodoroRepository(
        Pomodoro.initial().copyWith(
          topPriorities: const ['First', 'Second', 'Third'],
          brainDump: const ['A', 'B', 'C'],
          reminders: const ['R1', 'R2'],
        ),
      );
      final container = ProviderContainer(
        overrides: [pomodoroRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final controller = container.read(pomodoroControllerProvider.notifier);
      await _settleControllerRestore();

      final priorityMoved = controller.reorderDailyPlanItem(
        category: DailyPlanItemCategory.topPriority,
        fromIndex: 2,
        toIndex: 0,
      );
      final dumpMoved = controller.reorderDailyPlanItem(
        category: DailyPlanItemCategory.brainDump,
        fromIndex: 0,
        toIndex: 2,
      );
      final reminderMoved = controller.reorderDailyPlanItem(
        category: DailyPlanItemCategory.reminder,
        fromIndex: 1,
        toIndex: 1,
      );

      final state = container.read(pomodoroControllerProvider);
      expect(priorityMoved, isTrue);
      expect(state.topPriorities, ['Third', 'First', 'Second']);
      expect(dumpMoved, isTrue);
      expect(state.brainDump, ['B', 'C', 'A']);
      expect(reminderMoved, isFalse);
      expect(state.reminders, ['R1', 'R2']);
    });

    test('imports selected items without duplicating existing ones', () async {
      final repository = _MemoryPomodoroRepository(
        Pomodoro.initial().copyWith(
          topPriorities: const ['Existing', '', ''],
          brainDump: const ['Existing note'],
          timeBoxes: const [
            TimeBox(
              id: 'existing-box',
              title: 'Standup',
              timeRange: '09:00-09:30',
              durationSeconds: 30 * 60,
            ),
          ],
        ),
      );
      final container = ProviderContainer(
        overrides: [pomodoroRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final controller = container.read(pomodoroControllerProvider.notifier);
      await _settleControllerRestore();

      final prioritiesImported = controller.importDailyPlanItems(
        DailyPlanItemCategory.topPriority,
        ['Ship build', 'Write recap', 'Overflow priority'],
      );
      final dumpImported = controller.importDailyPlanItems(
        DailyPlanItemCategory.brainDump,
        ['Existing note', 'Fresh idea'],
      );
      final boxesImported = controller.importTimeBoxes(const [
        TimeBox(
          id: 'prev-standup',
          title: 'Standup',
          timeRange: '09:00-09:30',
          durationSeconds: 30 * 60,
        ),
        TimeBox(
          id: 'prev-review',
          title: 'Review',
          timeRange: '10:00-10:30',
          durationSeconds: 30 * 60,
        ),
      ]);

      final state = container.read(pomodoroControllerProvider);
      expect(prioritiesImported, isTrue);
      expect(state.topPriorities, ['Existing', 'Ship build', 'Write recap']);
      expect(dumpImported, isTrue);
      expect(state.brainDump, ['Existing note', 'Fresh idea']);
      expect(boxesImported, isTrue);
      expect(state.timeBoxes, hasLength(2));
      expect(
        state.timeBoxes.map((box) => box.title).toList(),
        containsAll(['Standup', 'Review']),
      );
    });

    test('reorders priorities across an empty slot by compacting', () async {
      final repository = _MemoryPomodoroRepository(
        Pomodoro.initial().copyWith(topPriorities: const ['One', '', 'Three']),
      );
      final container = ProviderContainer(
        overrides: [pomodoroRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final controller = container.read(pomodoroControllerProvider.notifier);
      await _settleControllerRestore();

      final moved = controller.reorderDailyPlanItem(
        category: DailyPlanItemCategory.topPriority,
        fromIndex: 2,
        toIndex: 0,
      );

      final state = container.read(pomodoroControllerProvider);
      expect(moved, isTrue);
      expect(state.topPriorities, ['Three', 'One', '']);
    });

    test('moves a scheduled card back to a planning category', () async {
      final repository = _MemoryPomodoroRepository(
        Pomodoro.initial().copyWith(
          timeBoxes: const [
            TimeBox(
              id: 'scheduled',
              title: 'Call supplier',
              timeRange: '15:00-15:30',
              durationSeconds: 30 * 60,
            ),
          ],
        ),
      );
      final container = ProviderContainer(
        overrides: [pomodoroRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final controller = container.read(pomodoroControllerProvider.notifier);
      await _settleControllerRestore();

      final moved = await controller.moveTimeBoxToDailyPlanItem(
        'scheduled',
        DailyPlanItemCategory.brainDump,
      );

      final state = container.read(pomodoroControllerProvider);
      expect(moved, isTrue);
      expect(state.timeBoxes, isEmpty);
      expect(state.brainDump, ['Call supplier']);
    });

    test('starts a fresh daily plan after midnight', () async {
      var now = DateTime(2026, 7, 20, 23, 59);
      final previousDay = Pomodoro.initial().copyWith(
        brainDump: const ['Yesterday'],
        topPriorities: const ['Finish yesterday', '', ''],
      );
      final repository = _MemoryPomodoroRepository(
        previousDay,
        onRestore: (fallback, restoreCallCount) {
          return restoreCallCount == 1 ? previousDay : fallback;
        },
      );
      final container = ProviderContainer(
        overrides: [
          pomodoroRepositoryProvider.overrideWithValue(repository),
          pomodoroClockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(pomodoroControllerProvider.notifier);
      await _settleControllerRestore();
      expect(container.read(pomodoroControllerProvider).brainDump, [
        'Yesterday',
      ]);

      now = DateTime(2026, 7, 21);
      controller.syncDayBoundaryAndFocus();
      await _settleControllerRestore();

      final newDay = container.read(pomodoroControllerProvider);
      expect(newDay.brainDump, isEmpty);
      expect(newDay.topPriorities, ['', '', '']);
      expect(repository.restoreCallCount, 2);
    });

    test('computes slot break windows from the wall clock', () {
      // 간격 30분·휴식 3분: 창은 매시 27~30분.
      // 10:00:00 → 휴식 시작까지 27분, 경계까지 30분.
      var window = slotBreakWindow(10 * 3600, 30, 3);
      expect(window.secondsToBreakStart, 27 * 60);
      expect(window.secondsToBoundary, 30 * 60);

      // 10:28:00 → 휴식 창 안 (시작 -60초 전), 경계까지 120초.
      window = slotBreakWindow((10 * 3600) + (28 * 60), 30, 3);
      expect(window.secondsToBreakStart, -60);
      expect(window.secondsToBoundary, 120);

      // 간격 15분·휴식 1분: 10:14:30 → 창 안, 경계까지 30초.
      window = slotBreakWindow((10 * 3600) + (14 * 60) + 30, 15, 1);
      expect(window.secondsToBreakStart, -30);
      expect(window.secondsToBoundary, 30);

      expect(slotBreakMinutesForInterval(15), 1);
      expect(slotBreakMinutesForInterval(30), 3);
      expect(slotBreakMinutesForInterval(60), 5);
    });

    test('disabling tracking keeps a manually started session', () async {
      final now = DateTime(2026, 7, 21, 9, 15);
      final repository = _MemoryPomodoroRepository(
        Pomodoro.initial().copyWith(
          timeBoxes: const [
            TimeBox(
              id: 'current',
              title: 'Deep work',
              timeRange: '09:00-10:00',
              durationSeconds: 60 * 60,
            ),
          ],
        ),
      );
      final container = ProviderContainer(
        overrides: [
          pomodoroRepositoryProvider.overrideWithValue(repository),
          pomodoroClockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(pomodoroControllerProvider.notifier);
      await _settleControllerRestore();

      // 추적 꺼진 상태에서 수동 시작
      await controller.start(const NativeTimerCopy());
      expect(
        container.read(pomodoroControllerProvider).status,
        PomodoroStatus.running,
      );

      // 추적을 켰다가 다시 꺼도 수동 세션은 유지되어야 한다.
      await controller.setScheduleTrackingEnabled(
        true,
        const NativeTimerCopy(),
      );
      await controller.setScheduleTrackingEnabled(
        false,
        const NativeTimerCopy(),
      );

      final state = container.read(pomodoroControllerProvider);
      expect(state.status, PomodoroStatus.running);
      expect(state.activeTimeBoxId, 'current');
    });

    test('disabling tracking stops an auto-started session', () async {
      final now = DateTime(2026, 7, 21, 9, 15);
      final repository = _MemoryPomodoroRepository(
        Pomodoro.initial().copyWith(
          timeBoxes: const [
            TimeBox(
              id: 'current',
              title: 'Deep work',
              timeRange: '09:00-10:00',
              durationSeconds: 60 * 60,
            ),
          ],
        ),
      );
      final container = ProviderContainer(
        overrides: [
          pomodoroRepositoryProvider.overrideWithValue(repository),
          pomodoroClockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(pomodoroControllerProvider.notifier);
      await _settleControllerRestore();

      await controller.setScheduleTrackingEnabled(
        true,
        const NativeTimerCopy(),
      );
      await _settleControllerRestore();
      expect(
        container.read(pomodoroControllerProvider).status,
        PomodoroStatus.running,
      );

      await controller.setScheduleTrackingEnabled(
        false,
        const NativeTimerCopy(),
      );

      expect(
        container.read(pomodoroControllerProvider).status,
        PomodoroStatus.idle,
      );
    });

    test('reset is not revived by clock sync while tracking is on', () async {
      final now = DateTime(2026, 7, 21, 9, 15);
      final repository = _MemoryPomodoroRepository(
        Pomodoro.initial().copyWith(
          autoStartFocus: true,
          timeBoxes: const [
            TimeBox(
              id: 'current',
              title: 'Deep work',
              timeRange: '09:00-10:00',
              durationSeconds: 60 * 60,
            ),
          ],
        ),
      );
      final container = ProviderContainer(
        overrides: [
          pomodoroRepositoryProvider.overrideWithValue(repository),
          pomodoroClockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(pomodoroControllerProvider.notifier);
      await _settleControllerRestore();
      expect(
        container.read(pomodoroControllerProvider).status,
        PomodoroStatus.running,
      );

      await controller.reset();
      // 1초 클록 동기화를 재현: 스킵한 박스는 되살아나면 안 된다.
      controller.syncFocusWithClock();
      await _settleControllerRestore();

      expect(
        container.read(pomodoroControllerProvider).status,
        PomodoroStatus.idle,
      );
    });

    test('slot breaks clip the focus segment to the break start', () async {
      SharedPreferences.setMockInitialValues({
        'app.slotBreakEnabled': true,
        'app.timeSlotIntervalMinutes': 30,
      });
      final now = DateTime(2026, 7, 21, 9, 0, 0);
      final repository = _MemoryPomodoroRepository(
        Pomodoro.initial().copyWith(
          autoStartFocus: true,
          timeBoxes: const [
            TimeBox(
              id: 'current',
              title: 'Deep work',
              timeRange: '09:00-10:00',
              durationSeconds: 60 * 60,
            ),
          ],
        ),
      );
      final container = ProviderContainer(
        overrides: [
          pomodoroRepositoryProvider.overrideWithValue(repository),
          pomodoroClockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(container.dispose);

      // 설정 로드가 끝난 뒤 추적 자동 시작이 세그먼트를 계산하도록 한다.
      container.read(appPreferencesControllerProvider);
      await _settleControllerRestore();
      container.read(pomodoroControllerProvider);
      await _settleControllerRestore();

      final state = container.read(pomodoroControllerProvider);
      expect(state.status, PomodoroStatus.running);
      expect(state.phase, PomodoroPhase.focus);
      // 09:00 시작, 간격 30분·휴식 3분 → 집중 세그먼트는 09:27까지 27분.
      expect(state.remainingTime, 27 * 60);
    });

    test('starting inside a slot break window runs the break first', () async {
      SharedPreferences.setMockInitialValues({
        'app.slotBreakEnabled': true,
        'app.timeSlotIntervalMinutes': 30,
      });
      final now = DateTime(2026, 7, 21, 9, 28, 0);
      final repository = _MemoryPomodoroRepository(
        Pomodoro.initial().copyWith(
          autoStartFocus: true,
          timeBoxes: const [
            TimeBox(
              id: 'current',
              title: 'Deep work',
              timeRange: '09:00-10:00',
              durationSeconds: 60 * 60,
            ),
          ],
        ),
      );
      final container = ProviderContainer(
        overrides: [
          pomodoroRepositoryProvider.overrideWithValue(repository),
          pomodoroClockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(container.dispose);

      container.read(appPreferencesControllerProvider);
      await _settleControllerRestore();
      container.read(pomodoroControllerProvider);
      await _settleControllerRestore();

      final state = container.read(pomodoroControllerProvider);
      // 09:28은 27~30분 휴식 창 안 → 남은 휴식 2분을 먼저 소화.
      expect(state.status, PomodoroStatus.running);
      expect(state.phase, PomodoroPhase.shortBreak);
      expect(state.remainingTime, 2 * 60);
    });

    test('auto-starts the current scheduled box when enabled', () async {
      final now = DateTime(2026, 7, 21, 9, 15);
      final repository = _MemoryPomodoroRepository(
        Pomodoro.initial().copyWith(
          autoStartFocus: true,
          timeBoxes: const [
            TimeBox(
              id: 'current',
              title: 'Deep work',
              timeRange: '09:00-10:00',
              durationSeconds: 60 * 60,
            ),
          ],
        ),
      );
      final container = ProviderContainer(
        overrides: [
          pomodoroRepositoryProvider.overrideWithValue(repository),
          pomodoroClockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(container.dispose);

      container.read(pomodoroControllerProvider);
      await _settleControllerRestore();

      final state = container.read(pomodoroControllerProvider);
      expect(state.status, PomodoroStatus.running);
      expect(state.activeTimeBoxId, 'current');
      expect(state.remainingTime, 45 * 60);
      expect(repository.startTimerCalls, 1);
    });

    test(
      'updates a running Focus UI and native timer after schedule edit',
      () async {
        final now = DateTime(2026, 7, 21, 9, 15);
        final repository = _MemoryPomodoroRepository(
          Pomodoro.initial().copyWith(
            autoStartFocus: true,
            timeBoxes: const [
              TimeBox(
                id: 'current',
                title: 'Before edit',
                timeRange: '09:00-10:00',
                durationSeconds: 60 * 60,
              ),
            ],
          ),
        );
        final container = ProviderContainer(
          overrides: [
            pomodoroRepositoryProvider.overrideWithValue(repository),
            pomodoroClockProvider.overrideWithValue(() => now),
          ],
        );
        addTearDown(container.dispose);

        final controller = container.read(pomodoroControllerProvider.notifier);
        await _settleControllerRestore();
        expect(repository.startTimerCalls, 1);

        controller.updateTimeBox('current', title: 'After edit');
        await _settleControllerRestore();

        final state = container.read(pomodoroControllerProvider);
        expect(state.currentTimeBoxTitle, 'After edit');
        expect(state.status, PomodoroStatus.running);
        expect(repository.startTimerCalls, 2);
      },
    );

    test(
      'switches to and starts the next scheduled box at its boundary',
      () async {
        var now = DateTime(2026, 7, 21, 9, 29, 50);
        final repository = _MemoryPomodoroRepository(
          Pomodoro.initial().copyWith(
            autoStartFocus: true,
            timeBoxes: const [
              TimeBox(
                id: 'first',
                title: 'First',
                timeRange: '09:00-09:30',
                durationSeconds: 30 * 60,
              ),
              TimeBox(
                id: 'second',
                title: 'Second',
                timeRange: '09:30-10:00',
                durationSeconds: 30 * 60,
              ),
            ],
          ),
        );
        final container = ProviderContainer(
          overrides: [
            pomodoroRepositoryProvider.overrideWithValue(repository),
            pomodoroClockProvider.overrideWithValue(() => now),
          ],
        );
        addTearDown(container.dispose);

        final controller = container.read(pomodoroControllerProvider.notifier);
        await _settleControllerRestore();
        expect(
          container.read(pomodoroControllerProvider).activeTimeBoxId,
          'first',
        );
        expect(repository.startTimerCalls, 1);

        now = DateTime(2026, 7, 21, 9, 30);
        controller.syncFocusWithClock();
        await _settleControllerRestore();

        final state = container.read(pomodoroControllerProvider);
        expect(state.activeTimeBoxId, 'second');
        expect(state.currentTimeBoxTitle, 'Second');
        expect(state.status, PomodoroStatus.running);
        expect(repository.startTimerCalls, 2);
      },
    );

    test('native restore preserves every synced daily-plan field', () async {
      final repository = _MemoryPomodoroRepository(
        Pomodoro.initial().copyWith(
          brainDump: const ['Capture the regression'],
          reminders: const ['Do not erase this'],
          topPriorities: const [
            'Ship a stable beta',
            'Verify Live Activity',
            'Review calendar sync',
          ],
          timeBoxes: const [
            TimeBox(
              id: 'box-regression',
              title: 'Protect saved plans',
              timeRange: '09:00-09:30',
              durationSeconds: 30 * 60,
            ),
          ],
        ),
        nativeSnapshot: const TimerSnapshot(
          status: 'running',
          remainingTime: 20 * 60,
          topPriorities: ['', '', ''],
        ),
      );
      final container = ProviderContainer(
        overrides: [pomodoroRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      container.read(pomodoroControllerProvider);
      await _settleControllerRestore();

      final state = container.read(pomodoroControllerProvider);
      expect(state.topPriorities, [
        'Ship a stable beta',
        'Verify Live Activity',
        'Review calendar sync',
      ]);
      expect(state.brainDump, ['Capture the regression']);
      expect(state.reminders, ['Do not erase this']);
      expect(state.timeBoxes.single.title, 'Protect saved plans');
    });

    test(
      'account transition flushes, clears, and can restore local data',
      () async {
        final savedPlan = Pomodoro.initial().copyWith(
          brainDump: const ['Keep after failed deletion'],
        );
        final repository = _MemoryPomodoroRepository(savedPlan);
        final container = ProviderContainer(
          overrides: [pomodoroRepositoryProvider.overrideWithValue(repository)],
        );
        addTearDown(container.dispose);

        final controller = container.read(pomodoroControllerProvider.notifier);
        await _settleControllerRestore();
        await controller.flushPendingPlanWrites();
        await controller.clearLocalPlanForSignOut();

        expect(repository.flushCallCount, 1);
        expect(repository.clearCallCount, 1);

        await controller.persistCurrentPlan();
        expect(repository.updates.last.brainDump, savedPlan.brainDump);
        expect(repository.flushCallCount, 2);
      },
    );
  });
}

Future<void> _settleControllerRestore() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

class _MemoryPomodoroRepository implements PomodoroRepository {
  Pomodoro pomodoro;
  final updates = <Pomodoro>[];
  final Pomodoro Function(Pomodoro fallback, int restoreCallCount)? onRestore;
  final Completer<Pomodoro>? restoreCompleter;
  final TimerSnapshot nativeSnapshot;
  final List<DailyPlanSummary> history;
  final Map<String, Pomodoro> plansByDate;
  int restoreCallCount = 0;
  int startTimerCalls = 0;
  int flushCallCount = 0;
  int clearCallCount = 0;

  _MemoryPomodoroRepository(
    this.pomodoro, {
    this.onRestore,
    this.restoreCompleter,
    this.nativeSnapshot = const TimerSnapshot(status: 'idle'),
    this.history = const [],
    this.plansByDate = const {},
  });

  @override
  Pomodoro getPomodoro() => pomodoro;

  @override
  void updatePomodoro(Pomodoro pomodoro) {
    this.pomodoro = pomodoro;
    updates.add(pomodoro);
  }

  @override
  Future<void> flushPendingWrites() async {
    flushCallCount += 1;
  }

  @override
  Future<Pomodoro> restoreTodayPlan(Pomodoro fallback) async {
    restoreCallCount += 1;
    final pendingRestore = restoreCompleter;
    pomodoro = pendingRestore == null
        ? onRestore?.call(fallback, restoreCallCount) ?? pomodoro
        : await pendingRestore.future;
    return pomodoro;
  }

  @override
  Future<Pomodoro?> loadPreviousPlan(Pomodoro fallback) async => null;

  @override
  Future<Pomodoro?> loadPlanForDate(String dateKey, Pomodoro fallback) async =>
      plansByDate[dateKey];

  @override
  Future<List<DailyPlanSummary>> loadDailyPlanHistory({int days = 7}) async {
    return history;
  }

  @override
  Stream<int> startTimer({
    required String phase,
    required bool notificationsEnabled,
    required bool soundEnabled,
    required List<String> topPriorities,
    required String currentTimeBoxTitle,
    required String currentTimeBoxTimeRange,
    required NativeTimerCopy nativeCopy,
  }) {
    startTimerCalls += 1;
    return const Stream<int>.empty();
  }

  @override
  Stream<int> ticks() => const Stream<int>.empty();

  @override
  Future<void> pauseTimer() async {}

  @override
  Future<void> resumeTimer() async {}

  @override
  Future<void> stopTimer() async {}

  @override
  Future<TimerSnapshot> restoreState(Pomodoro fallback) async {
    return nativeSnapshot;
  }

  @override
  Future<void> updateNotificationSettings({
    required bool notificationsEnabled,
    required bool soundEnabled,
  }) async {}

  @override
  Stream<LiveActivityPushRegistration> liveActivityRegistrations() =>
      const Stream<LiveActivityPushRegistration>.empty();

  @override
  Stream<String> endedLiveActivityIds() => const Stream<String>.empty();

  @override
  Future<void> registerLiveActivityPushToken(
    LiveActivityPushRegistration registration,
  ) async {}

  @override
  Future<void> removeLiveActivityPushToken(String activityId) async {}

  @override
  Future<void> syncLiveActivityPushTokens() async {}

  @override
  Future<void> clearLocalPlanData() async {
    clearCallCount += 1;
  }
}

String _dateKeyForTest(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
