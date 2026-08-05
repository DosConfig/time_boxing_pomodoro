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
  String get introBrandEyebrow => 'Weniger planen. Schneller loslegen.';

  @override
  String get introBrandTitle => 'Timeboxe deinen Tag';

  @override
  String get introBrandBody =>
      'Mache aus Notizen Prioritäten, flexible Zeitblöcke, Fokussitzungen und rechtzeitige Hinweise.';

  @override
  String get introBrainDumpTitle => 'Kopf leeren';

  @override
  String get introBrainDumpBody =>
      'Basierend auf bewahrtem Timeboxing und Pomodoro: erst sammeln, dann entscheiden.';

  @override
  String get introPrioritiesTitle => 'Top drei wählen';

  @override
  String get introPrioritiesBody =>
      'Lege drei sichtbare Prioritäten fest, bevor der Tag dich zieht.';

  @override
  String get introTimeBoxTitle => 'Flexible Zeitblöcke setzen';

  @override
  String get introTimeBoxBody =>
      'Tippe auf einen Slot und plane den Tag im passenden Zeitintervall.';

  @override
  String get introFocusTitle => 'Fokus folgt der Uhr';

  @override
  String get introFocusBody =>
      'Nach dem Login steuert der aktuelle Block Fokus, Live Activity, Alarme und Cloud-Sync.';

  @override
  String get introBackAction => 'Zurück';

  @override
  String get introNextAction => 'Weiter';

  @override
  String get introStartAction => 'Loslegen';

  @override
  String get introSkipAction => 'Überspringen';

  @override
  String get introSampleTopPriority => 'Launch-Plan';

  @override
  String get introSampleDeepWork => 'Deep Work';

  @override
  String get introSampleFollowUp => 'Follow-up';

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
  String get languageTitle => 'Sprache';

  @override
  String get languageSystem => 'Systemstandard';

  @override
  String get languageKorean => 'Koreanisch';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageJapanese => 'Japanisch';

  @override
  String get languageChinese => 'Chinesisch';

  @override
  String get languageSpanish => 'Spanisch';

  @override
  String get languageFrench => 'Französisch';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get awakeWindowTitle => 'Aktive Zeit';

  @override
  String get timeSlotIntervalTitle => 'Zeitintervall';

  @override
  String get timeSlotIntervalDescription =>
      'Legt die Schritte zum Erstellen, Verschieben und Skalieren von Zeitblöcken fest.';

  @override
  String get timeSlot15Minutes => '15 Min.';

  @override
  String get timeSlot30Minutes => '30 Min.';

  @override
  String get timeSlot1Hour => '1 Std.';

  @override
  String get editAction => 'Bearbeiten';

  @override
  String get executionTitle => 'Ausführung';

  @override
  String get autoStartNextTimeBox => 'Nächste Timebox automatisch starten';

  @override
  String get liveTrackingTitle => 'Live-Timebox-Tracking';

  @override
  String get liveTrackingDescription =>
      'Verfolgt den aktuellen Block automatisch in Fokus, Live Activity und Mitteilungen.';

  @override
  String get alertsTitle => 'Hinweise';

  @override
  String get localAlerts => 'Lokale Hinweise';

  @override
  String get soundLabel => 'Abschlusston';

  @override
  String get soundDescription =>
      'Spielt beim Abschluss einer Sitzung den Standardton des Geräts. Die laufende Timer-Benachrichtigung bleibt stumm.';

  @override
  String get slotBreakTitle => 'Slot-Pausen';

  @override
  String slotBreakDescription(int slotMinutes, int breakMinutes) {
    return 'In jedem $slotMinutes-Minuten-Slot die letzten $breakMinutes Minuten pausieren.';
  }

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
  String get calendarProviderSelectDescription =>
      'Wähle ein Ziel. Jeder Anbieter hat eine eigene Anleitung und einen eigenen Exportstatus.';

  @override
  String get calendarDuplicateProtectionDescription =>
      'Ein für dasselbe Datum und denselben Anbieter bereits verknüpfter Zeitblock wird übersprungen.';

  @override
  String get calendarExportAlreadySynced =>
      'Die heutigen Zeitblöcke sind bereits synchronisiert.';

  @override
  String get openCalendarAction => 'Kalender öffnen';

  @override
  String get calendarOpenFailed =>
      'Die Kalender-App konnte nicht geöffnet werden.';

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
  String get moveToBrainDump => 'Zu Gedankenspeicher verschieben';

  @override
  String get editBrainDumpTitle => 'Gedankenspeicher bearbeiten';

  @override
  String get editReminderTitle => 'Erinnerung bearbeiten';

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
  String get noCurrentTimeBoxTitle => 'Jetzt kein Block';

  @override
  String get noCurrentTimeBoxBody =>
      'Füge im Heute-Tab einen Block zum aktuellen Zeitfenster hinzu.';

  @override
  String get planCurrentSlotAction => 'Aktuellen Slot planen';

  @override
  String get currentTimeBoxRequired =>
      'Füge zuerst einen Zeitblock für den aktuellen Slot hinzu.';

  @override
  String get noTodayBoxesProgress => 'Noch keine Zeitblöcke geplant.';

  @override
  String get openFocusAction => 'Focus öffnen';

  @override
  String get topPrioritiesTitle => 'Top-Prioritäten';

  @override
  String get addPriorityTooltip => 'Priorität hinzufügen';

  @override
  String get noPrioritiesYet => 'Noch keine Prioritäten';

  @override
  String get carryOverPreviousPriorities => 'Vorige Prioritäten übernehmen';

  @override
  String get carryOverPreviousBrainDump => 'Vorigen Brain Dump übernehmen';

  @override
  String get carryOverPreviousReminders => 'Vorige Merkpunkte übernehmen';

  @override
  String get carryOverPreviousSchedule => 'Zeitblöcke von gestern übernehmen';

  @override
  String get importSelected => 'Auswahl übernehmen';

  @override
  String get nothingToImport => 'Nichts Neues zu übernehmen.';

  @override
  String get noItemsForDay => 'Keine Einträge für diesen Tag.';

  @override
  String get noPreviousDailyItems => 'Keine vorherigen Tagesdaten gefunden.';

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
      'Karte antippen zum Bearbeiten. Lange drücken zum Verschieben, untere Leiste zum Anpassen.';

  @override
  String get dragTimeBoxTooltip => 'Zum Verschieben ziehen';

  @override
  String get resizeTimeBoxTooltip => 'Antippen zum Anpassen';

  @override
  String get resizeTimeBoxActiveTooltip => 'Nach oben oder unten ziehen';

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
  String get repeatTimeBoxLabel => 'Wiederholen';

  @override
  String get repeatNone => 'Keine';

  @override
  String get repeatDaily => 'Täglich';

  @override
  String get repeatWeekdays => 'Wochentage';

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
      'Der Timer für den nächsten Termin startet.';

  @override
  String get notificationBreakCompleteBody =>
      'Der Timer für den nächsten Termin startet.';

  @override
  String get accountTitle => 'Konto';

  @override
  String get authGateSubtitle => 'Melde dich an, um zu starten.';

  @override
  String get firebaseSetupRequired => 'Firebase-Einrichtung erforderlich';

  @override
  String get firebaseSetupDescription =>
      'Erzeuge die lokalen FlutterFire-Dateien und setze das iOS-URL-Schema, bevor Cloud-Login verfügbar ist.';

  @override
  String get signInWithAppleAction => 'Mit Apple anmelden';

  @override
  String get signInWithGoogleAction => 'Mit Google anmelden';

  @override
  String get signInWithEmailAction => 'Mit E-Mail anmelden';

  @override
  String get emailSignInTitle => 'E-Mail-Anmeldung';

  @override
  String get emailLabel => 'E-Mail';

  @override
  String get passwordLabel => 'Passwort';

  @override
  String get showPasswordAction => 'Passwort anzeigen';

  @override
  String get hidePasswordAction => 'Passwort ausblenden';

  @override
  String get emailSignInValidation => 'Gib eine gültige E-Mail-Adresse ein.';

  @override
  String get passwordSignInValidation => 'Gib dein Passwort ein.';

  @override
  String get emailSignInFailed =>
      'Prüfe E-Mail und Passwort und versuche es erneut.';

  @override
  String get signInAction => 'Anmelden';

  @override
  String signedInAs(String label) {
    return 'Angemeldet als $label';
  }

  @override
  String get appleAccountConnected => 'Apple-Konto verbunden';

  @override
  String get googleAccountConnected => 'Google-Konto verbunden';

  @override
  String get accountConnected => 'Konto verbunden';

  @override
  String get signOutAction => 'Abmelden';

  @override
  String get deleteAccountAction => 'Konto löschen';

  @override
  String get deleteAccountTitle => 'Konto löschen';

  @override
  String get deleteAccountBody =>
      'Dein Konto und alle synchronisierten Timebox-Mark-Daten werden dauerhaft gelöscht. Gelöschte Daten können nicht wiederhergestellt werden.';

  @override
  String get accountDeleted => 'Konto gelöscht.';

  @override
  String get accountDeleteFailed =>
      'Konto konnte nicht gelöscht werden. Melde dich erneut an und versuche es noch einmal.';

  @override
  String get legalTitle => 'Rechtliches';

  @override
  String get privacyPolicyAction => 'Datenschutzerklärung';

  @override
  String get termsAction => 'Nutzungsbedingungen';

  @override
  String get supportAction => 'Support';

  @override
  String get linkOpenFailed => 'Link konnte nicht geöffnet werden.';

  @override
  String get cancelAction => 'Abbrechen';

  @override
  String get authSignInFailed =>
      'Anmeldung fehlgeschlagen. Bitte erneut versuchen.';
}
