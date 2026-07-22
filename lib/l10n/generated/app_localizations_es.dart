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
  String get introBrandEyebrow => 'Planifica menos. Avanza más.';

  @override
  String get introBrandTitle => 'Timeboxea tu día';

  @override
  String get introBrandBody =>
      'Convierte ideas sueltas en prioridades, bloques flexibles, Focus, avisos y planes listos para calendario.';

  @override
  String get introBrainDumpTitle => 'Vacía la mente';

  @override
  String get introBrainDumpBody =>
      'Basado en timeboxing y Pomodoro: captura primero, decide después.';

  @override
  String get introPrioritiesTitle => 'Elige tres claves';

  @override
  String get introPrioritiesBody =>
      'Fija tres prioridades visibles antes de que el día te arrastre.';

  @override
  String get introTimeBoxTitle => 'Bloques de tiempo flexibles';

  @override
  String get introTimeBoxBody =>
      'Toca un hueco y planifica el día con el intervalo que prefieras.';

  @override
  String get introFocusTitle => 'Focus sigue el reloj';

  @override
  String get introFocusBody =>
      'Tras iniciar sesión, el bloque actual guía Focus, Live Activity, avisos y sincronización.';

  @override
  String get introBackAction => 'Atrás';

  @override
  String get introNextAction => 'Siguiente';

  @override
  String get introStartAction => 'Empezar';

  @override
  String get introSkipAction => 'Omitir';

  @override
  String get introSampleTopPriority => 'Plan de lanzamiento';

  @override
  String get introSampleDeepWork => 'Trabajo profundo';

  @override
  String get introSampleFollowUp => 'Seguimiento';

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
  String get languageTitle => 'Idioma';

  @override
  String get languageSystem => 'Predeterminado del sistema';

  @override
  String get languageKorean => 'Coreano';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageJapanese => 'Japonés';

  @override
  String get languageChinese => 'Chino';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageFrench => 'Francés';

  @override
  String get languageGerman => 'Alemán';

  @override
  String get awakeWindowTitle => 'Horas activas';

  @override
  String get timeSlotIntervalTitle => 'Intervalo de ajuste';

  @override
  String get timeSlotIntervalDescription =>
      'Define el paso para añadir, mover o cambiar el tamaño de los bloques.';

  @override
  String get timeSlot15Minutes => '15 min';

  @override
  String get timeSlot30Minutes => '30 min';

  @override
  String get timeSlot1Hour => '1 h';

  @override
  String get editAction => 'Editar';

  @override
  String get executionTitle => 'Ejecución';

  @override
  String get autoStartNextTimeBox =>
      'Iniciar automáticamente el siguiente bloque';

  @override
  String get liveTrackingTitle => 'Seguimiento en vivo';

  @override
  String get liveTrackingDescription =>
      'Sigue el bloque actual automáticamente en Enfoque, Live Activity y notificaciones.';

  @override
  String get alertsTitle => 'Alertas';

  @override
  String get localAlerts => 'Alertas locales';

  @override
  String get soundLabel => 'Sonido';

  @override
  String get soundDescription =>
      'Usa el sonido predeterminado del dispositivo al completar.';

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
  String get calendarProviderSelectDescription =>
      'Elige un destino. Cada proveedor tiene su propia guía y estado de exportación.';

  @override
  String get calendarDuplicateProtectionDescription =>
      'Se omite cualquier bloque ya vinculado para la misma fecha y proveedor.';

  @override
  String get calendarExportAlreadySynced =>
      'Los bloques de hoy ya están sincronizados.';

  @override
  String get openCalendarAction => 'Abrir calendario';

  @override
  String get calendarOpenFailed =>
      'No se pudo abrir la aplicación de calendario.';

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
  String get noCurrentTimeBoxTitle => 'No hay bloque ahora';

  @override
  String get noCurrentTimeBoxBody =>
      'Agrega un bloque al tramo actual desde Hoy.';

  @override
  String get planCurrentSlotAction => 'Planificar tramo actual';

  @override
  String get currentTimeBoxRequired =>
      'Agrega primero un bloque para el tramo actual.';

  @override
  String get noTodayBoxesProgress => 'Aún no hay bloques planificados.';

  @override
  String get openFocusAction => 'Abrir Focus';

  @override
  String get topPrioritiesTitle => 'Prioridades principales';

  @override
  String get addPriorityTooltip => 'Agregar prioridad';

  @override
  String get noPrioritiesYet => 'Aún no hay prioridades';

  @override
  String get carryOverPreviousPriorities => 'Traer prioridades anteriores';

  @override
  String get carryOverPreviousBrainDump => 'Traer descarga mental anterior';

  @override
  String get carryOverPreviousReminders => 'Traer recordatorios anteriores';

  @override
  String get carryOverPreviousSchedule => 'Traer horario anterior';

  @override
  String get noPreviousDailyItems => 'No hay elementos diarios anteriores.';

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
      'Toca la tarjeta para editar. Mantén pulsado para mover y la barra inferior para ajustar.';

  @override
  String get dragTimeBoxTooltip => 'Arrastra para mover';

  @override
  String get resizeTimeBoxTooltip => 'Toca para ajustar';

  @override
  String get resizeTimeBoxActiveTooltip => 'Arrastra arriba o abajo';

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
  String get repeatTimeBoxLabel => 'Repetir';

  @override
  String get repeatNone => 'Ninguno';

  @override
  String get repeatDaily => 'Diario';

  @override
  String get repeatWeekdays => 'Días laborables';

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
  String get accountTitle => 'Cuenta';

  @override
  String get authGateSubtitle => 'Inicia sesión para empezar.';

  @override
  String get firebaseSetupRequired => 'Configura Firebase';

  @override
  String get firebaseSetupDescription =>
      'Genera los archivos locales de FlutterFire y configura el esquema URL de iOS antes de usar login en la nube.';

  @override
  String get signInWithAppleAction => 'Iniciar con Apple';

  @override
  String get signInWithGoogleAction => 'Iniciar con Google';

  @override
  String get signInWithEmailAction => 'Iniciar sesión con correo';

  @override
  String get emailSignInTitle => 'Inicio de sesión por correo';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get showPasswordAction => 'Mostrar contraseña';

  @override
  String get hidePasswordAction => 'Ocultar contraseña';

  @override
  String get emailSignInValidation => 'Introduce un correo electrónico válido.';

  @override
  String get passwordSignInValidation => 'Introduce tu contraseña.';

  @override
  String get emailSignInFailed =>
      'Comprueba el correo y la contraseña e inténtalo de nuevo.';

  @override
  String get signInAction => 'Iniciar sesión';

  @override
  String signedInAs(String label) {
    return 'Sesión como $label';
  }

  @override
  String get appleAccountConnected => 'Cuenta de Apple conectada';

  @override
  String get googleAccountConnected => 'Cuenta de Google conectada';

  @override
  String get accountConnected => 'Cuenta conectada';

  @override
  String get signOutAction => 'Cerrar sesión';

  @override
  String get deleteAccountAction => 'Eliminar cuenta';

  @override
  String get deleteAccountTitle => 'Eliminar cuenta';

  @override
  String get deleteAccountBody =>
      'Tu cuenta y todos los datos sincronizados de Timebox Mark se eliminarán de forma permanente. Los datos eliminados no se pueden recuperar.';

  @override
  String get accountDeleted => 'Cuenta eliminada.';

  @override
  String get accountDeleteFailed =>
      'No se pudo eliminar la cuenta. Inicia sesión otra vez y vuelve a intentarlo.';

  @override
  String get legalTitle => 'Legal';

  @override
  String get privacyPolicyAction => 'Política de privacidad';

  @override
  String get termsAction => 'Términos de uso';

  @override
  String get supportAction => 'Soporte';

  @override
  String get linkOpenFailed => 'No se pudo abrir el enlace.';

  @override
  String get cancelAction => 'Cancelar';

  @override
  String get authSignInFailed =>
      'No se pudo iniciar sesión. Inténtalo de nuevo.';
}
