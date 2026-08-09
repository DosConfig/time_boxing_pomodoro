import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_boxing_pomodoro/features/auth/presentation/controllers/auth_controller.dart';
import 'package:time_boxing_pomodoro/features/focus/presentation/controllers/pomodoro_controller.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/entities/native_timer_copy.dart';
import 'package:time_boxing_pomodoro/features/shell/presentation/app_shell.dart';
import 'package:time_boxing_pomodoro/main.dart';

import 'helpers/e2e_fakes.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture store product screens', (tester) async {
    SharedPreferences.setMockInitialValues({
      'app.introCompleted': true,
      'app.onboardingCompleted': true,
      'app.localeCode': 'en',
    });

    // Store screenshots must be deterministic and must never depend on a real
    // account or production Firestore data. The UI and application controller
    // are real; only authentication and cloud persistence are replaced.
    var fixedNow = DateTime(2026, 8, 6, 7, 15);
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWith((ref) => FakeAuthRepository()),
        pomodoroCloudDataSourceProvider.overrideWith(
          (ref) => FakeCloudDataSource(),
        ),
        pomodoroLocalDataSourceProvider.overrideWith(
          (ref) => fakeLocalDataSource(),
        ),
        pomodoroClockProvider.overrideWithValue(() => fixedNow),
      ],
    );
    addTearDown(container.dispose);
    final screenshotBoundaryKey = GlobalKey();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: RepaintBoundary(
          key: screenshotBoundaryKey,
          child: const MyApp(),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byType(AppShell), findsOneWidget);

    final notifier = container.read(pomodoroControllerProvider.notifier);
    notifier
      ..setTopPriority(0, 'Ship a stable beta')
      ..setTopPriority(1, 'Review the release checklist')
      ..setTopPriority(2, 'Plan tomorrow with clarity')
      ..addBrainDumpItem('Polish the onboarding copy')
      ..addBrainDumpItem('Prepare the App Store screenshots')
      ..addReminder('Check crash-free users after release')
      ..addTimeBoxAtStart(
        8 * 60,
        title: 'Plan the day',
        durationSeconds: 60 * 60,
      )
      ..addTimeBoxAtStart(
        9 * 60,
        title: 'Review critical flows',
        durationSeconds: 60 * 60,
      )
      ..addTimeBoxAtStart(
        11 * 60,
        title: 'Triage feedback',
        durationSeconds: 30 * 60,
      )
      ..addTimeBoxAtStart(13 * 60, title: 'Deep work', durationSeconds: 90 * 60)
      ..addTimeBoxAtStart(
        15 * 60,
        title: 'Release review',
        durationSeconds: 60 * 60,
      );
    final focusBox = notifier.addTimeBoxAtStart(
      10 * 60,
      title: 'Ship a stable beta',
      durationSeconds: 60 * 60,
    );
    await notifier.setScheduleTrackingEnabled(false, const NativeTimerCopy());
    fixedNow = DateTime(2026, 8, 6, 10, 15);
    notifier.syncFocusWithClock();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Ship a stable beta'), findsWidgets);
    await _captureFlutterSurface(
      binding,
      screenshotBoundaryKey,
      '01-today-plan',
    );

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
    await _captureFlutterSurface(
      binding,
      screenshotBoundaryKey,
      '02-timebox-board',
    );

    await tester.tap(find.byIcon(Icons.timer_outlined));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(
      container.read(pomodoroControllerProvider).activeTimeBoxId,
      focusBox.id,
    );
    await _captureFlutterSurface(binding, screenshotBoundaryKey, '03-focus');

    fixedNow = DateTime(2026, 8, 6, 7, 15);
    final focusNotifier = container.read(pomodoroControllerProvider.notifier);
    await focusNotifier.setScheduleTrackingEnabled(
      true,
      const NativeTimerCopy(),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await _captureFlutterSurface(binding, screenshotBoundaryKey, '04-settings');
  });
}

Future<void> _captureFlutterSurface(
  IntegrationTestWidgetsFlutterBinding binding,
  GlobalKey boundaryKey,
  String name,
) async {
  final boundary =
      boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final pixelRatio = View.of(boundaryKey.currentContext!).devicePixelRatio;
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  final bytes = byteData!.buffer.asUint8List();

  binding.reportData ??= <String, dynamic>{};
  binding.reportData!['screenshots'] ??= <dynamic>[];
  (binding.reportData!['screenshots']! as List<dynamic>).add({
    'screenshotName': name,
    'bytes': bytes,
  });
}
