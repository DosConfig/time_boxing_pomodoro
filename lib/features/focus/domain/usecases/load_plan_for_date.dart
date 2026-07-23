import '../entities/pomodoro.dart';
import '../repositories/pomodoro_repository.dart';

/// 특정 날짜 키(yyyy-MM-dd)의 저장된 플랜 전체를 조회한다.
/// 과거 기록 열람과 선택형 가져오기가 공유하는 단일 조회 경로다.
/// doc: docs/architecture/DATA_LIFECYCLE.md
class LoadPlanForDateUseCase {
  final PomodoroRepository repository;

  const LoadPlanForDateUseCase(this.repository);

  Future<Pomodoro?> call(String dateKey, Pomodoro fallback) {
    return repository.loadPlanForDate(dateKey, fallback);
  }
}
