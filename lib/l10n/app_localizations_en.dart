// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'WoAccount';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get navRecord => 'Record';

  @override
  String get navProfile => 'Profile';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonEditCategory => 'Edit Category';

  @override
  String get commonEditAmount => 'Edit Amount';

  @override
  String get commonEditDescription => 'Edit Description';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get chatPageTitle => 'AI Bookkeeping';

  @override
  String get chatPageVoicePlaceholder => '🎤 Voice Message';

  @override
  String get chatPageImagePlaceholder => '📷 Image Message';

  @override
  String chatPageVoiceTranscription(String text) {
    return '🎤 Voice to text: $text';
  }

  @override
  String chatPageImageRecognition(String text) {
    return '📷 Image recognition: $text';
  }

  @override
  String get chatPageNoSubcategory => 'None';

  @override
  String get chatPageConfigAiError =>
      'Please add and configure an AI provider in Settings first';

  @override
  String chatPageParseError(String error) {
    return '❌ Parse failed: $error\n\nPlease try a more specific description, e.g. \"lunch ramen 25\"';
  }

  @override
  String get chatPageNoCategoryError =>
      'No categories available. Please add a category in Category Management first';

  @override
  String get chatPageSaveSuccessTitle => 'Saved';

  @override
  String chatPageSaveSuccess(
    String amount,
    String category,
    String description,
    String date,
  ) {
    return '✅ Saved\n$amount · $category\n$description · $date';
  }

  @override
  String chatPageSaveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String get chatPageEmptyTitle => 'Start Bookkeeping';

  @override
  String get chatPageEmptyHint =>
      'Try typing \"lunch ramen 25\" or \"dinner 24, laundry 34\"';

  @override
  String get chatPageEmptyInstruction =>
      'Long press the record button for voice input 🎤 · Tap the right button for photo recognition 📷';

  @override
  String get chatPageAiParsing => 'AI is parsing...';

  @override
  String get chatBubbleImageFailed => 'Image failed to load';

  @override
  String get chatInputMicPermission => 'Please grant microphone permission';

  @override
  String get chatInputRecordShort => 'Recording too short';

  @override
  String chatInputImageFailed(String error) {
    return 'Failed to get image: $error';
  }

  @override
  String get chatInputCamera => 'Take Photo';

  @override
  String get chatInputGallery => 'Choose from Gallery';

  @override
  String get chatInputVoiceHint =>
      'Release to send, swipe left to cancel ↖, swipe right to transcribe ↗';

  @override
  String get chatInputListening => 'Listening...';

  @override
  String get chatInputRecording => 'Recording...';

  @override
  String get chatInputVoiceCancel => '← Release to cancel';

  @override
  String get chatInputVoiceSend => 'Release to send';

  @override
  String get chatInputVoiceCanceling => 'Release to cancel';

  @override
  String get voiceOverlaySwipeHint => '↑ Swipe up to cancel or transcribe';

  @override
  String get voiceOverlayCancelLabel => 'Release to cancel';

  @override
  String get voiceOverlayTranscribeLabel => 'Release to transcribe only';

  @override
  String get chatInputTextHint => 'Say something...';

  @override
  String get chatConfirmTitle => 'AI Parse Result';

  @override
  String get chatConfirmCategory => 'Category';

  @override
  String get chatConfirmDescription => 'Description';

  @override
  String get chatConfirmDate => 'Date';

  @override
  String get chatConfirmAmount => 'Amount';

  @override
  String get chatConfirmSave => 'Confirm Save';

  @override
  String get chatConfirmInputCategory => 'Enter category name';

  @override
  String get chatConfirmInputDescription => 'Enter description';

  @override
  String get chatConfirmInputAmount => 'Enter amount';

  @override
  String get chatDeleteTitle => 'Clear Chat';

  @override
  String get chatDeleteMessage =>
      'Are you sure you want to clear all chat history? This cannot be undone.';

  @override
  String get chatDeleteSuccess => 'Chat history cleared';

  @override
  String chatMultiSelectCount(String count) {
    return '$count selected';
  }

  @override
  String get chatDeleteSelected => 'Delete selected';

  @override
  String chatDeleteSelectedConfirm(String count) {
    return 'Delete $count selected messages?';
  }

  @override
  String get chatActionCopy => 'Copy';

  @override
  String get chatActionDelete => 'Delete Message';

  @override
  String get chatDeleteMsgConfirm =>
      'Are you sure you want to delete this message?';

  @override
  String get chatCopyMessage => 'Copied to clipboard';

  @override
  String get homePageAiNotConfigured =>
      'AI service not configured yet, basic rule parsing will be used';

  @override
  String get homePageGoSettings => 'Go to Settings';

  @override
  String get homePageNoContent => 'No content recognized';

  @override
  String homePageRecordFailed(String error) {
    return 'Recording failed: $error';
  }

  @override
  String homePageRecordSuccess(String amount) {
    return 'Recorded: $amount';
  }

  @override
  String homePageSaveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String get homePageBudgetAlert =>
      'Today\'s spending has exceeded 80% of the daily budget';

  @override
  String get homeInputManual => 'Manual Entry';

  @override
  String get homeInputHint => 'Lunch ramen 25 yuan';

  @override
  String get homeInputCamera => 'Photo Recognition';

  @override
  String get homeConfirmTitle => '🤖 AI Parse Result';

  @override
  String homeConfirmOriginalInput(String input) {
    return 'Original input: $input';
  }

  @override
  String get homeConfirmAmount => '💰 Amount';

  @override
  String get homeConfirmDate => '📅 Date';

  @override
  String get homeConfirmCategory => '🍜 Category';

  @override
  String get homeConfirmParseTime => '⏱️ Parse Time';

  @override
  String get homeConfirmDescription => '📝 Description';

  @override
  String get homeConfirmConfidence => 'Confidence';

  @override
  String get homeConfirmEditDate => 'Edit Date';

  @override
  String get homeConfirmRecord => 'Confirm Record';

  @override
  String get homeEntryTitle => 'AI Assistant';

  @override
  String get homeEntrySubtitle => 'Smart Bookkeeping · Spending Analysis · Q&A';

  @override
  String get homeBudgetDetails => 'Details';

  @override
  String get txnSearchHint => 'Search transactions';

  @override
  String get txnBudget => 'Budget';

  @override
  String get txnToday => 'Today';

  @override
  String get txnPeriodDay => 'Today';

  @override
  String get txnPeriodWeek => 'This Week';

  @override
  String get txnPeriodMonth => 'This Month';

  @override
  String txnExpense(String period) {
    return '$period Expenses';
  }

  @override
  String txnIncome(String period) {
    return '$period Income';
  }

  @override
  String get txnBalance => 'Balance';

  @override
  String get txnSortByTime => 'By Time';

  @override
  String get txnSortByAmount => 'By Amount';

  @override
  String get txnEmpty => 'No transaction records';

  @override
  String get txnDayDetailEmpty => 'No transactions for this day';

  @override
  String get txnDayFormat => 'MMM d, yyyy';

  @override
  String get txnMonthFormat => 'MMM yyyy';

  @override
  String txnGroupExpenseLabel(String amount) {
    return 'Expense $amount';
  }

  @override
  String txnGroupIncomeLabel(String amount) {
    return 'Income $amount';
  }

  @override
  String get txnGroupUncategorized => 'Uncategorized';

  @override
  String get txnGroupNoSubcategory => 'None';

  @override
  String get viewDay => 'Day';

  @override
  String get viewWeek => 'Week';

  @override
  String get viewMonth => 'Month';

  @override
  String get txnDetailTitle => 'Transaction Details';

  @override
  String get txnDetailSaved => 'Saved';

  @override
  String get txnDetailDeleteConfirmTitle => 'Confirm Delete';

  @override
  String get txnDetailDeleteConfirmContent =>
      'This cannot be undone. Are you sure you want to delete this transaction?';

  @override
  String get txnDetailNotFound => 'Transaction not found';

  @override
  String get txnDetailUncategorized => 'Uncategorized';

  @override
  String get txnDetailCategory => 'Category';

  @override
  String get txnDetailAmount => 'Amount';

  @override
  String get txnDetailDate => 'Date';

  @override
  String get txnDetailNote => 'Note';

  @override
  String get txnDetailPayMethod => 'Payment Method';

  @override
  String get txnDetailAddNoteHint => 'Tap to add a note';

  @override
  String get txnDetailAiRecord => 'AI Parse Record';

  @override
  String get txnDetailOriginalInput => 'Original Input';

  @override
  String get txnDetailParseSource => 'Parse Source';

  @override
  String get txnDetailConfidence => 'Confidence';

  @override
  String get txnDetailCreatedAt => 'Created At';

  @override
  String get entryTitle => 'Record';

  @override
  String get entryBookType => 'Daily Expense';

  @override
  String get entryExpense => 'Expense';

  @override
  String get entryIncome => 'Income';

  @override
  String get entryOther => 'Other';

  @override
  String entrySubCategoryTitle(String name) {
    return '$name - Subcategories';
  }

  @override
  String get entryNoteHint => 'Add a note...';

  @override
  String get entrySelectCategoryHint => 'Select a category';

  @override
  String get entrySelectThisCategory => 'Select this';

  @override
  String get entryNoSubCategory => 'No subcategories';

  @override
  String get payMethodDefault => 'Default';

  @override
  String get payMethodCash => 'Cash';

  @override
  String get payMethodWechat => 'WeChat';

  @override
  String get payMethodAlipay => 'Alipay';

  @override
  String get payMethodCard => 'Card';

  @override
  String get entryNumpadToday => 'Today';

  @override
  String get entryNumpadDelete => 'Delete';

  @override
  String get entryNumpadDone => 'Done';

  @override
  String entrySuccess(String amount) {
    return 'Recorded: $amount';
  }

  @override
  String entryFailure(String error) {
    return 'Recording failed: $error';
  }

  @override
  String get profileCheckedIn => 'Checked In';

  @override
  String get profileCheckIn => 'Check In';

  @override
  String get profileConsecutiveDays => 'Consecutive Days';

  @override
  String get profileTotalCheckInDays => 'Total Check-in Days';

  @override
  String get profileTotalTransactions => 'Total Transactions';

  @override
  String get profileFuncTheme => 'Theme';

  @override
  String get profileFuncAccountBooks => 'My Account Books';

  @override
  String get profileFuncBudget => 'Budget Management';

  @override
  String get profileFuncCategories => 'Category Management';

  @override
  String get profileFuncReports => 'Report Analysis';

  @override
  String get profileToolsAndServices => 'Tools & Services';

  @override
  String get profileMenuPasswordLock => 'Password Lock';

  @override
  String get profileMenuAcCoins => 'AC Coins';

  @override
  String get profileMenuAiConfig => 'AI Configuration';

  @override
  String get profileMenuDataBackup => 'Data Backup';

  @override
  String get profileMenuImport => 'Import Transactions';

  @override
  String get profileMenuExport => 'Export Transactions';

  @override
  String get profileMenuFeedback => 'Feedback';

  @override
  String get profileMenuSettings => 'Settings';

  @override
  String profileFeatureComingSoon(String label) {
    return '$label coming soon';
  }

  @override
  String get profileBackupShareText => 'WoAccount backup file';

  @override
  String get profileBackupSuccess => 'Backup successful';

  @override
  String profileBackupFailed(String error) {
    return 'Backup failed: $error';
  }

  @override
  String get profileExportShareText => 'WoAccount data export';

  @override
  String get profileExportSuccess => 'Export successful';

  @override
  String profileExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get profileImportConfirm =>
      'Importing will overwrite all current data. Continue?';

  @override
  String get profileImportNoBackup => 'No backup files found';

  @override
  String get profileImportSuccess => 'Import successful';

  @override
  String profileImportFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get profileExportExcel => 'Export Excel';

  @override
  String get profileImportExcel => 'Import Excel';

  @override
  String get profileExcelFormatTitle => 'Excel Format';

  @override
  String profileImportExcelSuccess(int count) {
    return 'Successfully imported $count records';
  }

  @override
  String get profileAlreadyCheckedIn => 'Already checked in today';

  @override
  String get profileCheckInSuccess => 'Check-in successful!';

  @override
  String profileCheckInFailure(String error) {
    return 'Check-in failed: $error';
  }

  @override
  String get profileThemeLight => 'Light Mode';

  @override
  String get profileThemeDark => 'Dark Mode';

  @override
  String get profileThemeSystem => 'Follow System';

  @override
  String profileUserId(String uid) {
    return 'ID: $uid';
  }

  @override
  String get profileEditTitle => 'Edit Profile';

  @override
  String get profileEditNickname => 'Nickname';

  @override
  String get profileEditId => 'ID';

  @override
  String get profileEditGender => 'Gender';

  @override
  String get profileEditEmail => 'Email';

  @override
  String get profileEditPhone => 'Phone';

  @override
  String get profileEditNotSet => 'Not set';

  @override
  String get profileEditNotFound => 'User profile not found';

  @override
  String get profileEditGenderMale => 'Male';

  @override
  String get profileEditGenderFemale => 'Female';

  @override
  String get profileEditGenderSecret => 'Prefer not to say';

  @override
  String get profileEditLogout => 'Log Out';

  @override
  String get profileEditLogoutConfirmContent =>
      'Are you sure you want to log out?';

  @override
  String get profileEditLogoutExit => 'Log Out';

  @override
  String get profileEditLogoutComingSoon => 'Logout feature coming soon';

  @override
  String get profileEditDeleteAccount => 'Delete Account';

  @override
  String get profileEditDeleteAccountConfirmContent =>
      'Account data cannot be recovered after deletion. Are you sure you want to proceed?';

  @override
  String get profileEditDeleteAccountSubmit => 'Delete Account';

  @override
  String get profileEditDeleteAccountSubmitted =>
      'Account deletion request submitted';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsCurrency => 'Currency';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsAutoBackup => 'Auto Backup';

  @override
  String get settingsBackupFrequency => 'Backup Frequency';

  @override
  String get settingsBackupDaily => 'Daily';

  @override
  String get settingsBackupWeekly => 'Weekly';

  @override
  String get settingsBackupMonthly => 'Monthly';

  @override
  String get settingsBackupManual => 'Manual Only';

  @override
  String get settingsNoBackupFound => 'No backup files found';

  @override
  String get settingsRestoreData => 'Restore Data';

  @override
  String get settingsRestoreConfirm =>
      'Restoring will overwrite all current data. Continue?';

  @override
  String get settingsRestoreSuccess => 'Data restored successfully';

  @override
  String settingsRestoreFailed(String error) {
    return 'Restore failed: $error';
  }

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsDangerZone => 'Danger Zone';

  @override
  String get settingsClearData => 'Clear All Data';

  @override
  String get settingsClearConfirm =>
      'This action cannot be undone. Are you sure you want to clear all data?';

  @override
  String get settingsClearDataSuccess => 'All data has been cleared';

  @override
  String get settingsDeleteAccount => 'Delete Account';

  @override
  String get settingsDeleteConfirm =>
      'All data will be permanently deleted. Are you sure you want to continue?';

  @override
  String get settingsDeleteAccountSuccess => 'Account data has been deleted';

  @override
  String get budgetTitle => 'Budget Management';

  @override
  String get budgetViewMonth => 'Month';

  @override
  String get budgetViewYear => 'Year';

  @override
  String budgetYearLabel(String year) {
    return '$year';
  }

  @override
  String get budgetYearTotal => 'Annual Budget';

  @override
  String budgetMonthCount(String count) {
    return '$count months budgeted';
  }

  @override
  String budgetMonthShort(String month) {
    return 'M$month';
  }

  @override
  String get budgetEmpty => 'No budget set yet';

  @override
  String get budgetSetButton => 'Set Budget';

  @override
  String get budgetSettingTitle => 'Budget Settings';

  @override
  String get budgetMonthlyTotal => 'Monthly Total Budget';

  @override
  String budgetSpent(String amount) {
    return 'Spent $amount';
  }

  @override
  String budgetRemaining(String amount) {
    return 'Remaining $amount';
  }

  @override
  String budgetOverSpent(String category, String amount) {
    return '$category budget exceeded by $amount';
  }

  @override
  String get budgetUnknownCategory => 'A category';

  @override
  String get budgetUncategorized => 'Uncategorized';

  @override
  String budgetUsedPercent(String percent) {
    return '$percent% used';
  }

  @override
  String budgetCategoryCount(String count) {
    return '$count category budgets set';
  }

  @override
  String get budgetAddCategoryBudget => 'Add Category Budget';

  @override
  String get budgetAddCategoryBudgetDeveloping =>
      'Category budget feature is under development';

  @override
  String get budgetEditBudgetDeveloping =>
      'Budget editing feature is under development';

  @override
  String get budgetSetTotalTitle => 'Set Total Budget';

  @override
  String get budgetEditTotalTitle => 'Edit Total Budget';

  @override
  String get budgetEditCategoryTitle => 'Edit Category Budget';

  @override
  String get budgetInputAmount => 'Enter budget amount';

  @override
  String get budgetSelectCategory => 'Select Category';

  @override
  String get budgetNoCategoryAvailable => 'No categories available';

  @override
  String get budgetCategoryAlreadyExists =>
      'Budget for this category already exists';

  @override
  String get budgetDeleteTitle => 'Delete Budget';

  @override
  String get budgetDeleteConfirm =>
      'Are you sure you want to delete this category budget?';

  @override
  String get budgetNoBudgets =>
      'No budgets set yet, tap the edit button to start';

  @override
  String get bookTitle => 'My Account Books';

  @override
  String get bookCreate => 'New Account Book';

  @override
  String get bookDescription =>
      'Each account book has its own transactions, budgets, and AI conversation history';

  @override
  String get bookDefault => 'Default';

  @override
  String get bookCurrent => 'Current';

  @override
  String get bookMonthlyExpense => 'Monthly Expense';

  @override
  String get bookMonthlyIncome => 'Monthly Income';

  @override
  String get bookTransactionCount => 'Transactions';

  @override
  String get bookSetDefault => 'Set as Default';

  @override
  String get bookDelete => 'Delete';

  @override
  String bookSwitchedTo(String name) {
    return 'Switched to $name';
  }

  @override
  String get bookDeleteTitle => 'Delete Account Book';

  @override
  String bookDeleteConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?\n\nAll transactions, budgets, and conversation history in this book will be removed. This action cannot be undone.';
  }

  @override
  String get bookDeleted => 'Account book moved to recycle bin';

  @override
  String get bookRecycleBin => 'Account Book Recycle Bin';

  @override
  String get bookRecycleBinEmpty => 'Recycle bin is empty';

  @override
  String get bookRestore => 'Restore';

  @override
  String get bookRestored => 'Account book restored';

  @override
  String get txnRecycleBin => 'Transaction Recycle Bin';

  @override
  String get txnRecycleBinEmpty => 'Recycle bin is empty';

  @override
  String get txnRestore => 'Restore';

  @override
  String get txnRestored => 'Transaction restored';

  @override
  String get txnRecycleSelectAll => 'Select All';

  @override
  String get txnRecycleDeselectAll => 'Cancel';

  @override
  String txnRecycleSelected(int count) {
    return '$count selected';
  }

  @override
  String get txnRecyclePermanentDelete => 'Delete Permanently';

  @override
  String get txnRecyclePermanentDeleteConfirm =>
      'Permanently delete selected transactions? This cannot be undone.';

  @override
  String txnRecycleBatchRestored(int count) {
    return '$count transactions restored';
  }

  @override
  String txnRecycleBatchDeleted(int count) {
    return '$count transactions permanently deleted';
  }

  @override
  String get txnRecycleSortByDeleteTime => 'Delete Time';

  @override
  String get txnRecycleSortByAmount => 'Amount';

  @override
  String get txnRecycleSortByDate => 'Transaction Date';

  @override
  String get txnRecycleGroupToday => 'Today';

  @override
  String get txnRecycleGroupWeek => 'This Week';

  @override
  String get txnRecycleGroupEarlier => 'Earlier';

  @override
  String get txnRecycleFilterAll => 'All';

  @override
  String get txnRecycleFilterExpense => 'Expense';

  @override
  String get txnRecycleFilterIncome => 'Income';

  @override
  String get bookPermanentDelete => 'Permanently Delete';

  @override
  String bookPermanentDeleteConfirm(String name) {
    return 'Permanently delete \"$name\"?\nAll data will be removed. This cannot be undone.';
  }

  @override
  String bookCountUnit(String count) {
    return '$count items';
  }

  @override
  String get bookTypePersonal => 'Personal';

  @override
  String get bookTypeFamily => 'Family';

  @override
  String get bookTypeTravel => 'Travel';

  @override
  String get bookTypeBusiness => 'Business';

  @override
  String get bookTypeCouple => 'Couple';

  @override
  String get bookTypeStudent => 'Student';

  @override
  String get bookTypeWedding => 'Wedding';

  @override
  String get bookTypeRental => 'Rent';

  @override
  String get bookTypeInvestment => 'Invest';

  @override
  String get bookTypePet => 'Pet';

  @override
  String get bookTypeHealth => 'Medical';

  @override
  String get bookTypeEvent => 'Event';

  @override
  String get bookTypeOther => 'Other';

  @override
  String get bookTypeCustom => 'Custom';

  @override
  String get bookTypeCustomHint => 'Enter custom type';

  @override
  String get bookDetailTitle => 'Account Book Details';

  @override
  String get bookDetailNotExist => 'Account book does not exist';

  @override
  String get bookDetailExpenseCount => 'Transaction Count';

  @override
  String get bookDetailNormalSection => 'General';

  @override
  String get bookDetailSetDefault => 'Set as Default Account Book';

  @override
  String get bookDetailSwitchTo => 'Switch to This Book';

  @override
  String get bookDetailDangerSection => 'Danger Zone';

  @override
  String get bookDetailClearData => 'Clear Book Data';

  @override
  String get bookDetailDefaultNotDeletable =>
      'Current account book cannot be deleted';

  @override
  String get bookDetailSetDefaultSuccess => 'Set as default account book';

  @override
  String get bookDetailClearTitle => 'Clear Data';

  @override
  String bookDetailClearConfirm(String name) {
    return 'Are you sure you want to clear all transactions and conversation history in \"$name\"?\n\nThis action cannot be undone.';
  }

  @override
  String get bookDetailClear => 'Clear';

  @override
  String get bookDetailCleared => 'Data cleared';

  @override
  String bookDetailDeleteConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?\n\nThe book will be moved to the recycle bin. Data will not be lost.';
  }

  @override
  String get bookDetailTypePersonal => 'Personal Book';

  @override
  String get bookDetailTypeFamily => 'Family Book';

  @override
  String get bookDetailTypeTravel => 'Travel Book';

  @override
  String get bookDetailTypeBusiness => 'Business Book';

  @override
  String get bookDetailTypeOther => 'Other';

  @override
  String get reportTitle => 'Report Analysis';

  @override
  String get reportPeriodWeek => 'Week';

  @override
  String get reportPeriodMonth => 'Month';

  @override
  String get reportPeriodYear => 'Year';

  @override
  String get reportTypeExpense => 'Expense';

  @override
  String get reportTypeIncome => 'Income';

  @override
  String get reportTotalExpense => 'Total Expenses';

  @override
  String get reportTotalIncome => 'Total Income';

  @override
  String get reportCount => 'Count';

  @override
  String reportCountUnit(String count) {
    return '$count items';
  }

  @override
  String get reportDailyAverage => 'Daily Avg';

  @override
  String get reportCategoryCount => 'Categories';

  @override
  String reportCategoryCountUnit(String count) {
    return '$count';
  }

  @override
  String get reportCategoryDistribution => 'Category Distribution';

  @override
  String get reportCategoryRanking => 'Category Ranking';

  @override
  String get reportNoData => 'No data available';

  @override
  String reportMonthLabel(String year, String month) {
    return '$month/$year';
  }

  @override
  String reportYearLabel(String year) {
    return '$year';
  }

  @override
  String reportWeekLabel(String start, String end) {
    return '$start - $end';
  }

  @override
  String get securityLockSettings => 'Password Lock Settings';

  @override
  String get securityEnableLock => 'Enable Password Lock';

  @override
  String get securityUnlockMethods => 'Unlock Methods (multiple allowed)';

  @override
  String get securityPinCode => 'PIN Code';

  @override
  String get securityPinCodeDesc => 'Unlock with a 4-digit PIN';

  @override
  String get securityBiometric => 'Fingerprint';

  @override
  String get securityBiometricDesc => 'Quick unlock with device fingerprint';

  @override
  String get securityPatternLock => 'Pattern Lock';

  @override
  String get securityPatternLockDesc => 'Unlock by drawing a pattern';

  @override
  String get securityLockHint =>
      'When multiple unlock methods are selected, a switch button will appear on the unlock screen. Fingerprint unlock requires device biometric support.';

  @override
  String get securityBiometricVerify =>
      'Verify fingerprint to enable fingerprint unlock';

  @override
  String securityBiometricFail(String error) {
    return 'Fingerprint verification failed: $error';
  }

  @override
  String get securitySetPinLock => 'Set PIN Lock';

  @override
  String get securitySetPinTitle => 'Set a 4-digit PIN';

  @override
  String get securityConfirmPinTitle => 'Please re-enter the new PIN';

  @override
  String get securityEnterPin => 'Enter PIN to unlock';

  @override
  String get securityPinWrong => 'Incorrect PIN, please try again';

  @override
  String get securityPinMismatch => 'PINs do not match, please try again';

  @override
  String get securityPinSetSuccess => 'PIN set successfully';

  @override
  String get securitySetPatternLock => 'Set Pattern Lock';

  @override
  String get securityDrawPattern => 'Draw unlock pattern';

  @override
  String get securityConfirmPattern =>
      'Please draw the pattern again to confirm';

  @override
  String get securityDrawToUnlock => 'Draw pattern to unlock';

  @override
  String get securityPatternHint => 'Connect at least 4 dots';

  @override
  String get securityConfirmPatternHint =>
      'Please draw the same pattern as before';

  @override
  String get securityRedraw => 'Redraw';

  @override
  String get securityPatternMinDots => 'Please connect at least 4 dots';

  @override
  String get securityPatternMismatch =>
      'Patterns do not match, please draw again';

  @override
  String get securityPatternSetSuccess => 'Pattern set successfully';

  @override
  String get securityPatternWrong => 'Incorrect pattern, please try again';

  @override
  String get securityAuthRequired =>
      'Please verify your identity to unlock the app';

  @override
  String get securitySelectUnlockMethod => 'Select unlock method';

  @override
  String get securitySwitchUnlockMethod => 'Switch unlock method';

  @override
  String get securityVerifyFingerprint => 'Please verify your fingerprint';

  @override
  String get securityTouchToUnlock => 'Touch the fingerprint sensor to unlock';

  @override
  String get securityRetryFingerprint => 'Retry fingerprint';

  @override
  String get checkinTitle => 'Check-in Calendar';

  @override
  String get checkinAlreadyCheckedIn => 'Already checked in today';

  @override
  String get checkinCheckInSuccess => 'Check-in successful! +10 AC Coins';

  @override
  String get checkinRewardDaily => 'Daily check-in reward';

  @override
  String get checkinStreak365 => '365-day streak! +2000 AC Coins';

  @override
  String get checkinStreak180 => '180-day streak! +1000 AC Coins';

  @override
  String get checkinStreak30 => '30-day streak! +300 AC Coins';

  @override
  String get checkinStreak7 => '7-day streak! +70 AC Coins';

  @override
  String get checkinReward365 => '365-day streak reward';

  @override
  String get checkinReward180 => '180-day streak reward';

  @override
  String get checkinReward30 => '30-day streak reward';

  @override
  String get checkinReward7 => '7-day streak reward';

  @override
  String get checkinMakeupSelectHint => 'Please select an unchecked date first';

  @override
  String get checkinMakeupFutureError => 'You can only make up for past dates';

  @override
  String get checkinMakeupAlreadyChecked => 'This date is already checked in';

  @override
  String get checkinMakeupInsufficient =>
      'Insufficient AC Coins. Makeup check-in costs 100 AC Coins';

  @override
  String get checkinMakeupConfirmTitle => 'Makeup Check-in';

  @override
  String checkinMakeupConfirmContent(String date, String balance) {
    return 'Make up check-in for $date?\nThis will cost 100 AC Coins (current balance: $balance)';
  }

  @override
  String get checkinMakeupConfirm => 'Confirm Makeup';

  @override
  String get checkinMakeupSuccess => 'Makeup check-in successful!';

  @override
  String checkinMakeupCost(String date) {
    return 'Makeup for $date';
  }

  @override
  String get checkinConsecutiveDays => 'Consecutive Days';

  @override
  String get checkinAcBalance => 'AC Coin Balance';

  @override
  String get checkinTodayStatus => 'Today\'s Status';

  @override
  String get checkinMakeupButton => 'Makeup (-100 AC Coins)';

  @override
  String get checkinMakeupSelectButton => 'Select a date to make up';

  @override
  String get checkinTodayCheckIn => 'Checked In';

  @override
  String get checkinTodayCheckInButton => 'Check in +10';

  @override
  String get acCoinTitle => 'AC Coin History';

  @override
  String get acCoinCurrentBalance => 'Current Balance';

  @override
  String get acCoinEmpty => 'No AC Coin records';

  @override
  String get catExpenseFood => 'Food & Dining';

  @override
  String get catExpenseTransport => 'Transportation';

  @override
  String get catExpenseHousing => 'Housing';

  @override
  String get catExpenseClothing => 'Clothing & Beauty';

  @override
  String get catExpenseDaily => 'Daily Necessities';

  @override
  String get catExpenseTech => 'Tech & Electronics';

  @override
  String get catExpenseMedical => 'Medical & Health';

  @override
  String get catExpenseEducation => 'Education';

  @override
  String get catExpenseEntertainment => 'Entertainment';

  @override
  String get catExpenseSocial => 'Social & Gifts';

  @override
  String get catExpenseChildren => 'Children';

  @override
  String get catExpenseElderly => 'Elderly Care';

  @override
  String get catExpensePet => 'Pets';

  @override
  String get catExpenseWork => 'Work & Office';

  @override
  String get catExpenseFinance => 'Finance & Insurance';

  @override
  String get catExpenseOther => 'Other Expenses';

  @override
  String get catIncomeSalary => 'Salary';

  @override
  String get catIncomeInvestment => 'Investment';

  @override
  String get catIncomeSideJob => 'Side Jobs';

  @override
  String get catIncomeGift => 'Gifts & Red Packets';

  @override
  String get catIncomeRefund => 'Refunds';

  @override
  String get catIncomeAsset => 'Rent & Assets';

  @override
  String get catIncomeTransferIn => 'Transfer In';

  @override
  String get catIncomeOther => 'Other Income';

  @override
  String get catOtherTransfer => 'Transfer';

  @override
  String get catOtherRepayment => 'Repayment';

  @override
  String get catOtherSocial => 'Social Occasions';

  @override
  String get catSubFoodBreakfast => 'Breakfast';

  @override
  String get catSubFoodLunch => 'Lunch';

  @override
  String get catSubFoodDinner => 'Dinner';

  @override
  String get catSubFoodLateSnack => 'Late Night Snack';

  @override
  String get catSubFoodDelivery => 'Takeout Delivery';

  @override
  String get catSubFoodMilkTea => 'Milk Tea';

  @override
  String get catSubFoodCoffee => 'Coffee';

  @override
  String get catSubFoodDrinks => 'Beverages';

  @override
  String get catSubFoodDessert => 'Desserts';

  @override
  String get catSubFoodSnacks => 'Snacks';

  @override
  String get catSubFoodFruit => 'Fruit';

  @override
  String get catSubFoodGroceries => 'Groceries';

  @override
  String get catSubFoodDiningOut => 'Dining Out';

  @override
  String get catSubTransportMetro => 'Subway';

  @override
  String get catSubTransportBus => 'Bus';

  @override
  String get catSubTransportTaxi => 'Taxi';

  @override
  String get catSubTransportRideshare => 'Rideshare';

  @override
  String get catSubTransportBikeShare => 'Bike Share';

  @override
  String get catSubTransportHighSpeedRail => 'High-Speed Rail';

  @override
  String get catSubTransportTrain => 'Train';

  @override
  String get catSubTransportFlight => 'Flight';

  @override
  String get catSubTransportFuel => 'Fuel';

  @override
  String get catSubTransportCharging => 'EV Charging';

  @override
  String get catSubTransportParking => 'Parking';

  @override
  String get catSubTransportToll => 'Toll';

  @override
  String get catSubTransportMaintenance => 'Car Maintenance';

  @override
  String get catSubTransportRepair => 'Car Repair';

  @override
  String get catSubTransportInsurance => 'Car Insurance';

  @override
  String get catSubHousingRent => 'Rent';

  @override
  String get catSubHousingMortgage => 'Mortgage';

  @override
  String get catSubHousingWater => 'Water Bill';

  @override
  String get catSubHousingElectricity => 'Electricity';

  @override
  String get catSubHousingGas => 'Gas';

  @override
  String get catSubHousingPropertyFee => 'HOA Fee';

  @override
  String get catSubHousingInternet => 'Internet';

  @override
  String get catSubHousingPhone => 'Phone Bill';

  @override
  String get catSubHousingCleaning => 'Cleaning Service';

  @override
  String get catSubHousingRepair => 'Home Repair';

  @override
  String get catSubClothingApparel => 'Clothing';

  @override
  String get catSubClothingShoes => 'Shoes';

  @override
  String get catSubClothingHats => 'Hats';

  @override
  String get catSubClothingBags => 'Bags';

  @override
  String get catSubClothingCosmetics => 'Cosmetics';

  @override
  String get catSubClothingSkincare => 'Skincare';

  @override
  String get catSubClothingHaircut => 'Haircut';

  @override
  String get catSubClothingManicure => 'Manicure';

  @override
  String get catSubClothingJewelry => 'Jewelry';

  @override
  String get catSubClothingAccessories => 'Accessories';

  @override
  String get catSubDailyNecessities => 'Daily Necessities';

  @override
  String get catSubDailyCleaning => 'Cleaning Supplies';

  @override
  String get catSubDailyKitchen => 'Kitchen Supplies';

  @override
  String get catSubDailyDecor => 'Home Decor';

  @override
  String get catSubDailyStorage => 'Storage';

  @override
  String get catSubDailyBedding => 'Bedding';

  @override
  String get catSubDailyTissue => 'Paper Products';

  @override
  String get catSubTechPhone => 'Phone';

  @override
  String get catSubTechComputer => 'Computer';

  @override
  String get catSubTechAccessories => 'Accessories';

  @override
  String get catSubTechConsumables => 'Consumables';

  @override
  String get catSubTechStorage => 'Storage Devices';

  @override
  String get catSubMedicalRegistration => 'Clinic Registration';

  @override
  String get catSubMedicalMedicine => 'Medicine';

  @override
  String get catSubMedicalHospitalization => 'Hospitalization';

  @override
  String get catSubMedicalCheckup => 'Health Checkup';

  @override
  String get catSubMedicalDental => 'Dental';

  @override
  String get catSubMedicalEyeCare => 'Eye Care';

  @override
  String get catSubMedicalVaccine => 'Vaccine';

  @override
  String get catSubMedicalWellness => 'Wellness';

  @override
  String get catSubMedicalFitness => 'Fitness';

  @override
  String get catSubEducationBooks => 'Books';

  @override
  String get catSubEducationTuition => 'Tuition';

  @override
  String get catSubEducationTraining => 'Training';

  @override
  String get catSubEducationExam => 'Exam Fees';

  @override
  String get catSubEducationOnlineCourse => 'Online Courses';

  @override
  String get catSubEducationStationery => 'Stationery';

  @override
  String get catSubEntertainmentMovies => 'Movies';

  @override
  String get catSubEntertainmentKtv => 'Karaoke';

  @override
  String get catSubEntertainmentGaming => 'Gaming Top-up';

  @override
  String get catSubEntertainmentSubscription => 'Subscriptions';

  @override
  String get catSubEntertainmentTickets => 'Attraction Tickets';

  @override
  String get catSubEntertainmentHotel => 'Hotel';

  @override
  String get catSubEntertainmentTravel => 'Travel';

  @override
  String get catSubEntertainmentShow => 'Shows & Concerts';

  @override
  String get catSubEntertainmentStreaming => 'Streaming Services';

  @override
  String get catSubSocialGift => 'Gifts';

  @override
  String get catSubSocialRedPacket => 'Red Packets';

  @override
  String get catSubSocialWeddingGift => 'Wedding Gifts';

  @override
  String get catSubSocialTreat => 'Treating Others';

  @override
  String get catSubSocialBirthday => 'Birthday Parties';

  @override
  String get catSubSocialVisit => 'Visiting the Sick';

  @override
  String get catSubSocialRespect => 'Elderly Respect';

  @override
  String get catSubSocialCharity => 'Charitable Donations';

  @override
  String get catSubChildrenFormula => 'Baby Formula';

  @override
  String get catSubChildrenDiapers => 'Diapers & Supplies';

  @override
  String get catSubChildrenTuition => 'Tuition';

  @override
  String get catSubChildrenHobby => 'Hobby Classes';

  @override
  String get catSubChildrenTutoring => 'Tutoring';

  @override
  String get catSubChildrenDaycare => 'Daycare';

  @override
  String get catSubChildrenToys => 'Toys';

  @override
  String get catSubElderlySupport => 'Support Allowance';

  @override
  String get catSubElderlyNutrition => 'Nutrition Supplements';

  @override
  String get catSubElderlyMedical => 'Medical Expenses';

  @override
  String get catSubElderlyAllowance => 'Gift Money';

  @override
  String get catSubPetFood => 'Pet Food';

  @override
  String get catSubPetMedical => 'Pet Medical';

  @override
  String get catSubPetSupplies => 'Pet Supplies';

  @override
  String get catSubPetGrooming => 'Pet Grooming';

  @override
  String get catSubWorkOffice => 'Office Supplies';

  @override
  String get catSubWorkPrinting => 'Printing & Copying';

  @override
  String get catSubWorkShipping => 'Shipping & Delivery';

  @override
  String get catSubWorkTravel => 'Business Travel';

  @override
  String get catSubFinanceInsurance => 'Insurance Premium';

  @override
  String get catSubFinanceLoss => 'Investment Loss';

  @override
  String get catSubFinanceFee => 'Service Fee';

  @override
  String get catSubFinanceLoanInterest => 'Loan Interest';

  @override
  String get catSubFinanceTax => 'Tax';

  @override
  String get catSubFinanceFine => 'Fine & Penalty';

  @override
  String get catSubOtherExpenseGeneral => 'Other Expenses';

  @override
  String get catSubOtherExpenseUnexpected => 'Unexpected Expenses';

  @override
  String get catSubSalaryBase => 'Base Salary';

  @override
  String get catSubSalaryBonus => 'Performance Bonus';

  @override
  String get catSubSalaryOvertime => 'Overtime Pay';

  @override
  String get catSubSalaryYearEnd => 'Year-End Bonus';

  @override
  String get catSubSalaryBackPay => 'Retroactive Pay';

  @override
  String get catSubSalaryAllowance => 'Allowances';

  @override
  String get catSubInvestmentFund => 'Fund Returns';

  @override
  String get catSubInvestmentStock => 'Stock Returns';

  @override
  String get catSubInvestmentInterest => 'Interest Income';

  @override
  String get catSubInvestmentWealthMgmt => 'Wealth Management';

  @override
  String get catSubInvestmentCrypto => 'Cryptocurrency';

  @override
  String get catSubInvestmentDividend => 'Dividends';

  @override
  String get catSubSideJobPartTime => 'Part-Time Income';

  @override
  String get catSubSideJobFreelance => 'Freelance';

  @override
  String get catSubSideJobRoyalty => 'Royalties';

  @override
  String get catSubSideJobCommission => 'Commission';

  @override
  String get catSubSideJobSales => 'Sales Income';

  @override
  String get catSubGiftRedPacket => 'Red Packet Income';

  @override
  String get catSubGiftPresent => 'Gift Money';

  @override
  String get catSubGiftFestival => 'Festival Red Packets';

  @override
  String get catSubRefundReimbursement => 'Reimbursement';

  @override
  String get catSubRefundReturn => 'Refund';

  @override
  String get catSubRefundMedical => 'Medical Insurance Reimbursement';

  @override
  String get catSubRefundInsurance => 'Insurance Claim';

  @override
  String get catSubAssetRent => 'Rental Income';

  @override
  String get catSubAssetIdleSale => 'Selling Idle Items';

  @override
  String get catSubAssetSecondhand => 'Secondhand Sales';

  @override
  String get catSubAssetProfit => 'Asset Returns';

  @override
  String get catSubTransferInBank => 'Bank Transfer In';

  @override
  String get catSubTransferInWallet => 'Wallet Transfer In';

  @override
  String get catSubTransferInDebt => 'Debt Recovery';

  @override
  String get catSubIncomeOtherWindfall => 'Windfall';

  @override
  String get catSubIncomeOtherSubsidy => 'Government Subsidy';

  @override
  String get catSubIncomeOtherUncategorized => 'Uncategorized';

  @override
  String get catSubTransferBankIn => 'Bank Transfer In';

  @override
  String get catSubTransferBankOut => 'Bank Transfer Out';

  @override
  String get catSubTransferWallet => 'Wallet Transfer';

  @override
  String get catSubTransferCrossIn => 'Cross-Platform In';

  @override
  String get catSubTransferCrossOut => 'Cross-Platform Out';

  @override
  String get catSubRepaymentCreditCard => 'Credit Card Payment';

  @override
  String get catSubRepaymentLoan => 'Loan Payment';

  @override
  String get catSubRepaymentBorrowed => 'Repaying a Loan';

  @override
  String get catSubRepaymentLent => 'Lending Money';

  @override
  String get catSubOtherSocialGift => 'Wedding Gift Money';

  @override
  String get catSubOtherSocialWedding => 'Weddings & Funerals';

  @override
  String get catSubOtherSocialBirthday => 'Birthday Parties';

  @override
  String get catSubOtherSocialFestival => 'Festival Red Packets';

  @override
  String get weekMon => 'M';

  @override
  String get weekTue => 'T';

  @override
  String get weekWed => 'W';

  @override
  String get weekThu => 'T';

  @override
  String get weekFri => 'F';

  @override
  String get weekSat => 'S';

  @override
  String get weekSun => 'S';

  @override
  String get weekMonFull => 'Mon';

  @override
  String get weekTueFull => 'Tue';

  @override
  String get weekWedFull => 'Wed';

  @override
  String get weekThuFull => 'Thu';

  @override
  String get weekFriFull => 'Fri';

  @override
  String get weekSatFull => 'Sat';

  @override
  String get weekSunFull => 'Sun';

  @override
  String get commonSelectDateTime => 'Select Date & Time';

  @override
  String get commonBack => 'Back';

  @override
  String get commonDone => 'Done';

  @override
  String get commonAdd => 'Add';

  @override
  String commonEnterHint(String field) {
    return 'Enter $field';
  }

  @override
  String get txnCategorySearch => 'Search categories...';

  @override
  String get txnCategoryEmpty => 'No categories';

  @override
  String get settingsSelectLanguage => 'Select Language';

  @override
  String get settingsSelectCurrency => 'Select Currency';

  @override
  String get profileDefaultNickname => 'User';

  @override
  String get catManageTitle => 'Category Management';

  @override
  String catManageSubTitle(String name) {
    return '$name - Subcategories';
  }

  @override
  String get catManageAddSub => 'Add Subcategory';

  @override
  String get catManageNameExists => 'Category name already exists';

  @override
  String get catManageSubNameExists => 'Subcategory name already exists';

  @override
  String get catManageDeleteTitle => 'Confirm Delete';

  @override
  String catManageDeleteWithChildren(String name) {
    return 'Delete category \"$name\" and all its subcategories?';
  }

  @override
  String catManageDeleteConfirm(String name) {
    return 'Delete category \"$name\"?';
  }

  @override
  String get catManageDeleteBlocked =>
      'This category has linked data and cannot be deleted';

  @override
  String get catManageCustomBadge => 'C';

  @override
  String get catManageCustom => 'Custom';

  @override
  String catManageAddTitle(String type) {
    return 'Add $type Category';
  }

  @override
  String get catManageNameLabel => 'Category Name';

  @override
  String get catManageNameHint => 'Enter category name';

  @override
  String get catManageSelectIcon => 'Select Icon';

  @override
  String get catManageSelectColor => 'Select Color';

  @override
  String catManageAddSubTitle(String name) {
    return 'Add Subcategory - $name';
  }

  @override
  String get catManageSubNameLabel => 'Subcategory Name';

  @override
  String get catManageSubNameHint => 'Enter subcategory name';

  @override
  String get catManageEditTitle => 'Edit Category';

  @override
  String get bookNameLabel => 'Book Name';

  @override
  String get bookNameHint => 'e.g. Daily Expenses';

  @override
  String get bookTypeLabel => 'Book Type';

  @override
  String get bookDescLabel => 'Note (optional)';

  @override
  String get bookDescHint => 'Briefly describe the purpose';

  @override
  String get bookCreateButton => 'Create';

  @override
  String get bookDescPersonal => 'Daily personal expenses';

  @override
  String get bookDescFamily => 'Shared family expenses';

  @override
  String get bookDescTravel => 'Travel expense tracking';

  @override
  String get bookDescBusiness => 'Side business income & expenses';

  @override
  String get bookDescOther => 'Custom purpose';

  @override
  String get aiPresetDeepseekNote => 'Cost-effective Chinese LLM';

  @override
  String get aiPresetOpenaiNote => 'Requires overseas network access';

  @override
  String get aiPresetQwenName => 'Tongyi Qianwen (Alibaba)';

  @override
  String get aiPresetQwenNote => 'Uses compatible mode URL';

  @override
  String get aiPresetDoubaoName => 'Doubao (ByteDance)';

  @override
  String get aiPresetDoubaoNote =>
      'Create an inference endpoint on Volcano Ark, use endpoint ID as model name';

  @override
  String get aiPresetZhipuName => 'Zhipu AI';

  @override
  String get aiPresetZhipuNote => 'glm-4-flash has free quota';

  @override
  String get aiPresetKimiName => 'Moonshot (Kimi)';

  @override
  String get aiPresetKimiNote => 'Excels at long text understanding';

  @override
  String get aiPresetClaudeNote => 'Uses Anthropic Messages API';

  @override
  String get aiPresetMimoName => 'Xiaomi MiMo';

  @override
  String get aiPresetMimoNote =>
      'Supports OpenAI/Anthropic compatible protocols, multi-region clusters';

  @override
  String get aiPresetOllamaName => 'Ollama (Local)';

  @override
  String get aiPresetOllamaNote =>
      'Requires local Ollama service, model names depend on local installation';

  @override
  String get llmCapTextLabel => 'Text Model';

  @override
  String get llmCapTextDesc => 'For bookkeeping parsing and AI conversations';

  @override
  String get llmCapVisionLabel => 'Vision Model';

  @override
  String get llmCapVisionDesc =>
      'For photo recognition of receipts and invoices';

  @override
  String get llmCapAudioLabel => 'Voice Model';

  @override
  String get llmCapAudioDesc => 'For voice-to-text transcription';

  @override
  String get currencyCny => 'Chinese Yuan (CNY)';

  @override
  String get currencyUsd => 'US Dollar (USD)';

  @override
  String get currencyKrw => 'Korean Won (KRW)';

  @override
  String get currencyJpy => 'Japanese Yen (JPY)';

  @override
  String get currencyEur => 'Euro (EUR)';

  @override
  String get currencyGbp => 'British Pound (GBP)';

  @override
  String get currencyUnitYi => '00M';

  @override
  String get currencyUnitWan => '0K';

  @override
  String get inputSourceText => 'Text';

  @override
  String get inputSourceVoice => 'Voice';

  @override
  String get inputSourceImage => 'Image';

  @override
  String reportTrendMonth(String period) {
    return '$period';
  }

  @override
  String reportTrendDay(String period) {
    return '$period';
  }

  @override
  String get llmSettingsTitle => 'AI Service Config';

  @override
  String get llmExportConfig => 'Export Config';

  @override
  String get llmImportConfig => 'Import Config';

  @override
  String get llmProviderManagement => 'Provider Management';

  @override
  String get llmAddProvider => 'Add Provider';

  @override
  String get llmEditProvider => 'Edit Provider';

  @override
  String get llmDeleteProvider => 'Delete Provider';

  @override
  String llmDeleteProviderConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get llmNotConfigured => 'Not configured';

  @override
  String get llmConfigured => 'Configured';

  @override
  String get llmNoProviders => 'No providers added yet';

  @override
  String get llmUnnamedProvider => 'Unnamed provider';

  @override
  String get llmInUse => 'In use';

  @override
  String get llmIncomplete => 'Incomplete';

  @override
  String get llmTest => 'Test';

  @override
  String get llmConfigIncomplete =>
      'Please complete the configuration first (API Key, URL, and at least one model required)';

  @override
  String get llmConnectSuccess => '✅ Connection successful';

  @override
  String get llmConnectFail =>
      '❌ Connection failed, please check URL, Key and model name';

  @override
  String get llmConfigCopied => 'Config copied to clipboard';

  @override
  String get llmClipboardEmpty => 'Clipboard is empty';

  @override
  String llmImported(String count) {
    return 'Imported $count provider(s)';
  }

  @override
  String get llmImportFailed => 'Import failed, please check JSON format';

  @override
  String get llmProviderNotConfigured =>
      'This provider has no API Key or URL configured, please edit first';

  @override
  String llmModelsFetched(String count, String label) {
    return 'Fetched $count $label';
  }

  @override
  String llmModelsFetchedAll(String count) {
    return 'Fetched $count models (no specialized models found, showing all)';
  }

  @override
  String get llmFetchFailed => 'Fetch failed, loaded preset model list';

  @override
  String llmFetchError(String error) {
    return 'Failed to fetch models: $error';
  }

  @override
  String llmModelSet(String capability, String provider, String model) {
    return 'Set $capability: $provider · $model';
  }

  @override
  String llmInputModelName(String capability) {
    return 'Enter $capability name';
  }

  @override
  String get llmConnectFailed => 'Connection failed';

  @override
  String get llmAutoDetectInterval => 'Auto detect interval';

  @override
  String get llmIntervalOff => 'Off';

  @override
  String get llmInterval10s => '10s';

  @override
  String get llmInterval30s => '30s';

  @override
  String get llmInterval1m => '1min';

  @override
  String get llmInterval2m => '2min';

  @override
  String get llmInterval5m => '5min';

  @override
  String get llmInterval10m => '10min';

  @override
  String get llmInterval30m => '30min';

  @override
  String get llmInterval1h => '1hr';

  @override
  String llmConfigureCap(String label) {
    return 'Configure $label';
  }

  @override
  String get llmCurrentUse => 'Currently in use';

  @override
  String get llmFetch => 'Fetch';

  @override
  String get llmTesting => 'Testing...';

  @override
  String get llmTestConnection => 'Test connection';

  @override
  String get llmFailed => 'Failed';

  @override
  String llmSelectCap(String label) {
    return 'Select $label';
  }

  @override
  String get llmManualInput => '✏️ Manual input...';

  @override
  String get llmFillApiKey => 'Please enter API Key and request URL';

  @override
  String get llmCustom => 'Custom';

  @override
  String get llmProviderName => 'Provider Name';

  @override
  String get llmApiUrl => 'API URL';

  @override
  String get llmApiUrlHintAnthropic =>
      'Anthropic API URL, e.g. https://api.anthropic.com';

  @override
  String get llmApiUrlHelper =>
      'Enter the API base_url, no need to append /chat/completions';

  @override
  String get llmSaveHint =>
      'After saving, go back to configure models via capability cards';

  @override
  String get llmInputApiKey => 'Enter API Key';

  @override
  String get llmApiUrlExample => 'e.g. https://api.example.com';

  @override
  String get llmAdvancedSettings => 'Advanced Settings';

  @override
  String get llmTemperature => 'Response Style';

  @override
  String get llmTemperatureHint =>
      'Lower = more precise and stable, Higher = more diverse and creative';

  @override
  String get llmTemperaturePrecise => 'Precise';

  @override
  String get llmTemperatureCreative => 'Creative';

  @override
  String get llmMaxToken => 'Max Token';

  @override
  String get llmTimeout => 'Timeout (seconds)';

  @override
  String get llmErrorNoModelForCapability =>
      'No model configured for this capability';

  @override
  String get llmErrorNoProviderConfigured =>
      'Please add and configure an AI provider in Settings first';

  @override
  String get llmErrorNoProviderOrInput =>
      'Please add an AI provider in Settings, or provide a more specific description';

  @override
  String get llmErrorCannotParseResponse => 'Unable to parse AI response';

  @override
  String get llmErrorInvalidResponseFormat => 'Invalid AI response format';

  @override
  String llmErrorParseFailed(String error) {
    return 'Failed to parse AI response: $error';
  }

  @override
  String get llmErrorTimeout =>
      'Request timed out, please check your network connection';

  @override
  String get llmErrorInvalidApiKey => 'Invalid API Key, please check Settings';

  @override
  String get llmErrorRateLimit => 'Too many requests, please try again later';

  @override
  String get llmErrorForbidden =>
      'Access denied, please check API Key permissions';

  @override
  String llmErrorRequestFailed(String code) {
    return 'Request failed ($code)';
  }

  @override
  String get llmErrorNetworkFailed =>
      'Network connection failed, please check your network';

  @override
  String llmErrorRequestFailedWithMessage(String message) {
    return 'Request failed: $message';
  }

  @override
  String get visionErrorNoModelConfigured =>
      'Vision model not configured. Please configure it in AI Settings';

  @override
  String get visionErrorImageNotFound => 'Image file not found';

  @override
  String visionErrorRecognitionFailed(String message) {
    return 'Image recognition failed: $message';
  }

  @override
  String get voiceErrorNoModelConfigured =>
      'Voice model not configured. Please configure it in AI Settings';

  @override
  String get voiceErrorNoEngineAvailable =>
      'No voice recognition engine available. Device native STT not supported — please configure a Whisper cloud model in AI Settings';

  @override
  String get voiceErrorAudioNotFound => 'Audio file not found';

  @override
  String get voiceErrorInvalidResponseFormat =>
      'Voice recognition returned invalid format';

  @override
  String voiceErrorTranscriptionFailed(String message) {
    return 'Voice recognition failed: $message';
  }

  @override
  String get voiceErrorEndpointNotFound =>
      'Whisper API endpoint not found. Please check supplier Base URL';

  @override
  String get pipelineErrorEmptyVoiceResult =>
      'Voice recognition returned empty, please record again';

  @override
  String get pipelineErrorEmptyImageResult =>
      'Image recognition returned empty, please choose a clearer image';

  @override
  String get acCoinInitialGiftDesc => 'New user registration gift';

  @override
  String get loadFailedPullToRefresh => 'Failed to load, pull to refresh';

  @override
  String get llmSettingsGetModelListError => 'Failed to get model list';

  @override
  String get searchPageTitle => 'Search Transactions';

  @override
  String get searchHint =>
      'Enter keywords or natural language, e.g. \'how much on taxis last month\'';

  @override
  String get searchAiParsing => 'AI is understanding your query...';

  @override
  String get searchNoResults => 'No matching transactions found';

  @override
  String get searchNoResultsHint => 'Try different keywords or rephrase';

  @override
  String searchResultCount(String count) {
    return 'Found $count results';
  }

  @override
  String get searchAiSummaryTitle => '📊 AI Analysis';

  @override
  String get searchAiSummaryLoading => 'AI is analyzing...';

  @override
  String get searchTotalExpense => 'Total Expense';

  @override
  String get searchTotalIncome => 'Total Income';

  @override
  String searchTransactionCount(String count) {
    return '$count transactions';
  }

  @override
  String get searchAverage => 'Daily Avg';

  @override
  String get searchMaxSingle => 'Largest';

  @override
  String get searchLlmNotConfigured => 'AI not configured, keyword search only';

  @override
  String get searchLlmError =>
      'AI query parsing failed, switched to keyword search';

  @override
  String get searchQuickSuggestions => 'Suggestions';

  @override
  String get searchSuggestionLastMonthExpense => 'Last month expenses';

  @override
  String get searchSuggestionThisMonthFood => 'This month food expenses';

  @override
  String get searchSuggestionRecentLarge => 'Recent large expenses';

  @override
  String get searchSuggestionRecentWeek => 'Recent week transactions';

  @override
  String get searchFilterExpense => 'Expense';

  @override
  String get searchFilterIncome => 'Income';

  @override
  String get searchFilterAll => 'All';

  @override
  String get searchFilterDateRange => 'Date Range';

  @override
  String get searchFilterAmountRange => 'Amount Range';

  @override
  String get searchFilterCategory => 'Category';

  @override
  String get searchFilterPayment => 'Payment';

  @override
  String get searchFilterClear => 'Clear Filters';

  @override
  String get searchModeKeyword => 'Keyword';

  @override
  String get searchModeAi => 'AI Search';

  @override
  String get searchKeywordPlaceholder => 'Search description, notes, amount...';

  @override
  String get searchParsingFailed => 'AI parsing failed';

  @override
  String get llmSupplierManagement => 'Supplier Management';

  @override
  String get llmModelManagement => 'Model Management';

  @override
  String get llmSelectProvider => 'Select Provider';

  @override
  String get llmSelectModel => 'Select Model';

  @override
  String get llmProviderIncomplete => 'Not configured';
}
