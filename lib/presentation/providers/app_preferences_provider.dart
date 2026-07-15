import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  final bool isLoaded;
  final bool onboardingCompleted;
  final int awakeStartMinutes;
  final int awakeEndMinutes;

  const AppPreferences({
    required this.isLoaded,
    required this.onboardingCompleted,
    required this.awakeStartMinutes,
    required this.awakeEndMinutes,
  });

  factory AppPreferences.initial() {
    return const AppPreferences(
      isLoaded: false,
      onboardingCompleted: false,
      awakeStartMinutes: 7 * 60,
      awakeEndMinutes: 23 * 60,
    );
  }

  AppPreferences copyWith({
    bool? isLoaded,
    bool? onboardingCompleted,
    int? awakeStartMinutes,
    int? awakeEndMinutes,
  }) {
    return AppPreferences(
      isLoaded: isLoaded ?? this.isLoaded,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      awakeStartMinutes: awakeStartMinutes ?? this.awakeStartMinutes,
      awakeEndMinutes: awakeEndMinutes ?? this.awakeEndMinutes,
    );
  }
}

class AppPreferencesNotifier extends Notifier<AppPreferences> {
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
    state = AppPreferences(
      isLoaded: true,
      onboardingCompleted:
          preferences.getBool(_onboardingCompletedKey) ?? false,
      awakeStartMinutes:
          preferences.getInt(_awakeStartKey) ??
          AppPreferences.initial().awakeStartMinutes,
      awakeEndMinutes:
          preferences.getInt(_awakeEndKey) ??
          AppPreferences.initial().awakeEndMinutes,
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

final appPreferencesProvider =
    NotifierProvider<AppPreferencesNotifier, AppPreferences>(() {
      return AppPreferencesNotifier();
    });
