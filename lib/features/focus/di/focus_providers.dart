import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/datasources/pomodoro_cloud_datasource.dart';
import '../data/datasources/pomodoro_local_datasource.dart';
import '../data/repositories/pomodoro_repository_impl.dart';
import '../domain/repositories/pomodoro_repository.dart';
import '../domain/usecases/clear_local_plan_data.dart';
import '../domain/usecases/load_daily_plan_history.dart';
import '../domain/usecases/load_previous_plan.dart';
import '../domain/usecases/pause_pomodoro.dart';
import '../domain/usecases/reset_pomodoro.dart';
import '../domain/usecases/restore_pomodoro_state.dart';
import '../domain/usecases/restore_today_plan.dart';
import '../domain/usecases/start_pomodoro.dart';

part 'focus_providers.g.dart';

@Riverpod(keepAlive: true)
PomodoroLocalDataSource pomodoroLocalDataSource(Ref ref) {
  return PomodoroLocalDataSource();
}

@Riverpod(keepAlive: true)
PomodoroCloudDataSource pomodoroCloudDataSource(Ref ref) {
  return PomodoroCloudDataSource();
}

@Riverpod(keepAlive: true)
PomodoroRepository pomodoroRepository(Ref ref) {
  return PomodoroRepositoryImpl(
    ref.watch(pomodoroLocalDataSourceProvider),
    ref.watch(pomodoroCloudDataSourceProvider),
  );
}

@Riverpod(keepAlive: true)
StartPomodoroUseCase startPomodoroUseCase(Ref ref) {
  return StartPomodoroUseCase(ref.watch(pomodoroRepositoryProvider));
}

@Riverpod(keepAlive: true)
PausePomodoroUseCase pausePomodoroUseCase(Ref ref) {
  return PausePomodoroUseCase(ref.watch(pomodoroRepositoryProvider));
}

@Riverpod(keepAlive: true)
ResetPomodoroUseCase resetPomodoroUseCase(Ref ref) {
  return ResetPomodoroUseCase(ref.watch(pomodoroRepositoryProvider));
}

@Riverpod(keepAlive: true)
RestorePomodoroStateUseCase restorePomodoroStateUseCase(Ref ref) {
  return RestorePomodoroStateUseCase(ref.watch(pomodoroRepositoryProvider));
}

@Riverpod(keepAlive: true)
RestoreTodayPlanUseCase restoreTodayPlanUseCase(Ref ref) {
  return RestoreTodayPlanUseCase(ref.watch(pomodoroRepositoryProvider));
}

@Riverpod(keepAlive: true)
LoadDailyPlanHistoryUseCase loadDailyPlanHistoryUseCase(Ref ref) {
  return LoadDailyPlanHistoryUseCase(ref.watch(pomodoroRepositoryProvider));
}

@Riverpod(keepAlive: true)
LoadPreviousPlanUseCase loadPreviousPlanUseCase(Ref ref) {
  return LoadPreviousPlanUseCase(ref.watch(pomodoroRepositoryProvider));
}

@Riverpod(keepAlive: true)
ClearLocalPlanDataUseCase clearLocalPlanDataUseCase(Ref ref) {
  return ClearLocalPlanDataUseCase(ref.watch(pomodoroRepositoryProvider));
}
