import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_boxing_pomodoro/features/onboarding/presentation/intro_onboarding_screen.dart';
import 'package:time_boxing_pomodoro/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpIntro(
    WidgetTester tester, {
    Size surfaceSize = const Size(390, 844),
  }) async {
    await tester.binding.setSurfaceSize(surfaceSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: IntroOnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('advances through the onboarding pages', (tester) async {
    await pumpIntro(tester);

    expect(find.text('Empty your head'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Pick the top three'), findsOneWidget);
  });

  testWidgets('persists completion when skipped', (tester) async {
    await pumpIntro(tester);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('app.introCompleted'), isTrue);
  });

  testWidgets('all pages fit on a compact Android display', (tester) async {
    await pumpIntro(tester, surfaceSize: const Size(360, 640));

    for (var page = 0; page < 4; page += 1) {
      expect(tester.takeException(), isNull);
      if (page < 3) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }
    }

    expect(tester.takeException(), isNull);
  });
}
