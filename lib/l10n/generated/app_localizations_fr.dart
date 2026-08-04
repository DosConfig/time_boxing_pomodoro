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
  String get introBrandEyebrow => 'Planifiez moins. Avancez plus.';

  @override
  String get introBrandTitle => 'Timeboxez votre journée';

  @override
  String get introBrandBody =>
      'Transformez les notes en priorités, blocs flexibles, Focus, alertes et plans prêts pour le calendrier.';

  @override
  String get introBrainDumpTitle => 'Vider l\'esprit';

  @override
  String get introBrainDumpBody =>
      'Basé sur le timeboxing et Pomodoro: capturez d\'abord, décidez ensuite.';

  @override
  String get introPrioritiesTitle => 'Choisir trois priorités';

  @override
  String get introPrioritiesBody =>
      'Fixez trois priorités visibles avant que la journée vous emporte.';

  @override
  String get introTimeBoxTitle => 'Blocs de temps flexibles';

  @override
  String get introTimeBoxBody =>
      'Touchez un créneau et planifiez la journée avec l’intervalle qui vous convient.';

  @override
  String get introFocusTitle => 'Focus suit l\'heure';

  @override
  String get introFocusBody =>
      'Après connexion, le bloc actuel pilote Focus, Live Activity, alertes et synchronisation.';

  @override
  String get introBackAction => 'Retour';

  @override
  String get introNextAction => 'Suivant';

  @override
  String get introStartAction => 'Commencer';

  @override
  String get introSkipAction => 'Passer';

  @override
  String get introSampleTopPriority => 'Plan de lancement';

  @override
  String get introSampleDeepWork => 'Travail profond';

  @override
  String get introSampleFollowUp => 'Suivi';

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
  String get languageTitle => 'Langue';

  @override
  String get languageSystem => 'Langue du système';

  @override
  String get languageKorean => 'Coréen';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageJapanese => 'Japonais';

  @override
  String get languageChinese => 'Chinois';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageGerman => 'Allemand';

  @override
  String get awakeWindowTitle => 'Plage active';

  @override
  String get timeSlotIntervalTitle => 'Intervalle d’ajustement';

  @override
  String get timeSlotIntervalDescription =>
      'Définit le pas pour ajouter, déplacer ou redimensionner les blocs.';

  @override
  String get timeSlot15Minutes => '15 min';

  @override
  String get timeSlot30Minutes => '30 min';

  @override
  String get timeSlot1Hour => '1 h';

  @override
  String get editAction => 'Modifier';

  @override
  String get executionTitle => 'Exécution';

  @override
  String get autoStartNextTimeBox => 'Démarrer automatiquement le bloc suivant';

  @override
  String get liveTrackingTitle => 'Suivi du bloc en direct';

  @override
  String get liveTrackingDescription =>
      'Suit automatiquement le bloc actuel dans Focus, Live Activity et les notifications.';

  @override
  String get alertsTitle => 'Alertes';

  @override
  String get localAlerts => 'Alertes locales';

  @override
  String get soundLabel => 'Son de fin';

  @override
  String get soundDescription =>
      'Joue le son par défaut à la fin d\'une session. La notification du minuteur en cours reste silencieuse.';

  @override
  String get slotBreakTitle => 'Pauses par créneau';

  @override
  String slotBreakDescription(int slotMinutes, int breakMinutes) {
    return 'Repos pendant les $breakMinutes dernières minutes de chaque créneau de $slotMinutes min.';
  }

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
  String get calendarProviderSelectDescription =>
      'Choisissez une destination. Chaque fournisseur dispose de son propre guide et état d\'exportation.';

  @override
  String get calendarDuplicateProtectionDescription =>
      'Un bloc déjà associé à la même date et au même fournisseur est ignoré.';

  @override
  String get calendarExportAlreadySynced =>
      'Les blocs d\'aujourd\'hui sont déjà synchronisés.';

  @override
  String get openCalendarAction => 'Ouvrir le calendrier';

  @override
  String get calendarOpenFailed =>
      'Impossible d\'ouvrir l\'application de calendrier.';

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
  String get moveToBrainDump => 'Déplacer en décharge mentale';

  @override
  String get editBrainDumpTitle => 'Modifier la décharge mentale';

  @override
  String get editReminderTitle => 'Modifier le rappel';

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
  String get noCurrentTimeBoxTitle => 'Aucun bloc maintenant';

  @override
  String get noCurrentTimeBoxBody =>
      'Ajoutez un bloc au créneau actuel depuis Aujourd’hui.';

  @override
  String get planCurrentSlotAction => 'Planifier le créneau actuel';

  @override
  String get currentTimeBoxRequired =>
      'Ajoutez d\'abord un bloc pour le créneau actuel.';

  @override
  String get noTodayBoxesProgress => 'Aucun bloc planifié pour l\'instant.';

  @override
  String get openFocusAction => 'Ouvrir Focus';

  @override
  String get topPrioritiesTitle => 'Priorités';

  @override
  String get addPriorityTooltip => 'Ajouter une priorité';

  @override
  String get noPrioritiesYet => 'Aucune priorité';

  @override
  String get carryOverPreviousPriorities => 'Reprendre les priorités';

  @override
  String get carryOverPreviousBrainDump => 'Reprendre le brain dump';

  @override
  String get carryOverPreviousReminders => 'Reprendre les rappels';

  @override
  String get carryOverPreviousSchedule => 'Importer les blocs de temps d’hier';

  @override
  String get importSelected => 'Importer la sélection';

  @override
  String get nothingToImport => 'Rien de nouveau à importer.';

  @override
  String get noItemsForDay => 'Aucun enregistrement pour ce jour.';

  @override
  String get noPreviousDailyItems => 'Aucun élément quotidien précédent.';

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
      'Touchez la carte pour modifier. Appui long pour déplacer, barre du bas pour ajuster.';

  @override
  String get dragTimeBoxTooltip => 'Glisser pour déplacer';

  @override
  String get resizeTimeBoxTooltip => 'Toucher pour ajuster';

  @override
  String get resizeTimeBoxActiveTooltip => 'Glisser haut ou bas';

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
  String get repeatTimeBoxLabel => 'Répéter';

  @override
  String get repeatNone => 'Aucun';

  @override
  String get repeatDaily => 'Chaque jour';

  @override
  String get repeatWeekdays => 'Jours ouvrés';

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
      'Le minuteur du prochain créneau démarre.';

  @override
  String get notificationBreakCompleteBody =>
      'Le minuteur du prochain créneau démarre.';

  @override
  String get accountTitle => 'Compte';

  @override
  String get authGateSubtitle => 'Connectez-vous pour commencer.';

  @override
  String get firebaseSetupRequired => 'Configuration Firebase requise';

  @override
  String get firebaseSetupDescription =>
      'Générez les fichiers FlutterFire locaux et configurez le schéma URL iOS avant d’utiliser le login cloud.';

  @override
  String get signInWithAppleAction => 'Se connecter avec Apple';

  @override
  String get signInWithGoogleAction => 'Se connecter avec Google';

  @override
  String get signInWithEmailAction => 'Se connecter par e-mail';

  @override
  String get emailSignInTitle => 'Connexion par e-mail';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get showPasswordAction => 'Afficher le mot de passe';

  @override
  String get hidePasswordAction => 'Masquer le mot de passe';

  @override
  String get emailSignInValidation => 'Saisissez une adresse e-mail valide.';

  @override
  String get passwordSignInValidation => 'Saisissez votre mot de passe.';

  @override
  String get emailSignInFailed =>
      'Vérifiez l’e-mail et le mot de passe, puis réessayez.';

  @override
  String get signInAction => 'Se connecter';

  @override
  String signedInAs(String label) {
    return 'Connecté en tant que $label';
  }

  @override
  String get appleAccountConnected => 'Compte Apple connecté';

  @override
  String get googleAccountConnected => 'Compte Google connecté';

  @override
  String get accountConnected => 'Compte connecté';

  @override
  String get signOutAction => 'Se déconnecter';

  @override
  String get deleteAccountAction => 'Supprimer le compte';

  @override
  String get deleteAccountTitle => 'Supprimer le compte';

  @override
  String get deleteAccountBody =>
      'Votre compte et toutes les données Timebox Mark synchronisées seront définitivement supprimés. Les données supprimées ne peuvent pas être récupérées.';

  @override
  String get accountDeleted => 'Compte supprimé.';

  @override
  String get accountDeleteFailed =>
      'Impossible de supprimer le compte. Reconnectez-vous puis réessayez.';

  @override
  String get legalTitle => 'Informations légales';

  @override
  String get privacyPolicyAction => 'Politique de confidentialité';

  @override
  String get termsAction => 'Conditions d’utilisation';

  @override
  String get supportAction => 'Assistance';

  @override
  String get linkOpenFailed => 'Impossible d’ouvrir le lien.';

  @override
  String get cancelAction => 'Annuler';

  @override
  String get authSignInFailed => 'Échec de la connexion. Réessayez.';
}
