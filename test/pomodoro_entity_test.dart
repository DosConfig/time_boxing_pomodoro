import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_method_channel/features/focus/data/dtos/today_plan_dto.dart';
import 'package:pomodoro_method_channel/features/focus/domain/entities/pomodoro.dart';

void main() {
  group('Pomodoro presets', () {
    test('classic uses a 25/5 cadence with five focus blocks', () {
      final pomodoro = Pomodoro.initial();

      expect(pomodoro.workDuration, 25 * 60);
      expect(pomodoro.breakDuration, 5 * 60);
      expect(pomodoro.sessionsUntilLongBreak, 5);
      expect(pomodoro.phase, PomodoroPhase.focus);
      expect(pomodoro.notificationsEnabled, isTrue);
      expect(pomodoro.soundEnabled, isTrue);
      expect(pomodoro.brainDump, isEmpty);
      expect(pomodoro.timeBoxes, isNotEmpty);
      expect(pomodoro.activeTimeBox?.title, 'Top priority');
      expect(pomodoro.activeTimeBox?.timeRange, '09:00-09:30');
      expect(pomodoro.activeTimeBox?.durationSeconds, 30 * 60);
    });

    test('deep work preset resets the active segment', () {
      final pomodoro = Pomodoro.initial()
          .copyWith(
            status: PomodoroStatus.running,
            remainingTime: 900,
            completedSessions: 2,
            notificationsEnabled: false,
            soundEnabled: false,
          )
          .applyPreset(PomodoroPreset.deepWork);

      expect(pomodoro.workDuration, 50 * 60);
      expect(pomodoro.breakDuration, 10 * 60);
      expect(pomodoro.remainingTime, 50 * 60);
      expect(pomodoro.completedSessions, 0);
      expect(pomodoro.status, PomodoroStatus.idle);
      expect(pomodoro.notificationsEnabled, isFalse);
      expect(pomodoro.soundEnabled, isFalse);
    });
  });

  group('Pomodoro phase helpers', () {
    test('progress is based on the active phase duration', () {
      final focus = Pomodoro.initial().copyWith(remainingTime: 15 * 60);
      final shortBreak = Pomodoro.initial().copyWith(
        phase: PomodoroPhase.shortBreak,
        remainingTime: 150,
      );

      expect(focus.progress, closeTo(0.4, 0.001));
      expect(shortBreak.progress, closeTo(0.5, 0.001));
    });

    test('phase values round-trip from native strings', () {
      expect(Pomodoro.phaseFromValue('focus'), PomodoroPhase.focus);
      expect(Pomodoro.phaseFromValue('shortBreak'), PomodoroPhase.shortBreak);
      expect(Pomodoro.phaseFromValue('longBreak'), PomodoroPhase.longBreak);
      expect(Pomodoro.phaseFromValue(null), PomodoroPhase.focus);
    });

    test('live activity context keeps only visible priority text', () {
      final pomodoro = Pomodoro.initial().copyWith(
        topPriorities: ['Plan launch', '  ', 'Review calendar', 'Overflow'],
        currentTimeBoxTitle: 'Write proposal',
        currentTimeBoxTimeRange: '09:00-10:00',
      );

      expect(pomodoro.visibleTopPriorities, [
        'Plan launch',
        'Review calendar',
        'Overflow',
      ]);
      expect(pomodoro.liveActivityTimeBoxTitle, 'Write proposal');
      expect(pomodoro.liveActivityTimeBoxRange, '09:00-10:00');
    });

    test('live activity context falls back to active time box', () {
      final pomodoro = Pomodoro.initial();

      expect(pomodoro.liveActivityTimeBoxTitle, 'Top priority');
      expect(pomodoro.liveActivityTimeBoxRange, '09:00-09:30');
    });

    test('time boxes parse fixed 30 minute slot ranges', () {
      const box = TimeBox(
        id: 'box-test',
        title: 'Slot',
        timeRange: '13:30-14:00',
        durationSeconds: 30 * 60,
      );

      expect(box.startMinutes, (13 * 60) + 30);
      expect(box.endMinutes, 14 * 60);
      expect(box.rangeDurationSeconds, 30 * 60);
    });
  });

  group('Today plan persistence', () {
    test('round-trips planned local fields without timer runtime state', () {
      final pomodoro = Pomodoro.initial().copyWith(
        brainDump: ['Client meeting', 'Draft launch plan'],
        reminders: ['Send recap'],
        topPriorities: ['Ship MVP', 'Calendar export', ''],
        completedSessions: 2,
        activeTimeBoxId: 'box-1000',
        status: PomodoroStatus.running,
        phase: PomodoroPhase.shortBreak,
        remainingTime: 42,
      );

      final dto = TodayPlanDto.fromEntity(pomodoro, dateKey: '2026-07-16');
      final restored = TodayPlanDto.fromJson(
        dto.toStorageJson(),
      ).toEntity(Pomodoro.initial());

      expect(restored.brainDump, ['Client meeting', 'Draft launch plan']);
      expect(restored.reminders, ['Send recap']);
      expect(restored.topPriorities, ['Ship MVP', 'Calendar export', '']);
      expect(restored.completedSessions, 2);
      expect(restored.activeTimeBoxId, 'box-1000');
      expect(restored.currentTimeBoxTimeRange, '10:00-10:30');
      expect(restored.status, PomodoroStatus.idle);
      expect(restored.phase, PomodoroPhase.focus);
      expect(restored.remainingTime, 30 * 60);
    });

    test('falls back to first box when active id is stale', () {
      const boxes = [
        TimeBox(
          id: 'box-custom',
          title: 'Custom',
          timeRange: '08:00-08:30',
          durationSeconds: 30 * 60,
        ),
      ];
      final dto = TodayPlanDto(
        dateKey: '2026-07-16',
        activeTimeBoxId: 'missing',
        timeBoxes: boxes.map(TimeBoxDto.fromEntity).toList(),
      );

      final restored = dto.toEntity(Pomodoro.initial());

      expect(restored.activeTimeBoxId, 'box-custom');
      expect(restored.activeTimeBox?.title, 'Custom');
    });
  });
}
