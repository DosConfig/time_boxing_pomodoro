import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Timebox Mark'**
  String get appName;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get navFocus;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @breakCompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Break complete. Next block is ready.'**
  String get breakCompleteMessage;

  /// No description provided for @focusCompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Focus complete. Step away before the next block.'**
  String get focusCompleteMessage;

  /// No description provided for @focusTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focusTitle;

  /// No description provided for @shortBreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Short break'**
  String get shortBreakLabel;

  /// No description provided for @longBreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Long break'**
  String get longBreakLabel;

  /// No description provided for @nowLabel.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get nowLabel;

  /// No description provided for @readyLabel.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get readyLabel;

  /// No description provided for @runningLabel.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get runningLabel;

  /// No description provided for @pausedLabel.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get pausedLabel;

  /// No description provided for @sessionProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} today boxes'**
  String sessionProgress(int completed, int total);

  /// No description provided for @resetAction.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetAction;

  /// No description provided for @pauseAction.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseAction;

  /// No description provided for @startAction.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startAction;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @awakeWindowTitle.
  ///
  /// In en, this message translates to:
  /// **'Awake window'**
  String get awakeWindowTitle;

  /// No description provided for @editAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editAction;

  /// No description provided for @executionTitle.
  ///
  /// In en, this message translates to:
  /// **'Execution'**
  String get executionTitle;

  /// No description provided for @autoStartNextTimeBox.
  ///
  /// In en, this message translates to:
  /// **'Auto-start next time box'**
  String get autoStartNextTimeBox;

  /// No description provided for @alertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsTitle;

  /// No description provided for @localAlerts.
  ///
  /// In en, this message translates to:
  /// **'Local alerts'**
  String get localAlerts;

  /// No description provided for @soundLabel.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get soundLabel;

  /// No description provided for @saveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAction;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set the hours you actually plan.'**
  String get onboardingSubtitle;

  /// No description provided for @startPlanning.
  ///
  /// In en, this message translates to:
  /// **'Start planning'**
  String get startPlanning;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @todayPlanSync.
  ///
  /// In en, this message translates to:
  /// **'Today plan sync'**
  String get todayPlanSync;

  /// No description provided for @syncModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync mode'**
  String get syncModeTitle;

  /// No description provided for @manualMode.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manualMode;

  /// No description provided for @autoMode.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get autoMode;

  /// No description provided for @calendarExport.
  ///
  /// In en, this message translates to:
  /// **'Calendar export'**
  String get calendarExport;

  /// No description provided for @providerSetupQueued.
  ///
  /// In en, this message translates to:
  /// **'{provider} setup is queued.'**
  String providerSetupQueued(String provider);

  /// No description provided for @providerAppleCalendar.
  ///
  /// In en, this message translates to:
  /// **'Apple Calendar'**
  String get providerAppleCalendar;

  /// No description provided for @appleCalendarExportDescription.
  ///
  /// In en, this message translates to:
  /// **'Exports today\'s time boxes to your default Apple Calendar.'**
  String get appleCalendarExportDescription;

  /// No description provided for @providerGoogleCalendar.
  ///
  /// In en, this message translates to:
  /// **'Google Calendar'**
  String get providerGoogleCalendar;

  /// No description provided for @googleCalendarExportDescription.
  ///
  /// In en, this message translates to:
  /// **'Adds today\'s time boxes to your primary Google Calendar after Google permission.'**
  String get googleCalendarExportDescription;

  /// No description provided for @providerOutlook.
  ///
  /// In en, this message translates to:
  /// **'Outlook'**
  String get providerOutlook;

  /// No description provided for @badgeFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get badgeFree;

  /// No description provided for @badgePro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get badgePro;

  /// No description provided for @statusLocal.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get statusLocal;

  /// No description provided for @statusFirebase.
  ///
  /// In en, this message translates to:
  /// **'Firebase'**
  String get statusFirebase;

  /// No description provided for @statusOAuth.
  ///
  /// In en, this message translates to:
  /// **'OAuth'**
  String get statusOAuth;

  /// No description provided for @setupAction.
  ///
  /// In en, this message translates to:
  /// **'Set up'**
  String get setupAction;

  /// No description provided for @connectAction.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connectAction;

  /// No description provided for @providersTitle.
  ///
  /// In en, this message translates to:
  /// **'Providers'**
  String get providersTitle;

  /// No description provided for @exportRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Export rules'**
  String get exportRulesTitle;

  /// No description provided for @topPrioritiesOnly.
  ///
  /// In en, this message translates to:
  /// **'Top priorities only'**
  String get topPrioritiesOnly;

  /// No description provided for @conflictCheck.
  ///
  /// In en, this message translates to:
  /// **'Conflict check'**
  String get conflictCheck;

  /// No description provided for @dedicatedCalendar.
  ///
  /// In en, this message translates to:
  /// **'Dedicated calendar'**
  String get dedicatedCalendar;

  /// No description provided for @includeBreaks.
  ///
  /// In en, this message translates to:
  /// **'Include breaks'**
  String get includeBreaks;

  /// No description provided for @todayQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Today queue'**
  String get todayQueueTitle;

  /// No description provided for @boxesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 boxes} =1{1 box} other{{count} boxes}}'**
  String boxesCount(int count);

  /// No description provided for @noBoxes.
  ///
  /// In en, this message translates to:
  /// **'No boxes'**
  String get noBoxes;

  /// No description provided for @exportSelected.
  ///
  /// In en, this message translates to:
  /// **'Export selected'**
  String get exportSelected;

  /// No description provided for @exportTodayAction.
  ///
  /// In en, this message translates to:
  /// **'Export today'**
  String get exportTodayAction;

  /// No description provided for @exportAppleTodayAction.
  ///
  /// In en, this message translates to:
  /// **'Export to Apple Calendar'**
  String get exportAppleTodayAction;

  /// No description provided for @exportGoogleTodayAction.
  ///
  /// In en, this message translates to:
  /// **'Export to Google Calendar'**
  String get exportGoogleTodayAction;

  /// No description provided for @calendarExporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting'**
  String get calendarExporting;

  /// No description provided for @calendarExportEmpty.
  ///
  /// In en, this message translates to:
  /// **'No time boxes to export.'**
  String get calendarExportEmpty;

  /// No description provided for @calendarExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No events exported} =1{1 event exported} other{{count} events exported}}'**
  String calendarExportSuccess(int count);

  /// No description provided for @calendarExportDenied.
  ///
  /// In en, this message translates to:
  /// **'Calendar access was denied.'**
  String get calendarExportDenied;

  /// No description provided for @calendarExportUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Calendar export is unavailable on this device.'**
  String get calendarExportUnavailable;

  /// No description provided for @calendarExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Calendar export failed. Try again.'**
  String get calendarExportFailed;

  /// No description provided for @todayTitle.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayTitle;

  /// No description provided for @startFocus.
  ///
  /// In en, this message translates to:
  /// **'Start focus'**
  String get startFocus;

  /// No description provided for @brainDumpTitle.
  ///
  /// In en, this message translates to:
  /// **'Brain dump'**
  String get brainDumpTitle;

  /// No description provided for @addBrainDumpTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add brain dump'**
  String get addBrainDumpTooltip;

  /// No description provided for @addBrainDumpTitle.
  ///
  /// In en, this message translates to:
  /// **'Add brain dump'**
  String get addBrainDumpTitle;

  /// No description provided for @captureLabel.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get captureLabel;

  /// No description provided for @makePriority.
  ///
  /// In en, this message translates to:
  /// **'Make priority'**
  String get makePriority;

  /// No description provided for @moveToReminder.
  ///
  /// In en, this message translates to:
  /// **'Move to reminder'**
  String get moveToReminder;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @keepInMindTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep in mind'**
  String get keepInMindTitle;

  /// No description provided for @addReminderTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get addReminderTooltip;

  /// No description provided for @addReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get addReminderTitle;

  /// No description provided for @reminderLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminderLabel;

  /// No description provided for @enterSomethingFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter something first.'**
  String get enterSomethingFirst;

  /// No description provided for @dailyProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Today summary'**
  String get dailyProgressTitle;

  /// No description provided for @planMetric.
  ///
  /// In en, this message translates to:
  /// **'Priorities'**
  String get planMetric;

  /// No description provided for @timeBoxesMetric.
  ///
  /// In en, this message translates to:
  /// **'Time boxes'**
  String get timeBoxesMetric;

  /// No description provided for @focusMetric.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get focusMetric;

  /// No description provided for @dailyProgressDescription.
  ///
  /// In en, this message translates to:
  /// **'Review priorities, planned boxes, and the next focus block.'**
  String get dailyProgressDescription;

  /// No description provided for @todayReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Today review'**
  String get todayReviewTitle;

  /// No description provided for @nextTimeBoxLabel.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextTimeBoxLabel;

  /// No description provided for @noActiveTimeBox.
  ///
  /// In en, this message translates to:
  /// **'No time box'**
  String get noActiveTimeBox;

  /// No description provided for @openFocusAction.
  ///
  /// In en, this message translates to:
  /// **'Open Focus'**
  String get openFocusAction;

  /// No description provided for @topPrioritiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Top priorities'**
  String get topPrioritiesTitle;

  /// No description provided for @addPriorityTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add priority'**
  String get addPriorityTooltip;

  /// No description provided for @noPrioritiesYet.
  ///
  /// In en, this message translates to:
  /// **'No priorities yet'**
  String get noPrioritiesYet;

  /// No description provided for @threePrioritiesAlreadySet.
  ///
  /// In en, this message translates to:
  /// **'Three priorities are already set.'**
  String get threePrioritiesAlreadySet;

  /// No description provided for @addPriorityTitle.
  ///
  /// In en, this message translates to:
  /// **'Add priority'**
  String get addPriorityTitle;

  /// No description provided for @editPriorityTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit priority'**
  String get editPriorityTitle;

  /// No description provided for @priorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority {number}'**
  String priorityLabel(int number);

  /// No description provided for @clearPriority.
  ///
  /// In en, this message translates to:
  /// **'Clear priority'**
  String get clearPriority;

  /// No description provided for @weekdayMonNarrow.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get weekdayMonNarrow;

  /// No description provided for @weekdayTueNarrow.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekdayTueNarrow;

  /// No description provided for @weekdayWedNarrow.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get weekdayWedNarrow;

  /// No description provided for @weekdayThuNarrow.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekdayThuNarrow;

  /// No description provided for @weekdayFriNarrow.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get weekdayFriNarrow;

  /// No description provided for @weekdaySatNarrow.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekdaySatNarrow;

  /// No description provided for @weekdaySunNarrow.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekdaySunNarrow;

  /// No description provided for @timeBoxesTitle.
  ///
  /// In en, this message translates to:
  /// **'Time boxes'**
  String get timeBoxesTitle;

  /// No description provided for @timeBoxesHint.
  ///
  /// In en, this message translates to:
  /// **'Tap an empty slot to add. Tap a box to edit.'**
  String get timeBoxesHint;

  /// No description provided for @nowBadge.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get nowBadge;

  /// No description provided for @newTimeBoxTitle.
  ///
  /// In en, this message translates to:
  /// **'New time box'**
  String get newTimeBoxTitle;

  /// No description provided for @editTimeBoxTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit time box'**
  String get editTimeBoxTitle;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @timeBoxRange.
  ///
  /// In en, this message translates to:
  /// **'Time box {range}'**
  String timeBoxRange(String range);

  /// No description provided for @newTimeBoxDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'New time box'**
  String get newTimeBoxDefaultTitle;

  /// No description provided for @nativeFocusBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus block'**
  String get nativeFocusBlockTitle;

  /// No description provided for @nativeBreakBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Break block'**
  String get nativeBreakBlockTitle;

  /// No description provided for @liveActivityTopPriorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get liveActivityTopPriorityLabel;

  /// No description provided for @notificationFocusInProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus in progress'**
  String get notificationFocusInProgressTitle;

  /// No description provided for @notificationShortBreakInProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Short break in progress'**
  String get notificationShortBreakInProgressTitle;

  /// No description provided for @notificationLongBreakInProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Long break in progress'**
  String get notificationLongBreakInProgressTitle;

  /// No description provided for @notificationRemainingTimeFormat.
  ///
  /// In en, this message translates to:
  /// **'%@ remaining'**
  String get notificationRemainingTimeFormat;

  /// No description provided for @notificationFocusCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus complete'**
  String get notificationFocusCompleteTitle;

  /// No description provided for @notificationBreakCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Break complete'**
  String get notificationBreakCompleteTitle;

  /// No description provided for @notificationFocusCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'Step away before the next block.'**
  String get notificationFocusCompleteBody;

  /// No description provided for @notificationBreakCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'Your next focus block is ready.'**
  String get notificationBreakCompleteBody;

  /// No description provided for @defaultTimeBoxTopPriority.
  ///
  /// In en, this message translates to:
  /// **'Top priority'**
  String get defaultTimeBoxTopPriority;

  /// No description provided for @defaultTimeBoxDeepWork.
  ///
  /// In en, this message translates to:
  /// **'Deep work'**
  String get defaultTimeBoxDeepWork;

  /// No description provided for @defaultTimeBoxAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get defaultTimeBoxAdmin;

  /// No description provided for @defaultTimeBoxSecondPriority.
  ///
  /// In en, this message translates to:
  /// **'Second priority'**
  String get defaultTimeBoxSecondPriority;

  /// No description provided for @defaultTimeBoxFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get defaultTimeBoxFollowUp;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @firebaseSetupRequired.
  ///
  /// In en, this message translates to:
  /// **'Firebase setup required'**
  String get firebaseSetupRequired;

  /// No description provided for @firebaseSetupDescription.
  ///
  /// In en, this message translates to:
  /// **'Add GoogleService-Info.plist and enable Apple sign-in in Firebase before cloud login is available.'**
  String get firebaseSetupDescription;

  /// No description provided for @signInWithAppleAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithAppleAction;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {label}'**
  String signedInAs(String label);

  /// No description provided for @signOutAction.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutAction;

  /// No description provided for @authSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Try again.'**
  String get authSignInFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'ko',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
