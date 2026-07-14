import 'package:custom_fluid_background/custom_fluid_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/pomodoro_platform_channel.dart';
import '../../domain/entities/pomodoro.dart';
import '../providers/pomodoro_provider.dart';
import '../widgets/crt_timer_widget.dart';

// LA 진단용 임시 표시 (해결 후 제거)
final ValueNotifier<String> _laDiag = ValueNotifier<String>('');

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomodoro = ref.watch(pomodoroProvider);
    final pomodoroNotifier = ref.read(pomodoroProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomFluidBackground(
        themePreset: _getThemePreset(pomodoro.status),
        animationPattern: AnimationPattern.floating,
        performanceMode: PerformanceMode.balanced,
        enableInteractive: true,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status Text
              Text(
                _getStatusText(pomodoro.status),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              const SizedBox(height: 20),

              // Session Counter
              Text(
                '${pomodoro.completedSessions}/5',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 5)],
                ),
              ),
              const SizedBox(height: 40),

              // Timer Widget
              CRTTimerWidget(minutes: pomodoro.minutes, seconds: pomodoro.seconds),
              const SizedBox(height: 40),

              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPixelButton(
                    icon: pomodoro.status == PomodoroStatus.running ? Icons.pause : Icons.play_arrow,
                    onPressed: () async {
                      if (pomodoro.status == PomodoroStatus.running) {
                        await pomodoroNotifier.pause();
                        _laDiag.value = 'pause 호출됨';
                      } else {
                        await pomodoroNotifier.start();
                        // 네이티브의 LA 시작 결과를 화면에 직접 표시
                        final status = await PomodoroPlatformChannel.getActivityStatus();
                        _laDiag.value = 'LA: $status';
                      }
                    },
                    color: Colors.green,
                  ),
                  const SizedBox(width: 20),
                  _buildPixelButton(
                    icon: Icons.refresh,
                    onPressed: () => pomodoroNotifier.reset(),
                    color: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // LA 진단 표시 (임시)
              ValueListenableBuilder<String>(
                valueListenable: _laDiag,
                builder: (_, value, __) => Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.yellowAccent,
                    shadows: [Shadow(color: Colors.black, blurRadius: 6)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPixelButton({required IconData icon, required VoidCallback onPressed, required Color color}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.white, width: 4),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(4, 4))],
        ),
        child: Icon(icon, size: 40, color: Colors.white),
      ),
    );
  }

  String _getStatusText(PomodoroStatus status) {
    switch (status) {
      case PomodoroStatus.idle:
        return 'Ready to Focus!';
      case PomodoroStatus.running:
        return 'Focus Time!';
      case PomodoroStatus.paused:
        return 'Paused';
      case PomodoroStatus.break_:
        return 'Break Time!';
    }
  }

  ThemePreset _getThemePreset(PomodoroStatus status) {
    switch (status) {
      case PomodoroStatus.idle:
        return ThemePreset.oceanWaves;
      case PomodoroStatus.running:
        return ThemePreset.sunsetGlow;
      case PomodoroStatus.paused:
        return ThemePreset.oceanWaves;
      case PomodoroStatus.break_:
        return ThemePreset.auroraLights;
    }
  }
}
