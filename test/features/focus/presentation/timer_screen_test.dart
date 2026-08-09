import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_boxing_pomodoro/features/focus/presentation/controllers/pomodoro_controller.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/entities/pomodoro.dart';
import 'package:time_boxing_pomodoro/features/focus/presentation/timer_screen.dart';
import 'package:time_boxing_pomodoro/l10n/generated/app_localizations.dart';

void main() {
  Future<void> pumpTimerScreen(WidgetTester tester, Pomodoro pomodoro) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pomodoroControllerProvider.overrideWith(
            () => _TestPomodoroController(pomodoro),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TimerScreen(onOpenToday: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'empty current slot omits timer controls and the duplicate tracking toggle',
    (tester) async {
      final pomodoro = Pomodoro.initial().copyWith(
        activeTimeBoxId: '',
        currentTimeBoxTitle: '',
        currentTimeBoxTimeRange: '',
        remainingTime: 0,
      );

      await pumpTimerScreen(tester, pomodoro);

      expect(find.text('No block right now'), findsOneWidget);
      expect(find.text('00:00'), findsNothing);
      expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
      expect(find.byIcon(Icons.restart_alt_rounded), findsNothing);
      expect(find.text('Live timebox tracking'), findsNothing);
    },
  );
}

class _TestPomodoroController extends PomodoroController {
  final Pomodoro initialState;

  _TestPomodoroController(this.initialState);

  @override
  Pomodoro build() => initialState;
}
