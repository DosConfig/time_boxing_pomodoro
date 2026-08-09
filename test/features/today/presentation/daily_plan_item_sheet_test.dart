import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_boxing_pomodoro/features/focus/presentation/controllers/pomodoro_controller.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/entities/daily_plan_item_category.dart';
import 'package:time_boxing_pomodoro/features/focus/domain/entities/pomodoro.dart';
import 'package:time_boxing_pomodoro/features/today/presentation/widgets/daily_plan_item_sheet.dart';
import 'package:time_boxing_pomodoro/l10n/generated/app_localizations.dart';

void main() {
  Future<ProviderContainer> pumpSheetHost(
    WidgetTester tester, {
    required Pomodoro pomodoro,
    required DailyPlanItemCategory category,
    required int index,
    required String value,
  }) async {
    late ProviderContainer container;

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
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, child) {
                container = ProviderScope.containerOf(context);
                return TextButton(
                  key: const ValueKey('openSheet'),
                  onPressed: () => showDailyPlanItemSheet(
                    context,
                    notifier: ref.read(pomodoroControllerProvider.notifier),
                    category: category,
                    index: index,
                    value: value,
                  ),
                  child: const Text('open'),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('openSheet')));
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('edits reminder text through the shared sheet', (tester) async {
    final container = await pumpSheetHost(
      tester,
      pomodoro: Pomodoro.initial().copyWith(reminders: const ['Water plants']),
      category: DailyPlanItemCategory.reminder,
      index: 0,
      value: 'Water plants',
    );

    final field = find.byKey(const ValueKey('dailyPlanSheetField'));
    expect(find.text('Water plants'), findsOneWidget);

    await tester.enterText(field, 'Water plants at noon');
    await tester.tap(find.byKey(const ValueKey('dailyPlanSheetSave')));
    await tester.pumpAndSettle();

    final state = container.read(pomodoroControllerProvider);
    expect(state.reminders, ['Water plants at noon']);
  });

  testWidgets('edits brain dump text through the shared sheet', (tester) async {
    final container = await pumpSheetHost(
      tester,
      pomodoro: Pomodoro.initial().copyWith(brainDump: const ['Draft note']),
      category: DailyPlanItemCategory.brainDump,
      index: 0,
      value: 'Draft note',
    );

    await tester.enterText(
      find.byKey(const ValueKey('dailyPlanSheetField')),
      'Draft launch note',
    );
    await tester.tap(find.byKey(const ValueKey('dailyPlanSheetSave')));
    await tester.pumpAndSettle();

    final state = container.read(pomodoroControllerProvider);
    expect(state.brainDump, ['Draft launch note']);
  });

  testWidgets('deletes a reminder from the shared sheet', (tester) async {
    final container = await pumpSheetHost(
      tester,
      pomodoro: Pomodoro.initial().copyWith(reminders: const ['Old note']),
      category: DailyPlanItemCategory.reminder,
      index: 0,
      value: 'Old note',
    );

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    final state = container.read(pomodoroControllerProvider);
    expect(state.reminders, isEmpty);
  });

  testWidgets('blocks promotion when three priorities are already set', (
    tester,
  ) async {
    final container = await pumpSheetHost(
      tester,
      pomodoro: Pomodoro.initial().copyWith(
        topPriorities: const ['One', 'Two', 'Three'],
        brainDump: const ['Fourth idea'],
      ),
      category: DailyPlanItemCategory.brainDump,
      index: 0,
      value: 'Fourth idea',
    );

    await tester.tap(find.text('Make priority'));
    await tester.pumpAndSettle();

    final state = container.read(pomodoroControllerProvider);
    expect(state.brainDump, ['Fourth idea']);
    expect(state.topPriorities, ['One', 'Two', 'Three']);
    expect(find.text('Three priorities are already set.'), findsOneWidget);
  });

  testWidgets('moves a reminder to brain dump from the shared sheet', (
    tester,
  ) async {
    final container = await pumpSheetHost(
      tester,
      pomodoro: Pomodoro.initial().copyWith(reminders: const ['Sort inbox']),
      category: DailyPlanItemCategory.reminder,
      index: 0,
      value: 'Sort inbox',
    );

    await tester.tap(find.text('Move to brain dump'));
    await tester.pumpAndSettle();

    final state = container.read(pomodoroControllerProvider);
    expect(state.reminders, isEmpty);
    expect(state.brainDump, ['Sort inbox']);
  });
}

class _TestPomodoroController extends PomodoroController {
  final Pomodoro initialState;

  _TestPomodoroController(this.initialState);

  @override
  Pomodoro build() => initialState;
}
