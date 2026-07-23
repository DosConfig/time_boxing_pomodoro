import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_boxing_pomodoro/features/focus/data/datasources/pomodoro_local_datasource.dart';
import 'package:time_boxing_pomodoro/features/focus/data/dtos/today_plan_dto.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/entities/pomodoro.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('restores a plan after restart only for the same user', () async {
    final savedPlan = _savedPlan();
    final firstSession = PomodoroLocalDataSource(storageScope: () => 'user-a');
    firstSession.updatePomodoro(savedPlan);
    await firstSession.flushPendingWrites();

    final restartedSession = PomodoroLocalDataSource(
      storageScope: () => 'user-a',
    );
    final restored = await restartedSession.restoreTodayPlan(
      Pomodoro.initial(),
    );
    final otherUserSession = PomodoroLocalDataSource(
      storageScope: () => 'user-b',
    );
    final otherUserPlan = await otherUserSession.restoreTodayPlan(
      Pomodoro.initial(),
    );

    expect(restored.brainDump, savedPlan.brainDump);
    expect(restored.reminders, savedPlan.reminders);
    expect(restored.topPriorities, savedPlan.topPriorities);
    expect(restored.timeBoxes, savedPlan.timeBoxes);
    expect(otherUserPlan.brainDump, isEmpty);
    expect(otherUserPlan.reminders, isEmpty);
    expect(otherUserPlan.topPriorities, ['', '', '']);
    expect(otherUserPlan.timeBoxes, isEmpty);
  });

  test('a queued write keeps the user scope captured at edit time', () async {
    var activeUserId = 'user-a';
    final dataSource = PomodoroLocalDataSource(
      storageScope: () => activeUserId,
    );
    dataSource.updatePomodoro(_savedPlan());
    activeUserId = 'user-b';
    await dataSource.flushPendingWrites();
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getKeys(), contains('today.plan.user-a.${_todayKey()}'));

    final userA = PomodoroLocalDataSource(storageScope: () => 'user-a');
    final userB = PomodoroLocalDataSource(storageScope: () => 'user-b');

    expect((await userA.restoreTodayPlan(Pomodoro.initial())).brainDump, [
      'Keep this draft',
    ]);
    expect(
      (await userB.restoreTodayPlan(Pomodoro.initial())).brainDump,
      isEmpty,
    );
  });

  test('migrates legacy unscoped plans to the first signed-in user', () async {
    final dateKey = _todayKey();
    final legacyDto = TodayPlanDto.fromEntity(
      _savedPlan(),
      dateKey: dateKey,
      updatedAtEpochMs: 10,
    );
    SharedPreferences.setMockInitialValues({
      'today.plan.keys': [dateKey],
      'today.plan.$dateKey': jsonEncode(legacyDto.toStorageJson()),
    });

    final migrated = PomodoroLocalDataSource(storageScope: () => 'user-a');
    final restored = await migrated.restoreTodayPlan(Pomodoro.initial());
    final preferences = await SharedPreferences.getInstance();

    expect(restored.brainDump, ['Keep this draft']);
    expect(preferences.containsKey('today.plan.$dateKey'), isFalse);
    expect(preferences.getStringList('today.plan.keys.user-a'), [dateKey]);

    final otherUser = PomodoroLocalDataSource(storageScope: () => 'user-b');
    expect(
      (await otherUser.restoreTodayPlan(Pomodoro.initial())).brainDump,
      isEmpty,
    );
  });

  test('loads a stored plan for a specific date key', () async {
    final savedPlan = _savedPlan();
    final dataSource = PomodoroLocalDataSource(storageScope: () => 'user-a');
    dataSource.updatePomodoro(savedPlan);
    await dataSource.flushPendingWrites();

    final loaded = await dataSource.loadPlanForDate(
      _todayKey(),
      Pomodoro.initial(),
    );
    final missing = await dataSource.loadPlanForDate(
      '1999-01-01',
      Pomodoro.initial(),
    );

    expect(loaded, isNotNull);
    expect(loaded!.brainDump, savedPlan.brainDump);
    expect(loaded.timeBoxes.single.title, 'Keep this time box');
    expect(missing, isNull);
  });
}

Pomodoro _savedPlan() {
  return Pomodoro.initial().copyWith(
    brainDump: const ['Keep this draft'],
    reminders: const ['Keep this reminder'],
    topPriorities: const ['Keep this priority', '', ''],
    timeBoxes: const [
      TimeBox(
        id: 'saved-box',
        title: 'Keep this time box',
        timeRange: '09:00-09:30',
        durationSeconds: 30 * 60,
      ),
    ],
    activeTimeBoxId: 'saved-box',
  );
}

String _todayKey() {
  final today = DateTime.now();
  final year = today.year.toString().padLeft(4, '0');
  final month = today.month.toString().padLeft(2, '0');
  final day = today.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
