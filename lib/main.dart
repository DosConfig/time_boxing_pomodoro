import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_method_channel/features/onboarding/presentation/onboarding_screen.dart';
import 'package:pomodoro_method_channel/features/settings/application/app_preferences_controller.dart';
import 'package:pomodoro_method_channel/features/shell/presentation/app_shell.dart';
import 'package:pomodoro_method_channel/l10n/generated/app_localizations.dart';
import 'package:pomodoro_method_channel/l10n/l10n.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(appPreferencesControllerProvider);

    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appName,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF6F3EC),
          brightness: Brightness.dark,
        ),
      ),
      home: !preferences.isLoaded
          ? const _LaunchLoadingScreen()
          : preferences.onboardingCompleted
          ? const AppShell()
          : const OnboardingScreen(),
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
