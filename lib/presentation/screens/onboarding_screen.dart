import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_preferences_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  RangeValues? _awakeRange;

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(appPreferencesProvider);
    final range =
        _awakeRange ??
        RangeValues(
          preferences.awakeStartMinutes.toDouble(),
          preferences.awakeEndMinutes.toDouble(),
        );

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Text(
                'Timebox Mark',
                style: TextStyle(
                  color: Color(0xFFF6F3EC),
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Set the hours you actually plan.',
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
                    const Text(
                      'Awake window',
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
                      max: 24 * 60,
                      divisions: 48,
                      activeColor: const Color(0xFFF6F3EC),
                      inactiveColor: Colors.white.withValues(alpha: 0.16),
                      labels: RangeLabels(
                        formatClock(range.start.round()),
                        formatClock(range.end.round()),
                      ),
                      onChanged: (next) {
                        final normalized = normalizeAwakeRange(next);
                        HapticFeedback.selectionClick();
                        setState(() => _awakeRange = normalized);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  await ref
                      .read(appPreferencesProvider.notifier)
                      .completeOnboarding(
                        range.start.round(),
                        range.end.round(),
                      );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF6F3EC),
                  foregroundColor: const Color(0xFF080808),
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                child: const Text('Start planning'),
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
  final minimumSpan = AppPreferencesNotifier.minimumAwakeWindowMinutes;

  if (end - start >= minimumSpan) {
    return RangeValues(start.toDouble(), end.toDouble());
  }

  final adjustedEnd = (start + minimumSpan).clamp(0, 24 * 60);
  final adjustedStart = (adjustedEnd - minimumSpan).clamp(0, 24 * 60);
  return RangeValues(adjustedStart.toDouble(), adjustedEnd.toDouble());
}

String formatClock(int minutes) {
  if (minutes >= 24 * 60) {
    return '24:00';
  }
  final normalized = minutes.clamp(0, (24 * 60) - 1);
  final hour = normalized ~/ 60;
  final minute = normalized % 60;
  return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
