import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_boxing_pomodoro/features/auth/presentation/controllers/auth_controller.dart';
import 'package:time_boxing_pomodoro/features/auth/domain/entities/auth_session.dart';
import 'package:time_boxing_pomodoro/features/auth/domain/repositories/auth_repository.dart';
import 'package:time_boxing_pomodoro/features/auth/presentation/auth_gate_screen.dart';
import 'package:time_boxing_pomodoro/features/focus/presentation/controllers/pomodoro_controller.dart';
import 'package:time_boxing_pomodoro/features/focus/data/datasources/pomodoro_cloud_datasource.dart';
import 'package:time_boxing_pomodoro/features/focus/data/datasources/pomodoro_local_datasource.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/entities/daily_plan_summary.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/entities/pomodoro.dart';
import 'package:time_boxing_pomodoro/features/shell/presentation/app_shell.dart';
import 'package:time_boxing_pomodoro/main.dart';

/// 로그인 상태를 provider override로 주입해 실제 로그인 UI 없이 쉘 진입을 검증한다.
/// Firestore 접근은 fake datasource로 차단한다 (E2E에서 실 계정, 실 DB 사용 금지).
class _FakeAuthRepository implements AuthRepository {
  static const _session = AuthSession(
    isConfigured: true,
    userId: 'e2e-user',
    email: 'e2e@test.local',
    displayName: 'E2E',
  );

  @override
  Future<AuthSession> currentSession() async => _session;

  @override
  Future<AuthSession> signInWithApple() async => _session;

  @override
  Future<AuthSession> signInWithGoogle() async => _session;

  @override
  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) async => _session;

  @override
  Future<void> signOut() async {}

  @override
  Future<bool> deleteAccount() async => true;
}

class _FakeCloudDataSource extends PomodoroCloudDataSource {
  @override
  Future<void> saveTodayPlan(
    Pomodoro pomodoro, {
    int? updatedAtEpochMs,
    String? expectedUserId,
  }) async {}

  @override
  Future<Never?> loadTodayPlanDto() async => null;

  @override
  Future<List<DailyPlanSummary>> loadDailyPlanHistory({int days = 7}) async =>
      const [];

  @override
  Future<Pomodoro?> loadPreviousPlan(Pomodoro fallback) async => null;

  @override
  Future<Pomodoro?> loadPlanForDate(String dateKey, Pomodoro fallback) async =>
      null;
}

void main() {
  patrolTest(
    'signed-in user lands on app shell, state survives backgrounding',
    ($) async {
      // 온보딩 완료 상태로 시작
      SharedPreferences.setMockInitialValues({
        'app.introCompleted': true,
        'app.onboardingCompleted': true,
      });

      await $.pumpWidgetAndSettle(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWith((ref) => _FakeAuthRepository()),
            pomodoroCloudDataSourceProvider.overrideWith(
              (ref) => _FakeCloudDataSource(),
            ),
            // Firebase 미초기화 환경에서 FirebaseAuth를 건드리지 않는 고정 스코프
            pomodoroLocalDataSourceProvider.overrideWith(
              (ref) => PomodoroLocalDataSource(storageScope: () => 'e2e-user'),
            ),
          ],
          child: const MyApp(),
        ),
      );

      // 인증 게이트를 거치지 않고 쉘에 진입해야 한다 (타입 기반 검증: locale 무관)
      expect($(AuthGateScreen), findsNothing);
      expect($(AppShell), findsOneWidget);

      // 네이티브 동작: 홈으로 나갔다 복귀해도 쉘 상태 유지
      await $.platformAutomator.mobile.pressHome();
      await $.platformAutomator.mobile.openApp();
      await $.pumpAndSettle();
      expect($(AppShell), findsOneWidget);
    },
  );
}
