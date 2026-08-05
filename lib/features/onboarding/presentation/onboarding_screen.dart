import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_boxing_pomodoro/l10n/l10n.dart';

import '../application/onboarding_draft_controller.dart';
import '../../settings/application/app_preferences_controller.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final preferences = ref.watch(appPreferencesControllerProvider);
    final draft = ref.watch(onboardingAwakeWindowDraftProvider);
    final range = draft == null
        ? RangeValues(
            preferences.awakeStartMinutes.toDouble(),
            preferences.awakeEndMinutes.toDouble(),
          )
        : RangeValues(
            draft.startMinutes.toDouble(),
            draft.endMinutes.toDouble(),
          );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                l10n.appName,
                style: TextStyle(
                  color: Color(0xFFF6F3EC),
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.onboardingSubtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.54),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 34),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.055),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.awakeWindowTitle,
                      style: TextStyle(
                        color: Color(0xFFF6F3EC),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${formatClock(range.start.round())} - ${formatClock(range.end.round())}',
                      style: const TextStyle(
                        color: Color(0xFFF6F3EC),
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RangeSlider(
                      values: range,
                      min: 0,
                      max: AppPreferencesController.maximumAwakeEndMinutes
                          .toDouble(),
                      divisions: 56,
                      activeColor: const Color(0xFFF6F3EC),
                      inactiveColor: Colors.white.withValues(alpha: 0.16),
                      labels: RangeLabels(
                        formatClock(range.start.round()),
                        formatClock(range.end.round()),
                      ),
                      onChanged: (next) {
                        final normalized = normalizeAwakeRange(next);
                        HapticFeedback.selectionClick();
                        ref
                            .read(onboardingAwakeWindowDraftProvider.notifier)
                            .setWindow(
                              normalized.start.round(),
                              normalized.end.round(),
                            );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const ValueKey('onboarding_complete'),
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  await ref
                      .read(appPreferencesControllerProvider.notifier)
                      .completeOnboarding(
                        range.start.round(),
                        range.end.round(),
                      );
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                child: Text(
                  l10n.startPlanning,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

RangeValues normalizeAwakeRange(RangeValues values) {
  final start = values.start.round();
  final end = values.end.round();
  final minimumSpan = AppPreferencesController.minimumAwakeWindowMinutes;
  final maximumEnd = AppPreferencesController.maximumAwakeEndMinutes;

  if (end - start >= minimumSpan) {
    return RangeValues(start.toDouble(), end.toDouble());
  }

  final adjustedEnd = (start + minimumSpan).clamp(0, maximumEnd);
  final adjustedStart = (adjustedEnd - minimumSpan).clamp(0, maximumEnd);
  return RangeValues(adjustedStart.toDouble(), adjustedEnd.toDouble());
}

/// 자정을 넘긴 시각(예: 1500분)은 "01:00 +1"처럼 다음날 표기를 붙인다.
String formatClock(int minutes) {
  if (minutes == 24 * 60) {
    return '24:00';
  }
  if (minutes > 24 * 60) {
    final wrapped = minutes - (24 * 60);
    final hour = wrapped ~/ 60;
    final minute = wrapped % 60;
    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')} +1';
  }
  final normalized = minutes.clamp(0, (24 * 60) - 1);
  final hour = normalized ~/ 60;
  final minute = normalized % 60;
  return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
