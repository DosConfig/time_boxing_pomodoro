import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_boxing_pomodoro/features/shell/presentation/app_shell.dart';
import 'package:time_boxing_pomodoro/firebase_options.dart';
import 'package:time_boxing_pomodoro/main.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture store product screens', (tester) async {
    const email = String.fromEnvironment('APP_REVIEW_EMAIL');
    const password = String.fromEnvironment('APP_REVIEW_PASSWORD');
    expect(email, isNotEmpty, reason: 'APP_REVIEW_EMAIL is required.');
    expect(password, isNotEmpty, reason: 'APP_REVIEW_PASSWORD is required.');

    SharedPreferences.setMockInitialValues({
      'app.introCompleted': true,
      'app.onboardingCompleted': true,
      'app.localeCode': 'en',
    });
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    await FirebaseAuth.instance.signOut();

    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final emailSignInButton = find.byKey(
      const ValueKey('emailSignInOpenButton'),
    );
    if (emailSignInButton.evaluate().isNotEmpty) {
      await tester.tap(emailSignInButton);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('emailSignInEmailField')),
        email,
      );
      await tester.enterText(
        find.byKey(const ValueKey('emailSignInPasswordField')),
        password,
      );
      await tester.tap(find.byKey(const ValueKey('emailSignInSubmitButton')));
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }

    expect(find.byType(AppShell), findsOneWidget);
    expect(find.text('Ship a stable beta'), findsOneWidget);
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('01-today-plan');

    final boardTitle = find.byKey(const ValueKey('timebox_board_title'));
    await tester.ensureVisible(boardTitle);
    await tester.pumpAndSettle();
    final boardTitleY = tester.getTopLeft(boardTitle).dy;
    await tester.timedDrag(
      find.byKey(const ValueKey('today_scroll')),
      Offset(0, 150 - boardTitleY),
      const Duration(seconds: 2),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await binding.takeScreenshot('02-timebox-board');

    await tester.tap(find.byIcon(Icons.timer_outlined));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await binding.takeScreenshot('03-focus');

    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await binding.takeScreenshot('04-calendar');

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await binding.takeScreenshot('05-settings');
  });
}
