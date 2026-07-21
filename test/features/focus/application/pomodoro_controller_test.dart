import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_boxing_pomodoro/features/focus/application/pomodoro_controller.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/entities/daily_plan_summary.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/entities/daily_plan_item_category.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/entities/native_timer_copy.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/entities/pomodoro.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/repositories/pomodoro_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PomodoroController time box editing', () {
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
  int restoreCallCount = 0;
  int startTimerCalls = 0;

  _MemoryPomodoroRepository(this.pomodoro, {this.onRestore});

  @override
  Pomodoro getPomodoro() => pomodoro;

  @override
  void updatePomodoro(Pomodoro pomodoro) {
    this.pomodoro = pomodoro;
    updates.add(pomodoro);
  }

  @override
  Future<void> flushPendingWrites() async {}

  @override
  Future<Pomodoro> restoreTodayPlan(Pomodoro fallback) async {
    restoreCallCount += 1;
    pomodoro = onRestore?.call(fallback, restoreCallCount) ?? pomodoro;
    return pomodoro;
  }

  @override
  Future<Pomodoro?> loadPreviousPlan(Pomodoro fallback) async => null;

  @override
  Future<List<DailyPlanSummary>> loadDailyPlanHistory({int days = 7}) async {
    return const [];
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
    return const TimerSnapshot(status: 'idle');
  }

  @override
  Future<void> updateNotificationSettings({
    required bool notificationsEnabled,
    required bool soundEnabled,
  }) async {}

  @override
  Future<void> clearLocalPlanData() async {}
}
