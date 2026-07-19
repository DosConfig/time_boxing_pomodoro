import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/app_preferences.dart';

part 'app_preferences_controller.g.dart';

@Riverpod(keepAlive: true)
class AppPreferencesController extends _$AppPreferencesController {
  static const _onboardingCompletedKey = 'app.onboardingCompleted';
  static const _awakeStartKey = 'app.awakeStartMinutes';
  static const _awakeEndKey = 'app.awakeEndMinutes';
  static const minimumAwakeWindowMinutes = 4 * 60;

  @override
  AppPreferences build() {
    Future.microtask(_load);
    return AppPreferences.initial();
  }

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    final initial = AppPreferences.initial();
    state = AppPreferences(
      isLoaded: true,
      onboardingCompleted:
          preferences.getBool(_onboardingCompletedKey) ?? false,
      awakeStartMinutes:
          preferences.getInt(_awakeStartKey) ?? initial.awakeStartMinutes,
      awakeEndMinutes:
          preferences.getInt(_awakeEndKey) ?? initial.awakeEndMinutes,
    );
  }

  Future<void> saveAwakeWindow(int startMinutes, int endMinutes) async {
    final normalized = _normalizeWindow(startMinutes, endMinutes);
    state = state.copyWith(
      awakeStartMinutes: normalized.$1,
      awakeEndMinutes: normalized.$2,
    );

    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_awakeStartKey, normalized.$1);
    await preferences.setInt(_awakeEndKey, normalized.$2);
  }

  Future<void> completeOnboarding(int startMinutes, int endMinutes) async {
    final normalized = _normalizeWindow(startMinutes, endMinutes);
    state = state.copyWith(
      isLoaded: true,
      onboardingCompleted: true,
      awakeStartMinutes: normalized.$1,
      awakeEndMinutes: normalized.$2,
    );

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_onboardingCompletedKey, true);
    await preferences.setInt(_awakeStartKey, normalized.$1);
    await preferences.setInt(_awakeEndKey, normalized.$2);
  }

  (int, int) _normalizeWindow(int startMinutes, int endMinutes) {
    final start = startMinutes.clamp(0, 20 * 60);
    final end = endMinutes.clamp(start + minimumAwakeWindowMinutes, 24 * 60);
    return (start, end);
  }
}
