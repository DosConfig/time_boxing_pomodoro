import '../entities/daily_plan_summary.dart';
import '../repositories/pomodoro_repository.dart';

class LoadDailyPlanHistoryUseCase {
  final PomodoroRepository repository;

  LoadDailyPlanHistoryUseCase(this.repository);

  Future<List<DailyPlanSummary>> call({int days = 7}) {
    return repository.loadDailyPlanHistory(days: days);
  }
}
