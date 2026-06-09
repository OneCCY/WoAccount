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
  String get chatInputVoiceHint => 'Release to send, swipe left to cancel ↖';

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
  String get txnDayFormat => 'MMM d';

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
  String get settingsRestoreData => 'Restore Data';

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
  String get settingsDeleteAccount => 'Delete Account';

  @override
  String get settingsDeleteConfirm =>
      'All data will be permanently deleted. Are you sure you want to continue?';

  @override
  String get budgetTitle => 'Budget Management';

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
  String get bookTitle => 'My Account Books';

  @override
  String get bookCreate => 'New Account Book';

  @override
  String get bookDescription =>
      'Each account book has its own transactions, budgets, and AI conversation history';

  @override
  String get bookDefault => 'Default';

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
  String get bookDeleted => 'Account book deleted';

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
  String get bookTypeOther => 'Other';

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
      'The default account book cannot be deleted';

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
    return 'Are you sure you want to delete \"$name\"?\n\nAll data in this book will be removed. This action cannot be undone.';
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
}
