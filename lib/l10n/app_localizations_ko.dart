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
  String get commonEdit => '편집';

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
  String get chatInputVoiceHint => '손을 떼면 전송, 왼쪽으로 밀면 취소 ↖, 오른쪽으로 밀면 텍스트 변환 ↗';

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
  String get chatDeleteTitle => '대화 지우기';

  @override
  String get chatDeleteMessage => '모든 대화 기록을 지우시겠습니까? 이 작업은 되돌릴 수 없습니다.';

  @override
  String get chatDeleteSuccess => '대화 기록이 지워졌습니다';

  @override
  String get chatActionCopy => '복사';

  @override
  String get chatActionDelete => '메시지 삭제';

  @override
  String get chatDeleteMsgConfirm => '이 메시지를 삭제하시겠습니까?';

  @override
  String get chatCopyMessage => '클립보드에 복사되었습니다';

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
  String get bookCurrent => '현재';

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
  String get bookDeleted => '가계부가 휴지통으로 이동되었습니다';

  @override
  String get bookRecycleBin => '가계부 휴지통';

  @override
  String get bookRecycleBinEmpty => '휴지통이 비어 있습니다';

  @override
  String get bookRestore => '복원';

  @override
  String get bookRestored => '가계부가 복원되었습니다';

  @override
  String get bookPermanentDelete => '영구 삭제';

  @override
  String bookPermanentDeleteConfirm(String name) {
    return '\"$name\"을(를) 영구 삭제하시겠습니까?\n모든 데이터가 삭제됩니다. 이 작업은 되돌릴 수 없습니다.';
  }

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
  String get bookTypeCouple => '커플';

  @override
  String get bookTypeStudent => '학생';

  @override
  String get bookTypeWedding => '결혼';

  @override
  String get bookTypeRental => '임대';

  @override
  String get bookTypeInvestment => '투자';

  @override
  String get bookTypePet => '반려동물';

  @override
  String get bookTypeHealth => '의료';

  @override
  String get bookTypeEvent => '이벤트';

  @override
  String get bookTypeOther => '기타';

  @override
  String get bookTypeCustom => '사용자 정의';

  @override
  String get bookTypeCustomHint => '사용자 정의 유형 입력';

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
  String get bookDetailDefaultNotDeletable => '현재 가계부는 삭제할 수 없습니다';

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
    return '「$name」을(를) 삭제하시겠습니까?\n\n휴지통으로 이동됩니다. 데이터는 삭제되지 않습니다.';
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

  @override
  String get catExpenseFood => '식사';

  @override
  String get catExpenseTransport => '교통';

  @override
  String get catExpenseHousing => '주거';

  @override
  String get catExpenseClothing => '의류·미용';

  @override
  String get catExpenseDaily => '생활용품';

  @override
  String get catExpenseTech => '디지털기기';

  @override
  String get catExpenseMedical => '의료·건강';

  @override
  String get catExpenseEducation => '교육';

  @override
  String get catExpenseEntertainment => '여가';

  @override
  String get catExpenseSocial => '경조사';

  @override
  String get catExpenseChildren => '자녀양육';

  @override
  String get catExpenseElderly => '부모부양';

  @override
  String get catExpensePet => '반려동물';

  @override
  String get catExpenseWork => '업무·사무';

  @override
  String get catExpenseFinance => '금융·보험';

  @override
  String get catExpenseOther => '기타지출';

  @override
  String get catIncomeSalary => '급여';

  @override
  String get catIncomeInvestment => '투자';

  @override
  String get catIncomeSideJob => '부업';

  @override
  String get catIncomeGift => '축의금';

  @override
  String get catIncomeRefund => '환급';

  @override
  String get catIncomeAsset => '임대·자산';

  @override
  String get catIncomeTransferIn => '이체입금';

  @override
  String get catIncomeOther => '기타수입';

  @override
  String get catOtherTransfer => '이체';

  @override
  String get catOtherRepayment => '상환';

  @override
  String get catOtherSocial => '경조사';

  @override
  String get catSubFoodBreakfast => '아침식사';

  @override
  String get catSubFoodLunch => '점심식사';

  @override
  String get catSubFoodDinner => '저녁식사';

  @override
  String get catSubFoodLateSnack => '야식';

  @override
  String get catSubFoodDelivery => '배달음식';

  @override
  String get catSubFoodMilkTea => '밀크티';

  @override
  String get catSubFoodCoffee => '커피';

  @override
  String get catSubFoodDrinks => '음료';

  @override
  String get catSubFoodDessert => '디저트';

  @override
  String get catSubFoodSnacks => '간식';

  @override
  String get catSubFoodFruit => '과일';

  @override
  String get catSubFoodGroceries => '식재료';

  @override
  String get catSubFoodDiningOut => '외식';

  @override
  String get catSubTransportMetro => '지하철';

  @override
  String get catSubTransportBus => '버스';

  @override
  String get catSubTransportTaxi => '택시';

  @override
  String get catSubTransportRideshare => '카셰어';

  @override
  String get catSubTransportBikeShare => '공유자전거';

  @override
  String get catSubTransportHighSpeedRail => '고속철도';

  @override
  String get catSubTransportTrain => '기차';

  @override
  String get catSubTransportFlight => '비행기';

  @override
  String get catSubTransportFuel => '주유';

  @override
  String get catSubTransportCharging => '충전';

  @override
  String get catSubTransportParking => '주차비';

  @override
  String get catSubTransportToll => '통행료';

  @override
  String get catSubTransportMaintenance => '차량정비';

  @override
  String get catSubTransportRepair => '차량수리';

  @override
  String get catSubTransportInsurance => '자동차보험';

  @override
  String get catSubHousingRent => '월세';

  @override
  String get catSubHousingMortgage => '주택대출';

  @override
  String get catSubHousingWater => '수도요금';

  @override
  String get catSubHousingElectricity => '전기요금';

  @override
  String get catSubHousingGas => '가스요금';

  @override
  String get catSubHousingPropertyFee => '관리비';

  @override
  String get catSubHousingInternet => '인터넷';

  @override
  String get catSubHousingPhone => '휴대폰';

  @override
  String get catSubHousingCleaning => '가사도우미';

  @override
  String get catSubHousingRepair => '주택수리';

  @override
  String get catSubClothingApparel => '의류';

  @override
  String get catSubClothingShoes => '신발';

  @override
  String get catSubClothingHats => '모자';

  @override
  String get catSubClothingBags => '가방';

  @override
  String get catSubClothingCosmetics => '화장품';

  @override
  String get catSubClothingSkincare => '스킨케어';

  @override
  String get catSubClothingHaircut => '미용실';

  @override
  String get catSubClothingManicure => '네일아트';

  @override
  String get catSubClothingJewelry => '쥬얼리';

  @override
  String get catSubClothingAccessories => '액세서리';

  @override
  String get catSubDailyNecessities => '생활용품';

  @override
  String get catSubDailyCleaning => '세제·청소용품';

  @override
  String get catSubDailyKitchen => '주방용품';

  @override
  String get catSubDailyDecor => '인테리어';

  @override
  String get catSubDailyStorage => '수납용품';

  @override
  String get catSubDailyBedding => '침구';

  @override
  String get catSubDailyTissue => '휴지류';

  @override
  String get catSubTechPhone => '스마트폰';

  @override
  String get catSubTechComputer => '노트북';

  @override
  String get catSubTechAccessories => '주변기기';

  @override
  String get catSubTechConsumables => '소모품';

  @override
  String get catSubTechStorage => '저장장치';

  @override
  String get catSubMedicalRegistration => '접수·진료';

  @override
  String get catSubMedicalMedicine => '의약품';

  @override
  String get catSubMedicalHospitalization => '입원';

  @override
  String get catSubMedicalCheckup => '건강검진';

  @override
  String get catSubMedicalDental => '치과';

  @override
  String get catSubMedicalEyeCare => '안과';

  @override
  String get catSubMedicalVaccine => '예방접종';

  @override
  String get catSubMedicalWellness => '건강보조식품';

  @override
  String get catSubMedicalFitness => '운동·피트니스';

  @override
  String get catSubEducationBooks => '도서';

  @override
  String get catSubEducationTuition => '등록금';

  @override
  String get catSubEducationTraining => '교육비';

  @override
  String get catSubEducationExam => '시험접수비';

  @override
  String get catSubEducationOnlineCourse => '온라인 강의';

  @override
  String get catSubEducationStationery => '문구류';

  @override
  String get catSubEntertainmentMovies => '영화';

  @override
  String get catSubEntertainmentKtv => '노래방';

  @override
  String get catSubEntertainmentGaming => '게임 충전';

  @override
  String get catSubEntertainmentSubscription => '구독서비스';

  @override
  String get catSubEntertainmentTickets => '입장권';

  @override
  String get catSubEntertainmentHotel => '호텔';

  @override
  String get catSubEntertainmentTravel => '여행';

  @override
  String get catSubEntertainmentShow => '공연';

  @override
  String get catSubEntertainmentStreaming => '스트리밍';

  @override
  String get catSubSocialGift => '선물';

  @override
  String get catSubSocialRedPacket => '세뱃돈';

  @override
  String get catSubSocialWeddingGift => '축의금·부의금';

  @override
  String get catSubSocialTreat => '밥사기';

  @override
  String get catSubSocialBirthday => '생일파티';

  @override
  String get catSubSocialVisit => '문병·방문';

  @override
  String get catSubSocialRespect => '효도';

  @override
  String get catSubSocialCharity => '기부';

  @override
  String get catSubChildrenFormula => '분유·이유식';

  @override
  String get catSubChildrenDiapers => '기저귀·용품';

  @override
  String get catSubChildrenTuition => '학비';

  @override
  String get catSubChildrenHobby => '취미반';

  @override
  String get catSubChildrenTutoring => '학원';

  @override
  String get catSubChildrenDaycare => '방과후 돌봄';

  @override
  String get catSubChildrenToys => '장난감';

  @override
  String get catSubElderlySupport => '부양비';

  @override
  String get catSubElderlyNutrition => '영양제';

  @override
  String get catSubElderlyMedical => '의료비';

  @override
  String get catSubElderlyAllowance => '용돈';

  @override
  String get catSubPetFood => '반려동물 사료';

  @override
  String get catSubPetMedical => '반려동물 진료';

  @override
  String get catSubPetSupplies => '반려동물 용품';

  @override
  String get catSubPetGrooming => '반려동물 미용';

  @override
  String get catSubWorkOffice => '사무용품';

  @override
  String get catSubWorkPrinting => '인쇄·복사';

  @override
  String get catSubWorkShipping => '택배·배송';

  @override
  String get catSubWorkTravel => '출장비';

  @override
  String get catSubFinanceInsurance => '보험료';

  @override
  String get catSubFinanceLoss => '투자 손실';

  @override
  String get catSubFinanceFee => '수수료';

  @override
  String get catSubFinanceLoanInterest => '대출 이자';

  @override
  String get catSubFinanceTax => '세금';

  @override
  String get catSubFinanceFine => '과태료·벌금';

  @override
  String get catSubOtherExpenseGeneral => '기타 소비';

  @override
  String get catSubOtherExpenseUnexpected => '예상치 못한 지출';

  @override
  String get catSubSalaryBase => '기본급';

  @override
  String get catSubSalaryBonus => '성과급';

  @override
  String get catSubSalaryOvertime => '야근수당';

  @override
  String get catSubSalaryYearEnd => '연말보너스';

  @override
  String get catSubSalaryBackPay => '소급분';

  @override
  String get catSubSalaryAllowance => '수당';

  @override
  String get catSubInvestmentFund => '펀드 수익';

  @override
  String get catSubInvestmentStock => '주식 수익';

  @override
  String get catSubInvestmentInterest => '이자수입';

  @override
  String get catSubInvestmentWealthMgmt => '재테크 상품';

  @override
  String get catSubInvestmentCrypto => '암호화폐';

  @override
  String get catSubInvestmentDividend => '배당금';

  @override
  String get catSubSideJobPartTime => '아르바이트 수입';

  @override
  String get catSubSideJobFreelance => '프리랜서';

  @override
  String get catSubSideJobRoyalty => '원고료·저작권';

  @override
  String get catSubSideJobCommission => '수수료·커미션';

  @override
  String get catSubSideJobSales => '판매 수입';

  @override
  String get catSubGiftRedPacket => '용돈 수입';

  @override
  String get catSubGiftPresent => '선물금';

  @override
  String get catSubGiftFestival => '명절 세뱃돈';

  @override
  String get catSubRefundReimbursement => '경비 정산';

  @override
  String get catSubRefundReturn => '반품 환불';

  @override
  String get catSubRefundMedical => '건강보험 환급';

  @override
  String get catSubRefundInsurance => '보험금 수령';

  @override
  String get catSubAssetRent => '임대 수입';

  @override
  String get catSubAssetIdleSale => '중고 판매';

  @override
  String get catSubAssetSecondhand => '중고 거래';

  @override
  String get catSubAssetProfit => '자산 수익';

  @override
  String get catSubTransferInBank => '은행 입금';

  @override
  String get catSubTransferInWallet => '지갑 입금';

  @override
  String get catSubTransferInDebt => '대여금 회수';

  @override
  String get catSubIncomeOtherWindfall => '뜻밖의 수입';

  @override
  String get catSubIncomeOtherSubsidy => '정부 보조금';

  @override
  String get catSubIncomeOtherUncategorized => '미분류';

  @override
  String get catSubTransferBankIn => '은행 이체 입금';

  @override
  String get catSubTransferBankOut => '은행 이체 출금';

  @override
  String get catSubTransferWallet => '지갑 이체';

  @override
  String get catSubTransferCrossIn => '타 플랫폼 입금';

  @override
  String get catSubTransferCrossOut => '타 플랫폼 출금';

  @override
  String get catSubRepaymentCreditCard => '신용카드 결제';

  @override
  String get catSubRepaymentLoan => '대출 상환';

  @override
  String get catSubRepaymentBorrowed => '차용금 상환';

  @override
  String get catSubRepaymentLent => '대여금';

  @override
  String get catSubOtherSocialGift => '축의금·부의금';

  @override
  String get catSubOtherSocialWedding => '혼사·상례';

  @override
  String get catSubOtherSocialBirthday => '생일모임';

  @override
  String get catSubOtherSocialFestival => '명절 용돈';

  @override
  String get weekMon => '월';

  @override
  String get weekTue => '화';

  @override
  String get weekWed => '수';

  @override
  String get weekThu => '목';

  @override
  String get weekFri => '금';

  @override
  String get weekSat => '토';

  @override
  String get weekSun => '일';

  @override
  String get weekMonFull => '월요일';

  @override
  String get weekTueFull => '화요일';

  @override
  String get weekWedFull => '수요일';

  @override
  String get weekThuFull => '목요일';

  @override
  String get weekFriFull => '금요일';

  @override
  String get weekSatFull => '토요일';

  @override
  String get weekSunFull => '일요일';

  @override
  String get commonSelectDateTime => '날짜 및 시간 선택';

  @override
  String get commonBack => '뒤로';

  @override
  String get commonDone => '완료';

  @override
  String get commonAdd => '추가';

  @override
  String commonEnterHint(String field) {
    return '$field 입력';
  }

  @override
  String get txnCategorySearch => '카테고리 검색...';

  @override
  String get txnCategoryEmpty => '카테고리 없음';

  @override
  String get settingsSelectLanguage => '언어 선택';

  @override
  String get settingsSelectCurrency => '통화 선택';

  @override
  String get profileDefaultNickname => '사용자';

  @override
  String get catManageTitle => '카테고리 관리';

  @override
  String catManageSubTitle(String name) {
    return '$name - 하위 카테고리';
  }

  @override
  String get catManageAddSub => '하위 카테고리 추가';

  @override
  String get catManageNameExists => '카테고리 이름이 이미 존재합니다';

  @override
  String get catManageSubNameExists => '하위 카테고리 이름이 이미 존재합니다';

  @override
  String get catManageDeleteTitle => '삭제 확인';

  @override
  String catManageDeleteWithChildren(String name) {
    return '카테고리 \"$name\"과(와) 모든 하위 카테고리를 삭제하시겠습니까?';
  }

  @override
  String catManageDeleteConfirm(String name) {
    return '카테고리 \"$name\"을(를) 삭제하시겠습니까?';
  }

  @override
  String get catManageDeleteBlocked => '이 카테고리에 연결된 데이터가 있어 삭제할 수 없습니다';

  @override
  String get catManageCustomBadge => '커';

  @override
  String get catManageCustom => '사용자 정의';

  @override
  String catManageAddTitle(String type) {
    return '$type 카테고리 추가';
  }

  @override
  String get catManageNameLabel => '카테고리 이름';

  @override
  String get catManageNameHint => '카테고리 이름 입력';

  @override
  String get catManageSelectIcon => '아이콘 선택';

  @override
  String get catManageSelectColor => '색상 선택';

  @override
  String catManageAddSubTitle(String name) {
    return '하위 카테고리 추가 - $name';
  }

  @override
  String get catManageSubNameLabel => '하위 카테고리 이름';

  @override
  String get catManageSubNameHint => '하위 카테고리 이름 입력';

  @override
  String get catManageEditTitle => '카테고리 편집';

  @override
  String get bookNameLabel => '가계부 이름';

  @override
  String get bookNameHint => '예: 일상 지출';

  @override
  String get bookTypeLabel => '가계부 유형';

  @override
  String get bookDescLabel => '메모 (선택)';

  @override
  String get bookDescHint => '가계부 용도를 간단히 설명';

  @override
  String get bookCreateButton => '생성';

  @override
  String get bookDescPersonal => '일상 개인 지출';

  @override
  String get bookDescFamily => '가족 공통 지출';

  @override
  String get bookDescTravel => '여행 경비 기록';

  @override
  String get bookDescBusiness => '부업 수입과 지출';

  @override
  String get bookDescOther => '사용자 정의 용도';

  @override
  String get aiPresetDeepseekNote => '비용 대비 성능이 우수한 중국 LLM';

  @override
  String get aiPresetOpenaiNote => '해외 네트워크 접속 필요';

  @override
  String get aiPresetQwenName => '통의천문 (알리바바)';

  @override
  String get aiPresetQwenNote => '호환 모드 URL 사용';

  @override
  String get aiPresetDoubaoName => '더우바오 (바이트댄스)';

  @override
  String get aiPresetDoubaoNote => '화산방주에서 추론 엔드포인트 생성 필요, 엔드포인트 ID를 모델명으로 사용';

  @override
  String get aiPresetZhipuName => '지푸AI';

  @override
  String get aiPresetZhipuNote => 'glm-4-flash 무료 할당량 있음';

  @override
  String get aiPresetKimiName => '월지암면 (Kimi)';

  @override
  String get aiPresetKimiNote => '긴 텍스트 이해에 뛰어남';

  @override
  String get aiPresetClaudeNote => 'Anthropic Messages API 사용';

  @override
  String get aiPresetMimoName => '샤오미 MiMo';

  @override
  String get aiPresetMimoNote =>
      'OpenAI/Anthropic 호환 프로토콜 지원, 중국/싱가포르/유럽 멀티 클러스터';

  @override
  String get aiPresetOllamaName => 'Ollama (로컬)';

  @override
  String get aiPresetOllamaNote => '로컬 Ollama 서비스 실행 필요, 모델명은 로컬 설치에 따라 다름';

  @override
  String get llmCapTextLabel => '텍스트 모델';

  @override
  String get llmCapTextDesc => '가계부 해석 및 AI 대화용';

  @override
  String get llmCapVisionLabel => '비전 모델';

  @override
  String get llmCapVisionDesc => '영수증/세금계산서 사진 인식용';

  @override
  String get llmCapAudioLabel => '음성 모델';

  @override
  String get llmCapAudioDesc => '음성-텍스트 변환용';

  @override
  String get currencyCny => '중국 위안 (CNY)';

  @override
  String get currencyUsd => '미국 달러 (USD)';

  @override
  String get currencyKrw => '대한민국 원 (KRW)';

  @override
  String get currencyJpy => '일본 엔 (JPY)';

  @override
  String get currencyEur => '유로 (EUR)';

  @override
  String get currencyGbp => '영국 파운드 (GBP)';

  @override
  String get currencyUnitYi => '억';

  @override
  String get currencyUnitWan => '만';

  @override
  String get inputSourceText => '텍스트';

  @override
  String get inputSourceVoice => '음성';

  @override
  String get inputSourceImage => '이미지';

  @override
  String reportTrendMonth(String period) {
    return '$period월';
  }

  @override
  String reportTrendDay(String period) {
    return '$period일';
  }

  @override
  String get llmSettingsTitle => 'AI 서비스 설정';

  @override
  String get llmExportConfig => '설정 내보내기';

  @override
  String get llmImportConfig => '설정 가져오기';

  @override
  String get llmProviderManagement => '프로바이더 관리';

  @override
  String get llmAddProvider => '프로바이더 추가';

  @override
  String get llmEditProvider => '프로바이더 편집';

  @override
  String get llmDeleteProvider => '프로바이더 삭제';

  @override
  String llmDeleteProviderConfirm(String name) {
    return '「$name」을(를) 삭제하시겠습니까?';
  }

  @override
  String get llmNotConfigured => '미설정';

  @override
  String get llmConfigured => '설정 완료';

  @override
  String get llmNoProviders => '아직 프로바이더가 추가되지 않았습니다';

  @override
  String get llmUnnamedProvider => '이름 없는 프로바이더';

  @override
  String get llmInUse => '사용 중';

  @override
  String get llmIncomplete => '미완성';

  @override
  String get llmTest => '테스트';

  @override
  String get llmConfigIncomplete =>
      '먼저 설정을 완료해 주세요 (API Key, URL, 최소 1개 모델 필요)';

  @override
  String get llmConnectSuccess => '✅ 연결 성공';

  @override
  String get llmConnectFail => '❌ 연결 실패. URL, Key, 모델명을 확인해 주세요';

  @override
  String get llmConfigCopied => '설정이 클립보드에 복사되었습니다';

  @override
  String get llmClipboardEmpty => '클립보드가 비어 있습니다';

  @override
  String llmImported(String count) {
    return '$count개의 프로바이더 설정을 가져왔습니다';
  }

  @override
  String get llmImportFailed => '가져오기에 실패했습니다. JSON 형식을 확인해 주세요';

  @override
  String get llmProviderNotConfigured =>
      '이 프로바이더에 API Key 또는 URL이 설정되지 않았습니다. 먼저 편집해 주세요';

  @override
  String llmModelsFetched(String count, String label) {
    return '$count개의 $label을(를) 가져왔습니다';
  }

  @override
  String llmModelsFetchedAll(String count) {
    return '$count개의 모델을 가져왔습니다 (전용 모델을 찾지 못해 전체 표시)';
  }

  @override
  String get llmFetchFailed => '가져오기에 실패했습니다. 프리셋 모델 목록을 불러왔습니다';

  @override
  String llmFetchError(String error) {
    return '모델 가져오기 실패: $error';
  }

  @override
  String llmModelSet(String capability, String provider, String model) {
    return '$capability 설정 완료: $provider · $model';
  }

  @override
  String llmInputModelName(String capability) {
    return '$capability 이름 입력';
  }

  @override
  String get llmConnectFailed => '연결 실패';

  @override
  String get llmAutoDetectInterval => '자동 감지 간격';

  @override
  String get llmIntervalOff => '끔';

  @override
  String get llmInterval10s => '10초';

  @override
  String get llmInterval30s => '30초';

  @override
  String get llmInterval1m => '1분';

  @override
  String get llmInterval2m => '2분';

  @override
  String get llmInterval5m => '5분';

  @override
  String get llmInterval10m => '10분';

  @override
  String get llmInterval30m => '30분';

  @override
  String get llmInterval1h => '1시간';

  @override
  String llmConfigureCap(String label) {
    return '$label 설정';
  }

  @override
  String get llmCurrentUse => '현재 사용 중';

  @override
  String get llmFetch => '가져오기';

  @override
  String get llmTesting => '테스트 중...';

  @override
  String get llmTestConnection => '연결 테스트';

  @override
  String get llmFailed => '실패';

  @override
  String llmSelectCap(String label) {
    return '$label 선택';
  }

  @override
  String get llmManualInput => '✏️ 직접 입력...';

  @override
  String get llmFillApiKey => 'API Key와 요청 URL을 입력해 주세요';

  @override
  String get llmCustom => '사용자 정의';

  @override
  String get llmProviderName => '프로바이더 이름';

  @override
  String get llmApiUrl => '요청 URL';

  @override
  String get llmApiUrlHintAnthropic =>
      'Anthropic API URL (예: https://api.anthropic.com)';

  @override
  String get llmApiUrlHelper =>
      'API의 base_url을 입력하세요. /chat/completions는 자동으로 추가됩니다';

  @override
  String get llmSaveHint => '저장 후 이전 페이지로 돌아가 능력 카드에서 모델을 설정해 주세요';

  @override
  String get llmInputApiKey => 'API Key 입력';

  @override
  String get llmApiUrlExample => '예: https://api.example.com';

  @override
  String get llmAdvancedSettings => '고급 설정';

  @override
  String get llmTemperature => '응답 스타일';

  @override
  String get llmTemperatureHint => '낮을수록 정확하고 안정적, 높을수록 다양하고 창의적';

  @override
  String get llmTemperaturePrecise => '정확';

  @override
  String get llmTemperatureCreative => '창의적';

  @override
  String get llmMaxToken => '최대 토큰 수';

  @override
  String get llmTimeout => '타임아웃 (초)';

  @override
  String get llmErrorNoModelForCapability => '이 기능에 해당하는 모델이 설정되지 않았습니다';

  @override
  String get llmErrorNoProviderConfigured => '설정에서 AI 프로바이더를 추가하고 구성해 주세요';

  @override
  String get llmErrorNoProviderOrInput =>
      '설정에서 AI 프로바이더를 추가하거나, 더 구체적으로 입력해 주세요';

  @override
  String get llmErrorCannotParseResponse => 'AI 응답을 분석할 수 없습니다';

  @override
  String get llmErrorInvalidResponseFormat => 'AI 응답 형식이 올바르지 않습니다';

  @override
  String llmErrorParseFailed(String error) {
    return 'AI 응답 분석에 실패했습니다: $error';
  }

  @override
  String get llmErrorTimeout => '요청 시간이 초과되었습니다. 네트워크 연결을 확인해 주세요';

  @override
  String get llmErrorInvalidApiKey => 'API Key가 유효하지 않습니다. 설정을 확인해 주세요';

  @override
  String get llmErrorRateLimit => '요청이 너무 많습니다. 잠시 후 다시 시도해 주세요';

  @override
  String get llmErrorForbidden => '접근이 거부되었습니다. API Key 권한을 확인해 주세요';

  @override
  String llmErrorRequestFailed(String code) {
    return '요청에 실패했습니다 ($code)';
  }

  @override
  String get llmErrorNetworkFailed => '네트워크 연결에 실패했습니다. 네트워크를 확인해 주세요';

  @override
  String llmErrorRequestFailedWithMessage(String message) {
    return '요청에 실패했습니다: $message';
  }

  @override
  String get visionErrorNoModelConfigured =>
      '비전 모델이 설정되지 않았습니다. AI 설정에서 구성해 주세요';

  @override
  String get visionErrorImageNotFound => '이미지 파일을 찾을 수 없습니다';

  @override
  String visionErrorRecognitionFailed(String message) {
    return '이미지 인식에 실패했습니다: $message';
  }

  @override
  String get voiceErrorNoModelConfigured =>
      '음성 모델이 설정되지 않았습니다. AI 설정에서 구성해 주세요';

  @override
  String get voiceErrorAudioNotFound => '오디오 파일을 찾을 수 없습니다';

  @override
  String get voiceErrorInvalidResponseFormat => '음성 인식 결과 형식이 올바르지 않습니다';

  @override
  String voiceErrorTranscriptionFailed(String message) {
    return '음성 인식에 실패했습니다: $message';
  }

  @override
  String get pipelineErrorEmptyVoiceResult => '음성 인식 결과가 비어 있습니다. 다시 녹음해 주세요';

  @override
  String get pipelineErrorEmptyImageResult =>
      '이미지 인식 결과가 비어 있습니다. 더 선명한 이미지를 선택해 주세요';

  @override
  String get acCoinInitialGiftDesc => '신규 회원 가입 선물';

  @override
  String get loadFailedPullToRefresh => '로드 실패, 아래로 당겨 새로고침';

  @override
  String get llmSettingsGetModelListError => '모델 목록을 가져오지 못했습니다';
}
