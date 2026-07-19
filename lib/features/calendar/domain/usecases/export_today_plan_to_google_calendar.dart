import '../entities/calendar_export.dart';
import '../repositories/calendar_repository.dart';

class ExportTodayPlanToGoogleCalendarUseCase {
  final CalendarRepository repository;

  ExportTodayPlanToGoogleCalendarUseCase(this.repository);

  Future<CalendarExportResult> call(CalendarExportRequest request) {
    return repository.exportToGoogleCalendar(request);
  }
}
