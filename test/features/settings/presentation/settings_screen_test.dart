import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_boxing_pomodoro/features/auth/application/auth_controller.dart';
import 'package:time_boxing_pomodoro/features/auth/domain/entities/auth_session.dart';
import 'package:time_boxing_pomodoro/features/focus/application/pomodoro_controller.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/entities/pomodoro.dart';
import 'package:time_boxing_pomodoro/features/settings/application/app_preferences_controller.dart';
import 'package:time_boxing_pomodoro/features/settings/domain/entities/app_preferences.dart';
import 'package:time_boxing_pomodoro/features/settings/presentation/settings_screen.dart';
import 'package:time_boxing_pomodoro/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('changes the time adjustment interval without layout overflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pomodoroControllerProvider.overrideWith(_TestPomodoroController.new),
          authControllerProvider.overrideWith(_TestAuthController.new),
          appPreferencesControllerProvider.overrideWith(
            _TestAppPreferencesController.new,
          ),
        ],
        child: const MaterialApp(
          locale: Locale('ko'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            backgroundColor: Color(0xFF080808),
            body: SettingsScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final intervalTitle = find.text('시간 조절 단위');
    await tester.ensureVisible(intervalTitle);
    await tester.pumpAndSettle();

    expect(intervalTitle, findsOneWidget);
    expect(find.text('15분'), findsOneWidget);
    expect(find.text('30분'), findsOneWidget);
    expect(find.text('1시간'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('15분'));
    await tester.pumpAndSettle();

    final context = tester.element(intervalTitle);
    final container = ProviderScope.containerOf(context);
    expect(
      container.read(appPreferencesControllerProvider).timeSlotInterval,
      TimeSlotInterval.fifteenMinutes,
    );
    expect(tester.takeException(), isNull);
  });
}

class _TestPomodoroController extends PomodoroController {
  @override
  Pomodoro build() => Pomodoro.initial();
}

class _TestAuthController extends AuthController {
  @override
  Future<AuthSession> build() async => const AuthSession(
    isConfigured: true,
    userId: 'test-user',
    displayName: 'Test User',
  );
}

class _TestAppPreferencesController extends AppPreferencesController {
  @override
  AppPreferences build() => const AppPreferences(isLoaded: true);

  @override
  Future<void> setTimeSlotInterval(TimeSlotInterval interval) async {
    state = state.copyWith(timeSlotInterval: interval);
  }
}
