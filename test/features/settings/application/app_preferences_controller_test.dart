import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_boxing_pomodoro/features/settings/application/app_preferences_controller.dart';
import 'package:time_boxing_pomodoro/features/settings/domain/entities/app_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads and persists the selected time slot interval', () async {
    SharedPreferences.setMockInitialValues({'app.timeSlotIntervalMinutes': 15});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(appPreferencesControllerProvider);
    await _waitForPreferences(container);

    expect(
      container.read(appPreferencesControllerProvider).timeSlotInterval,
      TimeSlotInterval.fifteenMinutes,
    );

    await container
        .read(appPreferencesControllerProvider.notifier)
        .setTimeSlotInterval(TimeSlotInterval.oneHour);

    final stored = await SharedPreferences.getInstance();
    expect(stored.getInt('app.timeSlotIntervalMinutes'), 60);
    expect(
      container.read(appPreferencesControllerProvider).timeSlotInterval,
      TimeSlotInterval.oneHour,
    );
  });

  test('falls back to 30 minutes for an unsupported stored value', () async {
    SharedPreferences.setMockInitialValues({'app.timeSlotIntervalMinutes': 45});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(appPreferencesControllerProvider);
    await _waitForPreferences(container);

    expect(
      container.read(appPreferencesControllerProvider).timeSlotInterval,
      TimeSlotInterval.thirtyMinutes,
    );
  });
}

Future<void> _waitForPreferences(ProviderContainer container) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    if (container.read(appPreferencesControllerProvider).isLoaded) {
      return;
    }
    await Future<void>.delayed(Duration.zero);
  }
  fail('App preferences did not finish loading.');
}
