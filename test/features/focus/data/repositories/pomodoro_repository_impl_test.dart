import 'package:flutter_test/flutter_test.dart';
import 'package:time_boxing_pomodoro/features/focus/data/datasources/pomodoro_cloud_datasource.dart';
import 'package:time_boxing_pomodoro/features/focus/data/datasources/pomodoro_local_datasource.dart';
import 'package:time_boxing_pomodoro/features/focus/data/repositories/pomodoro_repository_impl.dart';
import 'package:time_boxing_pomodoro/features/focus/data/dtos/today_plan_dto.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/entities/daily_plan_summary.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/entities/pomodoro.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PomodoroRepositoryImpl', () {
    test('rejects writes until the saved plan has been restored', () async {
      final savedPlan = Pomodoro.initial().copyWith(
        brainDump: const ['Keep the saved draft'],
        reminders: const ['Keep the reminder'],
        topPriorities: const ['Keep the priority', '', ''],
      );
      final localDataSource = _FakeLocalDataSource(
        savedPlan,
        updatedAtEpochMs: 20,
      );
      final repository = PomodoroRepositoryImpl(
        localDataSource,
        _FakeCloudDataSource(restoredPlan: savedPlan, updatedAtEpochMs: 20),
      );

      repository.updatePomodoro(Pomodoro.initial());
      expect(localDataSource.updatedPlans, isEmpty);

      final restored = await repository.restoreTodayPlan(Pomodoro.initial());

      expect(restored.brainDump, savedPlan.brainDump);
      expect(restored.reminders, savedPlan.reminders);
      expect(restored.topPriorities, savedPlan.topPriorities);
      expect(
        localDataSource.updatedPlans.single.brainDump,
        savedPlan.brainDump,
      );
    });

    test('cloud writes carry the user id captured for the edit', () async {
      final initialPlan = Pomodoro.initial().copyWith(
        topPriorities: const ['Initial priority', '', ''],
      );
      final cloudDataSource = _FakeCloudDataSource(
        restoredPlan: initialPlan,
        updatedAtEpochMs: 20,
      );
      final repository = PomodoroRepositoryImpl(
        _FakeLocalDataSource(initialPlan, updatedAtEpochMs: 20),
        cloudDataSource,
      );
      await repository.restoreTodayPlan(Pomodoro.initial());

      repository.updatePomodoro(
        initialPlan.copyWith(topPriorities: const ['Updated priority', '', '']),
      );
      await repository.flushPendingWrites();

      expect(cloudDataSource.savedExpectedUserIds, isNotEmpty);
      expect(cloudDataSource.savedExpectedUserIds, everyElement('test-user'));
    });

    test(
      'uploads local plan when cloud has no plan, even if local equals fallback',
      () async {
        final localPlan = Pomodoro.initial().copyWith(
          brainDump: const ['Write release notes'],
          topPriorities: const ['Ship TestFlight', '', ''],
          timeBoxes: const [
            TimeBox(
              id: 'box-local',
              title: 'Ship TestFlight',
              timeRange: '09:00-09:30',
              durationSeconds: 30 * 60,
            ),
          ],
          activeTimeBoxId: 'box-local',
        );
        final cloudDataSource = _FakeCloudDataSource();
        final repository = PomodoroRepositoryImpl(
          _FakeLocalDataSource(localPlan, updatedAtEpochMs: 10),
          cloudDataSource,
        );

        final restored = await repository.restoreTodayPlan(localPlan);

        expect(restored.brainDump, localPlan.brainDump);
        expect(restored.topPriorities, localPlan.topPriorities);
        expect(restored.timeBoxes, localPlan.timeBoxes);
        expect(
          cloudDataSource.savedPlans.single.brainDump,
          localPlan.brainDump,
        );
      },
    );

    test('uses cloud plan when one exists', () async {
      final localPlan = Pomodoro.initial().copyWith(
        brainDump: const ['Local item'],
      );
      final cloudPlan = Pomodoro.initial().copyWith(
        brainDump: const ['Cloud item'],
      );
      final localDataSource = _FakeLocalDataSource(
        localPlan,
        updatedAtEpochMs: 10,
      );
      final cloudDataSource = _FakeCloudDataSource(
        restoredPlan: cloudPlan,
        updatedAtEpochMs: 20,
      );
      final repository = PomodoroRepositoryImpl(
        localDataSource,
        cloudDataSource,
      );

      final restored = await repository.restoreTodayPlan(localPlan);

      expect(restored.brainDump, cloudPlan.brainDump);
      expect(
        localDataSource.updatedPlans.single.brainDump,
        cloudPlan.brainDump,
      );
      expect(cloudDataSource.savedPlans, isEmpty);
    });

    test('restores a cloud plan on a device with no local plan', () async {
      final cloudPlan = Pomodoro.initial().copyWith(
        brainDump: const ['Synced from the first device'],
        topPriorities: const ['Keep the plan', '', ''],
      );
      final localDataSource = _FakeLocalDataSource(
        Pomodoro.initial(),
        hasTodayPlan: false,
      );
      final repository = PomodoroRepositoryImpl(
        localDataSource,
        _FakeCloudDataSource(restoredPlan: cloudPlan, updatedAtEpochMs: 20),
      );

      final restored = await repository.restoreTodayPlan(Pomodoro.initial());

      expect(restored.brainDump, cloudPlan.brainDump);
      expect(restored.topPriorities, cloudPlan.topPriorities);
      expect(
        localDataSource.updatedPlans.single.brainDump,
        cloudPlan.brainDump,
      );
    });

    test('keeps local daily content when cloud has an empty plan', () async {
      final localPlan = Pomodoro.initial().copyWith(
        brainDump: const ['Keep this note'],
        topPriorities: const ['Do the important thing', '', ''],
      );
      final cloudPlan = Pomodoro.initial();
      final localDataSource = _FakeLocalDataSource(
        localPlan,
        updatedAtEpochMs: 20,
      );
      final cloudDataSource = _FakeCloudDataSource(
        restoredPlan: cloudPlan,
        updatedAtEpochMs: 10,
      );
      final repository = PomodoroRepositoryImpl(
        localDataSource,
        cloudDataSource,
      );

      final restored = await repository.restoreTodayPlan(Pomodoro.initial());

      expect(restored.brainDump, ['Keep this note']);
      expect(restored.topPriorities, ['Do the important thing', '', '']);
      expect(
        localDataSource.updatedPlans.single.brainDump,
        localPlan.brainDump,
      );
      expect(cloudDataSource.savedPlans.single.brainDump, localPlan.brainDump);
    });

    test('seeds a new empty day with recurring previous time boxes', () async {
      final fallback = Pomodoro.initial();
      final previousPlan = Pomodoro.initial().copyWith(
        timeBoxes: [
          TimeBox(
            id: 'box-standup',
            title: 'Standup',
            timeRange: '09:00-09:30',
            durationSeconds: 30 * 60,
            repeatWeekdays: [DateTime.now().weekday],
          ),
          const TimeBox(
            id: 'box-one-off',
            title: 'One-off',
            timeRange: '10:00-10:30',
            durationSeconds: 30 * 60,
          ),
        ],
      );
      final localDataSource = _FakeLocalDataSource(
        fallback,
        previousPlan: previousPlan,
        hasTodayPlan: false,
      );
      final cloudDataSource = _FakeCloudDataSource();
      final repository = PomodoroRepositoryImpl(
        localDataSource,
        cloudDataSource,
      );

      final restored = await repository.restoreTodayPlan(fallback);

      expect(restored.timeBoxes, hasLength(1));
      expect(restored.timeBoxes.single.title, 'Standup');
      expect(restored.topPriorities, ['', '', '']);
      expect(restored.brainDump, isEmpty);
      expect(restored.reminders, isEmpty);
      expect(restored.activeTimeBoxId, isEmpty);
      expect(localDataSource.updatedPlans.last, restored);
      expect(cloudDataSource.savedPlans.last, restored);
    });

    test('injects recurring boxes even when today already has content', () async {
      final fallback = Pomodoro.initial();
      final todayPlan = Pomodoro.initial().copyWith(
        brainDump: const ['Existing note'],
        timeBoxes: const [
          TimeBox(
            id: 'today-box',
            title: 'Existing box',
            timeRange: '11:00-11:30',
            durationSeconds: 30 * 60,
          ),
        ],
      );
      final previousPlan = Pomodoro.initial().copyWith(
        timeBoxes: [
          TimeBox(
            id: 'box-standup',
            title: 'Standup',
            timeRange: '09:00-09:30',
            durationSeconds: 30 * 60,
            repeatWeekdays: [DateTime.now().weekday],
          ),
        ],
      );
      final localDataSource = _FakeLocalDataSource(
        todayPlan,
        previousPlan: previousPlan,
      );
      final cloudDataSource = _FakeCloudDataSource();
      final repository = PomodoroRepositoryImpl(
        localDataSource,
        cloudDataSource,
      );

      final restored = await repository.restoreTodayPlan(fallback);

      expect(restored.brainDump, ['Existing note']);
      expect(
        restored.timeBoxes.map((box) => box.title).toList(),
        containsAll(['Existing box', 'Standup']),
      );
    });

    test('injects recurring boxes when the device is offline', () async {
      final fallback = Pomodoro.initial();
      final previousPlan = Pomodoro.initial().copyWith(
        timeBoxes: [
          TimeBox(
            id: 'box-standup',
            title: 'Standup',
            timeRange: '09:00-09:30',
            durationSeconds: 30 * 60,
            repeatWeekdays: [DateTime.now().weekday],
          ),
        ],
      );
      final localDataSource = _FakeLocalDataSource(
        fallback,
        previousPlan: previousPlan,
        hasTodayPlan: false,
      );
      final cloudDataSource = _FakeCloudDataSource(
        status: CloudTodayPlanStatus.unavailable,
      );
      final repository = PomodoroRepositoryImpl(
        localDataSource,
        cloudDataSource,
      );

      final restored = await repository.restoreTodayPlan(fallback);

      expect(restored.timeBoxes, hasLength(1));
      expect(restored.timeBoxes.single.title, 'Standup');
    });

    test('does not re-inject recurring boxes twice on the same day', () async {
      final fallback = Pomodoro.initial();
      final previousPlan = Pomodoro.initial().copyWith(
        timeBoxes: [
          TimeBox(
            id: 'box-standup',
            title: 'Standup',
            timeRange: '09:00-09:30',
            durationSeconds: 30 * 60,
            repeatWeekdays: [DateTime.now().weekday],
          ),
        ],
      );
      final localDataSource = _FakeLocalDataSource(
        fallback,
        previousPlan: previousPlan,
        hasTodayPlan: false,
      );
      final cloudDataSource = _FakeCloudDataSource();
      final repository = PomodoroRepositoryImpl(
        localDataSource,
        cloudDataSource,
      );

      final first = await repository.restoreTodayPlan(fallback);
      // 사용자가 오늘 인스턴스를 지운 상황을 재현: 오늘 플랜이 다시 비어
      // 있어도 같은 날의 두 번째 복원은 반복 박스를 되살리지 않는다.
      final second = await repository.restoreTodayPlan(fallback);

      expect(first.timeBoxes.single.title, 'Standup');
      expect(localDataSource.recurringAppliedDateKey, isNotNull);
      expect(second.timeBoxes.where((box) => box.title == 'Standup'), isEmpty);
    });

    test(
      'does not create an empty plan when cloud cannot be checked',
      () async {
        final fallback = Pomodoro.initial();
        final localDataSource = _FakeLocalDataSource(
          fallback,
          hasTodayPlan: false,
        );
        final cloudDataSource = _FakeCloudDataSource(
          status: CloudTodayPlanStatus.unavailable,
        );
        final repository = PomodoroRepositoryImpl(
          localDataSource,
          cloudDataSource,
        );

        final restored = await repository.restoreTodayPlan(fallback);

        expect(restored, fallback);
        expect(localDataSource.updatedPlans, isEmpty);
        expect(cloudDataSource.savedPlans, isEmpty);
      },
    );
  });
}

