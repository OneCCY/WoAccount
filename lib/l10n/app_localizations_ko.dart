// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'WoAccount';

  @override
  String get navTransactions => '내역';

  @override
  String get navRecord => '기록';

  @override
  String get navProfile => '프로필';

  @override
  String get commonCancel => '취소';

  @override
  String get commonConfirm => '확인';

  @override
  String get commonEditCategory => '카테고리 수정';

  @override
  String get commonEditAmount => '금액 수정';

  @override
  String get commonEditDescription => '설명 수정';

  @override
  String get commonSave => '저장';

  @override
  String get commonDelete => '삭제';

  @override
  String get chatPageTitle => 'AI 가계부';

  @override
  String get chatPageVoicePlaceholder => '🎤 음성 메시지';

  @override
  String get chatPageImagePlaceholder => '📷 이미지 메시지';

  @override
  String chatPageVoiceTranscription(String text) {
    return '🎤 음성 인식 결과: $text';
  }

  @override
  String chatPageImageRecognition(String text) {
    return '📷 이미지 인식 결과: $text';
  }

  @override
  String get chatPageNoSubcategory => '없음';

  @override
  String get chatPageConfigAiError => '설정에서 AI 서비스를 추가하고 구성해 주세요';

  @override
  String chatPageParseError(String error) {
    return '❌ 분석에 실패했습니다: $error\n\n\"점심 라면 25\"처럼 구체적으로 입력해 주세요';
  }

  @override
  String get chatPageNoCategoryError => '사용 가능한 카테고리가 없습니다. 카테고리 관리에서 추가해 주세요';

  @override
  String chatPageSaveSuccess(
    String amount,
    String category,
    String description,
    String date,
  ) {
    return '✅ 저장 완료\n$amount · $category\n$description · $date';
  }

  @override
  String chatPageSaveFailed(String error) {
    return '저장에 실패했습니다: $error';
  }

  @override
  String get chatPageEmptyTitle => '가계부를 시작해 보세요';

  @override
  String get chatPageEmptyHint => '\"점심 라면 25\" 또는 \"식사 24, 세탁 34\"처럼 입력해 보세요';

  @override
  String get chatPageEmptyInstruction =>
      '기록 버튼을 길게 눌러 음성 입력 🎤 · 오른쪽 버튼으로 사진 인식 📷';

  @override
  String get chatPageAiParsing => 'AI 분석 중...';

  @override
  String get chatBubbleImageFailed => '이미지를 불러오지 못했습니다';

  @override
  String get chatInputMicPermission => '마이크 권한을 허용해 주세요';

  @override
  String get chatInputRecordShort => '녹음 시간이 너무 짧습니다';

  @override
  String chatInputImageFailed(String error) {
    return '이미지를 가져오지 못했습니다: $error';
  }

  @override
  String get chatInputCamera => '사진 촬영';

  @override
  String get chatInputGallery => '앨범에서 선택';

  @override
  String get chatInputVoiceHint => '손을 떼면 전송, 왼쪽으로 밀면 취소 ↖';

  @override
  String get chatInputTextHint => '메시지를 입력하세요...';

  @override
  String get chatConfirmTitle => 'AI 분석 결과';

  @override
  String get chatConfirmCategory => '카테고리';

  @override
  String get chatConfirmDescription => '설명';

  @override
  String get chatConfirmDate => '날짜';

  @override
  String get chatConfirmAmount => '금액';

  @override
  String get chatConfirmSave => '저장하기';

  @override
  String get chatConfirmInputCategory => '카테고리 이름 입력';

  @override
  String get chatConfirmInputDescription => '설명 입력';

  @override
  String get chatConfirmInputAmount => '금액 입력';

  @override
  String get homePageAiNotConfigured => 'AI 서비스가 설정되지 않았습니다. 기본 규칙으로 분석합니다';

  @override
  String get homePageGoSettings => '설정으로 이동';

  @override
  String get homePageNoContent => '인식된 내용이 없습니다';

  @override
  String homePageRecordFailed(String error) {
    return '기록에 실패했습니다: $error';
  }

  @override
  String homePageRecordSuccess(String amount) {
    return '기록 완료: $amount';
  }

  @override
  String homePageSaveFailed(String error) {
    return '저장에 실패했습니다: $error';
  }

  @override
  String get homePageBudgetAlert => '오늘 지출이 일일 예산의 80%를 초과했습니다';

  @override
  String get homeInputManual => '직접 입력';

  @override
  String get homeInputHint => '점심 라면 25원';

  @override
  String get homeInputCamera => '사진으로 인식';

  @override
  String get homeConfirmTitle => '🤖 AI 분석 결과';

  @override
  String homeConfirmOriginalInput(String input) {
    return '입력 내용: $input';
  }

  @override
  String get homeConfirmAmount => '💰 금액';

  @override
  String get homeConfirmDate => '📅 날짜';

  @override
  String get homeConfirmCategory => '🍜 카테고리';

  @override
  String get homeConfirmParseTime => '⏱️ 분석 시간';

  @override
  String get homeConfirmDescription => '📝 설명';

  @override
  String get homeConfirmConfidence => '신뢰도';

  @override
  String get homeConfirmEditDate => '날짜 변경';

  @override
  String get homeConfirmRecord => '기록하기';

  @override
  String get homeEntryTitle => 'AI 어시스턴트';

  @override
  String get homeEntrySubtitle => '스마트 가계부 · 소비 분석 · 질의응답';

  @override
  String get homeBudgetDetails => '상세';

  @override
  String get txnSearchHint => '내역 검색';

  @override
  String get txnBudget => '예산';

  @override
  String get txnToday => '오늘';

  @override
  String get txnPeriodDay => '오늘';

  @override
  String get txnPeriodWeek => '이번 주';

  @override
  String get txnPeriodMonth => '이번 달';

  @override
  String txnExpense(String period) {
    return '$period 지출';
  }

  @override
  String txnIncome(String period) {
    return '$period 수입';
  }

  @override
  String get txnBalance => '잔액';

  @override
  String get txnSortByTime => '시간순';

  @override
  String get txnSortByAmount => '금액순';

  @override
  String get txnEmpty => '내역이 없습니다';

  @override
  String get txnDayDetailEmpty => '해당 날짜의 내역이 없습니다';

  @override
  String get txnDayFormat => 'M월 d일';

  @override
  String get txnMonthFormat => 'yyyy년 M월';

  @override
  String txnGroupExpenseLabel(String amount) {
    return '지출 $amount';
  }

  @override
  String txnGroupIncomeLabel(String amount) {
    return '수입 $amount';
  }

  @override
  String get txnGroupUncategorized => '카테고리 없음';

  @override
  String get txnGroupNoSubcategory => '없음';

  @override
  String get viewDay => '일';

  @override
  String get viewWeek => '주';

  @override
  String get viewMonth => '월';

  @override
  String get txnDetailTitle => '내역 상세';

  @override
  String get txnDetailSaved => '저장됨';

  @override
  String get txnDetailDeleteConfirmTitle => '삭제 확인';

  @override
  String get txnDetailDeleteConfirmContent =>
      '삭제하면 복구할 수 없습니다. 이 내역을 삭제하시겠습니까?';

  @override
  String get txnDetailNotFound => '내역을 찾을 수 없습니다';

  @override
  String get txnDetailUncategorized => '카테고리 없음';

  @override
  String get txnDetailCategory => '카테고리';

  @override
  String get txnDetailAmount => '금액';

  @override
  String get txnDetailDate => '날짜';

  @override
  String get txnDetailNote => '메모';

  @override
  String get txnDetailAddNoteHint => '탭하여 메모 추가';

  @override
  String get txnDetailAiRecord => 'AI 분석 기록';

  @override
  String get txnDetailOriginalInput => '입력 내용';

  @override
  String get txnDetailParseSource => '분석 출처';

  @override
  String get txnDetailConfidence => '신뢰도';

  @override
  String get txnDetailCreatedAt => '생성 시간';

  @override
  String get entryTitle => '기록';

  @override
  String get entryBookType => '일상 기록';

  @override
  String get entryExpense => '지출';

  @override
  String get entryIncome => '수입';

  @override
  String get entryOther => '기타';

  @override
  String entrySubCategoryTitle(String name) {
    return '$name - 하위 카테고리';
  }

  @override
  String get entryNoteHint => '메모 추가...';

  @override
  String get entryNumpadToday => '오늘';

  @override
  String get entryNumpadDelete => '삭제';

  @override
  String get entryNumpadDone => '완료';

  @override
  String entrySuccess(String amount) {
    return '기록 완료: $amount';
  }

  @override
  String entryFailure(String error) {
    return '기록에 실패했습니다: $error';
  }

  @override
  String get profileCheckedIn => '출석 완료';

  @override
  String get profileCheckIn => '출석';

  @override
  String get profileConsecutiveDays => '연속 출석';

  @override
  String get profileTotalCheckInDays => '총 출석 일수';

  @override
  String get profileTotalTransactions => '총 기록 건수';

  @override
  String get profileFuncTheme => '테마 전환';

  @override
  String get profileFuncAccountBooks => '내 가계부';

  @override
  String get profileFuncBudget => '예산 관리';

  @override
  String get profileFuncCategories => '카테고리 관리';

  @override
  String get profileFuncReports => '보고서 분석';

  @override
  String get profileToolsAndServices => '도구 및 서비스';

  @override
  String get profileMenuPasswordLock => '비밀번호 잠금';

  @override
  String get profileMenuAcCoins => 'AC코인';

  @override
  String get profileMenuAiConfig => 'AI 설정';

  @override
  String get profileMenuDataBackup => '데이터 백업';

  @override
  String get profileMenuImport => '내역 가져오기';

  @override
  String get profileMenuExport => '내역 내보내기';

  @override
  String get profileMenuFeedback => '사용자 피드백';

  @override
  String get profileMenuSettings => '설정';

  @override
  String profileFeatureComingSoon(String label) {
    return '$label 기능이 곧 출시됩니다';
  }

  @override
  String get profileAlreadyCheckedIn => '오늘 이미 출석했습니다';

  @override
  String get profileCheckInSuccess => '출석 성공!';

  @override
  String profileCheckInFailure(String error) {
    return '출석에 실패했습니다: $error';
  }

  @override
  String get profileThemeLight => '라이트 모드';

  @override
  String get profileThemeDark => '다크 모드';

  @override
  String get profileThemeSystem => '시스템 설정 따르기';

  @override
  String profileUserId(String uid) {
    return 'ID: $uid';
  }

  @override
  String get profileEditTitle => '프로필';

  @override
  String get profileEditNickname => '닉네임';

  @override
  String get profileEditId => 'ID';

  @override
  String get profileEditGender => '성별';

  @override
  String get profileEditEmail => '이메일';

  @override
  String get profileEditPhone => '전화번호';

  @override
  String get profileEditNotSet => '미설정';

  @override
  String get profileEditNotFound => '사용자 프로필을 찾을 수 없습니다';

  @override
  String get profileEditGenderMale => '남성';

  @override
  String get profileEditGenderFemale => '여성';

  @override
  String get profileEditGenderSecret => '비공개';

  @override
  String get profileEditLogout => '로그아웃';

  @override
  String get profileEditLogoutConfirmContent => '로그아웃하시겠습니까?';

  @override
  String get profileEditLogoutExit => '로그아웃';

  @override
  String get profileEditLogoutComingSoon => '로그아웃 기능이 곧 개선됩니다';

  @override
  String get profileEditDeleteAccount => '계정 삭제 요청';

  @override
  String get profileEditDeleteAccountConfirmContent =>
      '계정을 삭제하면 데이터를 복구할 수 없습니다. 삭제를 요청하시겠습니까?';

  @override
  String get profileEditDeleteAccountSubmit => '삭제 요청';

  @override
  String get profileEditDeleteAccountSubmitted => '삭제 요청이 제출되었습니다';

  @override
  String get settingsTitle => '시스템 설정';

  @override
  String get settingsGeneral => '일반';

  @override
  String get settingsLanguage => '언어';

  @override
  String get settingsDarkMode => '다크 모드';

  @override
  String get settingsCurrency => '통화';

  @override
  String get settingsData => '데이터';

  @override
  String get settingsAutoBackup => '자동 백업';

  @override
  String get settingsBackupFrequency => '백업 주기';

  @override
  String get settingsBackupDaily => '매일';

  @override
  String get settingsRestoreData => '데이터 복원';

  @override
  String get settingsAbout => '정보';

  @override
  String get settingsDangerZone => '위험 구역';

  @override
  String get settingsClearData => '모든 데이터 삭제';

  @override
  String get settingsClearConfirm => '이 작업은 되돌릴 수 없습니다. 모든 데이터를 삭제하시겠습니까?';

  @override
  String get settingsDeleteAccount => '계정 삭제';

  @override
  String get settingsDeleteConfirm => '삭제 후 모든 데이터가 영구적으로 삭제됩니다. 계속하시겠습니까?';

  @override
  String get budgetTitle => '예산 관리';

  @override
  String get budgetEmpty => '설정된 예산이 없습니다';

  @override
  String get budgetSetButton => '예산 설정';

  @override
  String get budgetSettingTitle => '예산 설정';

  @override
  String get budgetMonthlyTotal => '이번 달 총 예산';

  @override
  String budgetSpent(String amount) {
    return '사용 $amount';
  }

  @override
  String budgetRemaining(String amount) {
    return '잔여 $amount';
  }

  @override
  String budgetOverSpent(String category, String amount) {
    return '$category 예산을 $amount 초과했습니다';
  }

  @override
  String get budgetUnknownCategory => '카테고리';

  @override
  String get budgetUncategorized => '카테고리 없음';

  @override
  String budgetUsedPercent(String percent) {
    return '$percent% 사용';
  }

  @override
  String budgetCategoryCount(String count) {
    return '$count개 카테고리 예산 설정됨';
  }

  @override
  String get budgetAddCategoryBudget => '카테고리 예산 추가';

  @override
  String get budgetAddCategoryBudgetDeveloping => '카테고리 예산 추가 기능 개발 중';

  @override
  String get budgetEditBudgetDeveloping => '예산 편집 기능 개발 중';

  @override
  String get bookTitle => '내 가계부';

  @override
  String get bookCreate => '새 가계부';

  @override
  String get bookDescription => '각 가계부에는 독립적인 거래 기록, 예산, AI 대화 내역이 있습니다';

  @override
  String get bookDefault => '기본';

  @override
  String get bookMonthlyExpense => '이번 달 지출';

  @override
  String get bookMonthlyIncome => '이번 달 수입';

  @override
  String get bookTransactionCount => '건수';

  @override
  String get bookSetDefault => '기본으로 설정';

  @override
  String get bookDelete => '삭제';

  @override
  String bookSwitchedTo(String name) {
    return '$name(으)로 전환했습니다';
  }

  @override
  String get bookDeleteTitle => '가계부 삭제';

  @override
  String bookDeleteConfirm(String name) {
    return '「$name」을(를) 삭제하시겠습니까?\n\n이 가계부의 모든 거래 기록, 예산, 대화 내역이 삭제됩니다. 이 작업은 되돌릴 수 없습니다.';
  }

  @override
  String get bookDeleted => '가계부가 삭제되었습니다';

  @override
  String bookCountUnit(String count) {
    return '$count건';
  }

  @override
  String get bookTypePersonal => '개인';

  @override
  String get bookTypeFamily => '가족';

  @override
  String get bookTypeTravel => '여행';

  @override
  String get bookTypeBusiness => '사업';

  @override
  String get bookTypeOther => '기타';

  @override
  String get bookDetailTitle => '가계부 상세';

  @override
  String get bookDetailNotExist => '가계부가 존재하지 않습니다';

  @override
  String get bookDetailExpenseCount => '거래 건수';

  @override
  String get bookDetailNormalSection => '일반 작업';

  @override
  String get bookDetailSetDefault => '기본 가계부로 설정';

  @override
  String get bookDetailSwitchTo => '이 가계부로 전환';

  @override
  String get bookDetailDangerSection => '주의가 필요한 작업';

  @override
  String get bookDetailClearData => '가계부 데이터 초기화';

  @override
  String get bookDetailDefaultNotDeletable => '기본 가계부는 삭제할 수 없습니다';

  @override
  String get bookDetailSetDefaultSuccess => '기본 가계부로 설정되었습니다';

  @override
  String get bookDetailClearTitle => '데이터 초기화';

  @override
  String bookDetailClearConfirm(String name) {
    return '「$name」의 모든 거래 기록과 대화 내역을 초기화하시겠습니까?\n\n이 작업은 되돌릴 수 없습니다.';
  }

  @override
  String get bookDetailClear => '초기화';

  @override
  String get bookDetailCleared => '데이터가 초기화되었습니다';

  @override
  String bookDetailDeleteConfirm(String name) {
    return '「$name」을(를) 삭제하시겠습니까?\n\n이 가계부의 모든 데이터가 삭제됩니다. 이 작업은 되돌릴 수 없습니다.';
  }

  @override
  String get bookDetailTypePersonal => '개인 가계부';

  @override
  String get bookDetailTypeFamily => '가족 가계부';

  @override
  String get bookDetailTypeTravel => '여행 가계부';

  @override
  String get bookDetailTypeBusiness => '사업 가계부';

  @override
  String get bookDetailTypeOther => '기타';

  @override
  String get reportTitle => '보고서 분석';

  @override
  String get reportPeriodWeek => '주';

  @override
  String get reportPeriodMonth => '월';

  @override
  String get reportPeriodYear => '년';

  @override
  String get reportTypeExpense => '지출';

  @override
  String get reportTypeIncome => '수입';

  @override
  String get reportTotalExpense => '총 지출';

  @override
  String get reportTotalIncome => '총 수입';

  @override
  String get reportCount => '건수';

  @override
  String reportCountUnit(String count) {
    return '$count건';
  }

  @override
  String get reportDailyAverage => '일평균';

  @override
  String get reportCategoryCount => '카테고리';

  @override
  String reportCategoryCountUnit(String count) {
    return '$count개';
  }

  @override
  String get reportCategoryDistribution => '카테고리 비율';

  @override
  String get reportCategoryRanking => '카테고리 순위';

  @override
  String get reportNoData => '데이터가 없습니다';

  @override
  String reportMonthLabel(String year, String month) {
    return '$year년 $month월';
  }

  @override
  String reportYearLabel(String year) {
    return '$year년';
  }

  @override
  String reportWeekLabel(String start, String end) {
    return '$start - $end';
  }

  @override
  String get securityLockSettings => '비밀번호 잠금 설정';

  @override
  String get securityEnableLock => '비밀번호 잠금 활성화';

  @override
  String get securityUnlockMethods => '잠금 해제 방법 (복수 선택 가능)';

  @override
  String get securityPinCode => 'PIN 코드';

  @override
  String get securityPinCodeDesc => '4자리 PIN 코드로 잠금 해제';

  @override
  String get securityBiometric => '지문 인식';

  @override
  String get securityBiometricDesc => '기기의 지문으로 빠르게 잠금 해제';

  @override
  String get securityPatternLock => '패턴 잠금';

  @override
  String get securityPatternLockDesc => '패턴을 그려서 잠금 해제';

  @override
  String get securityLockHint =>
      '여러 잠금 해제 방법을 선택하면 잠금 화면에 전환 버튼이 표시됩니다. 지문 인식에는 기기의 생체 인식 기능이 필요합니다.';

  @override
  String get securityBiometricVerify => '지문을 확인하여 지문 인식을 활성화합니다';

  @override
  String securityBiometricFail(String error) {
    return '지문 인식에 실패했습니다: $error';
  }

  @override
  String get securitySetPinLock => 'PIN 잠금 설정';

  @override
  String get securitySetPinTitle => '4자리 PIN 코드 설정';

  @override
  String get securityConfirmPinTitle => '새 PIN 코드를 다시 입력해 주세요';

  @override
  String get securityEnterPin => 'PIN 코드를 입력하여 잠금 해제';

  @override
  String get securityPinWrong => 'PIN 코드가 잘못되었습니다. 다시 시도해 주세요';

  @override
  String get securityPinMismatch => '입력이 일치하지 않습니다. 처음부터 다시 설정해 주세요';

  @override
  String get securityPinSetSuccess => 'PIN 코드 설정이 완료되었습니다';

  @override
  String get securitySetPatternLock => '패턴 잠금 설정';

  @override
  String get securityDrawPattern => '잠금 해제 패턴 그리기';

  @override
  String get securityConfirmPattern => '같은 패턴을 다시 그려주세요';

  @override
  String get securityDrawToUnlock => '패턴을 그려서 잠금 해제';

  @override
  String get securityPatternHint => '4개 이상의 점을 연결하세요';

  @override
  String get securityConfirmPatternHint => '방금 그린 것과 같은 패턴을 그려주세요';

  @override
  String get securityRedraw => '다시 그리기';

  @override
  String get securityPatternMinDots => '최소 4개의 점을 연결해야 합니다';

  @override
  String get securityPatternMismatch => '패턴이 일치하지 않습니다. 처음부터 다시 그려주세요';

  @override
  String get securityPatternSetSuccess => '패턴 설정이 완료되었습니다';

  @override
  String get securityPatternWrong => '패턴이 잘못되었습니다. 다시 시도해 주세요';

  @override
  String get securityAuthRequired => '본인 확인 후 앱 잠금을 해제하세요';

  @override
  String get securitySelectUnlockMethod => '잠금 해제 방법 선택';

  @override
  String get securitySwitchUnlockMethod => '잠금 해제 방법 전환';

  @override
  String get securityVerifyFingerprint => '지문을 확인해 주세요';

  @override
  String get securityTouchToUnlock => '지문 센서에 손을 대어 앱 잠금 해제';

  @override
  String get securityRetryFingerprint => '지문 다시 시도';

  @override
  String get checkinTitle => '출석 캘린더';

  @override
  String get checkinAlreadyCheckedIn => '오늘 이미 출석했습니다';

  @override
  String get checkinCheckInSuccess => '출석 성공! +10 AC코인';

  @override
  String get checkinRewardDaily => '매일 출석 보상';

  @override
  String get checkinStreak365 => '1년 연속 출석! +2000 AC코인';

  @override
  String get checkinStreak180 => '6개월 연속 출석! +1000 AC코인';

  @override
  String get checkinStreak30 => '1개월 연속 출석! +300 AC코인';

  @override
  String get checkinStreak7 => '7일 연속 출석! +70 AC코인';

  @override
  String get checkinReward365 => '365일 연속 출석 보상';

  @override
  String get checkinReward180 => '180일 연속 출석 보상';

  @override
  String get checkinReward30 => '30일 연속 출석 보상';

  @override
  String get checkinReward7 => '7일 연속 출석 보상';

  @override
  String get checkinMakeupSelectHint => '출석하지 않은 날짜를 먼저 선택해 주세요';

  @override
  String get checkinMakeupFutureError => '과거 날짜만 보충할 수 있습니다';

  @override
  String get checkinMakeupAlreadyChecked => '해당 날짜는 이미 출석했습니다';

  @override
  String get checkinMakeupInsufficient => 'AC코인이 부족합니다. 보충에는 100 AC코인이 필요합니다';

  @override
  String get checkinMakeupConfirmTitle => '보충 확인';

  @override
  String checkinMakeupConfirmContent(String date, String balance) {
    return '$date를 보충하시겠습니까?\n100 AC코인이 소모됩니다 (현재 잔액: $balance)';
  }

  @override
  String get checkinMakeupConfirm => '보충하기';

  @override
  String get checkinMakeupSuccess => '보충이 완료되었습니다!';

  @override
  String checkinMakeupCost(String date) {
    return '$date 보충';
  }

  @override
  String get checkinConsecutiveDays => '연속 출석';

  @override
  String get checkinAcBalance => 'AC코인 잔액';

  @override
  String get checkinTodayStatus => '오늘 상태';

  @override
  String get checkinMakeupButton => '보충 (-100 AC코인)';

  @override
  String get checkinMakeupSelectButton => '날짜를 선택한 후 보충';

  @override
  String get checkinTodayCheckIn => '출석 완료';

  @override
  String get checkinTodayCheckInButton => '오늘 출석 +10';

  @override
  String get acCoinTitle => 'AC코인 내역';

  @override
  String get acCoinCurrentBalance => '현재 잔액';

  @override
  String get acCoinEmpty => 'AC코인 내역이 없습니다';
}
