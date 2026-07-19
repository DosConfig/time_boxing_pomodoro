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
  String get awakeWindowTitle => '깨어있는 시간';

  @override
  String get editAction => '수정';

  @override
  String get executionTitle => '실행';

  @override
  String get autoStartNextTimeBox => '다음 타임박스 자동 시작';

  @override
  String get alertsTitle => '알림';

  @override
  String get localAlerts => '로컬 알림';

  @override
  String get soundLabel => '사운드';

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
  String get openFocusAction => 'Focus 열기';

  @override
  String get topPrioritiesTitle => '최우선 항목';

  @override
  String get addPriorityTooltip => '우선순위 추가';

  @override
  String get noPrioritiesYet => '아직 우선순위가 없습니다';

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
  String get timeBoxesHint => '빈 슬롯을 탭해 추가하고, 박스를 탭해 수정하세요.';

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
  String get notificationFocusCompleteBody => '다음 블록 전에 잠깐 쉬세요.';

  @override
  String get notificationBreakCompleteBody => '다음 집중 블록을 준비하세요.';

  @override
  String get defaultTimeBoxTopPriority => '최우선 항목';

  @override
  String get defaultTimeBoxDeepWork => '딥워크';

  @override
  String get defaultTimeBoxAdmin => '관리 업무';

  @override
  String get defaultTimeBoxSecondPriority => '두 번째 우선순위';

  @override
  String get defaultTimeBoxFollowUp => '후속 작업';

  @override
  String get accountTitle => '계정';

  @override
  String get firebaseSetupRequired => 'Firebase 설정 필요';

  @override
  String get firebaseSetupDescription =>
      '클라우드 로그인을 사용하려면 GoogleService-Info.plist를 추가하고 Firebase에서 Apple 로그인을 활성화하세요.';

  @override
  String get signInWithAppleAction => 'Apple로 로그인';

  @override
  String signedInAs(String label) {
    return '$label로 로그인됨';
  }

  @override
  String get signOutAction => '로그아웃';

  @override
  String get authSignInFailed => '로그인에 실패했습니다. 다시 시도하세요.';
}
