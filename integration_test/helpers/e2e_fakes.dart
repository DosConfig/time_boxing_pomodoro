import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_boxing_pomodoro/features/auth/application/auth_controller.dart';
import 'package:time_boxing_pomodoro/features/auth/domain/entities/auth_session.dart';
import 'package:time_boxing_pomodoro/features/auth/domain/repositories/auth_repository.dart';
import 'package:time_boxing_pomodoro/features/focus/application/pomodoro_controller.dart';
import 'package:time_boxing_pomodoro/features/focus/data/datasources/pomodoro_cloud_datasource.dart';
import 'package:time_boxing_pomodoro/features/focus/data/datasources/pomodoro_local_datasource.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/entities/daily_plan_summary.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/entities/pomodoro.dart';

/// E2E 공용 테스트 더블. 실 로그인과 실 Firestore 접근을 차단한다.
/// 실제 UI 플로우(로그인 버튼 탭 등)는 그대로 타되, 뒤의 인프라만 교체한다.
class FakeAuthRepository implements AuthRepository {
  static const session = AuthSession(
    isConfigured: true,
    userId: 'e2e-user',
    email: 'e2e@test.local',
    displayName: 'E2E',
  );

  @override
  Future<AuthSession> currentSession() async => session;

  @override
  Future<AuthSession> signInWithApple() async => session;

  @override
  Future<AuthSession> signInWithGoogle() async => session;

  @override
  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) async => session;

  @override
  Future<void> signOut() async {}

  @override
  Future<bool> deleteAccount() async => true;
}

/// 로그인 전 상태로 시작하고 싶을 때 사용. 로그인 시도 시에만 세션을 준다.
class SignedOutFakeAuthRepository extends FakeAuthRepository {
  @override
  Future<AuthSession> currentSession() async =>
      const AuthSession(isConfigured: true);
}

class FakeCloudDataSource extends PomodoroCloudDataSource {
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

/// Firebase 미초기화 환경에서 FirebaseAuth를 건드리지 않는 고정 스코프.
PomodoroLocalDataSource fakeLocalDataSource() =>
    PomodoroLocalDataSource(storageScope: () => 'e2e-user');

/// 로그인 완료 상태로 시작하는 컨테이너 (로그인 이후 저니용)
ProviderContainer signedInContainer() => ProviderContainer(
  overrides: [
    authRepositoryProvider.overrideWith((ref) => FakeAuthRepository()),
    pomodoroCloudDataSourceProvider.overrideWith(
      (ref) => FakeCloudDataSource(),
    ),
    pomodoroLocalDataSourceProvider.overrideWith(
      (ref) => fakeLocalDataSource(),
    ),
  ],
);

/// 로그인 전 상태로 시작하는 컨테이너 (첫날 저니용: 로그인 버튼을 실제로 탭)
ProviderContainer signedOutContainer() => ProviderContainer(
  overrides: [
    authRepositoryProvider.overrideWith((ref) => SignedOutFakeAuthRepository()),
    pomodoroCloudDataSourceProvider.overrideWith(
      (ref) => FakeCloudDataSource(),
    ),
    pomodoroLocalDataSourceProvider.overrideWith(
      (ref) => fakeLocalDataSource(),
    ),
  ],
);
