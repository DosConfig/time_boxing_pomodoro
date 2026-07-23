// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'Timebox Mark';

  @override
  String get introBrandEyebrow => '少ない入力で、すぐ実行。';

  @override
  String get introBrandTitle => '一日をタイムボックス化';

  @override
  String get introBrandBody => 'ブレインダンプを優先事項、柔軟な時間ブロック、Focus、通知、カレンダー計画に変えます。';

  @override
  String get introBrainDumpTitle => '頭の中を空に';

  @override
  String get introBrainDumpBody => '実績あるタイムボックスとポモドーロの考え方で、まず記録して後で選びます。';

  @override
  String get introPrioritiesTitle => '上位3つを選ぶ';

  @override
  String get introPrioritiesBody => '一日に流される前に、見える優先事項を3つに絞ります。';

  @override
  String get introTimeBoxTitle => '柔軟な時間ブロックを配置';

  @override
  String get introTimeBoxBody => '空き枠をタップし、自分に合う時間単位で一日を組みます。';

  @override
  String get introFocusTitle => 'Focusは時間に同期';

  @override
  String get introFocusBody => 'ログイン後、現在のブロックがFocus、Live Activity、通知、同期を動かします。';

  @override
  String get introBackAction => '戻る';

  @override
  String get introNextAction => '次へ';

  @override
  String get introStartAction => '始める';

  @override
  String get introSkipAction => 'スキップ';

  @override
  String get introSampleTopPriority => 'ローンチ計画';

  @override
  String get introSampleDeepWork => 'ディープワーク';

  @override
  String get introSampleFollowUp => 'フォローアップ';

  @override
  String get navToday => '今日';

  @override
  String get navFocus => '集中';

  @override
  String get navCalendar => 'カレンダー';

  @override
  String get navSettings => '設定';

  @override
  String get ok => 'OK';

  @override
  String get breakCompleteMessage => '休憩が終わりました。次のブロックを準備できます。';

  @override
  String get focusCompleteMessage => '集中が終わりました。次の前に少し離れましょう。';

  @override
  String get focusTitle => '集中';

  @override
  String get shortBreakLabel => '短い休憩';

  @override
  String get longBreakLabel => '長い休憩';

  @override
  String get nowLabel => '現在';

  @override
  String get readyLabel => '準備完了';

  @override
  String get runningLabel => '実行中';

  @override
  String get pausedLabel => '一時停止';

  @override
  String sessionProgress(int completed, int total) {
    return '今日のボックス $total 個中 $completed 個';
  }

  @override
  String get resetAction => 'リセット';

  @override
  String get pauseAction => '一時停止';

  @override
  String get startAction => '開始';

  @override
  String get settingsTitle => '設定';

  @override
  String get languageTitle => '言語';

  @override
  String get languageSystem => 'システム設定';

  @override
  String get languageKorean => '韓国語';

  @override
  String get languageEnglish => '英語';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageChinese => '中国語';

  @override
  String get languageSpanish => 'スペイン語';

  @override
  String get languageFrench => 'フランス語';

  @override
  String get languageGerman => 'ドイツ語';

  @override
  String get awakeWindowTitle => '活動時間';

  @override
  String get timeSlotIntervalTitle => '時間調整単位';

  @override
  String get timeSlotIntervalDescription => '時間枠の追加、移動、サイズ変更に使う間隔を設定します。';

  @override
  String get timeSlot15Minutes => '15分';

  @override
  String get timeSlot30Minutes => '30分';

  @override
  String get timeSlot1Hour => '1時間';

  @override
  String get editAction => '編集';

  @override
  String get executionTitle => '実行';

  @override
  String get autoStartNextTimeBox => '次のタイムボックスを自動開始';

  @override
  String get liveTrackingTitle => 'タイムボックスのライブ追跡';

  @override
  String get liveTrackingDescription => '現在のブロックをFocus、ライブアクティビティ、通知で自動追跡します。';

  @override
  String get alertsTitle => '通知';

  @override
  String get localAlerts => 'ローカル通知';

  @override
  String get soundLabel => '完了通知音';

  @override
  String get soundDescription => 'セッション完了時に端末の標準音を鳴らします。進行中のタイマー通知は常に無音です。';

  @override
  String get slotBreakTitle => 'スロット休憩';

  @override
  String slotBreakDescription(int slotMinutes, int breakMinutes) {
    return '$slotMinutes分スロットごとに最後の$breakMinutes分を休憩します。';
  }

  @override
  String get saveAction => '保存';

  @override
  String get onboardingSubtitle => '実際に計画する時間を設定します。';

  @override
  String get startPlanning => '計画を始める';

  @override
  String get calendarTitle => 'カレンダー';

  @override
  String get todayPlanSync => '今日の計画同期';

  @override
  String get syncModeTitle => '同期モード';

  @override
  String get manualMode => '手動';

  @override
  String get autoMode => '自動';

  @override
  String get calendarExport => 'カレンダー書き出し';

  @override
  String providerSetupQueued(String provider) {
    return '$provider の設定は準備中です。';
  }

  @override
  String get providerAppleCalendar => 'Apple カレンダー';

  @override
  String get appleCalendarExportDescription => '今日の時間枠を既定のAppleカレンダーに追加します。';

  @override
  String get providerGoogleCalendar => 'Google カレンダー';

  @override
  String get googleCalendarExportDescription =>
      'Googleの許可後、今日の時間枠をメインのGoogleカレンダーに追加します。';

  @override
  String get providerOutlook => 'Outlook';

  @override
  String get badgeFree => '無料';

  @override
  String get badgePro => 'Pro';

  @override
  String get statusLocal => 'ローカル';

  @override
  String get statusFirebase => 'Firebase';

  @override
  String get statusOAuth => 'OAuth';

  @override
  String get setupAction => '設定';

  @override
  String get connectAction => '接続';

  @override
  String get providersTitle => 'プロバイダー';

  @override
  String get exportRulesTitle => '書き出しルール';

  @override
  String get topPrioritiesOnly => '最優先のみ';

  @override
  String get conflictCheck => '競合を確認';

  @override
  String get dedicatedCalendar => '専用カレンダー';

  @override
  String get includeBreaks => '休憩を含める';

  @override
  String get todayQueueTitle => '今日のキュー';

  @override
  String boxesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ボックス',
      zero: '0 ボックス',
    );
    return '$_temp0';
  }

  @override
  String get noBoxes => 'ボックスなし';

  @override
  String get exportSelected => '選択を書き出す';

  @override
  String get exportTodayAction => '今日を書き出す';

  @override
  String get exportAppleTodayAction => 'Appleカレンダーへ書き出す';

  @override
  String get exportGoogleTodayAction => 'Googleカレンダーへ書き出す';

  @override
  String get calendarExporting => '書き出し中';

  @override
  String get calendarExportEmpty => '書き出す時間枠がありません。';

  @override
  String calendarExportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件の予定を書き出しました',
      zero: '書き出した予定はありません',
    );
    return '$_temp0';
  }

  @override
  String get calendarExportDenied => 'カレンダーへのアクセスが拒否されました。';

  @override
  String get calendarExportUnavailable => 'このデバイスではカレンダー書き出しを利用できません。';

  @override
  String get calendarExportFailed => 'カレンダー書き出しに失敗しました。もう一度お試しください。';

  @override
  String get calendarProviderSelectDescription =>
      '書き出し先を1つ選択してください。案内と進行状況は提供元ごとに分かれています。';

  @override
  String get calendarDuplicateProtectionDescription =>
      '同じ日付と提供元にすでに連携済みの時間枠は再度書き出しません。';

  @override
  String get calendarExportAlreadySynced => '今日の時間枠はすでに同期されています。';

  @override
  String get openCalendarAction => 'カレンダーを開く';

  @override
  String get calendarOpenFailed => 'カレンダーアプリを開けませんでした。';

  @override
  String get todayTitle => '今日';

  @override
  String get startFocus => '集中を開始';

  @override
  String get brainDumpTitle => 'ブレインダンプ';

  @override
  String get addBrainDumpTooltip => 'ブレインダンプを追加';

  @override
  String get addBrainDumpTitle => 'ブレインダンプを追加';

  @override
  String get captureLabel => '記録';

  @override
  String get makePriority => '優先事項にする';

  @override
  String get moveToReminder => 'リマインダーへ移動';

  @override
  String get moveToBrainDump => 'ブレインダンプへ移動';

  @override
  String get editBrainDumpTitle => 'ブレインダンプを編集';

  @override
  String get editReminderTitle => 'リマインダーを編集';

  @override
  String get deleteAction => '削除';

  @override
  String get keepInMindTitle => '覚えておくこと';

  @override
  String get addReminderTooltip => 'リマインダーを追加';

  @override
  String get addReminderTitle => 'リマインダーを追加';

  @override
  String get reminderLabel => 'リマインダー';

  @override
  String get enterSomethingFirst => '内容を入力してください。';

  @override
  String get dailyProgressTitle => '今日の概要';

  @override
  String get planMetric => '優先事項';

  @override
  String get timeBoxesMetric => '時間枠';

  @override
  String get focusMetric => '完了';

  @override
  String get dailyProgressDescription => '優先事項、予定した時間枠、次の集中ブロックを確認します。';

  @override
  String get todayReviewTitle => '今日のレビュー';

  @override
  String get nextTimeBoxLabel => '次';

  @override
  String get noActiveTimeBox => '時間枠なし';

  @override
  String get noCurrentTimeBoxTitle => '現在のブロックはありません';

  @override
  String get noCurrentTimeBoxBody => '今日タブで現在の時間枠にタイムボックスを追加してください。';

  @override
  String get planCurrentSlotAction => '現在の枠を計画';

  @override
  String get currentTimeBoxRequired => '現在の時間帯のタイムボックスを先に追加してください。';

  @override
  String get noTodayBoxesProgress => '今日の時間枠はまだありません。';

  @override
  String get openFocusAction => 'Focusを開く';

  @override
  String get topPrioritiesTitle => '最優先事項';

  @override
  String get addPriorityTooltip => '優先事項を追加';

  @override
  String get noPrioritiesYet => '優先事項はまだありません';

  @override
  String get carryOverPreviousPriorities => '前回の優先事項を取り込む';

  @override
  String get carryOverPreviousBrainDump => '前回のメモを取り込む';

  @override
  String get carryOverPreviousReminders => '前回のリマインダーを取り込む';

  @override
  String get carryOverPreviousSchedule => '前回の予定を取り込む';

  @override
  String get importSelected => '選択した項目を取り込む';

  @override
  String get nothingToImport => '取り込む新しい項目がありません。';

  @override
  String get noItemsForDay => 'この日の記録はありません。';

  @override
  String get noPreviousDailyItems => '前回のデイリー項目がありません。';

  @override
  String get threePrioritiesAlreadySet => '優先事項はすでに3つ設定されています。';

  @override
  String get addPriorityTitle => '優先事項を追加';

  @override
  String get editPriorityTitle => '優先事項を編集';

  @override
  String priorityLabel(int number) {
    return '優先事項 $number';
  }

  @override
  String get clearPriority => '優先事項を消去';

  @override
  String get weekdayMonNarrow => '月';

  @override
  String get weekdayTueNarrow => '火';

  @override
  String get weekdayWedNarrow => '水';

  @override
  String get weekdayThuNarrow => '木';

  @override
  String get weekdayFriNarrow => '金';

  @override
  String get weekdaySatNarrow => '土';

  @override
  String get weekdaySunNarrow => '日';

  @override
  String get timeBoxesTitle => 'タイムボックス';

  @override
  String get timeBoxesHint => 'カードをタップして編集。長押しで移動、下のバーで長さ調整。';

  @override
  String get dragTimeBoxTooltip => 'ドラッグして移動';

  @override
  String get resizeTimeBoxTooltip => 'タップして長さ調整';

  @override
  String get resizeTimeBoxActiveTooltip => '上下にドラッグして調整';

  @override
  String get nowBadge => '現在';

  @override
  String get newTimeBoxTitle => '新しいタイムボックス';

  @override
  String get editTimeBoxTitle => 'タイムボックスを編集';

  @override
  String get titleLabel => 'タイトル';

  @override
  String timeBoxRange(String range) {
    return 'タイムボックス $range';
  }

  @override
  String get repeatTimeBoxLabel => '繰り返し';

  @override
  String get repeatNone => 'なし';

  @override
  String get repeatDaily => '毎日';

  @override
  String get repeatWeekdays => '平日';

  @override
  String get newTimeBoxDefaultTitle => '新しいタイムボックス';

  @override
  String get nativeFocusBlockTitle => '集中ブロック';

  @override
  String get nativeBreakBlockTitle => '休憩ブロック';

  @override
  String get liveActivityTopPriorityLabel => '優先';

  @override
  String get notificationFocusInProgressTitle => '集中しています';

  @override
  String get notificationShortBreakInProgressTitle => '短い休憩中';

  @override
  String get notificationLongBreakInProgressTitle => '長い休憩中';

  @override
  String get notificationRemainingTimeFormat => '残り %@';

  @override
  String get notificationFocusCompleteTitle => '集中完了';

  @override
  String get notificationBreakCompleteTitle => '休憩完了';

  @override
  String get notificationFocusCompleteBody => '次のブロックの前に少し休みましょう。';

  @override
  String get notificationBreakCompleteBody => '次の集中ブロックの準備ができました。';

  @override
  String get accountTitle => 'アカウント';

  @override
  String get authGateSubtitle => 'サインインして開始します。';

  @override
  String get firebaseSetupRequired => 'Firebase設定が必要です';

  @override
  String get firebaseSetupDescription =>
      'クラウドログインを使うにはローカルのFlutterFireファイルを生成し、iOSのURLスキームを設定してください。';

  @override
  String get signInWithAppleAction => 'Appleでサインイン';

  @override
  String get signInWithGoogleAction => 'Googleでサインイン';

  @override
  String get signInWithEmailAction => 'メールでサインイン';

  @override
  String get emailSignInTitle => 'メールサインイン';

  @override
  String get emailLabel => 'メールアドレス';

  @override
  String get passwordLabel => 'パスワード';

  @override
  String get showPasswordAction => 'パスワードを表示';

  @override
  String get hidePasswordAction => 'パスワードを非表示';

  @override
  String get emailSignInValidation => '有効なメールアドレスを入力してください。';

  @override
  String get passwordSignInValidation => 'パスワードを入力してください。';

  @override
  String get emailSignInFailed => 'メールアドレスとパスワードを確認してください。';

  @override
  String get signInAction => 'サインイン';

  @override
  String signedInAs(String label) {
    return '$labelでサインイン中';
  }

  @override
  String get appleAccountConnected => 'Appleアカウント接続済み';

  @override
  String get googleAccountConnected => 'Googleアカウント接続済み';

  @override
  String get accountConnected => 'アカウント接続済み';

  @override
  String get signOutAction => 'サインアウト';

  @override
  String get deleteAccountAction => 'アカウントを削除';

  @override
  String get deleteAccountTitle => 'アカウントを削除';

  @override
  String get deleteAccountBody =>
      'アカウントと同期済みのTimebox Markデータはすべて完全に削除されます。削除したデータは復元できません。';

  @override
  String get accountDeleted => 'アカウントを削除しました。';

  @override
  String get accountDeleteFailed => 'アカウントを削除できませんでした。再ログインしてもう一度お試しください。';

  @override
  String get legalTitle => '法的情報';

  @override
  String get privacyPolicyAction => 'プライバシーポリシー';

  @override
  String get termsAction => '利用規約';

  @override
  String get supportAction => 'サポート';

  @override
  String get linkOpenFailed => 'リンクを開けませんでした。';

  @override
  String get cancelAction => 'キャンセル';

  @override
  String get authSignInFailed => 'サインインに失敗しました。もう一度お試しください。';
}
