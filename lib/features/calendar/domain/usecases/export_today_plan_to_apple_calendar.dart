import '../entities/calendar_export.dart';
import '../repositories/calendar_repository.dart';

class ExportTodayPlanToAppleCalendarUseCase {
  final CalendarRepository repository;

  ExportTodayPlanToAppleCalendarUseCase(this.repository);

  Future<CalendarExportResult> call(CalendarExportRequest request) {
    return repository.exportToAppleCalendar(request);
  }
}
