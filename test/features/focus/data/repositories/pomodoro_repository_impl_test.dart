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
      expect(localDataSource.updatedPlans, [restored]);
      expect(cloudDataSource.savedPlans, [restored]);
    });
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
  final List<Pomodoro> savedPlans = [];

  _FakeCloudDataSource({this.restoredPlan, this.updatedAtEpochMs = 0});

  @override
  Future<TodayPlanDto?> loadTodayPlanDto() async {
    final plan = restoredPlan;
    if (plan == null) {
      return null;
    }
    return TodayPlanDto.fromEntity(
      plan,
      dateKey: _todayKey(),
      updatedAtEpochMs: updatedAtEpochMs,
    );
  }

  @override
  Future<Pomodoro?> loadPreviousPlan(Pomodoro fallback) async => null;

  @override
  Future<void> saveTodayPlan(Pomodoro pomodoro, {int? updatedAtEpochMs}) async {
    savedPlans.add(pomodoro);
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
