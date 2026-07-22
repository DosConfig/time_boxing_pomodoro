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
  String get introBrandEyebrow => '少输入，快执行。';

  @override
  String get introBrandTitle => '把一天装进时间块';

  @override
  String get introBrandBody => '把脑中事项变成重点、灵活时间块、Focus、提醒和可同步的日历计划。';

  @override
  String get introBrainDumpTitle => '清空脑中事项';

  @override
  String get introBrainDumpBody => '基于成熟的时间块和番茄钟原则：先记录，再决定。';

  @override
  String get introPrioritiesTitle => '选出前三件事';

  @override
  String get introPrioritiesBody => '在一天被打散前，先固定三个可见重点。';

  @override
  String get introTimeBoxTitle => '安排灵活时间块';

  @override
  String get introTimeBoxBody => '轻点空档，按适合你的时间间隔安排一天。';

  @override
  String get introFocusTitle => 'Focus跟随时间';

  @override
  String get introFocusBody => '登录后，当前时间块会驱动Focus、Live Activity、提醒和云同步。';

  @override
  String get introBackAction => '返回';

  @override
  String get introNextAction => '下一步';

  @override
  String get introStartAction => '开始使用';

  @override
  String get introSkipAction => '跳过';

  @override
  String get introSampleTopPriority => '发布计划';

  @override
  String get introSampleDeepWork => '深度工作';

  @override
  String get introSampleFollowUp => '跟进';

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
  String get languageTitle => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageKorean => '韩语';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageJapanese => '日语';

  @override
  String get languageChinese => '中文';

  @override
  String get languageSpanish => '西班牙语';

  @override
  String get languageFrench => '法语';

  @override
  String get languageGerman => '德语';

  @override
  String get awakeWindowTitle => '清醒时段';

  @override
  String get timeSlotIntervalTitle => '时间调整间隔';

  @override
  String get timeSlotIntervalDescription => '设置添加、移动或调整时间块大小时使用的步长。';

  @override
  String get timeSlot15Minutes => '15分钟';

  @override
  String get timeSlot30Minutes => '30分钟';

  @override
  String get timeSlot1Hour => '1小时';

  @override
  String get editAction => '编辑';

  @override
  String get executionTitle => '执行';

  @override
  String get autoStartNextTimeBox => '自动开始下一个时间盒';

  @override
  String get liveTrackingTitle => '实时追踪时间盒';

  @override
  String get liveTrackingDescription => '在专注、实时活动和通知中自动追踪当前区块。';

  @override
  String get alertsTitle => '提醒';

  @override
  String get localAlerts => '本地提醒';

  @override
  String get soundLabel => '声音';

  @override
  String get soundDescription => '完成提醒使用设备默认提示音。';

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
  String get calendarProviderSelectDescription =>
      '请选择一个导出目标。每个提供方都有独立的说明和进度状态。';

  @override
  String get calendarDuplicateProtectionDescription =>
      '同一日期和提供方中已关联的时间盒不会重复导出。';

  @override
  String get calendarExportAlreadySynced => '今天的时间盒已同步。';

  @override
  String get openCalendarAction => '打开日历';

  @override
  String get calendarOpenFailed => '无法打开日历应用。';

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
  String get noCurrentTimeBoxTitle => '当前没有时间盒';

  @override
  String get noCurrentTimeBoxBody => '请在今天页为当前时段添加时间盒。';

  @override
  String get planCurrentSlotAction => '规划当前时段';

  @override
  String get currentTimeBoxRequired => '请先为当前时段添加时间盒。';

  @override
  String get noTodayBoxesProgress => '今天还没有计划时间盒。';

  @override
  String get openFocusAction => '打开 Focus';

  @override
  String get topPrioritiesTitle => '最高优先级';

  @override
  String get addPriorityTooltip => '添加优先级';

  @override
  String get noPrioritiesYet => '还没有优先级';

  @override
  String get carryOverPreviousPriorities => '导入上次优先级';

  @override
  String get carryOverPreviousBrainDump => '导入上次脑内清单';

  @override
  String get carryOverPreviousReminders => '导入上次提醒';

  @override
  String get carryOverPreviousSchedule => '导入上次日程';

  @override
  String get noPreviousDailyItems => '没有找到上次每日项目。';

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
  String get timeBoxesHint => '点按卡片编辑。长按移动，拖动底部条调整长度。';

  @override
  String get dragTimeBoxTooltip => '拖动以移动';

  @override
  String get resizeTimeBoxTooltip => '点按调整长度';

  @override
  String get resizeTimeBoxActiveTooltip => '上下拖动调整';

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
  String get repeatTimeBoxLabel => '重复';

  @override
  String get repeatNone => '无';

  @override
  String get repeatDaily => '每天';

  @override
  String get repeatWeekdays => '工作日';

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
  String get accountTitle => '账户';

  @override
  String get authGateSubtitle => '登录后开始。';

  @override
  String get firebaseSetupRequired => '需要 Firebase 设置';

  @override
  String get firebaseSetupDescription =>
      '要使用云登录，请生成本地 FlutterFire 文件并设置 iOS URL scheme。';

  @override
  String get signInWithAppleAction => '使用 Apple 登录';

  @override
  String get signInWithGoogleAction => '使用 Google 登录';

  @override
  String get signInWithEmailAction => '使用电子邮件登录';

  @override
  String get emailSignInTitle => '电子邮件登录';

  @override
  String get emailLabel => '电子邮件';

  @override
  String get passwordLabel => '密码';

  @override
  String get showPasswordAction => '显示密码';

  @override
  String get hidePasswordAction => '隐藏密码';

  @override
  String get emailSignInValidation => '请输入有效的电子邮件地址。';

  @override
  String get passwordSignInValidation => '请输入密码。';

  @override
  String get emailSignInFailed => '请检查电子邮件和密码后重试。';

  @override
  String get signInAction => '登录';

  @override
  String signedInAs(String label) {
    return '已登录为 $label';
  }

  @override
  String get appleAccountConnected => '已连接 Apple 账户';

  @override
  String get googleAccountConnected => '已连接 Google 账户';

  @override
  String get accountConnected => '已连接账户';

  @override
  String get signOutAction => '退出登录';

  @override
  String get deleteAccountAction => '删除账户';

  @override
  String get deleteAccountTitle => '删除账户';

  @override
  String get deleteAccountBody =>
      '你的账户和所有已同步的 Timebox Mark 数据将被永久删除。删除后的数据无法恢复。';

  @override
  String get accountDeleted => '账户已删除。';

  @override
  String get accountDeleteFailed => '无法删除账户。请重新登录后再试。';

  @override
  String get legalTitle => '法律信息';

  @override
  String get privacyPolicyAction => '隐私政策';

  @override
  String get termsAction => '使用条款';

  @override
  String get supportAction => '支持';

  @override
  String get linkOpenFailed => '无法打开链接。';

  @override
  String get cancelAction => '取消';

  @override
  String get authSignInFailed => '登录失败，请重试。';
}
