// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Timebox Mark';

  @override
  String get navToday => '今天';

  @override
  String get navFocus => '专注';

  @override
  String get navCalendar => '日历';

  @override
  String get navSettings => '设置';

  @override
  String get ok => '确定';

  @override
  String get breakCompleteMessage => '休息结束。下一个区块已准备好。';

  @override
  String get focusCompleteMessage => '专注结束。开始下一个区块前先休息一下。';

  @override
  String get focusTitle => '专注';

  @override
  String get shortBreakLabel => '短休息';

  @override
  String get longBreakLabel => '长休息';

  @override
  String get nowLabel => '现在';

  @override
  String get readyLabel => '就绪';

  @override
  String get runningLabel => '进行中';

  @override
  String get pausedLabel => '已暂停';

  @override
  String sessionProgress(int completed, int total) {
    return '今日 $total 个区块中已完成 $completed 个';
  }

  @override
  String get resetAction => '重置';

  @override
  String get pauseAction => '暂停';

  @override
  String get startAction => '开始';

  @override
  String get settingsTitle => '设置';

  @override
  String get awakeWindowTitle => '清醒时段';

  @override
  String get editAction => '编辑';

  @override
  String get executionTitle => '执行';

  @override
  String get autoStartNextTimeBox => '自动开始下一个时间盒';

  @override
  String get alertsTitle => '提醒';

  @override
  String get localAlerts => '本地提醒';

  @override
  String get soundLabel => '声音';

  @override
  String get saveAction => '保存';

  @override
  String get onboardingSubtitle => '设置你真正用于计划的时间。';

  @override
  String get startPlanning => '开始计划';

  @override
  String get calendarTitle => '日历';

  @override
  String get todayPlanSync => '今日计划同步';

  @override
  String get syncModeTitle => '同步模式';

  @override
  String get manualMode => '手动';

  @override
  String get autoMode => '自动';

  @override
  String get calendarExport => '日历导出';

  @override
  String providerSetupQueued(String provider) {
    return '$provider 设置已加入队列。';
  }

  @override
  String get providerAppleCalendar => 'Apple 日历';

  @override
  String get appleCalendarExportDescription => '将今天的时间盒添加到默认 Apple 日历。';

  @override
  String get providerGoogleCalendar => 'Google 日历';

  @override
  String get googleCalendarExportDescription =>
      '获得 Google 授权后，将今天的时间盒添加到主 Google 日历。';

  @override
  String get providerOutlook => 'Outlook';

  @override
  String get badgeFree => '免费';

  @override
  String get badgePro => '专业';

  @override
  String get statusLocal => '本地';

  @override
  String get statusFirebase => 'Firebase';

  @override
  String get statusOAuth => 'OAuth';

  @override
  String get setupAction => '设置';

  @override
  String get connectAction => '连接';

  @override
  String get providersTitle => '服务';

  @override
  String get exportRulesTitle => '导出规则';

  @override
  String get topPrioritiesOnly => '仅最高优先级';

  @override
  String get conflictCheck => '冲突检查';

  @override
  String get dedicatedCalendar => '专用日历';

  @override
  String get includeBreaks => '包含休息';

  @override
  String get todayQueueTitle => '今日队列';

  @override
  String boxesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个区块',
      zero: '0 个区块',
    );
    return '$_temp0';
  }

  @override
  String get noBoxes => '没有区块';

  @override
  String get exportSelected => '导出所选';

  @override
  String get exportTodayAction => '导出今天';

  @override
  String get exportAppleTodayAction => '导出到 Apple 日历';

  @override
  String get exportGoogleTodayAction => '导出到 Google 日历';

  @override
  String get calendarExporting => '正在导出';

  @override
  String get calendarExportEmpty => '没有可导出的时间盒。';

  @override
  String calendarExportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已导出 $count 个日程',
      zero: '未导出日程',
    );
    return '$_temp0';
  }

  @override
  String get calendarExportDenied => '日历访问被拒绝。';

  @override
  String get calendarExportUnavailable => '此设备无法使用日历导出。';

  @override
  String get calendarExportFailed => '日历导出失败，请重试。';

  @override
  String get todayTitle => '今天';

  @override
  String get startFocus => '开始专注';

  @override
  String get brainDumpTitle => '想法收集';

  @override
  String get addBrainDumpTooltip => '添加想法';

  @override
  String get addBrainDumpTitle => '添加想法';

  @override
  String get captureLabel => '记录';

  @override
  String get makePriority => '设为优先级';

  @override
  String get moveToReminder => '移到提醒';

  @override
  String get deleteAction => '删除';

  @override
  String get keepInMindTitle => '记住事项';

  @override
  String get addReminderTooltip => '添加提醒';

  @override
  String get addReminderTitle => '添加提醒';

  @override
  String get reminderLabel => '提醒';

  @override
  String get enterSomethingFirst => '请先输入内容。';

  @override
  String get dailyProgressTitle => '今日摘要';

  @override
  String get planMetric => '优先级';

  @override
  String get timeBoxesMetric => '时间盒';

  @override
  String get focusMetric => '完成';

  @override
  String get dailyProgressDescription => '查看优先级、已计划的时间盒和下一个专注时段。';

  @override
  String get todayReviewTitle => '今日回顾';

  @override
  String get nextTimeBoxLabel => '下一个';

  @override
  String get noActiveTimeBox => '无时间盒';

  @override
  String get openFocusAction => '打开 Focus';

  @override
  String get topPrioritiesTitle => '最高优先级';

  @override
  String get addPriorityTooltip => '添加优先级';

  @override
  String get noPrioritiesYet => '还没有优先级';

  @override
  String get threePrioritiesAlreadySet => '已设置 3 个优先级。';

  @override
  String get addPriorityTitle => '添加优先级';

  @override
  String get editPriorityTitle => '编辑优先级';

  @override
  String priorityLabel(int number) {
    return '优先级 $number';
  }

  @override
  String get clearPriority => '清除优先级';

  @override
  String get weekdayMonNarrow => '一';

  @override
  String get weekdayTueNarrow => '二';

  @override
  String get weekdayWedNarrow => '三';

  @override
  String get weekdayThuNarrow => '四';

  @override
  String get weekdayFriNarrow => '五';

  @override
  String get weekdaySatNarrow => '六';

  @override
  String get weekdaySunNarrow => '日';

  @override
  String get timeBoxesTitle => '时间盒';

  @override
  String get timeBoxesHint => '点击空槽添加，点击时间盒编辑。';

  @override
  String get nowBadge => '现在';

  @override
  String get newTimeBoxTitle => '新时间盒';

  @override
  String get editTimeBoxTitle => '编辑时间盒';

  @override
  String get titleLabel => '标题';

  @override
  String timeBoxRange(String range) {
    return '时间盒 $range';
  }

  @override
  String get newTimeBoxDefaultTitle => '新时间盒';

  @override
  String get nativeFocusBlockTitle => '专注时段';

  @override
  String get nativeBreakBlockTitle => '休息时段';

  @override
  String get liveActivityTopPriorityLabel => '优先';

  @override
  String get notificationFocusInProgressTitle => '专注进行中';

  @override
  String get notificationShortBreakInProgressTitle => '短休息进行中';

  @override
  String get notificationLongBreakInProgressTitle => '长休息进行中';

  @override
  String get notificationRemainingTimeFormat => '剩余 %@';

  @override
  String get notificationFocusCompleteTitle => '专注完成';

  @override
  String get notificationBreakCompleteTitle => '休息完成';

  @override
  String get notificationFocusCompleteBody => '下一个时段前先休息一下。';

  @override
  String get notificationBreakCompleteBody => '下一个专注时段已准备好。';

  @override
  String get defaultTimeBoxTopPriority => '最高优先级';

  @override
  String get defaultTimeBoxDeepWork => '深度工作';

  @override
  String get defaultTimeBoxAdmin => '事务处理';

  @override
  String get defaultTimeBoxSecondPriority => '第二优先级';

  @override
  String get defaultTimeBoxFollowUp => '跟进';

  @override
  String get accountTitle => '账户';

  @override
  String get firebaseSetupRequired => '需要 Firebase 设置';

  @override
  String get firebaseSetupDescription =>
      '要使用云登录，请添加 GoogleService-Info.plist，并在 Firebase 中启用 Apple 登录。';

  @override
  String get signInWithAppleAction => '使用 Apple 登录';

  @override
  String signedInAs(String label) {
    return '已登录为 $label';
  }

  @override
  String get signOutAction => '退出登录';

  @override
  String get authSignInFailed => '登录失败，请重试。';
}