class _FakeLocalDataSource extends PomodoroLocalDataSource {
  final Pomodoro restoredPlan;
  final Pomodoro? previousPlan;
  final bool hasTodayPlan;
  final int updatedAtEpochMs;
  final List<Pomodoro> updatedPlans = [];

  _FakeLocalDataSource(
    this.restoredPlan, {
    this.previousPlan,
    this.hasTodayPlan = true,
    this.updatedAtEpochMs = 0,
  });

  @override
  Future<TodayPlanDto?> loadTodayPlanDto() async {
    if (!hasTodayPlan) {
      return null;
    }
    return TodayPlanDto.fromEntity(
      restoredPlan,
      dateKey: _todayKey(),
      updatedAtEpochMs: updatedAtEpochMs,
    );
  }

  @override
  Future<Pomodoro?> loadPreviousPlan(Pomodoro fallback) async => previousPlan;

  @override
  Future<Pomodoro?> loadPlanForDate(String dateKey, Pomodoro fallback) async {
    if (dateKey == _yesterdayKey()) {
      return previousPlan;
    }
    return null;
  }

  String? recurringAppliedDateKey;

  @override
  Future<String?> loadRecurringAppliedDateKey() async =>
      recurringAppliedDateKey;

  @override
  Future<void> saveRecurringAppliedDateKey(String dateKey) async {
    recurringAppliedDateKey = dateKey;
  }

