import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_boxing_pomodoro/features/auth/presentation/auth_gate_screen.dart';
import 'package:time_boxing_pomodoro/features/auth/presentation/widgets/auth_provider_buttons.dart';
import 'package:time_boxing_pomodoro/features/focus/application/pomodoro_controller.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/entities/pomodoro.dart';
import 'package:time_boxing_pomodoro/features/onboarding/presentation/intro_onboarding_screen.dart';
import 'package:time_boxing_pomodoro/features/onboarding/presentation/onboarding_screen.dart';
import 'package:time_boxing_pomodoro/features/settings/application/app_preferences_controller.dart';
import 'package:time_boxing_pomodoro/features/shell/presentation/app_shell.dart';
import 'package:time_boxing_pomodoro/main.dart';

import 'helpers/e2e_fakes.dart';

/// J1: 첫날 유저 저니 (docs/testing/E2E_SCENARIOS.md)
/// 설치 직후 → 인트로 → 로그인 → 온보딩 → 타임박스 UI 생성 → 집중 시작.
/// 신규 사용자가 앱의 핵심 가치에 도달하는 전체 경로가 끊기지 않는지 보장한다.
void main() {
  patrolTest('first day: install to first focus session', ($) async {
    // 설치 직후 상태
    SharedPreferences.setMockInitialValues({});

    final container = signedOutContainer();
    await $.pumpWidgetAndSettle(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );

    // 1. 인트로: 마지막 슬라이드까지 같은 버튼을 반복 탭 (최대 8회 안전 장치)
    expect($(IntroOnboardingScreen), findsOneWidget);
    var guard = 0;
    while ($(IntroOnboardingScreen).exists && guard < 8) {
      await $(const ValueKey('intro_next')).tap();
      guard += 1;
    }
    expect($(IntroOnboardingScreen), findsNothing,
        reason: '인트로가 8번의 탭 안에 끝나야 한다');

    // 2. 로그인: 실제 버튼을 탭한다 (뒤의 인증만 페이크)
    expect($(AuthGateScreen), findsOneWidget);
    await $(GoogleSignInBrandButton).tap();
    await $.pumpAndSettle();

    // 3. 온보딩: 기상 시간 설정 화면에서 완료
    expect($(OnboardingScreen), findsOneWidget);
    await $(const ValueKey('onboarding_complete')).tap();
    await $.pumpAndSettle();
    expect($(AppShell), findsOneWidget);

    // 테스트가 어느 시각에 돌아도 현재 슬롯이 보드에 있도록
    // awake window를 하루 전체로 설정한다 (설정 화면과 같은 실제 API 사용)
    await container
        .read(appPreferencesControllerProvider.notifier)
        .saveAwakeWindow(0, 24 * 60);
    await $.pumpAndSettle();

    // 4. 타임박스 생성: 현재 시각 슬롯을 탭 → 제목 입력 → 저장
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final slotStart = nowMinutes - (nowMinutes % 30);
    final slotKey = ValueKey('timebox_slot_$slotStart');

    // 보드는 슬롯을 전부 즉시 생성하므로 ensureVisible로 정확히 스크롤한다
    // (드래그 탐색 방식 scrollTo는 보드가 길어 5초 안에 도달하지 못함)
    await $.tester.ensureVisible(find.byKey(slotKey));
    await $.pumpAndSettle();
    await $(slotKey).tap();
    await $(const ValueKey('timebox_title_field')).enterText('Deep work');
    await $(const ValueKey('timebox_save')).tap();
    await $.pumpAndSettle();

    // 저장 결과가 상태에 반영됐는지 확인
    final planned = container.read(pomodoroControllerProvider);
    expect(planned.timeBoxes.length, 1);
    expect(planned.timeBoxes.first.title, 'Deep work');

    // 5. 집중 시작: Start focus 탭 → 타이머 실행 (보드 아래에 있어 스크롤 필요)
    await $.tester.ensureVisible(find.byKey(const ValueKey('start_focus')));
    await $.pumpAndSettle();
    await $(const ValueKey('start_focus')).tap();
    await $.pumpAndSettle();

    final started = container.read(pomodoroControllerProvider);
    expect(started.status, PomodoroStatus.running,
        reason: '첫날 저니의 종착지: 타이머가 실행 중이어야 한다');
    expect(started.remainingTime, greaterThan(0));
  });
}
