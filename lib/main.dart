import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_method_channel/presentation/providers/app_preferences_provider.dart';
import 'package:pomodoro_method_channel/presentation/screens/app_shell.dart';
import 'package:pomodoro_method_channel/presentation/screens/onboarding_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(appPreferencesProvider);

    return MaterialApp(
      title: 'Timebox Mark',
      debugShowCheckedModeBanner: false,
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
