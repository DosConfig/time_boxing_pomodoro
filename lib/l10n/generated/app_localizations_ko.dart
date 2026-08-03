// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => '타임박스 마크';

  @override
  String get introBrandEyebrow => '적게 입력하고, 바로 실행하세요.';

  @override
  String get introBrandTitle => '하루를 타임박스로';

  @override
  String get introBrandBody =>
      '브레인 덤프를 우선순위, 유연한 타임박스, 집중, 알림, 캘린더 계획으로 빠르게 바꿉니다.';

  @override
  String get introBrainDumpTitle => '머릿속을 비우기';

  @override
  String get introBrainDumpBody => '검증된 타임박싱과 포모도로 원칙으로, 먼저 적고 나중에 정리하세요.';

  @override
  String get introPrioritiesTitle => '오늘의 세 가지';

  @override
  String get introPrioritiesBody => '하루가 끌고 가기 전에, 오늘 볼 최우선 항목 세 개를 먼저 고정합니다.';

  @override
  String get introTimeBoxTitle => '내게 맞는 타임박스 배치';

  @override
  String get introTimeBoxBody => '빈 슬롯을 탭하고 원하는 시간 단위로 하루를 빠르게 배치하세요.';

  @override
  String get introFocusTitle => '집중은 시간에 맞춰';

  @override
  String get introFocusBody =>
      '로그인 후 현재 블록이 집중, Live Activity, 알림, 클라우드 동기화를 이끕니다.';

  @override
  String get introBackAction => '뒤로';

  @override
  String get introNextAction => '다음';

  @override
  String get introStartAction => '시작하기';

  @override
  String get introSkipAction => '건너뛰기';

  @override
  String get introSampleTopPriority => '런칭 계획';

  @override
  String get introSampleDeepWork => '딥워크';

  @override
  String get introSampleFollowUp => '후속 작업';

  @override
  String get navToday => '오늘';

  @override
  String get navFocus => '집중';

  @override
  String get navCalendar => '캘린더';

  @override
  String get navSettings => '설정';

  @override
  String get ok => '확인';

  @override
  String get breakCompleteMessage => '휴식이 끝났어요. 다음 블록을 준비하세요.';

  @override
  String get focusCompleteMessage => '집중이 끝났어요. 다음 블록 전에 잠깐 쉬세요.';

  @override
  String get focusTitle => '집중';

  @override
  String get shortBreakLabel => '짧은 휴식';

  @override
  String get longBreakLabel => '긴 휴식';

  @override
  String get nowLabel => '지금';

  @override
  String get readyLabel => '대기';

  @override
  String get runningLabel => '진행 중';

  @override
  String get pausedLabel => '일시정지';

  @override
  String sessionProgress(int completed, int total) {
    return '오늘 박스 $total개 중 $completed개 완료';
  }

  @override
  String get resetAction => '초기화';

  @override
  String get pauseAction => '일시정지';

  @override
  String get startAction => '시작';

  @override
  String get settingsTitle => '설정';

  @override
  String get languageTitle => '언어';

  @override
  String get languageSystem => '시스템 기본값';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageEnglish => '영어';

  @override
  String get languageJapanese => '일본어';

  @override
  String get languageChinese => '중국어';

  @override
  String get languageSpanish => '스페인어';

  @override
  String get languageFrench => '프랑스어';

  @override
  String get languageGerman => '독일어';

  @override
  String get awakeWindowTitle => '깨어있는 시간';

  @override
  String get timeSlotIntervalTitle => '시간 조절 단위';

  @override
  String get timeSlotIntervalDescription =>
      '타임박스를 추가하거나 이동하고 길이를 조절할 때 사용할 간격입니다.';

  @override
  String get timeSlot15Minutes => '15분';

  @override
  String get timeSlot30Minutes => '30분';

  @override
  String get timeSlot1Hour => '1시간';

  @override
  String get editAction => '수정';

  @override
  String get executionTitle => '실행';

  @override
  String get autoStartNextTimeBox => '다음 타임박스 자동 시작';

  @override
  String get liveTrackingTitle => '타임박스 실시간 추적';

  @override
  String get liveTrackingDescription =>
      '현재 블록을 Focus, 라이브 액티비티와 알림에서 자동으로 추적합니다.';

  @override
  String get alertsTitle => '알림';

  @override
  String get localAlerts => '로컬 알림';

  @override
  String get soundLabel => '완료 알림음';

  @override
  String get soundDescription =>
      '세션이 완료될 때 기기 기본 알림음을 재생합니다. 진행 중 타이머 알림은 항상 무음입니다.';

  @override
  String get slotBreakTitle => '슬롯 휴식';

  @override
  String slotBreakDescription(int slotMinutes, int breakMinutes) {
    return '$slotMinutes분 슬롯마다 마지막 $breakMinutes분을 휴식합니다.';
  }

  @override
  String get saveAction => '저장';

  @override
  String get onboardingSubtitle => '실제로 계획할 시간을 설정하세요.';

  @override
  String get startPlanning => '계획 시작';

  @override
  String get calendarTitle => '캘린더';

  @override
  String get todayPlanSync => '오늘 계획 동기화';

  @override
  String get syncModeTitle => '동기화 방식';

  @override
  String get manualMode => '수동';

  @override
  String get autoMode => '자동';

  @override
  String get calendarExport => '캘린더 내보내기';

  @override
  String providerSetupQueued(String provider) {
    return '$provider 설정은 준비 중입니다.';
  }

  @override
  String get providerAppleCalendar => 'Apple 캘린더';

  @override
  String get appleCalendarExportDescription => '오늘 타임박스를 기본 Apple 캘린더에 추가합니다.';

  @override
  String get providerGoogleCalendar => 'Google 캘린더';

  @override
  String get googleCalendarExportDescription =>
      'Google 권한을 받은 뒤 오늘 타임박스를 기본 Google 캘린더에 추가합니다.';

  @override
  String get providerOutlook => 'Outlook';

  @override
  String get badgeFree => '무료';

  @override
  String get badgePro => '프로';

  @override
  String get statusLocal => '로컬';

  @override
  String get statusFirebase => 'Firebase';

  @override
  String get statusOAuth => 'OAuth';

  @override
  String get setupAction => '설정';

  @override
  String get connectAction => '연결';

  @override
  String get providersTitle => '제공자';

  @override
  String get exportRulesTitle => '내보내기 규칙';

  @override
  String get topPrioritiesOnly => '최우선 항목만';

  @override
  String get conflictCheck => '일정 충돌 확인';

  @override
  String get dedicatedCalendar => '전용 캘린더';

  @override
  String get includeBreaks => '휴식 포함';

  @override
  String get todayQueueTitle => '오늘 대기열';

  @override
  String boxesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 박스',
      zero: '0개 박스',
    );
    return '$_temp0';
  }

  @override
  String get noBoxes => '박스 없음';

  @override
  String get exportSelected => '선택 항목 내보내기';

  @override
  String get exportTodayAction => '오늘 내보내기';

  @override
  String get exportAppleTodayAction => 'Apple 캘린더로 내보내기';

  @override
  String get exportGoogleTodayAction => 'Google 캘린더로 내보내기';

  @override
  String get calendarExporting => '내보내는 중';

  @override
  String get calendarExportEmpty => '내보낼 타임박스가 없습니다.';

  @override
  String calendarExportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '일정 $count개를 내보냈습니다',
      zero: '내보낸 일정이 없습니다',
    );
    return '$_temp0';
  }

  @override
  String get calendarExportDenied => '캘린더 접근이 거부되었습니다.';

  @override
  String get calendarExportUnavailable => '이 기기에서는 캘린더 내보내기를 사용할 수 없습니다.';

  @override
  String get calendarExportFailed => '캘린더 내보내기에 실패했습니다. 다시 시도하세요.';

  @override
  String get calendarProviderSelectDescription =>
      '내보낼 캘린더를 하나 선택하세요. 제공자별 안내와 진행 상태가 분리됩니다.';

  @override
  String get calendarDuplicateProtectionDescription =>
      '같은 날짜와 제공자에 이미 연결된 타임박스는 다시 내보내지 않습니다.';

  @override
  String get calendarExportAlreadySynced => '오늘 타임박스는 이미 동기화되어 있습니다.';

  @override
  String get openCalendarAction => '캘린더 열기';

  @override
  String get calendarOpenFailed => '캘린더 앱을 열 수 없습니다.';

  @override
  String get todayTitle => '오늘';

  @override
  String get startFocus => '집중 시작';

  @override
  String get brainDumpTitle => '브레인 덤프';

  @override
  String get addBrainDumpTooltip => '브레인 덤프 추가';

  @override
  String get addBrainDumpTitle => '브레인 덤프 추가';

  @override
  String get captureLabel => '기록';

  @override
  String get makePriority => '우선순위로 만들기';

  @override
  String get moveToReminder => '리마인더로 이동';

  @override
  String get moveToBrainDump => '브레인 덤프로 이동';

  @override
  String get editBrainDumpTitle => '브레인 덤프 수정';

  @override
  String get editReminderTitle => '리마인더 수정';

  @override
  String get deleteAction => '삭제';

  @override
  String get keepInMindTitle => '기억할 것';

  @override
  String get addReminderTooltip => '리마인더 추가';

  @override
  String get addReminderTitle => '리마인더 추가';

  @override
  String get reminderLabel => '리마인더';

  @override
  String get enterSomethingFirst => '내용을 입력하세요.';

  @override
  String get dailyProgressTitle => '오늘 요약';

  @override
  String get planMetric => '우선순위';

  @override
  String get timeBoxesMetric => '타임박스';

  @override
  String get focusMetric => '완료';

  @override
  String get dailyProgressDescription => '우선순위, 계획된 타임박스, 다음 집중 블록을 확인하세요.';

  @override
  String get todayReviewTitle => '오늘 리뷰';

  @override
  String get nextTimeBoxLabel => '다음';

  @override
  String get noActiveTimeBox => '타임박스 없음';

  @override
  String get noCurrentTimeBoxTitle => '지금은 비어있는 슬롯';

  @override
  String get noCurrentTimeBoxBody => '오늘 탭에서 현재 시간 슬롯에 타임박스를 추가하세요.';

  @override
  String get planCurrentSlotAction => '현재 슬롯 계획';

  @override
  String get currentTimeBoxRequired => '현재 시간대의 타임박스를 먼저 추가하세요.';

  @override
  String get noTodayBoxesProgress => '아직 계획된 타임박스가 없습니다.';

  @override
  String get openFocusAction => 'Focus 열기';

  @override
  String get topPrioritiesTitle => '최우선 항목';

  @override
  String get addPriorityTooltip => '우선순위 추가';

  @override
  String get noPrioritiesYet => '아직 우선순위가 없습니다';

  @override
  String get carryOverPreviousPriorities => '이전 우선순위 가져오기';

  @override
  String get carryOverPreviousBrainDump => '이전 브레인덤프 가져오기';

  @override
  String get carryOverPreviousReminders => '이전 기억할 것 가져오기';

  @override
  String get carryOverPreviousSchedule => '최근 타임박스 불러오기';

  @override
  String get importSelected => '선택 항목 가져오기';

  @override
  String get nothingToImport => '가져올 새 항목이 없습니다.';

  @override
  String get noItemsForDay => '이 날의 기록이 없습니다.';

  @override
  String get noPreviousDailyItems => '가져올 이전 항목이 없어요.';

  @override
  String get threePrioritiesAlreadySet => '우선순위 3개가 이미 설정됐습니다.';

  @override
  String get addPriorityTitle => '우선순위 추가';

  @override
  String get editPriorityTitle => '우선순위 수정';

  @override
  String priorityLabel(int number) {
    return '우선순위 $number';
  }

  @override
  String get clearPriority => '우선순위 지우기';

  @override
  String get weekdayMonNarrow => '월';

  @override
  String get weekdayTueNarrow => '화';

  @override
  String get weekdayWedNarrow => '수';

  @override
  String get weekdayThuNarrow => '목';

  @override
  String get weekdayFriNarrow => '금';

  @override
  String get weekdaySatNarrow => '토';

  @override
  String get weekdaySunNarrow => '일';

  @override
  String get timeBoxesTitle => '타임박스';

  @override
  String get timeBoxesHint => '카드는 탭해 수정, 길게 눌러 이동, 아래 막대로 길이 조절.';

  @override
  String get dragTimeBoxTooltip => '드래그해 이동';

  @override
  String get resizeTimeBoxTooltip => '탭해 길이 조절 켜기';

  @override
  String get resizeTimeBoxActiveTooltip => '위아래로 드래그해 길이 조절';

  @override
  String get nowBadge => '지금';

  @override
  String get newTimeBoxTitle => '새 타임박스';

  @override
  String get editTimeBoxTitle => '타임박스 수정';

  @override
  String get titleLabel => '제목';

  @override
  String timeBoxRange(String range) {
    return '타임박스 $range';
  }

  @override
  String get repeatTimeBoxLabel => '반복';

  @override
  String get repeatNone => '없음';

  @override
  String get repeatDaily => '매일';

  @override
  String get repeatWeekdays => '평일';

  @override
  String get newTimeBoxDefaultTitle => '새 타임박스';

  @override
  String get nativeFocusBlockTitle => '집중 블록';

  @override
  String get nativeBreakBlockTitle => '휴식 블록';

  @override
  String get liveActivityTopPriorityLabel => '우선';

  @override
  String get notificationFocusInProgressTitle => '집중 진행 중';

  @override
  String get notificationShortBreakInProgressTitle => '짧은 휴식 진행 중';

  @override
  String get notificationLongBreakInProgressTitle => '긴 휴식 진행 중';

  @override
  String get notificationRemainingTimeFormat => '남은 시간 %@';

  @override
  String get notificationFocusCompleteTitle => '집중 완료';

  @override
  String get notificationBreakCompleteTitle => '휴식 완료';

  @override
  String get notificationFocusCompleteBody => '다음 스케줄의 타이머가 시작됩니다.';

  @override
  String get notificationBreakCompleteBody => '다음 스케줄의 타이머가 시작됩니다.';

  @override
  String get accountTitle => '계정';

  @override
  String get authGateSubtitle => '로그인하고 시작하세요.';

  @override
  String get firebaseSetupRequired => 'Firebase 설정 필요';

  @override
  String get firebaseSetupDescription =>
      '클라우드 로그인을 사용하려면 로컬 FlutterFire 파일을 생성하고 iOS URL scheme을 설정하세요.';

  @override
  String get signInWithAppleAction => 'Apple로 로그인';

  @override
  String get signInWithGoogleAction => 'Google로 로그인';

  @override
  String get signInWithEmailAction => '이메일로 로그인';

  @override
  String get emailSignInTitle => '이메일 로그인';

  @override
  String get emailLabel => '이메일';

  @override
  String get passwordLabel => '비밀번호';

  @override
  String get showPasswordAction => '비밀번호 보기';

  @override
  String get hidePasswordAction => '비밀번호 숨기기';

  @override
  String get emailSignInValidation => '올바른 이메일 주소를 입력하세요.';

  @override
  String get passwordSignInValidation => '비밀번호를 입력하세요.';

  @override
  String get emailSignInFailed => '이메일과 비밀번호를 확인한 뒤 다시 시도하세요.';

  @override
  String get signInAction => '로그인';

  @override
  String signedInAs(String label) {
    return '$label로 로그인됨';
  }

  @override
  String get appleAccountConnected => 'Apple 계정 연결됨';

  @override
  String get googleAccountConnected => 'Google 계정 연결됨';

  @override
  String get accountConnected => '계정 연결됨';

  @override
  String get signOutAction => '로그아웃';

  @override
  String get deleteAccountAction => '계정 삭제';

  @override
  String get deleteAccountTitle => '계정 삭제';

  @override
  String get deleteAccountBody =>
      '계정과 동기화된 모든 Timebox Mark 데이터가 영구적으로 삭제됩니다. 삭제된 데이터는 복원할 수 없습니다.';

  @override
  String get accountDeleted => '계정이 삭제되었습니다.';

  @override
  String get accountDeleteFailed => '계정을 삭제하지 못했습니다. 다시 로그인한 뒤 시도하세요.';

  @override
  String get legalTitle => '법적 정보';

  @override
  String get privacyPolicyAction => '개인정보 처리방침';

  @override
  String get termsAction => '이용약관';

  @override
  String get supportAction => '지원';

  @override
  String get linkOpenFailed => '링크를 열 수 없습니다.';

  @override
  String get cancelAction => '취소';

  @override
  String get authSignInFailed => '로그인에 실패했습니다. 다시 시도하세요.';
}
