import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_boxing_pomodoro/features/focus/presentation/controllers/pomodoro_controller.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/entities/pomodoro.dart';
import 'package:time_boxing_pomodoro/features/shell/presentation/app_shell.dart';
import 'package:time_boxing_pomodoro/main.dart';

import 'helpers/e2e_fakes.dart';

/// J2: 핵심 가치 검증. 타임박스를 실행한 뒤 앱을 재실행해도
/// 벽시계 기준으로 타이머가 이어지는지 확인한다 (docs/testing/E2E_SCENARIOS.md 참조).
void main() {
  patrolTest('timebox focus survives app relaunch (wall clock sync)',
      ($) async {
    SharedPreferences.setMockInitialValues({
      'app.introCompleted': true,
      'app.onboardingCompleted': true,
    });

    // ---- 1차 실행 ----
    final container = signedInContainer();
    await $.pumpWidgetAndSettle(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
    expect($(AppShell), findsOneWidget);

    // arrange: 현재 시각이 속한 30분 슬롯에 타임박스 추가 (상태 API 경로)
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final slotStart = nowMinutes - (nowMinutes % 30);
    container
        .read(pomodoroControllerProvider.notifier)
        .addTimeBoxAtStart(slotStart, title: 'E2E focus');
    await $.pumpAndSettle();

    // act: Today 화면의 Start focus 버튼을 실제 탭 (보드 아래에 있어 ensureVisible로 스크롤)
    await $.tester.ensureVisible(find.byKey(const ValueKey('start_focus')));
    await $.pumpAndSettle();
    await $(const ValueKey('start_focus')).tap();
    await $.pumpAndSettle();

    // assert 1: 타이머 실행 상태 진입
    final started = container.read(pomodoroControllerProvider);
    expect(started.status, PomodoroStatus.running);
    final remainingBefore = started.remainingTime;
    expect(remainingBefore, greaterThan(0));

    // 벽시계 경과
    await $.pump(const Duration(seconds: 3));

    // ---- 2차 실행: 재시작 시뮬레이션 ----
    // 새 컨테이너 = 메모리 상태 전부 초기화. SharedPreferences만 살아남는다.
    container.dispose();
    final relaunched = signedInContainer();
    await $.pumpWidgetAndSettle(
      UncontrolledProviderScope(container: relaunched, child: const MyApp()),
    );
    expect($(AppShell), findsOneWidget);

    // assert 2: 복원은 비동기이므로 최대 10초 폴링
    var restored = relaunched.read(pomodoroControllerProvider);
    final deadline = DateTime.now().add(const Duration(seconds: 10));
    while (restored.status != PomodoroStatus.running &&
        DateTime.now().isBefore(deadline)) {
      await $.pump(const Duration(milliseconds: 500));
      restored = relaunched.read(pomodoroControllerProvider);
    }

    expect(restored.status, PomodoroStatus.running,
        reason: '재실행 후 타이머가 running으로 복원되어야 한다');
    expect(restored.remainingTime, lessThan(remainingBefore),
        reason: '재실행 후 남은 시간은 벽시계 경과만큼 줄어 있어야 한다');
  });
}
