import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_boxing_pomodoro/features/auth/application/auth_controller.dart';
import 'package:time_boxing_pomodoro/features/auth/presentation/auth_gate_screen.dart';
import 'package:time_boxing_pomodoro/features/focus/application/pomodoro_controller.dart';
import 'package:time_boxing_pomodoro/features/onboarding/presentation/intro_onboarding_screen.dart';
import 'package:time_boxing_pomodoro/features/onboarding/presentation/onboarding_screen.dart';
import 'package:time_boxing_pomodoro/features/settings/application/app_preferences_controller.dart';
import 'package:time_boxing_pomodoro/features/shell/presentation/app_shell.dart';
import 'package:time_boxing_pomodoro/l10n/generated/app_localizations.dart';
import 'package:time_boxing_pomodoro/l10n/l10n.dart';
import 'package:time_boxing_pomodoro/shared/diagnostics/app_diagnostics.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final diagnostics = await initializeAppDiagnostics();
  installGlobalErrorHandlers(diagnostics);
  await diagnostics.breadcrumb('app_started');

  runApp(
    AppLifecycleDiagnostics(
      diagnostics: diagnostics,
      child: ProviderScope(
        overrides: [appDiagnosticsProvider.overrideWithValue(diagnostics)],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authControllerProvider, (previous, next) {
      final session = next.asData?.value;
      if (session == null) {
        return;
      }

      final diagnostics = ref.read(appDiagnosticsProvider);
      final authState = session.isSignedIn ? 'signed_in' : 'signed_out';
      unawaited(diagnostics.setContext('auth_state', authState));
      unawaited(
        diagnostics.breadcrumb(
          'auth_state_changed',
          attributes: {'signed_in': session.isSignedIn ? 1 : 0},
        ),
      );

      ref.invalidate(dailyPlanHistoryProvider);
      ref.invalidate(pomodoroControllerProvider);
      ref.invalidate(pomodoroRepositoryProvider);
      if (session.isSignedIn) {
        unawaited(
          ref
              .read(pomodoroControllerProvider.notifier)
              .syncTodayPlanWithDatabase(),
        );
      } else {
        return;
      }
    });

    final preferences = ref.watch(appPreferencesControllerProvider);
    final Widget home;
    if (!preferences.isLoaded) {
      home = const _LaunchLoadingScreen();
    } else if (!preferences.introCompleted) {
      home = const IntroOnboardingScreen();
    } else {
      final authSession = ref.watch(authControllerProvider);
      home = authSession.isLoading
          ? const _LaunchLoadingScreen()
          : authSession.asData?.value.isSignedIn != true
          ? const AuthGateScreen()
          : preferences.onboardingCompleted
          ? const AppShell()
          : const OnboardingScreen();
    }

    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appName,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      navigatorObservers: ref.read(appDiagnosticsProvider).navigatorObservers,
      locale: preferences.localeCode.isEmpty
          ? null
          : Locale(preferences.localeCode),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF6F3EC),
          brightness: Brightness.dark,
        ),
      ),
      home: home,
    );
  }
}

class _LaunchLoadingScreen extends StatelessWidget {
  const _LaunchLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF080808),
      body: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFF6F3EC),
          ),
        ),
      ),
    );
  }
}
