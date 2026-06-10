// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'WoAccount';

  @override
  String get navTransactions => '明細';

  @override
  String get navRecord => '記帳';

  @override
  String get navProfile => 'マイページ';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonConfirm => '確認';

  @override
  String get commonEditCategory => 'カテゴリを編集';

  @override
  String get commonEditAmount => '金額を編集';

  @override
  String get commonEditDescription => 'メモを編集';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '削除';

  @override
  String get chatPageTitle => 'AI記帳';

  @override
  String get chatPageVoicePlaceholder => '🎤 音声メッセージ';

  @override
  String get chatPageImagePlaceholder => '📷 画像メッセージ';

  @override
  String chatPageVoiceTranscription(String text) {
    return '🎤 音声認識結果：$text';
  }

  @override
  String chatPageImageRecognition(String text) {
    return '📷 画像認識結果：$text';
  }

  @override
  String get chatPageNoSubcategory => 'なし';

  @override
  String get chatPageConfigAiError => '設定でAIサービスを追加・設定してください';

  @override
  String chatPageParseError(String error) {
    return '❌ 解析に失敗しました：$error\n\n「昼食ラーメン25」のように具体的に入力してください';
  }

  @override
  String get chatPageNoCategoryError => '利用可能なカテゴリがありません。カテゴリ管理で追加してください';

  @override
  String chatPageSaveSuccess(
    String amount,
    String category,
    String description,
    String date,
  ) {
    return '✅ 保存しました\n$amount · $category\n$description · $date';
  }

  @override
  String chatPageSaveFailed(String error) {
    return '保存に失敗しました: $error';
  }

  @override
  String get chatPageEmptyTitle => '記帳を始めましょう';

  @override
  String get chatPageEmptyHint => '「昼食ラーメン25」や「食事24、洗濯34」のように入力してみてください';

  @override
  String get chatPageEmptyInstruction => '記帳ボタンを長押しで音声入力 🎤 · 右のボタンで写真認識 📷';

  @override
  String get chatPageAiParsing => 'AIが解析中...';

  @override
  String get chatBubbleImageFailed => '画像の読み込みに失敗しました';

  @override
  String get chatInputMicPermission => 'マイクの使用を許可してください';

  @override
  String get chatInputRecordShort => '録音時間が短すぎます';

  @override
  String chatInputImageFailed(String error) {
    return '画像の取得に失敗しました: $error';
  }

  @override
  String get chatInputCamera => '写真を撮る';

  @override
  String get chatInputGallery => 'アルバムから選択';

  @override
  String get chatInputVoiceHint => '話すのをやめて送信、左にスライドでキャンセル ↖、右にスライドで文字変換 ↗';

  @override
  String get chatInputTextHint => 'メッセージを入力...';

  @override
  String get chatConfirmTitle => 'AI解析結果';

  @override
  String get chatConfirmCategory => 'カテゴリ';

  @override
  String get chatConfirmDescription => 'メモ';

  @override
  String get chatConfirmDate => '日付';

  @override
  String get chatConfirmAmount => '金額';

  @override
  String get chatConfirmSave => '保存する';

  @override
  String get chatConfirmInputCategory => 'カテゴリ名を入力';

  @override
  String get chatConfirmInputDescription => 'メモを入力';

  @override
  String get chatConfirmInputAmount => '金額を入力';

  @override
  String get homePageAiNotConfigured => 'AIサービスが未設定です。基本ルールで解析します';

  @override
  String get homePageGoSettings => '設定へ';

  @override
  String get homePageNoContent => '内容を認識できませんでした';

  @override
  String homePageRecordFailed(String error) {
    return '記帳に失敗しました：$error';
  }

  @override
  String homePageRecordSuccess(String amount) {
    return '記帳完了：$amount';
  }

  @override
  String homePageSaveFailed(String error) {
    return '保存に失敗しました：$error';
  }

  @override
  String get homePageBudgetAlert => '本日の支出が日予算の80%を超過しています';

  @override
  String get homeInputManual => '手動入力';

  @override
  String get homeInputHint => '昼食ラーメン25円';

  @override
  String get homeInputCamera => '写真で認識';

  @override
  String get homeConfirmTitle => '🤖 AI解析結果';

  @override
  String homeConfirmOriginalInput(String input) {
    return '入力内容: $input';
  }

  @override
  String get homeConfirmAmount => '💰 金額';

  @override
  String get homeConfirmDate => '📅 日付';

  @override
  String get homeConfirmCategory => '🍜 カテゴリ';

  @override
  String get homeConfirmParseTime => '⏱️ 解析時間';

  @override
  String get homeConfirmDescription => '📝 メモ';

  @override
  String get homeConfirmConfidence => '確信度';

  @override
  String get homeConfirmEditDate => '日付を変更';

  @override
  String get homeConfirmRecord => '記帳する';

  @override
  String get homeEntryTitle => 'AIアシスタント';

  @override
  String get homeEntrySubtitle => 'スマート記帳 · 支出分析 · Q&A';

  @override
  String get homeBudgetDetails => '詳細';

  @override
  String get txnSearchHint => '明細を検索';

  @override
  String get txnBudget => '予算';

  @override
  String get txnToday => '今日';

  @override
  String get txnPeriodDay => '今日';

  @override
  String get txnPeriodWeek => '今週';

  @override
  String get txnPeriodMonth => '今月';

  @override
  String txnExpense(String period) {
    return '$periodの支出';
  }

  @override
  String txnIncome(String period) {
    return '$periodの収入';
  }

  @override
  String get txnBalance => '収支';

  @override
  String get txnSortByTime => '時刻順';

  @override
  String get txnSortByAmount => '金額順';

  @override
  String get txnEmpty => '明細がありません';

  @override
  String get txnDayDetailEmpty => 'この日の明細はありません';

  @override
  String get txnDayFormat => 'M月d日';

  @override
  String get txnMonthFormat => 'yyyy年M月';

  @override
  String txnGroupExpenseLabel(String amount) {
    return '支出 $amount';
  }

  @override
  String txnGroupIncomeLabel(String amount) {
    return '収入 $amount';
  }

  @override
  String get txnGroupUncategorized => 'カテゴリなし';

  @override
  String get txnGroupNoSubcategory => 'なし';

  @override
  String get viewDay => '日';

  @override
  String get viewWeek => '週';

  @override
  String get viewMonth => '月';

  @override
  String get txnDetailTitle => '明細詳細';

  @override
  String get txnDetailSaved => '保存済み';

  @override
  String get txnDetailDeleteConfirmTitle => '削除の確認';

  @override
  String get txnDetailDeleteConfirmContent => '削除すると元に戻せません。この明細を削除しますか？';

  @override
  String get txnDetailNotFound => '明細が見つかりません';

  @override
  String get txnDetailUncategorized => 'カテゴリなし';

  @override
  String get txnDetailCategory => 'カテゴリ';

  @override
  String get txnDetailAmount => '金額';

  @override
  String get txnDetailDate => '日付';

  @override
  String get txnDetailNote => 'メモ';

  @override
  String get txnDetailAddNoteHint => 'タップしてメモを追加';

  @override
  String get txnDetailAiRecord => 'AI解析記録';

  @override
  String get txnDetailOriginalInput => '入力内容';

  @override
  String get txnDetailParseSource => '解析元';

  @override
  String get txnDetailConfidence => '確信度';

  @override
  String get txnDetailCreatedAt => '作成日時';

  @override
  String get entryTitle => '記帳';

  @override
  String get entryBookType => '日常記帳';

  @override
  String get entryExpense => '支出';

  @override
  String get entryIncome => '収入';

  @override
  String get entryOther => 'その他';

  @override
  String entrySubCategoryTitle(String name) {
    return '$name - サブカテゴリ';
  }

  @override
  String get entryNoteHint => 'メモを追加...';

  @override
  String get entryNumpadToday => '今日';

  @override
  String get entryNumpadDelete => '削除';

  @override
  String get entryNumpadDone => '完了';

  @override
  String entrySuccess(String amount) {
    return '記帳完了：$amount';
  }

  @override
  String entryFailure(String error) {
    return '記帳に失敗しました：$error';
  }

  @override
  String get profileCheckedIn => 'チェックイン済み';

  @override
  String get profileCheckIn => 'チェックイン';

  @override
  String get profileConsecutiveDays => '連続チェックイン';

  @override
  String get profileTotalCheckInDays => '累計チェックイン日数';

  @override
  String get profileTotalTransactions => '累計記帳件数';

  @override
  String get profileFuncTheme => 'テーマ切替';

  @override
  String get profileFuncAccountBooks => 'マイ家計簿';

  @override
  String get profileFuncBudget => '予算管理';

  @override
  String get profileFuncCategories => 'カテゴリ管理';

  @override
  String get profileFuncReports => 'レポート分析';

  @override
  String get profileToolsAndServices => 'ツールとサービス';

  @override
  String get profileMenuPasswordLock => 'パスワードロック';

  @override
  String get profileMenuAcCoins => 'ACコイン';

  @override
  String get profileMenuAiConfig => 'AI設定';

  @override
  String get profileMenuDataBackup => 'データバックアップ';

  @override
  String get profileMenuImport => '明細インポート';

  @override
  String get profileMenuExport => '明細エクスポート';

  @override
  String get profileMenuFeedback => 'フィードバック';

  @override
  String get profileMenuSettings => '設定';

  @override
  String profileFeatureComingSoon(String label) {
    return '$label機能は近日公開予定です';
  }

  @override
  String get profileAlreadyCheckedIn => '本日はチェックイン済みです';

  @override
  String get profileCheckInSuccess => 'チェックイン成功！';

  @override
  String profileCheckInFailure(String error) {
    return 'チェックインに失敗しました: $error';
  }

  @override
  String get profileThemeLight => 'ライトモード';

  @override
  String get profileThemeDark => 'ダークモード';

  @override
  String get profileThemeSystem => 'システム設定に従う';

  @override
  String profileUserId(String uid) {
    return 'ID: $uid';
  }

  @override
  String get profileEditTitle => 'プロフィール';

  @override
  String get profileEditNickname => 'ニックネーム';

  @override
  String get profileEditId => 'ID';

  @override
  String get profileEditGender => '性別';

  @override
  String get profileEditEmail => 'メールアドレス';

  @override
  String get profileEditPhone => '電話番号';

  @override
  String get profileEditNotSet => '未設定';

  @override
  String get profileEditNotFound => 'ユーザープロフィールが見つかりません';

  @override
  String get profileEditGenderMale => '男性';

  @override
  String get profileEditGenderFemale => '女性';

  @override
  String get profileEditGenderSecret => '非公開';

  @override
  String get profileEditLogout => 'ログアウト';

  @override
  String get profileEditLogoutConfirmContent => 'ログアウトしますか？';

  @override
  String get profileEditLogoutExit => 'ログアウト';

  @override
  String get profileEditLogoutComingSoon => 'ログアウト機能は近日改善予定です';

  @override
  String get profileEditDeleteAccount => 'アカウント削除申請';

  @override
  String get profileEditDeleteAccountConfirmContent =>
      'アカウントを削除するとデータは復元できません。削除を申請しますか？';

  @override
  String get profileEditDeleteAccountSubmit => '削除を申請';

  @override
  String get profileEditDeleteAccountSubmitted => '削除申請を送信しました';

  @override
  String get settingsTitle => 'システム設定';

  @override
  String get settingsGeneral => '一般';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsDarkMode => 'ダークモード';

  @override
  String get settingsCurrency => '通貨';

  @override
  String get settingsData => 'データ';

  @override
  String get settingsAutoBackup => '自動バックアップ';

  @override
  String get settingsBackupFrequency => 'バックアップ頻度';

  @override
  String get settingsBackupDaily => '毎日';

  @override
  String get settingsRestoreData => 'データ復元';

  @override
  String get settingsAbout => 'アプリについて';

  @override
  String get settingsDangerZone => '危険ゾーン';

  @override
  String get settingsClearData => '全データを削除';

  @override
  String get settingsClearConfirm => 'この操作は元に戻せません。全データを削除しますか？';

  @override
  String get settingsDeleteAccount => 'アカウント削除';

  @override
  String get settingsDeleteConfirm => '削除後、全データが完全に消去されます。続行しますか？';

  @override
  String get budgetTitle => '予算管理';

  @override
  String get budgetEmpty => '予算が設定されていません';

  @override
  String get budgetSetButton => '予算を設定';

  @override
  String get budgetSettingTitle => '予算設定';

  @override
  String get budgetMonthlyTotal => '今月の予算合計';

  @override
  String budgetSpent(String amount) {
    return '使用済み $amount';
  }

  @override
  String budgetRemaining(String amount) {
    return '残り $amount';
  }

  @override
  String budgetOverSpent(String category, String amount) {
    return '$categoryの予算を $amount 超過しています';
  }

  @override
  String get budgetUnknownCategory => 'カテゴリ';

  @override
  String get budgetUncategorized => 'カテゴリなし';

  @override
  String budgetUsedPercent(String percent) {
    return '$percent% 使用済み';
  }

  @override
  String budgetCategoryCount(String count) {
    return '$count 個のカテゴリ予算を設定済み';
  }

  @override
  String get budgetAddCategoryBudget => 'カテゴリ予算を追加';

  @override
  String get budgetAddCategoryBudgetDeveloping => 'カテゴリ予算追加機能は開発中です';

  @override
  String get budgetEditBudgetDeveloping => '予算編集機能は開発中です';

  @override
  String get bookTitle => 'マイ家計簿';

  @override
  String get bookCreate => '新しい家計簿';

  @override
  String get bookDescription => '各家計簿には独立した取引記録・予算・AI会話履歴があります';

  @override
  String get bookDefault => 'デフォルト';

  @override
  String get bookMonthlyExpense => '今月の支出';

  @override
  String get bookMonthlyIncome => '今月の収入';

  @override
  String get bookTransactionCount => '件数';

  @override
  String get bookSetDefault => 'デフォルトに設定';

  @override
  String get bookDelete => '削除';

  @override
  String bookSwitchedTo(String name) {
    return '$name に切り替えました';
  }

  @override
  String get bookDeleteTitle => '家計簿を削除';

  @override
  String bookDeleteConfirm(String name) {
    return '「$name」を削除しますか？\n\nこの家計簿のすべての取引記録・予算・会話履歴が削除されます。この操作は元に戻せません。';
  }

  @override
  String get bookDeleted => '家計簿を削除しました';

  @override
  String bookCountUnit(String count) {
    return '$count件';
  }

  @override
  String get bookTypePersonal => '個人';

  @override
  String get bookTypeFamily => '家族';

  @override
  String get bookTypeTravel => '旅行';

  @override
  String get bookTypeBusiness => 'ビジネス';

  @override
  String get bookTypeOther => 'その他';

  @override
  String get bookDetailTitle => '家計簿の詳細';

  @override
  String get bookDetailNotExist => '家計簿が存在しません';

  @override
  String get bookDetailExpenseCount => '取引件数';

  @override
  String get bookDetailNormalSection => '通常操作';

  @override
  String get bookDetailSetDefault => 'デフォルト家計簿に設定';

  @override
  String get bookDetailSwitchTo => 'この家計簿に切替';

  @override
  String get bookDetailDangerSection => '注意が必要な操作';

  @override
  String get bookDetailClearData => '家計簿データを消去';

  @override
  String get bookDetailDefaultNotDeletable => 'デフォルト家計簿は削除できません';

  @override
  String get bookDetailSetDefaultSuccess => 'デフォルト家計簿に設定しました';

  @override
  String get bookDetailClearTitle => 'データ消去';

  @override
  String bookDetailClearConfirm(String name) {
    return '「$name」のすべての取引記録と会話履歴を消去しますか？\n\nこの操作は元に戻せません。';
  }

  @override
  String get bookDetailClear => '消去';

  @override
  String get bookDetailCleared => 'データを消去しました';

  @override
  String bookDetailDeleteConfirm(String name) {
    return '「$name」を削除しますか？\n\nこの家計簿のすべてのデータが削除されます。この操作は元に戻せません。';
  }

  @override
  String get bookDetailTypePersonal => '個人家計簿';

  @override
  String get bookDetailTypeFamily => '家族家計簿';

  @override
  String get bookDetailTypeTravel => '旅行家計簿';

  @override
  String get bookDetailTypeBusiness => 'ビジネス家計簿';

  @override
  String get bookDetailTypeOther => 'その他';

  @override
  String get reportTitle => 'レポート分析';

  @override
  String get reportPeriodWeek => '週';

  @override
  String get reportPeriodMonth => '月';

  @override
  String get reportPeriodYear => '年';

  @override
  String get reportTypeExpense => '支出';

  @override
  String get reportTypeIncome => '収入';

  @override
  String get reportTotalExpense => '支出合計';

  @override
  String get reportTotalIncome => '収入合計';

  @override
  String get reportCount => '件数';

  @override
  String reportCountUnit(String count) {
    return '$count件';
  }

  @override
  String get reportDailyAverage => '日平均';

  @override
  String get reportCategoryCount => 'カテゴリ数';

  @override
  String reportCategoryCountUnit(String count) {
    return '$count個';
  }

  @override
  String get reportCategoryDistribution => 'カテゴリ別構成比';

  @override
  String get reportCategoryRanking => 'カテゴリ別ランキング';

  @override
  String get reportNoData => 'データがありません';

  @override
  String reportMonthLabel(String year, String month) {
    return '$year年$month月';
  }

  @override
  String reportYearLabel(String year) {
    return '$year年';
  }

  @override
  String reportWeekLabel(String start, String end) {
    return '$start - $end';
  }

  @override
  String get securityLockSettings => 'パスワードロック設定';

  @override
  String get securityEnableLock => 'パスワードロックを有効化';

  @override
  String get securityUnlockMethods => 'ロック解除方法（複数選択可）';

  @override
  String get securityPinCode => 'PINコード';

  @override
  String get securityPinCodeDesc => '4桁のPINコードでロック解除';

  @override
  String get securityBiometric => '指紋認証';

  @override
  String get securityBiometricDesc => 'デバイスの指紋で素早くロック解除';

  @override
  String get securityPatternLock => 'パターンロック';

  @override
  String get securityPatternLockDesc => 'パターンを描いてロック解除';

  @override
  String get securityLockHint =>
      '複数のロック解除方法を選択すると、ロック画面に切り替えボタンが表示されます。指紋認証にはデバイスの生体認証機能が必要です。';

  @override
  String get securityBiometricVerify => '指紋を確認して指紋認証を有効化';

  @override
  String securityBiometricFail(String error) {
    return '指紋認証に失敗しました: $error';
  }

  @override
  String get securitySetPinLock => 'PINロックを設定';

  @override
  String get securitySetPinTitle => '4桁のPINコードを設定';

  @override
  String get securityConfirmPinTitle => '新しいPINコードを再入力してください';

  @override
  String get securityEnterPin => 'PINコードを入力してロック解除';

  @override
  String get securityPinWrong => 'PINコードが間違っています。再試行してください';

  @override
  String get securityPinMismatch => '入力が一致しません。最初からやり直してください';

  @override
  String get securityPinSetSuccess => 'PINコードの設定が完了しました';

  @override
  String get securitySetPatternLock => 'パターンロックを設定';

  @override
  String get securityDrawPattern => 'パターンを描いてロック解除';

  @override
  String get securityConfirmPattern => '同じパターンをもう一度描いてください';

  @override
  String get securityDrawToUnlock => 'パターンを描いてロック解除';

  @override
  String get securityPatternHint => '4つ以上の点を結んでください';

  @override
  String get securityConfirmPatternHint => '先ほどと同じパターンを描いてください';

  @override
  String get securityRedraw => 'やり直す';

  @override
  String get securityPatternMinDots => '少なくとも4つの点を結んでください';

  @override
  String get securityPatternMismatch => 'パターンが一致しません。最初からやり直してください';

  @override
  String get securityPatternSetSuccess => 'パターンの設定が完了しました';

  @override
  String get securityPatternWrong => 'パターンが間違っています。再試行してください';

  @override
  String get securityAuthRequired => '本人確認をしてアプリをロック解除してください';

  @override
  String get securitySelectUnlockMethod => 'ロック解除方法を選択';

  @override
  String get securitySwitchUnlockMethod => 'ロック解除方法を切替';

  @override
  String get securityVerifyFingerprint => '指紋を確認してください';

  @override
  String get securityTouchToUnlock => '指紋センサーに触れてアプリをロック解除';

  @override
  String get securityRetryFingerprint => '指紋を再試行';

  @override
  String get checkinTitle => 'チェックインカレンダー';

  @override
  String get checkinAlreadyCheckedIn => '本日はチェックイン済みです';

  @override
  String get checkinCheckInSuccess => 'チェックイン成功！+10 ACコイン';

  @override
  String get checkinRewardDaily => '毎日のチェックイン報酬';

  @override
  String get checkinStreak365 => '1年連続チェックイン！+2000 ACコイン';

  @override
  String get checkinStreak180 => '半年連続チェックイン！+1000 ACコイン';

  @override
  String get checkinStreak30 => '1ヶ月連続チェックイン！+300 ACコイン';

  @override
  String get checkinStreak7 => '7日連続チェックイン！+70 ACコイン';

  @override
  String get checkinReward365 => '365日連続チェックイン報酬';

  @override
  String get checkinReward180 => '180日連続チェックイン報酬';

  @override
  String get checkinReward30 => '30日連続チェックイン報酬';

  @override
  String get checkinReward7 => '7日連続チェックイン報酬';

  @override
  String get checkinMakeupSelectHint => 'チェックインしていない日付を選択してください';

  @override
  String get checkinMakeupFutureError => '過去の日付のみ補填できます';

  @override
  String get checkinMakeupAlreadyChecked => 'この日付はチェックイン済みです';

  @override
  String get checkinMakeupInsufficient => 'ACコインが不足しています。補填には100 ACコインが必要です';

  @override
  String get checkinMakeupConfirmTitle => '補填の確認';

  @override
  String checkinMakeupConfirmContent(String date, String balance) {
    return '$date を補填しますか？\n100 ACコインを消費します（現在の残高: $balance）';
  }

  @override
  String get checkinMakeupConfirm => '補填する';

  @override
  String get checkinMakeupSuccess => '補填が完了しました！';

  @override
  String checkinMakeupCost(String date) {
    return '$date を補填';
  }

  @override
  String get checkinConsecutiveDays => '連続チェックイン';

  @override
  String get checkinAcBalance => 'ACコイン残高';

  @override
  String get checkinTodayStatus => '今日の状態';

  @override
  String get checkinMakeupButton => '補填 (-100 ACコイン)';

  @override
  String get checkinMakeupSelectButton => '日付を選択して補填';

  @override
  String get checkinTodayCheckIn => 'チェックイン済み';

  @override
  String get checkinTodayCheckInButton => 'チェックイン +10';

  @override
  String get acCoinTitle => 'ACコイン履歴';

  @override
  String get acCoinCurrentBalance => '現在の残高';

  @override
  String get acCoinEmpty => 'ACコインの履歴がありません';

  @override
  String get catExpenseFood => '飲食';

  @override
  String get catExpenseTransport => '交通';

  @override
  String get catExpenseHousing => '住居';

  @override
  String get catExpenseClothing => '美容・衣類';

  @override
  String get catExpenseDaily => '日用品';

  @override
  String get catExpenseTech => 'デジタル機器';

  @override
  String get catExpenseMedical => '医療・健康';

  @override
  String get catExpenseEducation => '教育';

  @override
  String get catExpenseEntertainment => 'レジャー';

  @override
  String get catExpenseSocial => '交際費';

  @override
  String get catExpenseChildren => '子育て';

  @override
  String get catExpenseElderly => '親の介護';

  @override
  String get catExpensePet => 'ペット';

  @override
  String get catExpenseWork => '仕事・オフィス';

  @override
  String get catExpenseFinance => '金融・保険';

  @override
  String get catExpenseOther => 'その他支出';

  @override
  String get catIncomeSalary => '給与';

  @override
  String get catIncomeInvestment => '投資';

  @override
  String get catIncomeSideJob => '副業';

  @override
  String get catIncomeGift => 'お祝い金';

  @override
  String get catIncomeRefund => '払い戻し';

  @override
  String get catIncomeAsset => '賃貸・資産';

  @override
  String get catIncomeTransferIn => '振込受入';

  @override
  String get catIncomeOther => 'その他収入';

  @override
  String get catOtherTransfer => '振替';

  @override
  String get catOtherRepayment => '返済';

  @override
  String get catOtherSocial => '冠婚葬祭';

  @override
  String get weekMon => '月';

  @override
  String get weekTue => '火';

  @override
  String get weekWed => '水';

  @override
  String get weekThu => '木';

  @override
  String get weekFri => '金';

  @override
  String get weekSat => '土';

  @override
  String get weekSun => '日';

  @override
  String get weekMonFull => '月曜';

  @override
  String get weekTueFull => '火曜';

  @override
  String get weekWedFull => '水曜';

  @override
  String get weekThuFull => '木曜';

  @override
  String get weekFriFull => '金曜';

  @override
  String get weekSatFull => '土曜';

  @override
  String get weekSunFull => '日曜';

  @override
  String get commonSelectDateTime => '日時を選択';

  @override
  String get commonBack => '戻る';

  @override
  String get commonDone => '完了';

  @override
  String get commonAdd => '追加';

  @override
  String commonEnterHint(String field) {
    return '$fieldを入力';
  }

  @override
  String get txnCategorySearch => 'カテゴリを検索...';

  @override
  String get txnCategoryEmpty => 'カテゴリなし';

  @override
  String get settingsSelectLanguage => '言語を選択';

  @override
  String get settingsSelectCurrency => '通貨を選択';

  @override
  String get profileDefaultNickname => 'ユーザー';

  @override
  String get catManageTitle => 'カテゴリ管理';

  @override
  String catManageSubTitle(String name) {
    return '$name - サブカテゴリ';
  }

  @override
  String get catManageAddSub => 'サブカテゴリ追加';

  @override
  String get catManageNameExists => 'カテゴリ名は既に存在します';

  @override
  String get catManageSubNameExists => 'サブカテゴリ名は既に存在します';

  @override
  String get catManageDeleteTitle => '削除確認';

  @override
  String catManageDeleteWithChildren(String name) {
    return 'カテゴリ「$name」とそのサブカテゴリをすべて削除しますか？';
  }

  @override
  String catManageDeleteConfirm(String name) {
    return 'カテゴリ「$name」を削除しますか？';
  }

  @override
  String get catManageDeleteBlocked => 'このカテゴリには関連データがあるため削除できません';

  @override
  String get catManageCustomBadge => '自';

  @override
  String get catManageCustom => 'カスタム';

  @override
  String catManageAddTitle(String type) {
    return '$typeカテゴリ追加';
  }

  @override
  String get catManageNameLabel => 'カテゴリ名';

  @override
  String get catManageNameHint => 'カテゴリ名を入力';

  @override
  String get catManageSelectIcon => 'アイコン選択';

  @override
  String get catManageSelectColor => '色選択';

  @override
  String catManageAddSubTitle(String name) {
    return 'サブカテゴリ追加 - $name';
  }

  @override
  String get catManageSubNameLabel => 'サブカテゴリ名';

  @override
  String get catManageSubNameHint => 'サブカテゴリ名を入力';

  @override
  String get catManageEditTitle => 'カテゴリ編集';

  @override
  String get bookNameLabel => '帳簿名';

  @override
  String get bookNameHint => '例：日常支出';

  @override
  String get bookTypeLabel => '帳簿タイプ';

  @override
  String get bookDescLabel => 'メモ（任意）';

  @override
  String get bookDescHint => '帳簿の用途を簡単に説明';

  @override
  String get bookCreateButton => '作成';

  @override
  String get bookDescPersonal => '日常の個人支出';

  @override
  String get bookDescFamily => '家庭の共通支出';

  @override
  String get bookDescTravel => '旅行費用の記録';

  @override
  String get bookDescBusiness => '副業の収支';

  @override
  String get bookDescOther => 'カスタム用途';
}
