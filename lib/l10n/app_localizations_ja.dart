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
  String get commonEdit => '編集';

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
  String get chatPageSaveSuccessTitle => '記帳成功';

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
  String get chatInputListening => '正在聆听...';

  @override
  String get chatInputRecording => '正在录音...';

  @override
  String get chatInputVoiceCancel => '← 松手取消';

  @override
  String get chatInputVoiceSend => '松开发送';

  @override
  String get chatInputVoiceCanceling => '松手取消';

  @override
  String get voiceOverlaySwipeHint => '↑ スワイプでキャンセルまたは文字変換';

  @override
  String get voiceOverlayCancelLabel => '離して キャンセル';

  @override
  String get voiceOverlayTranscribeLabel => '離して 文字変換のみ';

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
  String get chatDeleteTitle => '会話をクリア';

  @override
  String get chatDeleteMessage => 'すべての会話履歴をクリアしますか？この操作は元に戻せません。';

  @override
  String get chatDeleteSuccess => '会話履歴をクリアしました';

  @override
  String chatMultiSelectCount(String count) {
    return '$count件選択中';
  }

  @override
  String get chatDeleteSelected => '選択を削除';

  @override
  String chatDeleteSelectedConfirm(String count) {
    return '選択した$count件のメッセージを削除しますか？';
  }

  @override
  String get chatActionCopy => 'コピー';

  @override
  String get chatActionDelete => 'メッセージを削除';

  @override
  String get chatDeleteMsgConfirm => 'このメッセージを削除しますか？';

  @override
  String get chatCopyMessage => 'クリップボードにコピーしました';

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
  String get homeInputSubmit => '送信';

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
  String get txnDayFormat => 'yyyy年M月d日';

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
  String get txnDetailPayMethod => '支払方法';

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
  String get entrySelectCategoryHint => 'カテゴリを選択';

  @override
  String get entrySelectThisCategory => 'このカテゴリを選択';

  @override
  String get entryNoSubCategory => 'サブカテゴリなし';

  @override
  String get payMethodDefault => 'デフォルト';

  @override
  String get payMethodCash => '現金';

  @override
  String get payMethodWechat => 'WeChat';

  @override
  String get payMethodAlipay => 'Alipay';

  @override
  String get payMethodCard => 'カード';

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
  String get profileBackupShareText => 'WoAccount データバックアップ';

  @override
  String get profileBackupSuccess => 'バックアップ成功';

  @override
  String profileBackupFailed(String error) {
    return 'バックアップ失敗: $error';
  }

  @override
  String get profileExportShareText => 'WoAccount データエクスポート';

  @override
  String get profileExportSuccess => 'エクスポート成功';

  @override
  String profileExportFailed(String error) {
    return 'エクスポート失敗: $error';
  }

  @override
  String get profileImportConfirm => 'インポートすると現在のデータが上書きされます。続行しますか？';

  @override
  String get profileImportNoBackup => 'バックアップファイルが見つかりません';

  @override
  String get profileImportSuccess => 'インポート成功';

  @override
  String profileImportFailed(String error) {
    return 'インポート失敗: $error';
  }

  @override
  String get profileExportExcel => 'Excel エクスポート';

  @override
  String get profileImportExcel => 'Excel インポート';

  @override
  String get profileExcelFormatTitle => 'Excel 形式';

  @override
  String profileImportExcelSuccess(int count) {
    return '$count 件のレコードをインポートしました';
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
  String get settingsBackupWeekly => '毎週';

  @override
  String get settingsBackupMonthly => '毎月';

  @override
  String get settingsBackupManual => '手動のみ';

  @override
  String get settingsNoBackupFound => 'バックアップファイルが見つかりません';

  @override
  String get settingsRestoreData => 'データ復元';

  @override
  String get settingsRestoreConfirm => '復元すると現在のデータが上書きされます。続行しますか？';

  @override
  String get settingsRestoreSuccess => 'データの復元に成功しました';

  @override
  String settingsRestoreFailed(String error) {
    return '復元失敗: $error';
  }

  @override
  String get settingsAbout => 'アプリについて';

  @override
  String get settingsDangerZone => '危険ゾーン';

  @override
  String get settingsClearData => '全データを削除';

  @override
  String get settingsClearConfirm => 'この操作は元に戻せません。全データを削除しますか？';

  @override
  String get settingsClearDataSuccess => 'データを削除しました';

  @override
  String get settingsDeleteAccount => 'アカウント削除';

  @override
  String get settingsDeleteConfirm => '削除後、全データが完全に消去されます。続行しますか？';

  @override
  String get settingsDeleteAccountSuccess => 'アカウントデータを削除しました';

  @override
  String get budgetTitle => '予算管理';

  @override
  String get budgetViewMonth => '月';

  @override
  String get budgetViewYear => '年';

  @override
  String budgetYearLabel(String year) {
    return '$year年';
  }

  @override
  String get budgetYearTotal => '年間予算合計';

  @override
  String budgetMonthCount(String count) {
    return '$countヶ月分の予算';
  }

  @override
  String budgetMonthShort(String month) {
    return '$month月';
  }

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
  String get budgetSetTotalTitle => '合計予算を設定';

  @override
  String get budgetEditTotalTitle => '合計予算を編集';

  @override
  String get budgetEditCategoryTitle => 'カテゴリ予算を編集';

  @override
  String get budgetInputAmount => '予算金額を入力';

  @override
  String get budgetSelectCategory => 'カテゴリを選択';

  @override
  String get budgetNoCategoryAvailable => '利用可能なカテゴリがありません';

  @override
  String get budgetCategoryAlreadyExists => 'このカテゴリの予算は既に存在します';

  @override
  String get budgetDeleteTitle => '予算を削除';

  @override
  String get budgetDeleteConfirm => 'このカテゴリの予算を削除しますか？';

  @override
  String get budgetNoBudgets => '予算が未設定です。右上の編集ボタンから開始';

  @override
  String get bookTitle => 'マイ家計簿';

  @override
  String get bookCreate => '新しい家計簿';

  @override
  String get bookDescription => '各家計簿には独立した取引記録・予算・AI会話履歴があります';

  @override
  String get bookDefault => 'デフォルト';

  @override
  String get bookCurrent => '現在';

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
  String get bookDeleted => '家計簿をごみ箱に移動しました';

  @override
  String get bookRecycleBin => '家計簿ごみ箱';

  @override
  String get bookRecycleBinEmpty => 'ごみ箱は空です';

  @override
  String get bookRestore => '復元';

  @override
  String get bookRestored => '家計簿を復元しました';

  @override
  String get txnRecycleBin => '取引ゴミ箱';

  @override
  String get txnRecycleBinEmpty => 'ゴミ箱は空です';

  @override
  String get txnRestore => '復元';

  @override
  String get txnRestored => '取引を復元しました';

  @override
  String get txnRecycleSelectAll => 'すべて選択';

  @override
  String get txnRecycleDeselectAll => 'キャンセル';

  @override
  String txnRecycleSelected(int count) {
    return '$count 件選択中';
  }

  @override
  String get txnRecyclePermanentDelete => '完全に削除';

  @override
  String get txnRecyclePermanentDeleteConfirm =>
      '選択した取引を完全に削除しますか？この操作は元に戻せません。';

  @override
  String txnRecycleBatchRestored(int count) {
    return '$count 件の取引を復元しました';
  }

  @override
  String txnRecycleBatchDeleted(int count) {
    return '$count 件の取引を完全に削除しました';
  }

  @override
  String get txnRecycleSortByDeleteTime => '削除日時';

  @override
  String get txnRecycleSortByAmount => '金額';

  @override
  String get txnRecycleSortByDate => '取引日';

  @override
  String get txnRecycleGroupToday => '今日';

  @override
  String get txnRecycleGroupWeek => '今週';

  @override
  String get txnRecycleGroupEarlier => 'それ以前';

  @override
  String get txnRecycleFilterAll => 'すべて';

  @override
  String get txnRecycleFilterExpense => '支出';

  @override
  String get txnRecycleFilterIncome => '収入';

  @override
  String get bookPermanentDelete => '完全に削除';

  @override
  String bookPermanentDeleteConfirm(String name) {
    return '「$name」を完全に削除しますか？\nすべてのデータが削除されます。この操作は元に戻せません。';
  }

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
  String get bookTypeCouple => 'カップル';

  @override
  String get bookTypeStudent => '学生';

  @override
  String get bookTypeWedding => '結婚式';

  @override
  String get bookTypeRental => '賃貸';

  @override
  String get bookTypeInvestment => '投資';

  @override
  String get bookTypePet => 'ペット';

  @override
  String get bookTypeHealth => '医療';

  @override
  String get bookTypeEvent => 'イベント';

  @override
  String get bookTypeOther => 'その他';

  @override
  String get bookTypeCustom => 'カスタム';

  @override
  String get bookTypeCustomHint => 'カスタムタイプを入力';

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
  String get bookDetailDefaultNotDeletable => '現在の家計簿は削除できません';

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
    return '「$name」を削除しますか？\n\nごみ箱に移動されます。データは失われません。';
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
  String get catSubFoodBreakfast => '朝食';

  @override
  String get catSubFoodLunch => '昼食';

  @override
  String get catSubFoodDinner => '夕食';

  @override
  String get catSubFoodLateSnack => '夜食';

  @override
  String get catSubFoodDelivery => 'デリバリー';

  @override
  String get catSubFoodMilkTea => 'ミルクティー';

  @override
  String get catSubFoodCoffee => 'コーヒー';

  @override
  String get catSubFoodDrinks => '飲料';

  @override
  String get catSubFoodDessert => 'デザート';

  @override
  String get catSubFoodSnacks => 'お菓子';

  @override
  String get catSubFoodFruit => '果物';

  @override
  String get catSubFoodGroceries => '食料品';

  @override
  String get catSubFoodDiningOut => '外食';

  @override
  String get catSubTransportMetro => '地下鉄';

  @override
  String get catSubTransportBus => 'バス';

  @override
  String get catSubTransportTaxi => 'タクシー';

  @override
  String get catSubTransportRideshare => 'ライドシェア';

  @override
  String get catSubTransportBikeShare => 'シェアサイクル';

  @override
  String get catSubTransportHighSpeedRail => '新幹線';

  @override
  String get catSubTransportTrain => '電車';

  @override
  String get catSubTransportFlight => '飛行機';

  @override
  String get catSubTransportFuel => 'ガソリン';

  @override
  String get catSubTransportCharging => '充電';

  @override
  String get catSubTransportParking => '駐車場代';

  @override
  String get catSubTransportToll => '高速代';

  @override
  String get catSubTransportMaintenance => '車検・メンテ';

  @override
  String get catSubTransportRepair => '車の修理';

  @override
  String get catSubTransportInsurance => '自動車保険';

  @override
  String get catSubHousingRent => '家賃';

  @override
  String get catSubHousingMortgage => '住宅ローン';

  @override
  String get catSubHousingWater => '水道代';

  @override
  String get catSubHousingElectricity => '電気代';

  @override
  String get catSubHousingGas => 'ガス代';

  @override
  String get catSubHousingPropertyFee => '管理費';

  @override
  String get catSubHousingInternet => 'インターネット';

  @override
  String get catSubHousingPhone => '携帯電話';

  @override
  String get catSubHousingCleaning => 'ハウスクリーニング';

  @override
  String get catSubHousingRepair => '住宅修繕';

  @override
  String get catSubClothingApparel => '衣類';

  @override
  String get catSubClothingShoes => '靴';

  @override
  String get catSubClothingHats => '帽子';

  @override
  String get catSubClothingBags => 'バッグ';

  @override
  String get catSubClothingCosmetics => '化粧品';

  @override
  String get catSubClothingSkincare => 'スキンケア';

  @override
  String get catSubClothingHaircut => '美容院';

  @override
  String get catSubClothingManicure => 'ネイル';

  @override
  String get catSubClothingJewelry => 'アクセサリー';

  @override
  String get catSubClothingAccessories => '小物';

  @override
  String get catSubDailyNecessities => '日用品';

  @override
  String get catSubDailyCleaning => '洗剤類';

  @override
  String get catSubDailyKitchen => '台所用品';

  @override
  String get catSubDailyDecor => 'インテリア';

  @override
  String get catSubDailyStorage => '収納用品';

  @override
  String get catSubDailyBedding => '寝具';

  @override
  String get catSubDailyTissue => 'ティッシュ類';

  @override
  String get catSubTechPhone => 'スマートフォン';

  @override
  String get catSubTechComputer => 'パソコン';

  @override
  String get catSubTechAccessories => '周辺機器';

  @override
  String get catSubTechConsumables => '消耗品';

  @override
  String get catSubTechStorage => '記憶装置';

  @override
  String get catSubMedicalRegistration => '受付・診察';

  @override
  String get catSubMedicalMedicine => '医薬品';

  @override
  String get catSubMedicalHospitalization => '入院';

  @override
  String get catSubMedicalCheckup => '健康診断';

  @override
  String get catSubMedicalDental => '歯科';

  @override
  String get catSubMedicalEyeCare => '眼科';

  @override
  String get catSubMedicalVaccine => 'ワクチン';

  @override
  String get catSubMedicalWellness => '健康・サプリ';

  @override
  String get catSubMedicalFitness => 'フィットネス';

  @override
  String get catSubEducationBooks => '書籍';

  @override
  String get catSubEducationTuition => '学費';

  @override
  String get catSubEducationTraining => '研修費';

  @override
  String get catSubEducationExam => '受験料';

  @override
  String get catSubEducationOnlineCourse => 'オンライン講座';

  @override
  String get catSubEducationStationery => '文房具';

  @override
  String get catSubEntertainmentMovies => '映画';

  @override
  String get catSubEntertainmentKtv => 'カラオケ';

  @override
  String get catSubEntertainmentGaming => 'ゲーム課金';

  @override
  String get catSubEntertainmentSubscription => 'サブスク';

  @override
  String get catSubEntertainmentTickets => '入園料';

  @override
  String get catSubEntertainmentHotel => 'ホテル';

  @override
  String get catSubEntertainmentTravel => '旅行';

  @override
  String get catSubEntertainmentShow => 'ライブ・公演';

  @override
  String get catSubEntertainmentStreaming => '動画配信';

  @override
  String get catSubSocialGift => 'プレゼント';

  @override
  String get catSubSocialRedPacket => 'お年玉';

  @override
  String get catSubSocialWeddingGift => '祝儀・香典';

  @override
  String get catSubSocialTreat => 'おごり';

  @override
  String get catSubSocialBirthday => '誕生会';

  @override
  String get catSubSocialVisit => 'お見舞い';

  @override
  String get catSubSocialRespect => '親孝行';

  @override
  String get catSubSocialCharity => '寄付';

  @override
  String get catSubChildrenFormula => '粉ミルク・離乳食';

  @override
  String get catSubChildrenDiapers => 'おむつ用品';

  @override
  String get catSubChildrenTuition => '学費';

  @override
  String get catSubChildrenHobby => '習い事';

  @override
  String get catSubChildrenTutoring => '塾・予備校';

  @override
  String get catSubChildrenDaycare => '保育園';

  @override
  String get catSubChildrenToys => 'おもちゃ';

  @override
  String get catSubElderlySupport => '仕送り';

  @override
  String get catSubElderlyNutrition => '栄養補助食品';

  @override
  String get catSubElderlyMedical => '医療費';

  @override
  String get catSubElderlyAllowance => 'お小遣い';

  @override
  String get catSubPetFood => 'ペットフード';

  @override
  String get catSubPetMedical => 'ペット医療';

  @override
  String get catSubPetSupplies => 'ペット用品';

  @override
  String get catSubPetGrooming => 'トリミング';

  @override
  String get catSubWorkOffice => '事務用品';

  @override
  String get catSubWorkPrinting => 'コピー・印刷';

  @override
  String get catSubWorkShipping => '郵送・配達';

  @override
  String get catSubWorkTravel => '出張費';

  @override
  String get catSubFinanceInsurance => '保険料';

  @override
  String get catSubFinanceLoss => '投資損失';

  @override
  String get catSubFinanceFee => '手数料';

  @override
  String get catSubFinanceLoanInterest => 'ローン利息';

  @override
  String get catSubFinanceTax => '税金';

  @override
  String get catSubFinanceFine => '罰金';

  @override
  String get catSubOtherExpenseGeneral => 'その他支出';

  @override
  String get catSubOtherExpenseUnexpected => '臨時支出';

  @override
  String get catSubSalaryBase => '基本給';

  @override
  String get catSubSalaryBonus => '賞与';

  @override
  String get catSubSalaryOvertime => '残業手当';

  @override
  String get catSubSalaryYearEnd => '年末賞与';

  @override
  String get catSubSalaryBackPay => '遡及支給';

  @override
  String get catSubSalaryAllowance => '手当';

  @override
  String get catSubInvestmentFund => '投資信託';

  @override
  String get catSubInvestmentStock => '株式収益';

  @override
  String get catSubInvestmentInterest => '利息収入';

  @override
  String get catSubInvestmentWealthMgmt => '資産運用';

  @override
  String get catSubInvestmentCrypto => '仮想通貨';

  @override
  String get catSubInvestmentDividend => '配当金';

  @override
  String get catSubSideJobPartTime => 'アルバイト収入';

  @override
  String get catSubSideJobFreelance => 'フリーランス';

  @override
  String get catSubSideJobRoyalty => '印税・著作権';

  @override
  String get catSubSideJobCommission => 'コミッション';

  @override
  String get catSubSideJobSales => '販売収入';

  @override
  String get catSubGiftRedPacket => 'お年玉・お祝い金';

  @override
  String get catSubGiftPresent => '贈り物';

  @override
  String get catSubGiftFestival => '年中行事の祝儀';

  @override
  String get catSubRefundReimbursement => '経費精算';

  @override
  String get catSubRefundReturn => '返品返金';

  @override
  String get catSubRefundMedical => '医療保険の給付';

  @override
  String get catSubRefundInsurance => '保険金';

  @override
  String get catSubAssetRent => '家賃収入';

  @override
  String get catSubAssetIdleSale => '不用品販売';

  @override
  String get catSubAssetSecondhand => '中古販売';

  @override
  String get catSubAssetProfit => '資産収益';

  @override
  String get catSubTransferInBank => '銀行振込受入';

  @override
  String get catSubTransferInWallet => 'ウォレット振込';

  @override
  String get catSubTransferInDebt => '貸付金回収';

  @override
  String get catSubIncomeOtherWindfall => '一時所得';

  @override
  String get catSubIncomeOtherSubsidy => '助成金';

  @override
  String get catSubIncomeOtherUncategorized => '未分類';

  @override
  String get catSubTransferBankIn => '銀行振込入金';

  @override
  String get catSubTransferBankOut => '銀行振込出金';

  @override
  String get catSubTransferWallet => 'ウォレット振替';

  @override
  String get catSubTransferCrossIn => '他プラットフォーム入金';

  @override
  String get catSubTransferCrossOut => '他プラットフォーム出金';

  @override
  String get catSubRepaymentCreditCard => 'クレジットカード返済';

  @override
  String get catSubRepaymentLoan => 'ローン返済';

  @override
  String get catSubRepaymentBorrowed => '借入金返済';

  @override
  String get catSubRepaymentLent => '貸付';

  @override
  String get catSubOtherSocialGift => '祝儀・香典';

  @override
  String get catSubOtherSocialWedding => '冠婚葬祭';

  @override
  String get catSubOtherSocialBirthday => '誕生会';

  @override
  String get catSubOtherSocialFestival => '年中行事の祝儀';

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

  @override
  String get aiPresetDeepseekNote => 'コストパフォーマンスの高い中国産LLM';

  @override
  String get aiPresetOpenaiNote => '海外ネットワークアクセスが必要';

  @override
  String get aiPresetQwenName => '通義千問 (アリババ)';

  @override
  String get aiPresetQwenNote => '互換モードURLを使用';

  @override
  String get aiPresetDoubaoName => '豆包 (バイトダンス)';

  @override
  String get aiPresetDoubaoNote => '火山方舟で推論エンドポイントを作成し、エンドポイントIDをモデル名として使用';

  @override
  String get aiPresetZhipuName => '智譜AI';

  @override
  String get aiPresetZhipuNote => 'glm-4-flashに無料枠あり';

  @override
  String get aiPresetKimiName => '月之暗面 (Kimi)';

  @override
  String get aiPresetKimiNote => '長文理解に優れる';

  @override
  String get aiPresetClaudeNote => 'Anthropic Messages APIを使用';

  @override
  String get aiPresetMimoName => 'Xiaomi MiMo';

  @override
  String get aiPresetMimoNote =>
      'OpenAI/Anthropic互換プロトコル対応、中国/シンガポール/欧州マルチクラスター';

  @override
  String get aiPresetOllamaName => 'Ollama (ローカル)';

  @override
  String get aiPresetOllamaNote => 'ローカルでOllamaサービスの実行が必要、モデル名はローカルインストールに依存';

  @override
  String get llmCapTextLabel => 'テキストモデル';

  @override
  String get llmCapTextDesc => '記帳解析・AI会話用';

  @override
  String get llmCapVisionLabel => 'ビジョンモデル';

  @override
  String get llmCapVisionDesc => 'レシート・請求書の写真認識用';

  @override
  String get llmCapAudioLabel => '音声モデル';

  @override
  String get llmCapAudioDesc => '音声テキスト変換用';

  @override
  String get currencyCny => '中国人民元 (CNY)';

  @override
  String get currencyUsd => '米ドル (USD)';

  @override
  String get currencyKrw => '韓国ウォン (KRW)';

  @override
  String get currencyJpy => '日本円 (JPY)';

  @override
  String get currencyEur => 'ユーロ (EUR)';

  @override
  String get currencyGbp => '英ポンド (GBP)';

  @override
  String get currencyUnitYi => '億';

  @override
  String get currencyUnitWan => '万';

  @override
  String get inputSourceText => 'テキスト';

  @override
  String get inputSourceVoice => '音声';

  @override
  String get inputSourceImage => '画像';

  @override
  String reportTrendMonth(String period) {
    return '$period月';
  }

  @override
  String reportTrendDay(String period) {
    return '$period日';
  }

  @override
  String get llmSettingsTitle => 'AIサービス設定';

  @override
  String get llmExportConfig => '設定をエクスポート';

  @override
  String get llmImportConfig => '設定をインポート';

  @override
  String get llmProviderManagement => 'プロバイダー管理';

  @override
  String get llmAddProvider => 'プロバイダーを追加';

  @override
  String get llmEditProvider => 'プロバイダーを編集';

  @override
  String get llmDeleteProvider => 'プロバイダーを削除';

  @override
  String llmDeleteProviderConfirm(String name) {
    return '「$name」を削除しますか？';
  }

  @override
  String get llmNotConfigured => '未設定';

  @override
  String get llmConfigured => '設定済み';

  @override
  String get llmNoProviders => 'プロバイダーがまだ追加されていません';

  @override
  String get llmUnnamedProvider => '名前のないプロバイダー';

  @override
  String get llmInUse => '使用中';

  @override
  String get llmIncomplete => '未完了';

  @override
  String get llmTest => 'テスト';

  @override
  String get llmConfigIncomplete => '先に設定を完了してください（API Key、URL、最低1つのモデルが必要）';

  @override
  String get llmConnectSuccess => '✅ 接続成功';

  @override
  String get llmConnectFail => '❌ 接続失敗。URL、Key、モデル名を確認してください';

  @override
  String get llmConfigCopied => '設定をクリップボードにコピーしました';

  @override
  String get llmClipboardEmpty => 'クリップボードが空です';

  @override
  String llmImported(String count) {
    return '$count 件のプロバイダー設定をインポートしました';
  }

  @override
  String get llmImportFailed => 'インポートに失敗しました。JSON形式を確認してください';

  @override
  String get llmProviderNotConfigured =>
      'このプロバイダーにはAPI KeyまたはURLが設定されていません。先に編集してください';

  @override
  String llmModelsFetched(String count, String label) {
    return '$count 件の$labelを取得しました';
  }

  @override
  String llmModelsFetchedAll(String count) {
    return '$count 個のモデルを取得しました（専用モデルが見つからず、全件表示）';
  }

  @override
  String get llmFetchFailed => '取得に失敗しました。プリセットモデルリストを読み込みました';

  @override
  String llmFetchError(String error) {
    return 'モデルの取得に失敗しました: $error';
  }

  @override
  String llmModelSet(String capability, String provider, String model) {
    return '$capabilityを設定しました：$provider · $model';
  }

  @override
  String llmInputModelName(String capability) {
    return '$capability名を入力';
  }

  @override
  String get llmConnectFailed => '接続失敗';

  @override
  String get llmAutoDetectInterval => '自動検出間隔';

  @override
  String get llmIntervalOff => 'オフ';

  @override
  String get llmInterval10s => '10秒';

  @override
  String get llmInterval30s => '30秒';

  @override
  String get llmInterval1m => '1分';

  @override
  String get llmInterval2m => '2分';

  @override
  String get llmInterval5m => '5分';

  @override
  String get llmInterval10m => '10分';

  @override
  String get llmInterval30m => '30分';

  @override
  String get llmInterval1h => '1時間';

  @override
  String llmConfigureCap(String label) {
    return '$labelを設定';
  }

  @override
  String get llmCurrentUse => '現在使用中';

  @override
  String get llmFetch => '取得';

  @override
  String get llmTesting => 'テスト中...';

  @override
  String get llmTestConnection => '接続テスト';

  @override
  String get llmFailed => '失敗';

  @override
  String llmSelectCap(String label) {
    return '$labelを選択';
  }

  @override
  String get llmManualInput => '✏️ 手動入力...';

  @override
  String get llmFillApiKey => 'API KeyとリクエストURLを入力してください';

  @override
  String get llmCustom => 'カスタム';

  @override
  String get llmProviderName => 'プロバイダー名';

  @override
  String get llmApiUrl => 'リクエストURL';

  @override
  String get llmApiUrlHintAnthropic =>
      'Anthropic API URL（例: https://api.anthropic.com）';

  @override
  String get llmApiUrlHelper => 'APIのbase_urlを入力してください。/chat/completionsは不要です';

  @override
  String get llmSaveHint => '保存後、前のページに戻って能力カードからモデルを設定してください';

  @override
  String get llmInputApiKey => 'API Keyを入力';

  @override
  String get llmApiUrlExample => '例：https://api.example.com';

  @override
  String get llmAdvancedSettings => '詳細設定';

  @override
  String get llmTemperature => '回答スタイル';

  @override
  String get llmTemperatureHint => '低いほど正確で安定、高いほど多様で創造的';

  @override
  String get llmTemperaturePrecise => '正確';

  @override
  String get llmTemperatureCreative => '創造的';

  @override
  String get llmMaxToken => '最大トークン数';

  @override
  String get llmTimeout => 'タイムアウト（秒）';

  @override
  String get llmErrorNoModelForCapability => 'この機能に対応するモデルが設定されていません';

  @override
  String get llmErrorNoProviderConfigured => '設定でAIプロバイダーを追加・設定してください';

  @override
  String get llmErrorNoProviderOrInput => '設定でAIプロバイダーを追加するか、より具体的に入力してください';

  @override
  String get llmErrorCannotParseResponse => 'AIレスポンスを解析できません';

  @override
  String get llmErrorInvalidResponseFormat => 'AIレスポンスの形式が正しくありません';

  @override
  String llmErrorParseFailed(String error) {
    return 'AIレスポンスの解析に失敗しました: $error';
  }

  @override
  String get llmErrorTimeout => 'リクエストがタイムアウトしました。ネットワーク接続を確認してください';

  @override
  String get llmErrorInvalidApiKey => 'API Keyが無効です。設定を確認してください';

  @override
  String get llmErrorRateLimit => 'リクエストが多すぎます。しばらくしてから再試行してください';

  @override
  String get llmErrorForbidden => 'アクセスが拒否されました。API Keyの権限を確認してください';

  @override
  String llmErrorRequestFailed(String code) {
    return 'リクエストに失敗しました ($code)';
  }

  @override
  String get llmErrorNetworkFailed => 'ネットワーク接続に失敗しました。ネットワークを確認してください';

  @override
  String llmErrorRequestFailedWithMessage(String message) {
    return 'リクエストに失敗しました: $message';
  }

  @override
  String get visionErrorNoModelConfigured => 'ビジョンモデルが設定されていません。AI設定で設定してください';

  @override
  String get visionErrorImageNotFound => '画像ファイルが見つかりません';

  @override
  String visionErrorRecognitionFailed(String message) {
    return '画像認識に失敗しました: $message';
  }

  @override
  String get voiceErrorNoModelConfigured => '音声モデルが設定されていません。AI設定で設定してください';

  @override
  String get voiceErrorNoEngineAvailable =>
      '音声認識エンジンが利用できません。AI設定またはデバイスの音声サポートを確認してください';

  @override
  String get voiceErrorAudioNotFound => '音声ファイルが見つかりません';

  @override
  String get voiceErrorInvalidResponseFormat => '音声認識の返答形式が異常です';

  @override
  String voiceErrorTranscriptionFailed(String message) {
    return '音声認識に失敗しました: $message';
  }

  @override
  String get voiceErrorEndpointNotFound =>
      'Whisper APIエンドポイントが見つかりません。サプライヤーのBase URLを確認してください';

  @override
  String get pipelineErrorEmptyVoiceResult => '音声認識結果が空です。再度録音してください';

  @override
  String get pipelineErrorEmptyImageResult => '画像認識結果が空です。より鮮明な画像を選択してください';

  @override
  String get acCoinInitialGiftDesc => '新規ユーザー登録特典';

  @override
  String get loadFailedPullToRefresh => '読み込み失敗、引っ張って更新';

  @override
  String get llmSettingsGetModelListError => 'モデル一覧の取得に失敗しました';

  @override
  String get searchPageTitle => '取引検索';

  @override
  String get searchHint => 'キーワードまたは自然言語で入力（例：「先月タクシーにいくら」）';

  @override
  String get searchAiParsing => 'AIがクエリを理解中...';

  @override
  String get searchNoResults => '一致する取引が見つかりません';

  @override
  String get searchNoResultsHint => '別のキーワードや表現をお試しください';

  @override
  String searchResultCount(String count) {
    return '$count件の結果';
  }

  @override
  String get searchAiSummaryTitle => '📊 AI分析結果';

  @override
  String get searchAiSummaryLoading => 'AIが分析中...';

  @override
  String get searchTotalExpense => '合計支出';

  @override
  String get searchTotalIncome => '合計収入';

  @override
  String searchTransactionCount(String count) {
    return '$count件';
  }

  @override
  String get searchAverage => '日平均';

  @override
  String get searchMaxSingle => '最大1件';

  @override
  String get searchLlmNotConfigured => 'AI未設定、キーワード検索のみ';

  @override
  String get searchLlmError => 'AI解析失敗、キーワード検索に切り替え';

  @override
  String get searchQuickSuggestions => '検索候補';

  @override
  String get searchSuggestionLastMonthExpense => '先月の支出合計';

  @override
  String get searchSuggestionThisMonthFood => '今月の飲食費';

  @override
  String get searchSuggestionRecentLarge => '最近の高額支出';

  @override
  String get searchSuggestionRecentWeek => '直近1週間の取引';

  @override
  String get searchFilterExpense => '支出';

  @override
  String get searchFilterIncome => '収入';

  @override
  String get searchFilterAll => 'すべて';

  @override
  String get searchFilterDateRange => '日付範囲';

  @override
  String get searchFilterAmountRange => '金額範囲';

  @override
  String get searchFilterCategory => 'カテゴリ';

  @override
  String get searchFilterPayment => '支払方法';

  @override
  String get searchFilterClear => 'フィルター解除';

  @override
  String get searchModeKeyword => 'キーワード';

  @override
  String get searchModeAi => 'AI検索';

  @override
  String get searchKeywordPlaceholder => '説明・メモ・金額を検索...';

  @override
  String get searchParsingFailed => 'AI解析失敗';

  @override
  String get llmSupplierManagement => 'サプライヤー管理';

  @override
  String get llmModelManagement => 'モデル管理';

  @override
  String get llmSelectProvider => 'プロバイダー選択';

  @override
  String get llmSelectModel => 'モデル選択';

  @override
  String get llmProviderIncomplete => '未設定';

  @override
  String get llmNone => '使用しない';

  @override
  String get cancel => 'キャンセル';

  @override
  String get confirm => '確認';

  @override
  String get agentTransactionParser => '記帳解析';

  @override
  String get agentTransactionParserDesc => '自然言語から金額・カテゴリ・日時を抽出';

  @override
  String get agentReceiptOcr => 'レシートOCR';

  @override
  String get agentReceiptOcrDesc => 'レシート/請求書の画像から支出情報を認識';

  @override
  String get agentVoiceTranscribe => '音声文字起こし';

  @override
  String get agentVoiceTranscribeDesc => '音声録音をテキストに変換';

  @override
  String get agentFinanceSearch => '財務検索';

  @override
  String get agentFinanceSearchDesc => '自然言語で取引・予算・カテゴリを検索';

  @override
  String get agentEditTitle => '機能設定';

  @override
  String get agentEditSave => '保存';

  @override
  String get agentEditSaved => '設定を保存しました';

  @override
  String get agentEditSelectModel => 'まずモデルを選択してください';

  @override
  String get agentEditPrimaryModel => 'メインモデル';

  @override
  String get agentEditFallbackModel => 'フォールバックモデル';

  @override
  String get agentEditEnableFallback => '自動フォールバックを有効化';

  @override
  String get agentEditTestCases => 'テストケース';

  @override
  String get agentEditTestCase => 'ケース';

  @override
  String get agentEditProvider => 'プロバイダー';

  @override
  String get agentEditModel => 'モデル';

  @override
  String get agentEditManualInput => 'モデル名を手動入力';

  @override
  String get agentEditModelNameHint => 'モデル名を入力';

  @override
  String get aiSettingsTitle => 'AI設定';

  @override
  String get aiSettingsAgents => '機能設定';

  @override
  String get aiSettingsSuppliers => 'プロバイダー管理';

  @override
  String get aiSettingsUsage => '今月の利用状況';

  @override
  String get aiSettingsUsageCalls => '回';

  @override
  String get aiSettingsUsageFallback => '回フォールバック';

  @override
  String get aiSettingsNoAgents => '機能が設定されていません';

  @override
  String get aiSettingsAddSupplier => 'プロバイダー追加';

  @override
  String get aiSettingsTestConnection => '接続テスト';

  @override
  String get aiSettingsConnected => '接続済み';

  @override
  String get aiSettingsDisconnected => '未接続';

  @override
  String get aiSettingsLatency => 'レイテンシ';

  @override
  String get aiPersonaManage => 'AI 角色管理';

  @override
  String get aiPersonaAdd => '添加角色';

  @override
  String get aiPersonaEdit => '编辑角色';

  @override
  String get aiPersonaName => '角色名称';

  @override
  String get aiPersonaAvatar => '角色头像';

  @override
  String get aiPersonaDescription => '性格描述';

  @override
  String get aiPersonaDescriptionHint => '描述角色的性格特点、说话方式...';

  @override
  String get aiPersonaNone => '不启用角色';

  @override
  String aiPersonaDeleteConfirm(Object name) {
    return '确定删除角色\"$name\"吗？同时也将清除聊天记录。';
  }

  @override
  String get aiPersonaEmpty => '还没有创建角色哦～';

  @override
  String get aiPersonaNameRequired => '请输入角色名称';

  @override
  String get aiPersonaTip => '角色性格越具体，AI 表现越鲜明！建议包含语气、说话风格、习惯用语等';

  @override
  String get aiPersonaExamples => '对话示例';

  @override
  String get aiPersonaExamplesHint => '添加几组对话示例，让 AI 更贴合人设';

  @override
  String get aiPersonaExampleUser => '用户';

  @override
  String get aiPersonaExampleAssistant => '角色';

  @override
  String get aiPersonaAddExample => '添加示例';

  @override
  String get aiPersonaGreeting => '开场白';

  @override
  String get aiPersonaGreetingHint => '激活角色时自动发送的第一句话';

  @override
  String get aiChatHistoryCleared => '聊天记录已清除';

  @override
  String get aiChatHistoryClear => '清空聊天记录';

  @override
  String get aiPersonaManageMemories => '管理记忆';
}