  @override
  void updatePomodoro(Pomodoro pomodoro, {int? updatedAtEpochMs}) {
    updatedPlans.add(pomodoro);
  }

  @override
  Future<void> flushPendingWrites() async {}

  @override
  Future<List<DailyPlanSummary>> loadDailyPlanHistory({int days = 7}) async {
    return const [];
  }
}

class _FakeCloudDataSource extends PomodoroCloudDataSource {
  final Pomodoro? restoredPlan;
  final int updatedAtEpochMs;
  final CloudTodayPlanStatus? status;
  final List<Pomodoro> savedPlans = [];
  final List<String?> savedExpectedUserIds = [];

  @override
  String? get currentUserId => 'test-user';

  _FakeCloudDataSource({
    this.restoredPlan,
    this.updatedAtEpochMs = 0,
    this.status,
  });

  @override
  Future<CloudTodayPlanResult> loadTodayPlanResult() async {
    final plan = restoredPlan;
    if (plan == null) {
      return CloudTodayPlanResult(
        status: status ?? CloudTodayPlanStatus.missing,
      );
    }
    return CloudTodayPlanResult(
      status: status ?? CloudTodayPlanStatus.available,
      plan: TodayPlanDto.fromEntity(
        plan,
        dateKey: _todayKey(),
        updatedAtEpochMs: updatedAtEpochMs,
      ),
    );
  }

  @override
  Future<Pomodoro?> loadPreviousPlan(Pomodoro fallback) async => null;

  @override
  Future<Pomodoro?> loadPlanForDate(String dateKey, Pomodoro fallback) async =>
      null;

  @override
  Future<void> saveTodayPlan(
    Pomodoro pomodoro, {
    int? updatedAtEpochMs,
    String? expectedUserId,
  }) async {
    savedPlans.add(pomodoro);
    savedExpectedUserIds.add(expectedUserId);
  }

  @override
  Future<List<DailyPlanSummary>> loadDailyPlanHistory({int days = 7}) async {
    return const [];
  }
}

String _todayKey() {
  final now = DateTime.now();
  final year = now.year.toString().padLeft(4, '0');
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String _yesterdayKey() {
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  final year = yesterday.year.toString().padLeft(4, '0');
  final month = yesterday.month.toString().padLeft(2, '0');
  final day = yesterday.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
