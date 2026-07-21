import '../entities/calendar_export.dart';
import '../repositories/calendar_repository.dart';

class OpenCalendarAppUseCase {
  final CalendarRepository repository;

  const OpenCalendarAppUseCase(this.repository);

  Future<CalendarAppOpenResult> call(CalendarProvider provider) {
    return repository.openCalendarApp(provider);
  }
}
