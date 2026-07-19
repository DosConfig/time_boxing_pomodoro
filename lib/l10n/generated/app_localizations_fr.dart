// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Timebox Mark';

  @override
  String get navToday => 'Aujourd’hui';

  @override
  String get navFocus => 'Focus';

  @override
  String get navCalendar => 'Calendrier';

  @override
  String get navSettings => 'Réglages';

  @override
  String get ok => 'OK';

  @override
  String get breakCompleteMessage =>
      'Pause terminée. Le bloc suivant est prêt.';

  @override
  String get focusCompleteMessage =>
      'Focus terminé. Fais une pause avant le prochain bloc.';

  @override
  String get focusTitle => 'Focus';

  @override
  String get shortBreakLabel => 'Pause courte';

  @override
  String get longBreakLabel => 'Pause longue';

  @override
  String get nowLabel => 'Maintenant';

  @override
  String get readyLabel => 'Prêt';

  @override
  String get runningLabel => 'En cours';

  @override
  String get pausedLabel => 'En pause';

  @override
  String sessionProgress(int completed, int total) {
    return '$completed sur $total blocs du jour';
  }

  @override
  String get resetAction => 'Réinitialiser';

  @override
  String get pauseAction => 'Pause';

  @override
  String get startAction => 'Démarrer';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get awakeWindowTitle => 'Plage active';

  @override
  String get editAction => 'Modifier';

  @override
  String get executionTitle => 'Exécution';

  @override
  String get autoStartNextTimeBox => 'Démarrer automatiquement le bloc suivant';

  @override
  String get alertsTitle => 'Alertes';

  @override
  String get localAlerts => 'Alertes locales';

  @override
  String get soundLabel => 'Son';

  @override
  String get saveAction => 'Enregistrer';

  @override
  String get onboardingSubtitle =>
      'Définis les heures que tu planifies vraiment.';

  @override
  String get startPlanning => 'Commencer';

  @override
  String get calendarTitle => 'Calendrier';

  @override
  String get todayPlanSync => 'Synchro du plan du jour';

  @override
  String get syncModeTitle => 'Mode de synchro';

  @override
  String get manualMode => 'Manuel';

  @override
  String get autoMode => 'Auto';

  @override
  String get calendarExport => 'Export calendrier';

  @override
  String providerSetupQueued(String provider) {
    return 'La configuration de $provider est en attente.';
  }

  @override
  String get providerAppleCalendar => 'Calendrier Apple';

  @override
  String get appleCalendarExportDescription =>
      'Ajoute les blocs du jour à votre calendrier Apple par défaut.';

  @override
  String get providerGoogleCalendar => 'Google Agenda';

  @override
  String get googleCalendarExportDescription =>
      'Ajoute les blocs du jour à votre agenda Google principal après autorisation.';

  @override
  String get providerOutlook => 'Outlook';

  @override
  String get badgeFree => 'Gratuit';

  @override
  String get badgePro => 'Pro';

  @override
  String get statusLocal => 'Local';

  @override
  String get statusFirebase => 'Firebase';

  @override
  String get statusOAuth => 'OAuth';

  @override
  String get setupAction => 'Configurer';

  @override
  String get connectAction => 'Connecter';

  @override
  String get providersTitle => 'Fournisseurs';

  @override
  String get exportRulesTitle => 'Règles d’export';

  @override
  String get topPrioritiesOnly => 'Priorités seulement';

  @override
  String get conflictCheck => 'Vérifier les conflits';

  @override
  String get dedicatedCalendar => 'Calendrier dédié';

  @override
  String get includeBreaks => 'Inclure les pauses';

  @override
  String get todayQueueTitle => 'File du jour';

  @override
  String boxesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count blocs',
      one: '1 bloc',
      zero: '0 blocs',
    );
    return '$_temp0';
  }

  @override
  String get noBoxes => 'Aucun bloc';

  @override
  String get exportSelected => 'Exporter la sélection';

  @override
  String get exportTodayAction => 'Exporter aujourd\'hui';

  @override
  String get exportAppleTodayAction => 'Exporter vers Apple Calendar';

  @override
  String get exportGoogleTodayAction => 'Exporter vers Google Agenda';

  @override
  String get calendarExporting => 'Exportation';

  @override
  String get calendarExportEmpty => 'Aucun bloc à exporter.';

  @override
  String calendarExportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count événements exportés',
      one: '1 événement exporté',
      zero: 'Aucun événement exporté',
    );
    return '$_temp0';
  }

  @override
  String get calendarExportDenied => 'L\'accès au calendrier a été refusé.';

  @override
  String get calendarExportUnavailable =>
      'L\'export calendrier n\'est pas disponible sur cet appareil.';

  @override
  String get calendarExportFailed =>
      'L\'export calendrier a échoué. Réessayez.';

  @override
  String get todayTitle => 'Aujourd’hui';

  @override
  String get startFocus => 'Démarrer le focus';

  @override
  String get brainDumpTitle => 'Décharge mentale';

  @override
  String get addBrainDumpTooltip => 'Ajouter une idée';

  @override
  String get addBrainDumpTitle => 'Ajouter une idée';

  @override
  String get captureLabel => 'Capturer';

  @override
  String get makePriority => 'Mettre en priorité';

  @override
  String get moveToReminder => 'Déplacer en rappel';

  @override
  String get deleteAction => 'Supprimer';

  @override
  String get keepInMindTitle => 'À retenir';

  @override
  String get addReminderTooltip => 'Ajouter un rappel';

  @override
  String get addReminderTitle => 'Ajouter un rappel';

  @override
  String get reminderLabel => 'Rappel';

  @override
  String get enterSomethingFirst => 'Saisis quelque chose.';

  @override
  String get dailyProgressTitle => 'Résumé du jour';

  @override
  String get planMetric => 'Priorités';

  @override
  String get timeBoxesMetric => 'Blocs';

  @override
  String get focusMetric => 'Faits';

  @override
  String get dailyProgressDescription =>
      'Passez en revue les priorités, les blocs prévus et le prochain bloc de concentration.';

  @override
  String get todayReviewTitle => 'Revue du jour';

  @override
  String get nextTimeBoxLabel => 'Suivant';

  @override
  String get noActiveTimeBox => 'Aucun bloc';

  @override
  String get openFocusAction => 'Ouvrir Focus';

  @override
  String get topPrioritiesTitle => 'Priorités';

  @override
  String get addPriorityTooltip => 'Ajouter une priorité';

  @override
  String get noPrioritiesYet => 'Aucune priorité';

  @override
  String get threePrioritiesAlreadySet => 'Trois priorités sont déjà définies.';

  @override
  String get addPriorityTitle => 'Ajouter une priorité';

  @override
  String get editPriorityTitle => 'Modifier la priorité';

  @override
  String priorityLabel(int number) {
    return 'Priorité $number';
  }

  @override
  String get clearPriority => 'Effacer la priorité';

  @override
  String get weekdayMonNarrow => 'L';

  @override
  String get weekdayTueNarrow => 'M';

  @override
  String get weekdayWedNarrow => 'M';

  @override
  String get weekdayThuNarrow => 'J';

  @override
  String get weekdayFriNarrow => 'V';

  @override
  String get weekdaySatNarrow => 'S';

  @override
  String get weekdaySunNarrow => 'D';

  @override
  String get timeBoxesTitle => 'Blocs de temps';

  @override
  String get timeBoxesHint =>
      'Touchez un créneau vide pour ajouter. Touchez un bloc pour modifier.';

  @override
  String get nowBadge => 'Maintenant';

  @override
  String get newTimeBoxTitle => 'Nouveau bloc';

  @override
  String get editTimeBoxTitle => 'Modifier le bloc';

  @override
  String get titleLabel => 'Titre';

  @override
  String timeBoxRange(String range) {
    return 'Bloc $range';
  }

  @override
  String get newTimeBoxDefaultTitle => 'Nouveau bloc';

  @override
  String get nativeFocusBlockTitle => 'Bloc de concentration';

  @override
  String get nativeBreakBlockTitle => 'Bloc de pause';

  @override
  String get liveActivityTopPriorityLabel => 'Prio';

  @override
  String get notificationFocusInProgressTitle => 'Concentration en cours';

  @override
  String get notificationShortBreakInProgressTitle => 'Pause courte en cours';

  @override
  String get notificationLongBreakInProgressTitle => 'Pause longue en cours';

  @override
  String get notificationRemainingTimeFormat => '%@ restantes';

  @override
  String get notificationFocusCompleteTitle => 'Concentration terminée';

  @override
  String get notificationBreakCompleteTitle => 'Pause terminée';

  @override
  String get notificationFocusCompleteBody =>
      'Faites une pause avant le prochain bloc.';

  @override
  String get notificationBreakCompleteBody =>
      'Votre prochain bloc de concentration est prêt.';

  @override
  String get defaultTimeBoxTopPriority => 'Priorité principale';

  @override
  String get defaultTimeBoxDeepWork => 'Travail profond';

  @override
  String get defaultTimeBoxAdmin => 'Admin';

  @override
  String get defaultTimeBoxSecondPriority => 'Deuxième priorité';

  @override
  String get defaultTimeBoxFollowUp => 'Suivi';

  @override
  String get accountTitle => 'Compte';

  @override
  String get firebaseSetupRequired => 'Configuration Firebase requise';

  @override
  String get firebaseSetupDescription =>
      'Ajoutez GoogleService-Info.plist et activez la connexion Apple dans Firebase pour utiliser le login cloud.';

  @override
  String get signInWithAppleAction => 'Se connecter avec Apple';

  @override
  String signedInAs(String label) {
    return 'Connecté en tant que $label';
  }

  @override
  String get signOutAction => 'Se déconnecter';

  @override
  String get authSignInFailed => 'Échec de la connexion. Réessayez.';
}
