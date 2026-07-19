// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Timebox Mark';

  @override
  String get navToday => 'Hoy';

  @override
  String get navFocus => 'Enfoque';

  @override
  String get navCalendar => 'Calendario';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get ok => 'OK';

  @override
  String get breakCompleteMessage =>
      'Descanso terminado. El siguiente bloque está listo.';

  @override
  String get focusCompleteMessage =>
      'Enfoque terminado. Aléjate un momento antes del siguiente bloque.';

  @override
  String get focusTitle => 'Enfoque';

  @override
  String get shortBreakLabel => 'Descanso corto';

  @override
  String get longBreakLabel => 'Descanso largo';

  @override
  String get nowLabel => 'Ahora';

  @override
  String get readyLabel => 'Listo';

  @override
  String get runningLabel => 'En curso';

  @override
  String get pausedLabel => 'Pausado';

  @override
  String sessionProgress(int completed, int total) {
    return '$completed de $total bloques de hoy';
  }

  @override
  String get resetAction => 'Reiniciar';

  @override
  String get pauseAction => 'Pausar';

  @override
  String get startAction => 'Iniciar';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get awakeWindowTitle => 'Horas activas';

  @override
  String get editAction => 'Editar';

  @override
  String get executionTitle => 'Ejecución';

  @override
  String get autoStartNextTimeBox =>
      'Iniciar automáticamente el siguiente bloque';

  @override
  String get alertsTitle => 'Alertas';

  @override
  String get localAlerts => 'Alertas locales';

  @override
  String get soundLabel => 'Sonido';

  @override
  String get saveAction => 'Guardar';

  @override
  String get onboardingSubtitle =>
      'Define las horas que realmente vas a planificar.';

  @override
  String get startPlanning => 'Empezar a planificar';

  @override
  String get calendarTitle => 'Calendario';

  @override
  String get todayPlanSync => 'Sincronizar plan de hoy';

  @override
  String get syncModeTitle => 'Modo de sincronización';

  @override
  String get manualMode => 'Manual';

  @override
  String get autoMode => 'Auto';

  @override
  String get calendarExport => 'Exportar calendario';

  @override
  String providerSetupQueued(String provider) {
    return 'La configuración de $provider está en cola.';
  }

  @override
  String get providerAppleCalendar => 'Calendario de Apple';

  @override
  String get appleCalendarExportDescription =>
      'Exporta los bloques de hoy a tu calendario predeterminado de Apple.';

  @override
  String get providerGoogleCalendar => 'Calendario de Google';

  @override
  String get googleCalendarExportDescription =>
      'Agrega los bloques de hoy a tu calendario principal de Google tras conceder permiso.';

  @override
  String get providerOutlook => 'Outlook';

  @override
  String get badgeFree => 'Gratis';

  @override
  String get badgePro => 'Pro';

  @override
  String get statusLocal => 'Local';

  @override
  String get statusFirebase => 'Firebase';

  @override
  String get statusOAuth => 'OAuth';

  @override
  String get setupAction => 'Configurar';

  @override
  String get connectAction => 'Conectar';

  @override
  String get providersTitle => 'Proveedores';

  @override
  String get exportRulesTitle => 'Reglas de exportación';

  @override
  String get topPrioritiesOnly => 'Solo prioridades principales';

  @override
  String get conflictCheck => 'Revisar conflictos';

  @override
  String get dedicatedCalendar => 'Calendario dedicado';

  @override
  String get includeBreaks => 'Incluir descansos';

  @override
  String get todayQueueTitle => 'Cola de hoy';

  @override
  String boxesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bloques',
      one: '1 bloque',
      zero: '0 bloques',
    );
    return '$_temp0';
  }

  @override
  String get noBoxes => 'Sin bloques';

  @override
  String get exportSelected => 'Exportar selección';

  @override
  String get exportTodayAction => 'Exportar hoy';

  @override
  String get exportAppleTodayAction => 'Exportar a Apple Calendar';

  @override
  String get exportGoogleTodayAction => 'Exportar a Google Calendar';

  @override
  String get calendarExporting => 'Exportando';

  @override
  String get calendarExportEmpty => 'No hay bloques para exportar.';

  @override
  String calendarExportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eventos exportados',
      one: '1 evento exportado',
      zero: 'No se exportaron eventos',
    );
    return '$_temp0';
  }

  @override
  String get calendarExportDenied => 'Se denegó el acceso al calendario.';

  @override
  String get calendarExportUnavailable =>
      'La exportación de calendario no está disponible en este dispositivo.';

  @override
  String get calendarExportFailed =>
      'La exportación falló. Inténtalo de nuevo.';

  @override
  String get todayTitle => 'Hoy';

  @override
  String get startFocus => 'Iniciar enfoque';

  @override
  String get brainDumpTitle => 'Descarga mental';

  @override
  String get addBrainDumpTooltip => 'Agregar idea';

  @override
  String get addBrainDumpTitle => 'Agregar idea';

  @override
  String get captureLabel => 'Capturar';

  @override
  String get makePriority => 'Convertir en prioridad';

  @override
  String get moveToReminder => 'Mover a recordatorio';

  @override
  String get deleteAction => 'Eliminar';

  @override
  String get keepInMindTitle => 'Para recordar';

  @override
  String get addReminderTooltip => 'Agregar recordatorio';

  @override
  String get addReminderTitle => 'Agregar recordatorio';

  @override
  String get reminderLabel => 'Recordatorio';

  @override
  String get enterSomethingFirst => 'Ingresa algo primero.';

  @override
  String get dailyProgressTitle => 'Resumen de hoy';

  @override
  String get planMetric => 'Prioridades';

  @override
  String get timeBoxesMetric => 'Bloques';

  @override
  String get focusMetric => 'Hechos';

  @override
  String get dailyProgressDescription =>
      'Revisa prioridades, bloques planificados y el siguiente bloque de concentración.';

  @override
  String get todayReviewTitle => 'Revisión de hoy';

  @override
  String get nextTimeBoxLabel => 'Siguiente';

  @override
  String get noActiveTimeBox => 'Sin bloque';

  @override
  String get openFocusAction => 'Abrir Focus';

  @override
  String get topPrioritiesTitle => 'Prioridades principales';

  @override
  String get addPriorityTooltip => 'Agregar prioridad';

  @override
  String get noPrioritiesYet => 'Aún no hay prioridades';

  @override
  String get threePrioritiesAlreadySet => 'Ya hay tres prioridades.';

  @override
  String get addPriorityTitle => 'Agregar prioridad';

  @override
  String get editPriorityTitle => 'Editar prioridad';

  @override
  String priorityLabel(int number) {
    return 'Prioridad $number';
  }

  @override
  String get clearPriority => 'Borrar prioridad';

  @override
  String get weekdayMonNarrow => 'L';

  @override
  String get weekdayTueNarrow => 'M';

  @override
  String get weekdayWedNarrow => 'X';

  @override
  String get weekdayThuNarrow => 'J';

  @override
  String get weekdayFriNarrow => 'V';

  @override
  String get weekdaySatNarrow => 'S';

  @override
  String get weekdaySunNarrow => 'D';

  @override
  String get timeBoxesTitle => 'Bloques de tiempo';

  @override
  String get timeBoxesHint =>
      'Toca un espacio vacío para agregar. Toca un bloque para editar.';

  @override
  String get nowBadge => 'Ahora';

  @override
  String get newTimeBoxTitle => 'Nuevo bloque';

  @override
  String get editTimeBoxTitle => 'Editar bloque';

  @override
  String get titleLabel => 'Título';

  @override
  String timeBoxRange(String range) {
    return 'Bloque $range';
  }

  @override
  String get newTimeBoxDefaultTitle => 'Nuevo bloque';

  @override
  String get nativeFocusBlockTitle => 'Bloque de concentración';

  @override
  String get nativeBreakBlockTitle => 'Bloque de descanso';

  @override
  String get liveActivityTopPriorityLabel => 'Prior.';

  @override
  String get notificationFocusInProgressTitle => 'Concentración en curso';

  @override
  String get notificationShortBreakInProgressTitle => 'Descanso corto en curso';

  @override
  String get notificationLongBreakInProgressTitle => 'Descanso largo en curso';

  @override
  String get notificationRemainingTimeFormat => 'Queda %@';

  @override
  String get notificationFocusCompleteTitle => 'Concentración completada';

  @override
  String get notificationBreakCompleteTitle => 'Descanso completado';

  @override
  String get notificationFocusCompleteBody =>
      'Tómate una pausa antes del siguiente bloque.';

  @override
  String get notificationBreakCompleteBody =>
      'Tu siguiente bloque de concentración está listo.';

  @override
  String get defaultTimeBoxTopPriority => 'Prioridad principal';

  @override
  String get defaultTimeBoxDeepWork => 'Trabajo profundo';

  @override
  String get defaultTimeBoxAdmin => 'Administración';

  @override
  String get defaultTimeBoxSecondPriority => 'Segunda prioridad';

  @override
  String get defaultTimeBoxFollowUp => 'Seguimiento';

  @override
  String get accountTitle => 'Cuenta';

  @override
  String get firebaseSetupRequired => 'Configura Firebase';

  @override
  String get firebaseSetupDescription =>
      'Agrega GoogleService-Info.plist y habilita el inicio con Apple en Firebase para usar login en la nube.';

  @override
  String get signInWithAppleAction => 'Iniciar con Apple';

  @override
  String signedInAs(String label) {
    return 'Sesión como $label';
  }

  @override
  String get signOutAction => 'Cerrar sesión';

  @override
  String get authSignInFailed =>
      'No se pudo iniciar sesión. Inténtalo de nuevo.';
}
