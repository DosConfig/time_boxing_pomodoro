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
  String get introBrandEyebrow => 'Plan less. Move faster.';

  @override
  String get introBrandTitle => 'Timebox your day';

  @override
  String get introBrandBody =>
      'Turn brain dumps into priorities, 30-minute blocks, Focus, alerts, and calendar-ready plans.';

  @override
  String get introBrainDumpTitle => 'Empty your head';

  @override
  String get introBrainDumpBody =>
      'Built on proven timeboxing and Pomodoro principles: capture first, decide later.';

  @override
  String get introPrioritiesTitle => 'Pick the top three';

  @override
  String get introPrioritiesBody =>
      'Turn the noisy list into three visible priorities before the day pulls you around.';

  @override
  String get introTimeBoxTitle => 'Place 30-minute blocks';

  @override
  String get introTimeBoxBody =>
      'Tap a slot, add a box, and plan the day in 30-minute blocks with less typing.';

  @override
  String get introFocusTitle => 'Focus follows the clock';

  @override
  String get introFocusBody =>
      'After sign-in, the current block drives Focus, Live Activity, alerts, and cloud sync.';

  @override
  String get introBackAction => 'Back';

  @override
  String get introNextAction => 'Next';

  @override
  String get introStartAction => 'Get started';

  @override
  String get introSkipAction => 'Skip';

  @override
  String get introSampleTopPriority => 'Launch plan';

  @override
  String get introSampleDeepWork => 'Deep work';

  @override
  String get introSampleFollowUp => 'Follow-up';

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
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageKorean => 'Korean';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => 'Japanese';

  @override
  String get languageChinese => 'Chinese';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageFrench => 'French';

  @override
  String get languageGerman => 'German';

  @override
  String get awakeWindowTitle => 'Awake window';

  @override
  String get editAction => 'Edit';

  @override
  String get executionTitle => 'Execution';

  @override
  String get autoStartNextTimeBox => 'Auto-start next time box';

  @override
  String get liveTrackingTitle => 'Live timebox tracking';

  @override
  String get liveTrackingDescription =>
      'Follows the current block automatically in Focus, Live Activity, and notifications.';

  @override
  String get alertsTitle => 'Alerts';

  @override
  String get localAlerts => 'Local alerts';

  @override
  String get soundLabel => 'Sound';

  @override
  String get soundDescription =>
      'Uses the iOS default sound for completion alerts.';

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
  String get calendarProviderSelectDescription =>
      'Choose one destination. Each provider has its own guide and export state.';

  @override
  String get calendarDuplicateProtectionDescription =>
      'A time box already mapped for the same date and provider is skipped.';

  @override
  String get calendarExportAlreadySynced =>
      'Today\'s time boxes are already synced.';

  @override
  String get openCalendarAction => 'Open calendar';

  @override
  String get calendarOpenFailed => 'The calendar app could not be opened.';

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
  String get noCurrentTimeBoxTitle => 'No block right now';

  @override
  String get noCurrentTimeBoxBody =>
      'Add a box to the current 30-minute slot from Today.';

  @override
  String get planCurrentSlotAction => 'Plan current slot';

  @override
  String get currentTimeBoxRequired =>
      'Add a time box for the current slot first.';

  @override
  String get noTodayBoxesProgress => 'No time boxes planned yet.';

  @override
  String get openFocusAction => 'Open Focus';

  @override
  String get topPrioritiesTitle => 'Top priorities';

  @override
  String get addPriorityTooltip => 'Add priority';

  @override
  String get noPrioritiesYet => 'No priorities yet';

  @override
  String get carryOverPreviousPriorities => 'Bring in previous priorities';

  @override
  String get carryOverPreviousBrainDump => 'Bring in previous brain dump';

  @override
  String get carryOverPreviousReminders => 'Bring in previous reminders';

  @override
  String get carryOverPreviousSchedule => 'Bring in previous schedule';

  @override
  String get noPreviousDailyItems => 'No previous daily items found.';

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
  String get timeBoxesHint =>
      'Tap a card to edit. Long-press to move. Pull the bottom bar to resize.';

  @override
  String get dragTimeBoxTooltip => 'Drag to move';

  @override
  String get resizeTimeBoxTooltip => 'Tap to resize';

  @override
  String get resizeTimeBoxActiveTooltip => 'Drag up or down to resize';

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
  String get repeatTimeBoxLabel => 'Repeat';

  @override
  String get repeatNone => 'None';

  @override
  String get repeatDaily => 'Daily';

  @override
  String get repeatWeekdays => 'Weekdays';

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
  String get accountTitle => 'Account';

  @override
  String get authGateSubtitle => 'Sign in to start.';

  @override
  String get firebaseSetupRequired => 'Firebase setup required';

  @override
  String get firebaseSetupDescription =>
      'Generate the local FlutterFire files and set the iOS URL scheme before cloud login is available.';

  @override
  String get signInWithAppleAction => 'Sign in with Apple';

  @override
  String get signInWithGoogleAction => 'Sign in with Google';

  @override
  String signedInAs(String label) {
    return 'Signed in as $label';
  }

  @override
  String get appleAccountConnected => 'Apple account connected';

  @override
  String get googleAccountConnected => 'Google account connected';

  @override
  String get accountConnected => 'Account connected';

  @override
  String get signOutAction => 'Sign out';

  @override
  String get deleteAccountAction => 'Delete account';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountBody =>
      'Your account and all synced Timebox Mark data will be permanently deleted. Deleted data cannot be recovered.';

  @override
  String get accountDeleted => 'Account deleted.';

  @override
  String get accountDeleteFailed =>
      'Could not delete account. Sign in again and try once more.';

  @override
  String get legalTitle => 'Legal';

  @override
  String get privacyPolicyAction => 'Privacy Policy';

  @override
  String get termsAction => 'Terms of Use';

  @override
  String get supportAction => 'Support';

  @override
  String get linkOpenFailed => 'Could not open link.';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get authSignInFailed => 'Sign-in failed. Try again.';
}
