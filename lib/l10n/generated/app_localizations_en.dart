// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Timebox Mark';

  @override
  String get navToday => 'Today';

  @override
  String get navFocus => 'Focus';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navSettings => 'Settings';

  @override
  String get ok => 'OK';

  @override
  String get breakCompleteMessage => 'Break complete. Next block is ready.';

  @override
  String get focusCompleteMessage =>
      'Focus complete. Step away before the next block.';

  @override
  String get focusTitle => 'Focus';

  @override
  String get shortBreakLabel => 'Short break';

  @override
  String get longBreakLabel => 'Long break';

  @override
  String get nowLabel => 'Now';

  @override
  String get readyLabel => 'Ready';

  @override
  String get runningLabel => 'Running';

  @override
  String get pausedLabel => 'Paused';

  @override
  String sessionProgress(int completed, int total) {
    return '$completed of $total today boxes';
  }

  @override
  String get resetAction => 'Reset';

  @override
  String get pauseAction => 'Pause';

  @override
  String get startAction => 'Start';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get awakeWindowTitle => 'Awake window';

  @override
  String get editAction => 'Edit';

  @override
  String get executionTitle => 'Execution';

  @override
  String get autoStartNextTimeBox => 'Auto-start next time box';

  @override
  String get alertsTitle => 'Alerts';

  @override
  String get localAlerts => 'Local alerts';

  @override
  String get soundLabel => 'Sound';

  @override
  String get saveAction => 'Save';

  @override
  String get onboardingSubtitle => 'Set the hours you actually plan.';

  @override
  String get startPlanning => 'Start planning';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get todayPlanSync => 'Today plan sync';

  @override
  String get syncModeTitle => 'Sync mode';

  @override
  String get manualMode => 'Manual';

  @override
  String get autoMode => 'Auto';

  @override
  String get calendarExport => 'Calendar export';

  @override
  String providerSetupQueued(String provider) {
    return '$provider setup is queued.';
  }

  @override
  String get providerAppleCalendar => 'Apple Calendar';

  @override
  String get appleCalendarExportDescription =>
      'Exports today\'s time boxes to your default Apple Calendar.';

  @override
  String get providerGoogleCalendar => 'Google Calendar';

  @override
  String get googleCalendarExportDescription =>
      'Adds today\'s time boxes to your primary Google Calendar after Google permission.';

  @override
  String get providerOutlook => 'Outlook';

  @override
  String get badgeFree => 'Free';

  @override
  String get badgePro => 'Pro';

  @override
  String get statusLocal => 'Local';

  @override
  String get statusFirebase => 'Firebase';

  @override
  String get statusOAuth => 'OAuth';

  @override
  String get setupAction => 'Set up';

  @override
  String get connectAction => 'Connect';

  @override
  String get providersTitle => 'Providers';

  @override
  String get exportRulesTitle => 'Export rules';

  @override
  String get topPrioritiesOnly => 'Top priorities only';

  @override
  String get conflictCheck => 'Conflict check';

  @override
  String get dedicatedCalendar => 'Dedicated calendar';

  @override
  String get includeBreaks => 'Include breaks';

  @override
  String get todayQueueTitle => 'Today queue';

  @override
  String boxesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count boxes',
      one: '1 box',
      zero: '0 boxes',
    );
    return '$_temp0';
  }

  @override
  String get noBoxes => 'No boxes';

  @override
  String get exportSelected => 'Export selected';

  @override
  String get exportTodayAction => 'Export today';

  @override
  String get exportAppleTodayAction => 'Export to Apple Calendar';

  @override
  String get exportGoogleTodayAction => 'Export to Google Calendar';

  @override
  String get calendarExporting => 'Exporting';

  @override
  String get calendarExportEmpty => 'No time boxes to export.';

  @override
  String calendarExportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events exported',
      one: '1 event exported',
      zero: 'No events exported',
    );
    return '$_temp0';
  }

  @override
  String get calendarExportDenied => 'Calendar access was denied.';

  @override
  String get calendarExportUnavailable =>
      'Calendar export is unavailable on this device.';

  @override
  String get calendarExportFailed => 'Calendar export failed. Try again.';

  @override
  String get todayTitle => 'Today';

  @override
  String get startFocus => 'Start focus';

  @override
  String get brainDumpTitle => 'Brain dump';

  @override
  String get addBrainDumpTooltip => 'Add brain dump';

  @override
  String get addBrainDumpTitle => 'Add brain dump';

  @override
  String get captureLabel => 'Capture';

  @override
  String get makePriority => 'Make priority';

  @override
  String get moveToReminder => 'Move to reminder';

  @override
  String get deleteAction => 'Delete';

  @override
  String get keepInMindTitle => 'Keep in mind';

  @override
  String get addReminderTooltip => 'Add reminder';

  @override
  String get addReminderTitle => 'Add reminder';

  @override
  String get reminderLabel => 'Reminder';

  @override
  String get enterSomethingFirst => 'Enter something first.';

  @override
  String get dailyProgressTitle => 'Today summary';

  @override
  String get planMetric => 'Priorities';

  @override
  String get timeBoxesMetric => 'Time boxes';

  @override
  String get focusMetric => 'Done';

  @override
  String get dailyProgressDescription =>
      'Review priorities, planned boxes, and the next focus block.';

  @override
  String get todayReviewTitle => 'Today review';

  @override
  String get nextTimeBoxLabel => 'Next';

  @override
  String get noActiveTimeBox => 'No time box';

  @override
  String get openFocusAction => 'Open Focus';

  @override
  String get topPrioritiesTitle => 'Top priorities';

  @override
  String get addPriorityTooltip => 'Add priority';

  @override
  String get noPrioritiesYet => 'No priorities yet';

  @override
  String get threePrioritiesAlreadySet => 'Three priorities are already set.';

  @override
  String get addPriorityTitle => 'Add priority';

  @override
  String get editPriorityTitle => 'Edit priority';

  @override
  String priorityLabel(int number) {
    return 'Priority $number';
  }

  @override
  String get clearPriority => 'Clear priority';

  @override
  String get weekdayMonNarrow => 'M';

  @override
  String get weekdayTueNarrow => 'T';

  @override
  String get weekdayWedNarrow => 'W';

  @override
  String get weekdayThuNarrow => 'T';

  @override
  String get weekdayFriNarrow => 'F';

  @override
  String get weekdaySatNarrow => 'S';

  @override
  String get weekdaySunNarrow => 'S';

  @override
  String get timeBoxesTitle => 'Time boxes';

  @override
  String get timeBoxesHint => 'Tap an empty slot to add. Tap a box to edit.';

  @override
  String get nowBadge => 'Now';

  @override
  String get newTimeBoxTitle => 'New time box';

  @override
  String get editTimeBoxTitle => 'Edit time box';

  @override
  String get titleLabel => 'Title';

  @override
  String timeBoxRange(String range) {
    return 'Time box $range';
  }

  @override
  String get newTimeBoxDefaultTitle => 'New time box';

  @override
  String get nativeFocusBlockTitle => 'Focus block';

  @override
  String get nativeBreakBlockTitle => 'Break block';

  @override
  String get liveActivityTopPriorityLabel => 'Top';

  @override
  String get notificationFocusInProgressTitle => 'Focus in progress';

  @override
  String get notificationShortBreakInProgressTitle => 'Short break in progress';

  @override
  String get notificationLongBreakInProgressTitle => 'Long break in progress';

  @override
  String get notificationRemainingTimeFormat => '%@ remaining';

  @override
  String get notificationFocusCompleteTitle => 'Focus complete';

  @override
  String get notificationBreakCompleteTitle => 'Break complete';

  @override
  String get notificationFocusCompleteBody =>
      'Step away before the next block.';

  @override
  String get notificationBreakCompleteBody => 'Your next focus block is ready.';

  @override
  String get defaultTimeBoxTopPriority => 'Top priority';

  @override
  String get defaultTimeBoxDeepWork => 'Deep work';

  @override
  String get defaultTimeBoxAdmin => 'Admin';

  @override
  String get defaultTimeBoxSecondPriority => 'Second priority';

  @override
  String get defaultTimeBoxFollowUp => 'Follow-up';

  @override
  String get accountTitle => 'Account';

  @override
  String get firebaseSetupRequired => 'Firebase setup required';

  @override
  String get firebaseSetupDescription =>
      'Add GoogleService-Info.plist and enable Apple sign-in in Firebase before cloud login is available.';

  @override
  String get signInWithAppleAction => 'Sign in with Apple';

  @override
  String signedInAs(String label) {
    return 'Signed in as $label';
  }

  @override
  String get signOutAction => 'Sign out';

  @override
  String get authSignInFailed => 'Sign-in failed. Try again.';
}
