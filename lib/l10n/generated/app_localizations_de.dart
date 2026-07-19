// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Timebox Mark';

  @override
  String get navToday => 'Heute';

  @override
  String get navFocus => 'Fokus';

  @override
  String get navCalendar => 'Kalender';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get ok => 'OK';

  @override
  String get breakCompleteMessage =>
      'Pause beendet. Der nächste Block ist bereit.';

  @override
  String get focusCompleteMessage =>
      'Fokus beendet. Mach vor dem nächsten Block kurz Pause.';

  @override
  String get focusTitle => 'Fokus';

  @override
  String get shortBreakLabel => 'Kurze Pause';

  @override
  String get longBreakLabel => 'Lange Pause';

  @override
  String get nowLabel => 'Jetzt';

  @override
  String get readyLabel => 'Bereit';

  @override
  String get runningLabel => 'Läuft';

  @override
  String get pausedLabel => 'Pausiert';

  @override
  String sessionProgress(int completed, int total) {
    return '$completed von $total heutigen Blöcken';
  }

  @override
  String get resetAction => 'Zurücksetzen';

  @override
  String get pauseAction => 'Pausieren';

  @override
  String get startAction => 'Starten';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get awakeWindowTitle => 'Aktive Zeit';

  @override
  String get editAction => 'Bearbeiten';

  @override
  String get executionTitle => 'Ausführung';

  @override
  String get autoStartNextTimeBox => 'Nächste Timebox automatisch starten';

  @override
  String get alertsTitle => 'Hinweise';

  @override
  String get localAlerts => 'Lokale Hinweise';

  @override
  String get soundLabel => 'Ton';

  @override
  String get saveAction => 'Speichern';

  @override
  String get onboardingSubtitle =>
      'Lege die Stunden fest, die du wirklich planst.';

  @override
  String get startPlanning => 'Planung starten';

  @override
  String get calendarTitle => 'Kalender';

  @override
  String get todayPlanSync => 'Tagesplan-Sync';

  @override
  String get syncModeTitle => 'Sync-Modus';

  @override
  String get manualMode => 'Manuell';

  @override
  String get autoMode => 'Auto';

  @override
  String get calendarExport => 'Kalenderexport';

  @override
  String providerSetupQueued(String provider) {
    return '$provider Einrichtung ist vorgemerkt.';
  }

  @override
  String get providerAppleCalendar => 'Apple Kalender';

  @override
  String get appleCalendarExportDescription =>
      'Exportiert heutige Zeitblöcke in deinen Standard-Apple-Kalender.';

  @override
  String get providerGoogleCalendar => 'Google Kalender';

  @override
  String get googleCalendarExportDescription =>
      'Fügt heutige Zeitblöcke nach Google-Berechtigung deinem primären Google Kalender hinzu.';

  @override
  String get providerOutlook => 'Outlook';

  @override
  String get badgeFree => 'Kostenlos';

  @override
  String get badgePro => 'Pro';

  @override
  String get statusLocal => 'Lokal';

  @override
  String get statusFirebase => 'Firebase';

  @override
  String get statusOAuth => 'OAuth';

  @override
  String get setupAction => 'Einrichten';

  @override
  String get connectAction => 'Verbinden';

  @override
  String get providersTitle => 'Anbieter';

  @override
  String get exportRulesTitle => 'Exportregeln';

  @override
  String get topPrioritiesOnly => 'Nur Top-Prioritäten';

  @override
  String get conflictCheck => 'Konflikte prüfen';

  @override
  String get dedicatedCalendar => 'Eigener Kalender';

  @override
  String get includeBreaks => 'Pausen einschließen';

  @override
  String get todayQueueTitle => 'Heutige Warteschlange';

  @override
  String boxesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Blöcke',
      one: '1 Block',
      zero: '0 Blöcke',
    );
    return '$_temp0';
  }

  @override
  String get noBoxes => 'Keine Blöcke';

  @override
  String get exportSelected => 'Auswahl exportieren';

  @override
  String get exportTodayAction => 'Heute exportieren';

  @override
  String get exportAppleTodayAction => 'In Apple Kalender exportieren';

  @override
  String get exportGoogleTodayAction => 'In Google Kalender exportieren';

  @override
  String get calendarExporting => 'Export läuft';

  @override
  String get calendarExportEmpty => 'Keine Zeitblöcke zum Exportieren.';

  @override
  String calendarExportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Termine exportiert',
      one: '1 Termin exportiert',
      zero: 'Keine Termine exportiert',
    );
    return '$_temp0';
  }

  @override
  String get calendarExportDenied => 'Kalenderzugriff wurde abgelehnt.';

  @override
  String get calendarExportUnavailable =>
      'Kalenderexport ist auf diesem Gerät nicht verfügbar.';

  @override
  String get calendarExportFailed =>
      'Kalenderexport fehlgeschlagen. Bitte erneut versuchen.';

  @override
  String get todayTitle => 'Heute';

  @override
  String get startFocus => 'Fokus starten';

  @override
  String get brainDumpTitle => 'Gedankenspeicher';

  @override
  String get addBrainDumpTooltip => 'Gedanken hinzufügen';

  @override
  String get addBrainDumpTitle => 'Gedanken hinzufügen';

  @override
  String get captureLabel => 'Erfassen';

  @override
  String get makePriority => 'Zur Priorität machen';

  @override
  String get moveToReminder => 'Zu Erinnerung verschieben';

  @override
  String get deleteAction => 'Löschen';

  @override
  String get keepInMindTitle => 'Merken';

  @override
  String get addReminderTooltip => 'Erinnerung hinzufügen';

  @override
  String get addReminderTitle => 'Erinnerung hinzufügen';

  @override
  String get reminderLabel => 'Erinnerung';

  @override
  String get enterSomethingFirst => 'Bitte erst etwas eingeben.';

  @override
  String get dailyProgressTitle => 'Heute';

  @override
  String get planMetric => 'Prioritäten';

  @override
  String get timeBoxesMetric => 'Zeitblöcke';

  @override
  String get focusMetric => 'Fertig';

  @override
  String get dailyProgressDescription =>
      'Prüfe Prioritäten, geplante Blöcke und den nächsten Fokusblock.';

  @override
  String get todayReviewTitle => 'Tagesrückblick';

  @override
  String get nextTimeBoxLabel => 'Nächster';

  @override
  String get noActiveTimeBox => 'Kein Zeitblock';

  @override
  String get openFocusAction => 'Focus öffnen';

  @override
  String get topPrioritiesTitle => 'Top-Prioritäten';

  @override
  String get addPriorityTooltip => 'Priorität hinzufügen';

  @override
  String get noPrioritiesYet => 'Noch keine Prioritäten';

  @override
  String get threePrioritiesAlreadySet =>
      'Drei Prioritäten sind bereits gesetzt.';

  @override
  String get addPriorityTitle => 'Priorität hinzufügen';

  @override
  String get editPriorityTitle => 'Priorität bearbeiten';

  @override
  String priorityLabel(int number) {
    return 'Priorität $number';
  }

  @override
  String get clearPriority => 'Priorität löschen';

  @override
  String get weekdayMonNarrow => 'M';

  @override
  String get weekdayTueNarrow => 'D';

  @override
  String get weekdayWedNarrow => 'M';

  @override
  String get weekdayThuNarrow => 'D';

  @override
  String get weekdayFriNarrow => 'F';

  @override
  String get weekdaySatNarrow => 'S';

  @override
  String get weekdaySunNarrow => 'S';

  @override
  String get timeBoxesTitle => 'Timeboxes';

  @override
  String get timeBoxesHint =>
      'Leeren Slot antippen zum Hinzufügen. Box antippen zum Bearbeiten.';

  @override
  String get nowBadge => 'Jetzt';

  @override
  String get newTimeBoxTitle => 'Neue Timebox';

  @override
  String get editTimeBoxTitle => 'Timebox bearbeiten';

  @override
  String get titleLabel => 'Titel';

  @override
  String timeBoxRange(String range) {
    return 'Timebox $range';
  }

  @override
  String get newTimeBoxDefaultTitle => 'Neue Timebox';

  @override
  String get nativeFocusBlockTitle => 'Fokusblock';

  @override
  String get nativeBreakBlockTitle => 'Pausenblock';

  @override
  String get liveActivityTopPriorityLabel => 'Top';

  @override
  String get notificationFocusInProgressTitle => 'Fokus läuft';

  @override
  String get notificationShortBreakInProgressTitle => 'Kurze Pause läuft';

  @override
  String get notificationLongBreakInProgressTitle => 'Lange Pause läuft';

  @override
  String get notificationRemainingTimeFormat => '%@ verbleibend';

  @override
  String get notificationFocusCompleteTitle => 'Fokus abgeschlossen';

  @override
  String get notificationBreakCompleteTitle => 'Pause abgeschlossen';

  @override
  String get notificationFocusCompleteBody =>
      'Mach vor dem nächsten Block eine kurze Pause.';

  @override
  String get notificationBreakCompleteBody =>
      'Dein nächster Fokusblock ist bereit.';

  @override
  String get defaultTimeBoxTopPriority => 'Top-Priorität';

  @override
  String get defaultTimeBoxDeepWork => 'Deep Work';

  @override
  String get defaultTimeBoxAdmin => 'Admin';

  @override
  String get defaultTimeBoxSecondPriority => 'Zweite Priorität';

  @override
  String get defaultTimeBoxFollowUp => 'Follow-up';

  @override
  String get accountTitle => 'Konto';

  @override
  String get firebaseSetupRequired => 'Firebase-Einrichtung erforderlich';

  @override
  String get firebaseSetupDescription =>
      'Füge GoogleService-Info.plist hinzu und aktiviere Apple-Anmeldung in Firebase, um Cloud-Login zu nutzen.';

  @override
  String get signInWithAppleAction => 'Mit Apple anmelden';

  @override
  String signedInAs(String label) {
    return 'Angemeldet als $label';
  }

  @override
  String get signOutAction => 'Abmelden';

  @override
  String get authSignInFailed =>
      'Anmeldung fehlgeschlagen. Bitte erneut versuchen.';
}
