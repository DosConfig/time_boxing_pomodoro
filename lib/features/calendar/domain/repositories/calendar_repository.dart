import '../entities/calendar_export.dart';

abstract class CalendarRepository {
  Future<CalendarExportResult> exportToAppleCalendar(
    CalendarExportRequest request,
  );

  Future<CalendarExportResult> exportToGoogleCalendar(
    CalendarExportRequest request,
  );

  Future<CalendarAppOpenResult> openCalendarApp(CalendarProvider provider);
}
