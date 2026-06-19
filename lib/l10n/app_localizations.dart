import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'WoAccount'**
  String get appTitle;

  /// No description provided for @navTransactions.
  ///
  /// In zh, this message translates to:
  /// **'账单'**
  String get navTransactions;

  /// No description provided for @navRecord.
  ///
  /// In zh, this message translates to:
  /// **'记账'**
  String get navRecord;

  /// No description provided for @navProfile.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get navProfile;

  /// No description provided for @commonCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get commonConfirm;

  /// No description provided for @commonEditCategory.
  ///
  /// In zh, this message translates to:
  /// **'修改分类'**
  String get commonEditCategory;

  /// No description provided for @commonEditAmount.
  ///
  /// In zh, this message translates to:
  /// **'修改金额'**
  String get commonEditAmount;

  /// No description provided for @commonEditDescription.
  ///
  /// In zh, this message translates to:
  /// **'修改描述'**
  String get commonEditDescription;

  /// No description provided for @commonSave.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get commonEdit;

  /// No description provided for @chatPageTitle.
  ///
  /// In zh, this message translates to:
  /// **'AI 记账'**
  String get chatPageTitle;

  /// No description provided for @chatPageVoicePlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'🎤 语音消息'**
  String get chatPageVoicePlaceholder;

  /// No description provided for @chatPageImagePlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'📷 图片消息'**
  String get chatPageImagePlaceholder;

  /// No description provided for @chatPageVoiceTranscription.
  ///
  /// In zh, this message translates to:
  /// **'🎤 语音转文字：{text}'**
  String chatPageVoiceTranscription(String text);

  /// No description provided for @chatPageImageRecognition.
  ///
  /// In zh, this message translates to:
  /// **'📷 图片识别结果：{text}'**
  String chatPageImageRecognition(String text);

  /// No description provided for @chatPageNoSubcategory.
  ///
  /// In zh, this message translates to:
  /// **'暂无'**
  String get chatPageNoSubcategory;

  /// No description provided for @chatPageConfigAiError.
  ///
  /// In zh, this message translates to:
  /// **'请先在设置中添加并配置 AI 服务商'**
  String get chatPageConfigAiError;

  /// No description provided for @chatPageParseError.
  ///
  /// In zh, this message translates to:
  /// **'❌ 解析失败：{error}\n\n请尝试更明确的描述，如\"午饭拉面25\"'**
  String chatPageParseError(String error);

  /// No description provided for @chatPageNoCategoryError.
  ///
  /// In zh, this message translates to:
  /// **'没有可用分类，请先在分类管理中添加分类'**
  String get chatPageNoCategoryError;

  /// No description provided for @chatPageSaveSuccessTitle.
  ///
  /// In zh, this message translates to:
  /// **'记账成功'**
  String get chatPageSaveSuccessTitle;

  /// No description provided for @chatPageSaveSuccess.
  ///
  /// In zh, this message translates to:
  /// **'✅ 已保存\n{amount} · {category}\n{description} · {date}'**
  String chatPageSaveSuccess(
    String amount,
    String category,
    String description,
    String date,
  );

  /// No description provided for @chatPageSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败: {error}'**
  String chatPageSaveFailed(String error);

  /// No description provided for @chatPageEmptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'开始记账吧'**
  String get chatPageEmptyTitle;

  /// No description provided for @chatPageEmptyHint.
  ///
  /// In zh, this message translates to:
  /// **'试试输入 \"午饭拉面25\" 或 \"吃饭24，洗衣服34\"'**
  String get chatPageEmptyHint;

  /// No description provided for @chatPageEmptyInstruction.
  ///
  /// In zh, this message translates to:
  /// **'长按记账按钮可语音输入 🎤 · 点击右侧按钮拍照识别 📷'**
  String get chatPageEmptyInstruction;

  /// No description provided for @chatPageAiParsing.
  ///
  /// In zh, this message translates to:
  /// **'AI 正在解析...'**
  String get chatPageAiParsing;

  /// No description provided for @chatBubbleImageFailed.
  ///
  /// In zh, this message translates to:
  /// **'图片加载失败'**
  String get chatBubbleImageFailed;

  /// No description provided for @chatInputMicPermission.
  ///
  /// In zh, this message translates to:
  /// **'请授权麦克风权限'**
  String get chatInputMicPermission;

  /// No description provided for @chatInputRecordShort.
  ///
  /// In zh, this message translates to:
  /// **'录音时间太短'**
  String get chatInputRecordShort;

  /// No description provided for @chatInputImageFailed.
  ///
  /// In zh, this message translates to:
  /// **'获取图片失败: {error}'**
  String chatInputImageFailed(String error);

  /// No description provided for @chatInputCamera.
  ///
  /// In zh, this message translates to:
  /// **'拍照'**
  String get chatInputCamera;

  /// No description provided for @chatInputGallery.
  ///
  /// In zh, this message translates to:
  /// **'从相册选择'**
  String get chatInputGallery;

  /// No description provided for @chatInputVoiceHint.
  ///
  /// In zh, this message translates to:
  /// **'松手发送，左滑取消 ↖，右滑转文字 ↗'**
  String get chatInputVoiceHint;

  /// No description provided for @voiceOverlaySwipeHint.
  ///
  /// In zh, this message translates to:
  /// **'↑ 上滑取消或转文字'**
  String get voiceOverlaySwipeHint;

  /// No description provided for @voiceOverlayCancelLabel.
  ///
  /// In zh, this message translates to:
  /// **'松手 取消'**
  String get voiceOverlayCancelLabel;

  /// No description provided for @voiceOverlayTranscribeLabel.
  ///
  /// In zh, this message translates to:
  /// **'松手 仅转文字'**
  String get voiceOverlayTranscribeLabel;

  /// No description provided for @chatInputTextHint.
  ///
  /// In zh, this message translates to:
  /// **'说点什么...'**
  String get chatInputTextHint;

  /// No description provided for @chatConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'AI 解析结果'**
  String get chatConfirmTitle;

  /// No description provided for @chatConfirmCategory.
  ///
  /// In zh, this message translates to:
  /// **'分类'**
  String get chatConfirmCategory;

  /// No description provided for @chatConfirmDescription.
  ///
  /// In zh, this message translates to:
  /// **'描述'**
  String get chatConfirmDescription;

  /// No description provided for @chatConfirmDate.
  ///
  /// In zh, this message translates to:
  /// **'日期'**
  String get chatConfirmDate;

  /// No description provided for @chatConfirmAmount.
  ///
  /// In zh, this message translates to:
  /// **'金额'**
  String get chatConfirmAmount;

  /// No description provided for @chatConfirmSave.
  ///
  /// In zh, this message translates to:
  /// **'确认保存'**
  String get chatConfirmSave;

  /// No description provided for @chatConfirmInputCategory.
  ///
  /// In zh, this message translates to:
  /// **'输入分类名称'**
  String get chatConfirmInputCategory;

  /// No description provided for @chatConfirmInputDescription.
  ///
  /// In zh, this message translates to:
  /// **'输入描述'**
  String get chatConfirmInputDescription;

  /// No description provided for @chatConfirmInputAmount.
  ///
  /// In zh, this message translates to:
  /// **'输入金额'**
  String get chatConfirmInputAmount;

  /// No description provided for @chatDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'清空对话'**
  String get chatDeleteTitle;

  /// No description provided for @chatDeleteMessage.
  ///
  /// In zh, this message translates to:
  /// **'确定要清空所有对话记录吗？此操作不可撤销。'**
  String get chatDeleteMessage;

  /// No description provided for @chatDeleteSuccess.
  ///
  /// In zh, this message translates to:
  /// **'对话已清空'**
  String get chatDeleteSuccess;

  /// No description provided for @chatActionCopy.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get chatActionCopy;

  /// No description provided for @chatActionDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除消息'**
  String get chatActionDelete;

  /// No description provided for @chatDeleteMsgConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除这条消息吗？'**
  String get chatDeleteMsgConfirm;

  /// No description provided for @chatCopyMessage.
  ///
  /// In zh, this message translates to:
  /// **'已复制到剪贴板'**
  String get chatCopyMessage;

  /// No description provided for @homePageAiNotConfigured.
  ///
  /// In zh, this message translates to:
  /// **'尚未配置 AI 服务，将使用基础规则解析'**
  String get homePageAiNotConfigured;

  /// No description provided for @homePageGoSettings.
  ///
  /// In zh, this message translates to:
  /// **'去配置'**
  String get homePageGoSettings;

  /// No description provided for @homePageNoContent.
  ///
  /// In zh, this message translates to:
  /// **'未识别到内容'**
  String get homePageNoContent;

  /// No description provided for @homePageRecordFailed.
  ///
  /// In zh, this message translates to:
  /// **'记账失败：{error}'**
  String homePageRecordFailed(String error);

  /// No description provided for @homePageRecordSuccess.
  ///
  /// In zh, this message translates to:
  /// **'记账成功：{amount}'**
  String homePageRecordSuccess(String amount);

  /// No description provided for @homePageSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败：{error}'**
  String homePageSaveFailed(String error);

  /// No description provided for @homePageBudgetAlert.
  ///
  /// In zh, this message translates to:
  /// **'今日消费已超过日均预算的80%'**
  String get homePageBudgetAlert;

  /// No description provided for @homeInputManual.
  ///
  /// In zh, this message translates to:
  /// **'手动记账'**
  String get homeInputManual;

  /// No description provided for @homeInputHint.
  ///
  /// In zh, this message translates to:
  /// **'午饭吃了碗拉面25元'**
  String get homeInputHint;

  /// No description provided for @homeInputCamera.
  ///
  /// In zh, this message translates to:
  /// **'拍照识别'**
  String get homeInputCamera;

  /// No description provided for @homeConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'🤖 AI解析结果'**
  String get homeConfirmTitle;

  /// No description provided for @homeConfirmOriginalInput.
  ///
  /// In zh, this message translates to:
  /// **'原始输入: {input}'**
  String homeConfirmOriginalInput(String input);

  /// No description provided for @homeConfirmAmount.
  ///
  /// In zh, this message translates to:
  /// **'💰 金额'**
  String get homeConfirmAmount;

  /// No description provided for @homeConfirmDate.
  ///
  /// In zh, this message translates to:
  /// **'📅 日期'**
  String get homeConfirmDate;

  /// No description provided for @homeConfirmCategory.
  ///
  /// In zh, this message translates to:
  /// **'🍜 分类'**
  String get homeConfirmCategory;

  /// No description provided for @homeConfirmParseTime.
  ///
  /// In zh, this message translates to:
  /// **'⏱️ 解析耗时'**
  String get homeConfirmParseTime;

  /// No description provided for @homeConfirmDescription.
  ///
  /// In zh, this message translates to:
  /// **'📝 描述'**
  String get homeConfirmDescription;

  /// No description provided for @homeConfirmConfidence.
  ///
  /// In zh, this message translates to:
  /// **'置信度'**
  String get homeConfirmConfidence;

  /// No description provided for @homeConfirmEditDate.
  ///
  /// In zh, this message translates to:
  /// **'修改日期'**
  String get homeConfirmEditDate;

  /// No description provided for @homeConfirmRecord.
  ///
  /// In zh, this message translates to:
  /// **'确认记账'**
  String get homeConfirmRecord;

  /// No description provided for @homeEntryTitle.
  ///
  /// In zh, this message translates to:
  /// **'AI 助手'**
  String get homeEntryTitle;

  /// No description provided for @homeEntrySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'智能记账 · 消费分析 · 问答查询'**
  String get homeEntrySubtitle;

  /// No description provided for @homeBudgetDetails.
  ///
  /// In zh, this message translates to:
  /// **'详情'**
  String get homeBudgetDetails;

  /// No description provided for @txnSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索账单'**
  String get txnSearchHint;

  /// No description provided for @txnBudget.
  ///
  /// In zh, this message translates to:
  /// **'预算'**
  String get txnBudget;

  /// No description provided for @txnToday.
  ///
  /// In zh, this message translates to:
  /// **'今天'**
  String get txnToday;

  /// No description provided for @txnPeriodDay.
  ///
  /// In zh, this message translates to:
  /// **'本日'**
  String get txnPeriodDay;

  /// No description provided for @txnPeriodWeek.
  ///
  /// In zh, this message translates to:
  /// **'本周'**
  String get txnPeriodWeek;

  /// No description provided for @txnPeriodMonth.
  ///
  /// In zh, this message translates to:
  /// **'本月'**
  String get txnPeriodMonth;

  /// No description provided for @txnExpense.
  ///
  /// In zh, this message translates to:
  /// **'{period}支出'**
  String txnExpense(String period);

  /// No description provided for @txnIncome.
  ///
  /// In zh, this message translates to:
  /// **'{period}收入'**
  String txnIncome(String period);

  /// No description provided for @txnBalance.
  ///
  /// In zh, this message translates to:
  /// **'结余'**
  String get txnBalance;

  /// No description provided for @txnSortByTime.
  ///
  /// In zh, this message translates to:
  /// **'按时间'**
  String get txnSortByTime;

  /// No description provided for @txnSortByAmount.
  ///
  /// In zh, this message translates to:
  /// **'按金额'**
  String get txnSortByAmount;

  /// No description provided for @txnEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无账单记录'**
  String get txnEmpty;

  /// No description provided for @txnDayDetailEmpty.
  ///
  /// In zh, this message translates to:
  /// **'当日无账单记录'**
  String get txnDayDetailEmpty;

  /// No description provided for @txnDayFormat.
  ///
  /// In zh, this message translates to:
  /// **'yyyy年M月d日'**
  String get txnDayFormat;

  /// No description provided for @txnMonthFormat.
  ///
  /// In zh, this message translates to:
  /// **'yyyy年M月'**
  String get txnMonthFormat;

  /// No description provided for @txnGroupExpenseLabel.
  ///
  /// In zh, this message translates to:
  /// **'支出 {amount}'**
  String txnGroupExpenseLabel(String amount);

  /// No description provided for @txnGroupIncomeLabel.
  ///
  /// In zh, this message translates to:
  /// **'收入 {amount}'**
  String txnGroupIncomeLabel(String amount);

  /// No description provided for @txnGroupUncategorized.
  ///
  /// In zh, this message translates to:
  /// **'未分类'**
  String get txnGroupUncategorized;

  /// No description provided for @txnGroupNoSubcategory.
  ///
  /// In zh, this message translates to:
  /// **'暂无'**
  String get txnGroupNoSubcategory;

  /// No description provided for @viewDay.
  ///
  /// In zh, this message translates to:
  /// **'日'**
  String get viewDay;

  /// No description provided for @viewWeek.
  ///
  /// In zh, this message translates to:
  /// **'周'**
  String get viewWeek;

  /// No description provided for @viewMonth.
  ///
  /// In zh, this message translates to:
  /// **'月'**
  String get viewMonth;

  /// No description provided for @txnDetailTitle.
  ///
  /// In zh, this message translates to:
  /// **'账单详情'**
  String get txnDetailTitle;

  /// No description provided for @txnDetailSaved.
  ///
  /// In zh, this message translates to:
  /// **'已保存'**
  String get txnDetailSaved;

  /// No description provided for @txnDetailDeleteConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get txnDetailDeleteConfirmTitle;

  /// No description provided for @txnDetailDeleteConfirmContent.
  ///
  /// In zh, this message translates to:
  /// **'删除后将无法恢复，确定要删除这条账单吗？'**
  String get txnDetailDeleteConfirmContent;

  /// No description provided for @txnDetailNotFound.
  ///
  /// In zh, this message translates to:
  /// **'账单不存在'**
  String get txnDetailNotFound;

  /// No description provided for @txnDetailUncategorized.
  ///
  /// In zh, this message translates to:
  /// **'未分类'**
  String get txnDetailUncategorized;

  /// No description provided for @txnDetailCategory.
  ///
  /// In zh, this message translates to:
  /// **'分类'**
  String get txnDetailCategory;

  /// No description provided for @txnDetailAmount.
  ///
  /// In zh, this message translates to:
  /// **'金额'**
  String get txnDetailAmount;

  /// No description provided for @txnDetailDate.
  ///
  /// In zh, this message translates to:
  /// **'日期'**
  String get txnDetailDate;

  /// No description provided for @txnDetailNote.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get txnDetailNote;

  /// No description provided for @txnDetailPayMethod.
  ///
  /// In zh, this message translates to:
  /// **'支付方式'**
  String get txnDetailPayMethod;

  /// No description provided for @txnDetailTags.
  ///
  /// In zh, this message translates to:
  /// **'标签'**
  String get txnDetailTags;

  /// No description provided for @txnDetailAddTagHint.
  ///
  /// In zh, this message translates to:
  /// **'点击添加标签'**
  String get txnDetailAddTagHint;

  /// No description provided for @txnDetailAddNoteHint.
  ///
  /// In zh, this message translates to:
  /// **'点击添加备注'**
  String get txnDetailAddNoteHint;

  /// No description provided for @txnDetailAiRecord.
  ///
  /// In zh, this message translates to:
  /// **'AI解析记录'**
  String get txnDetailAiRecord;

  /// No description provided for @txnDetailOriginalInput.
  ///
  /// In zh, this message translates to:
  /// **'原始输入'**
  String get txnDetailOriginalInput;

  /// No description provided for @txnDetailParseSource.
  ///
  /// In zh, this message translates to:
  /// **'解析来源'**
  String get txnDetailParseSource;

  /// No description provided for @txnDetailConfidence.
  ///
  /// In zh, this message translates to:
  /// **'置信度'**
  String get txnDetailConfidence;

  /// No description provided for @txnDetailCreatedAt.
  ///
  /// In zh, this message translates to:
  /// **'创建时间'**
  String get txnDetailCreatedAt;

  /// No description provided for @entryTitle.
  ///
  /// In zh, this message translates to:
  /// **'记账'**
  String get entryTitle;

  /// No description provided for @entryBookType.
  ///
  /// In zh, this message translates to:
  /// **'日常记账'**
  String get entryBookType;

  /// No description provided for @entryExpense.
  ///
  /// In zh, this message translates to:
  /// **'支出'**
  String get entryExpense;

  /// No description provided for @entryIncome.
  ///
  /// In zh, this message translates to:
  /// **'收入'**
  String get entryIncome;

  /// No description provided for @entryOther.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get entryOther;

  /// No description provided for @entrySubCategoryTitle.
  ///
  /// In zh, this message translates to:
  /// **'{name} - 子分类'**
  String entrySubCategoryTitle(String name);

  /// No description provided for @entryNoteHint.
  ///
  /// In zh, this message translates to:
  /// **'添加备注...'**
  String get entryNoteHint;

  /// No description provided for @entrySelectCategoryHint.
  ///
  /// In zh, this message translates to:
  /// **'请选择分类'**
  String get entrySelectCategoryHint;

  /// No description provided for @entrySelectThisCategory.
  ///
  /// In zh, this message translates to:
  /// **'选此分类'**
  String get entrySelectThisCategory;

  /// No description provided for @entryNoSubCategory.
  ///
  /// In zh, this message translates to:
  /// **'暂无子分类'**
  String get entryNoSubCategory;

  /// No description provided for @payMethodDefault.
  ///
  /// In zh, this message translates to:
  /// **'默认'**
  String get payMethodDefault;

  /// No description provided for @payMethodCash.
  ///
  /// In zh, this message translates to:
  /// **'现金'**
  String get payMethodCash;

  /// No description provided for @payMethodWechat.
  ///
  /// In zh, this message translates to:
  /// **'微信'**
  String get payMethodWechat;

  /// No description provided for @payMethodAlipay.
  ///
  /// In zh, this message translates to:
  /// **'支付宝'**
  String get payMethodAlipay;

  /// No description provided for @payMethodCard.
  ///
  /// In zh, this message translates to:
  /// **'银行卡'**
  String get payMethodCard;

  /// No description provided for @entryNumpadToday.
  ///
  /// In zh, this message translates to:
  /// **'今天'**
  String get entryNumpadToday;

  /// No description provided for @entryNumpadDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get entryNumpadDelete;

  /// No description provided for @entryNumpadDone.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get entryNumpadDone;

  /// No description provided for @entrySuccess.
  ///
  /// In zh, this message translates to:
  /// **'记账成功：{amount}'**
  String entrySuccess(String amount);

  /// No description provided for @entryFailure.
  ///
  /// In zh, this message translates to:
  /// **'记账失败：{error}'**
  String entryFailure(String error);

  /// No description provided for @profileCheckedIn.
  ///
  /// In zh, this message translates to:
  /// **'已打卡'**
  String get profileCheckedIn;

  /// No description provided for @profileCheckIn.
  ///
  /// In zh, this message translates to:
  /// **'打卡'**
  String get profileCheckIn;

  /// No description provided for @profileConsecutiveDays.
  ///
  /// In zh, this message translates to:
  /// **'连续打卡'**
  String get profileConsecutiveDays;

  /// No description provided for @profileTotalCheckInDays.
  ///
  /// In zh, this message translates to:
  /// **'打卡总天数'**
  String get profileTotalCheckInDays;

  /// No description provided for @profileTotalTransactions.
  ///
  /// In zh, this message translates to:
  /// **'记账总笔数'**
  String get profileTotalTransactions;

  /// No description provided for @profileFuncTheme.
  ///
  /// In zh, this message translates to:
  /// **'主题切换'**
  String get profileFuncTheme;

  /// No description provided for @profileFuncAccountBooks.
  ///
  /// In zh, this message translates to:
  /// **'我的账本'**
  String get profileFuncAccountBooks;

  /// No description provided for @profileFuncBudget.
  ///
  /// In zh, this message translates to:
  /// **'预算管理'**
  String get profileFuncBudget;

  /// No description provided for @profileFuncCategories.
  ///
  /// In zh, this message translates to:
  /// **'分类管理'**
  String get profileFuncCategories;

  /// No description provided for @profileFuncReports.
  ///
  /// In zh, this message translates to:
  /// **'报表分析'**
  String get profileFuncReports;

  /// No description provided for @profileToolsAndServices.
  ///
  /// In zh, this message translates to:
  /// **'工具与服务'**
  String get profileToolsAndServices;

  /// No description provided for @profileMenuPasswordLock.
  ///
  /// In zh, this message translates to:
  /// **'密码锁'**
  String get profileMenuPasswordLock;

  /// No description provided for @profileMenuAcCoins.
  ///
  /// In zh, this message translates to:
  /// **'AC币'**
  String get profileMenuAcCoins;

  /// No description provided for @profileMenuAiConfig.
  ///
  /// In zh, this message translates to:
  /// **'AI 配置'**
  String get profileMenuAiConfig;

  /// No description provided for @profileMenuDataBackup.
  ///
  /// In zh, this message translates to:
  /// **'数据备份'**
  String get profileMenuDataBackup;

  /// No description provided for @profileMenuImport.
  ///
  /// In zh, this message translates to:
  /// **'账单导入'**
  String get profileMenuImport;

  /// No description provided for @profileMenuExport.
  ///
  /// In zh, this message translates to:
  /// **'账单导出'**
  String get profileMenuExport;

  /// No description provided for @profileMenuFeedback.
  ///
  /// In zh, this message translates to:
  /// **'用户反馈'**
  String get profileMenuFeedback;

  /// No description provided for @profileMenuSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get profileMenuSettings;

  /// No description provided for @profileFeatureComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'{label}功能即将推出'**
  String profileFeatureComingSoon(String label);

  /// No description provided for @profileAlreadyCheckedIn.
  ///
  /// In zh, this message translates to:
  /// **'今天已经打过卡了'**
  String get profileAlreadyCheckedIn;

  /// No description provided for @profileCheckInSuccess.
  ///
  /// In zh, this message translates to:
  /// **'打卡成功！'**
  String get profileCheckInSuccess;

  /// No description provided for @profileCheckInFailure.
  ///
  /// In zh, this message translates to:
  /// **'打卡失败: {error}'**
  String profileCheckInFailure(String error);

  /// No description provided for @profileThemeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色模式'**
  String get profileThemeLight;

  /// No description provided for @profileThemeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色模式'**
  String get profileThemeDark;

  /// No description provided for @profileThemeSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get profileThemeSystem;

  /// No description provided for @profileUserId.
  ///
  /// In zh, this message translates to:
  /// **'ID: {uid}'**
  String profileUserId(String uid);

  /// No description provided for @profileEditTitle.
  ///
  /// In zh, this message translates to:
  /// **'个人资料'**
  String get profileEditTitle;

  /// No description provided for @profileEditNickname.
  ///
  /// In zh, this message translates to:
  /// **'昵称'**
  String get profileEditNickname;

  /// No description provided for @profileEditId.
  ///
  /// In zh, this message translates to:
  /// **'ID'**
  String get profileEditId;

  /// No description provided for @profileEditGender.
  ///
  /// In zh, this message translates to:
  /// **'性别'**
  String get profileEditGender;

  /// No description provided for @profileEditEmail.
  ///
  /// In zh, this message translates to:
  /// **'邮箱'**
  String get profileEditEmail;

  /// No description provided for @profileEditPhone.
  ///
  /// In zh, this message translates to:
  /// **'手机'**
  String get profileEditPhone;

  /// No description provided for @profileEditNotSet.
  ///
  /// In zh, this message translates to:
  /// **'未设置'**
  String get profileEditNotSet;

  /// No description provided for @profileEditNotFound.
  ///
  /// In zh, this message translates to:
  /// **'未找到用户资料'**
  String get profileEditNotFound;

  /// No description provided for @profileEditGenderMale.
  ///
  /// In zh, this message translates to:
  /// **'男'**
  String get profileEditGenderMale;

  /// No description provided for @profileEditGenderFemale.
  ///
  /// In zh, this message translates to:
  /// **'女'**
  String get profileEditGenderFemale;

  /// No description provided for @profileEditGenderSecret.
  ///
  /// In zh, this message translates to:
  /// **'保密'**
  String get profileEditGenderSecret;

  /// No description provided for @profileEditLogout.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get profileEditLogout;

  /// No description provided for @profileEditLogoutConfirmContent.
  ///
  /// In zh, this message translates to:
  /// **'确定要退出登录吗？'**
  String get profileEditLogoutConfirmContent;

  /// No description provided for @profileEditLogoutExit.
  ///
  /// In zh, this message translates to:
  /// **'退出'**
  String get profileEditLogoutExit;

  /// No description provided for @profileEditLogoutComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'退出登录功能即将完善'**
  String get profileEditLogoutComingSoon;

  /// No description provided for @profileEditDeleteAccount.
  ///
  /// In zh, this message translates to:
  /// **'申请注销账号'**
  String get profileEditDeleteAccount;

  /// No description provided for @profileEditDeleteAccountConfirmContent.
  ///
  /// In zh, this message translates to:
  /// **'注销账号后数据将无法恢复，确定要申请注销吗？'**
  String get profileEditDeleteAccountConfirmContent;

  /// No description provided for @profileEditDeleteAccountSubmit.
  ///
  /// In zh, this message translates to:
  /// **'申请注销'**
  String get profileEditDeleteAccountSubmit;

  /// No description provided for @profileEditDeleteAccountSubmitted.
  ///
  /// In zh, this message translates to:
  /// **'注销申请已提交'**
  String get profileEditDeleteAccountSubmitted;

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'系统设置'**
  String get settingsTitle;

  /// No description provided for @settingsGeneral.
  ///
  /// In zh, this message translates to:
  /// **'通用'**
  String get settingsGeneral;

  /// No description provided for @settingsLanguage.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get settingsLanguage;

  /// No description provided for @settingsDarkMode.
  ///
  /// In zh, this message translates to:
  /// **'深色模式'**
  String get settingsDarkMode;

  /// No description provided for @settingsCurrency.
  ///
  /// In zh, this message translates to:
  /// **'货币'**
  String get settingsCurrency;

  /// No description provided for @settingsData.
  ///
  /// In zh, this message translates to:
  /// **'数据'**
  String get settingsData;

  /// No description provided for @settingsAutoBackup.
  ///
  /// In zh, this message translates to:
  /// **'自动备份'**
  String get settingsAutoBackup;

  /// No description provided for @settingsBackupFrequency.
  ///
  /// In zh, this message translates to:
  /// **'备份频率'**
  String get settingsBackupFrequency;

  /// No description provided for @settingsBackupDaily.
  ///
  /// In zh, this message translates to:
  /// **'每天'**
  String get settingsBackupDaily;

  /// No description provided for @settingsRestoreData.
  ///
  /// In zh, this message translates to:
  /// **'恢复数据'**
  String get settingsRestoreData;

  /// No description provided for @settingsAbout.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get settingsAbout;

  /// No description provided for @settingsDangerZone.
  ///
  /// In zh, this message translates to:
  /// **'危险区'**
  String get settingsDangerZone;

  /// No description provided for @settingsClearData.
  ///
  /// In zh, this message translates to:
  /// **'清除所有数据'**
  String get settingsClearData;

  /// No description provided for @settingsClearConfirm.
  ///
  /// In zh, this message translates to:
  /// **'此操作不可恢复，确定要清除所有数据吗？'**
  String get settingsClearConfirm;

  /// No description provided for @settingsClearDataSuccess.
  ///
  /// In zh, this message translates to:
  /// **'数据已清除'**
  String get settingsClearDataSuccess;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In zh, this message translates to:
  /// **'注销账号'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'注销后所有数据将被永久删除，确定要继续吗？'**
  String get settingsDeleteConfirm;

  /// No description provided for @settingsDeleteAccountSuccess.
  ///
  /// In zh, this message translates to:
  /// **'账户数据已删除'**
  String get settingsDeleteAccountSuccess;

  /// No description provided for @budgetTitle.
  ///
  /// In zh, this message translates to:
  /// **'预算管理'**
  String get budgetTitle;

  /// No description provided for @budgetViewMonth.
  ///
  /// In zh, this message translates to:
  /// **'月'**
  String get budgetViewMonth;

  /// No description provided for @budgetViewYear.
  ///
  /// In zh, this message translates to:
  /// **'年'**
  String get budgetViewYear;

  /// No description provided for @budgetYearLabel.
  ///
  /// In zh, this message translates to:
  /// **'{year}年'**
  String budgetYearLabel(String year);

  /// No description provided for @budgetYearTotal.
  ///
  /// In zh, this message translates to:
  /// **'年度总预算'**
  String get budgetYearTotal;

  /// No description provided for @budgetMonthCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个月有预算'**
  String budgetMonthCount(String count);

  /// No description provided for @budgetMonthShort.
  ///
  /// In zh, this message translates to:
  /// **'{month}月'**
  String budgetMonthShort(String month);

  /// No description provided for @budgetEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂未设置预算'**
  String get budgetEmpty;

  /// No description provided for @budgetSetButton.
  ///
  /// In zh, this message translates to:
  /// **'设置预算'**
  String get budgetSetButton;

  /// No description provided for @budgetSettingTitle.
  ///
  /// In zh, this message translates to:
  /// **'预算设置'**
  String get budgetSettingTitle;

  /// No description provided for @budgetMonthlyTotal.
  ///
  /// In zh, this message translates to:
  /// **'本月总预算'**
  String get budgetMonthlyTotal;

  /// No description provided for @budgetSpent.
  ///
  /// In zh, this message translates to:
  /// **'已消费 {amount}'**
  String budgetSpent(String amount);

  /// No description provided for @budgetRemaining.
  ///
  /// In zh, this message translates to:
  /// **'剩余 {amount}'**
  String budgetRemaining(String amount);

  /// No description provided for @budgetOverSpent.
  ///
  /// In zh, this message translates to:
  /// **'{category}预算已超支 {amount}'**
  String budgetOverSpent(String category, String amount);

  /// No description provided for @budgetUnknownCategory.
  ///
  /// In zh, this message translates to:
  /// **'某分类'**
  String get budgetUnknownCategory;

  /// No description provided for @budgetUncategorized.
  ///
  /// In zh, this message translates to:
  /// **'未分类'**
  String get budgetUncategorized;

  /// No description provided for @budgetUsedPercent.
  ///
  /// In zh, this message translates to:
  /// **'已使用 {percent}%'**
  String budgetUsedPercent(String percent);

  /// No description provided for @budgetCategoryCount.
  ///
  /// In zh, this message translates to:
  /// **'已设置 {count} 个分类预算'**
  String budgetCategoryCount(String count);

  /// No description provided for @budgetAddCategoryBudget.
  ///
  /// In zh, this message translates to:
  /// **'添加分类预算'**
  String get budgetAddCategoryBudget;

  /// No description provided for @budgetAddCategoryBudgetDeveloping.
  ///
  /// In zh, this message translates to:
  /// **'添加分类预算功能开发中'**
  String get budgetAddCategoryBudgetDeveloping;

  /// No description provided for @budgetEditBudgetDeveloping.
  ///
  /// In zh, this message translates to:
  /// **'编辑预算功能开发中'**
  String get budgetEditBudgetDeveloping;

  /// No description provided for @budgetSetTotalTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置总预算'**
  String get budgetSetTotalTitle;

  /// No description provided for @budgetEditTotalTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑总预算'**
  String get budgetEditTotalTitle;

  /// No description provided for @budgetEditCategoryTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑分类预算'**
  String get budgetEditCategoryTitle;

  /// No description provided for @budgetInputAmount.
  ///
  /// In zh, this message translates to:
  /// **'输入预算金额'**
  String get budgetInputAmount;

  /// No description provided for @budgetSelectCategory.
  ///
  /// In zh, this message translates to:
  /// **'选择分类'**
  String get budgetSelectCategory;

  /// No description provided for @budgetNoCategoryAvailable.
  ///
  /// In zh, this message translates to:
  /// **'没有可用的分类'**
  String get budgetNoCategoryAvailable;

  /// No description provided for @budgetCategoryAlreadyExists.
  ///
  /// In zh, this message translates to:
  /// **'该分类预算已存在'**
  String get budgetCategoryAlreadyExists;

  /// No description provided for @budgetDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除预算'**
  String get budgetDeleteTitle;

  /// No description provided for @budgetDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除该分类的预算吗？'**
  String get budgetDeleteConfirm;

  /// No description provided for @budgetNoBudgets.
  ///
  /// In zh, this message translates to:
  /// **'暂未设置预算，点击右上角编辑按钮开始'**
  String get budgetNoBudgets;

  /// No description provided for @bookTitle.
  ///
  /// In zh, this message translates to:
  /// **'我的账本'**
  String get bookTitle;

  /// No description provided for @bookCreate.
  ///
  /// In zh, this message translates to:
  /// **'新建账本'**
  String get bookCreate;

  /// No description provided for @bookDescription.
  ///
  /// In zh, this message translates to:
  /// **'每个账本拥有独立的交易记录、预算和 AI 对话历史'**
  String get bookDescription;

  /// No description provided for @bookDefault.
  ///
  /// In zh, this message translates to:
  /// **'默认'**
  String get bookDefault;

  /// No description provided for @bookCurrent.
  ///
  /// In zh, this message translates to:
  /// **'当前'**
  String get bookCurrent;

  /// No description provided for @bookMonthlyExpense.
  ///
  /// In zh, this message translates to:
  /// **'本月支出'**
  String get bookMonthlyExpense;

  /// No description provided for @bookMonthlyIncome.
  ///
  /// In zh, this message translates to:
  /// **'本月收入'**
  String get bookMonthlyIncome;

  /// No description provided for @bookTransactionCount.
  ///
  /// In zh, this message translates to:
  /// **'笔数'**
  String get bookTransactionCount;

  /// No description provided for @bookSetDefault.
  ///
  /// In zh, this message translates to:
  /// **'设为默认'**
  String get bookSetDefault;

  /// No description provided for @bookDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get bookDelete;

  /// No description provided for @bookSwitchedTo.
  ///
  /// In zh, this message translates to:
  /// **'已切换到 {name}'**
  String bookSwitchedTo(String name);

  /// No description provided for @bookDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除账本'**
  String get bookDeleteTitle;

  /// No description provided for @bookDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除「{name}」吗？\n\n该账本下的所有交易记录、预算和对话历史将被清除，此操作不可撤销。'**
  String bookDeleteConfirm(String name);

  /// No description provided for @bookDeleted.
  ///
  /// In zh, this message translates to:
  /// **'账本已移至回收站'**
  String get bookDeleted;

  /// No description provided for @bookRecycleBin.
  ///
  /// In zh, this message translates to:
  /// **'账本回收站'**
  String get bookRecycleBin;

  /// No description provided for @bookRecycleBinEmpty.
  ///
  /// In zh, this message translates to:
  /// **'回收站为空'**
  String get bookRecycleBinEmpty;

  /// No description provided for @bookRestore.
  ///
  /// In zh, this message translates to:
  /// **'恢复'**
  String get bookRestore;

  /// No description provided for @bookRestored.
  ///
  /// In zh, this message translates to:
  /// **'账本已恢复'**
  String get bookRestored;

  /// No description provided for @txnRecycleBin.
  ///
  /// In zh, this message translates to:
  /// **'交易回收站'**
  String get txnRecycleBin;

  /// No description provided for @txnRecycleBinEmpty.
  ///
  /// In zh, this message translates to:
  /// **'回收站为空'**
  String get txnRecycleBinEmpty;

  /// No description provided for @txnRestore.
  ///
  /// In zh, this message translates to:
  /// **'恢复'**
  String get txnRestore;

  /// No description provided for @txnRestored.
  ///
  /// In zh, this message translates to:
  /// **'交易已恢复'**
  String get txnRestored;

  /// No description provided for @tagManage.
  ///
  /// In zh, this message translates to:
  /// **'标签管理'**
  String get tagManage;

  /// No description provided for @tagManageEmpty.
  ///
  /// In zh, this message translates to:
  /// **'还没有标签，点击右上角添加'**
  String get tagManageEmpty;

  /// No description provided for @tagAdd.
  ///
  /// In zh, this message translates to:
  /// **'新建标签'**
  String get tagAdd;

  /// No description provided for @tagEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑标签'**
  String get tagEdit;

  /// No description provided for @tagDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除标签'**
  String get tagDelete;

  /// No description provided for @tagDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除标签「{name}」吗？关联的交易不会被删除。'**
  String tagDeleteConfirm(String name);

  /// No description provided for @tagPickerTitle.
  ///
  /// In zh, this message translates to:
  /// **'选择标签'**
  String get tagPickerTitle;

  /// No description provided for @tagPickerCreate.
  ///
  /// In zh, this message translates to:
  /// **'新建标签'**
  String get tagPickerCreate;

  /// No description provided for @tagPickerNone.
  ///
  /// In zh, this message translates to:
  /// **'无标签'**
  String get tagPickerNone;

  /// No description provided for @tagCreated.
  ///
  /// In zh, this message translates to:
  /// **'标签已创建'**
  String get tagCreated;

  /// No description provided for @tagUpdated.
  ///
  /// In zh, this message translates to:
  /// **'标签已更新'**
  String get tagUpdated;

  /// No description provided for @tagDeleted.
  ///
  /// In zh, this message translates to:
  /// **'标签已删除'**
  String get tagDeleted;

  /// No description provided for @bookPermanentDelete.
  ///
  /// In zh, this message translates to:
  /// **'永久删除'**
  String get bookPermanentDelete;

  /// No description provided for @bookPermanentDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要永久删除「{name}」吗？\n所有数据将被清除，此操作不可撤销。'**
  String bookPermanentDeleteConfirm(String name);

  /// No description provided for @bookCountUnit.
  ///
  /// In zh, this message translates to:
  /// **'{count} 笔'**
  String bookCountUnit(String count);

  /// No description provided for @bookTypePersonal.
  ///
  /// In zh, this message translates to:
  /// **'个人'**
  String get bookTypePersonal;

  /// No description provided for @bookTypeFamily.
  ///
  /// In zh, this message translates to:
  /// **'家庭'**
  String get bookTypeFamily;

  /// No description provided for @bookTypeTravel.
  ///
  /// In zh, this message translates to:
  /// **'旅行'**
  String get bookTypeTravel;

  /// No description provided for @bookTypeBusiness.
  ///
  /// In zh, this message translates to:
  /// **'生意'**
  String get bookTypeBusiness;

  /// No description provided for @bookTypeCouple.
  ///
  /// In zh, this message translates to:
  /// **'情侣'**
  String get bookTypeCouple;

  /// No description provided for @bookTypeStudent.
  ///
  /// In zh, this message translates to:
  /// **'学生'**
  String get bookTypeStudent;

  /// No description provided for @bookTypeWedding.
  ///
  /// In zh, this message translates to:
  /// **'婚礼'**
  String get bookTypeWedding;

  /// No description provided for @bookTypeRental.
  ///
  /// In zh, this message translates to:
  /// **'租房'**
  String get bookTypeRental;

  /// No description provided for @bookTypeInvestment.
  ///
  /// In zh, this message translates to:
  /// **'投资'**
  String get bookTypeInvestment;

  /// No description provided for @bookTypePet.
  ///
  /// In zh, this message translates to:
  /// **'宠物'**
  String get bookTypePet;

  /// No description provided for @bookTypeHealth.
  ///
  /// In zh, this message translates to:
  /// **'医疗'**
  String get bookTypeHealth;

  /// No description provided for @bookTypeEvent.
  ///
  /// In zh, this message translates to:
  /// **'活动'**
  String get bookTypeEvent;

  /// No description provided for @bookTypeOther.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get bookTypeOther;

  /// No description provided for @bookTypeCustom.
  ///
  /// In zh, this message translates to:
  /// **'自定义'**
  String get bookTypeCustom;

  /// No description provided for @bookTypeCustomHint.
  ///
  /// In zh, this message translates to:
  /// **'输入自定义类型'**
  String get bookTypeCustomHint;

  /// No description provided for @bookDetailTitle.
  ///
  /// In zh, this message translates to:
  /// **'账本详情'**
  String get bookDetailTitle;

  /// No description provided for @bookDetailNotExist.
  ///
  /// In zh, this message translates to:
  /// **'账本不存在'**
  String get bookDetailNotExist;

  /// No description provided for @bookDetailExpenseCount.
  ///
  /// In zh, this message translates to:
  /// **'交易笔数'**
  String get bookDetailExpenseCount;

  /// No description provided for @bookDetailNormalSection.
  ///
  /// In zh, this message translates to:
  /// **'常规操作'**
  String get bookDetailNormalSection;

  /// No description provided for @bookDetailSetDefault.
  ///
  /// In zh, this message translates to:
  /// **'设为默认账本'**
  String get bookDetailSetDefault;

  /// No description provided for @bookDetailSwitchTo.
  ///
  /// In zh, this message translates to:
  /// **'切换到此账本'**
  String get bookDetailSwitchTo;

  /// No description provided for @bookDetailDangerSection.
  ///
  /// In zh, this message translates to:
  /// **'危险操作'**
  String get bookDetailDangerSection;

  /// No description provided for @bookDetailClearData.
  ///
  /// In zh, this message translates to:
  /// **'清空账本数据'**
  String get bookDetailClearData;

  /// No description provided for @bookDetailDefaultNotDeletable.
  ///
  /// In zh, this message translates to:
  /// **'当前账本不可删除'**
  String get bookDetailDefaultNotDeletable;

  /// No description provided for @bookDetailSetDefaultSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已设为默认账本'**
  String get bookDetailSetDefaultSuccess;

  /// No description provided for @bookDetailClearTitle.
  ///
  /// In zh, this message translates to:
  /// **'清空数据'**
  String get bookDetailClearTitle;

  /// No description provided for @bookDetailClearConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要清空「{name}」的所有交易记录和对话历史吗？\n\n此操作不可撤销。'**
  String bookDetailClearConfirm(String name);

  /// No description provided for @bookDetailClear.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get bookDetailClear;

  /// No description provided for @bookDetailCleared.
  ///
  /// In zh, this message translates to:
  /// **'数据已清空'**
  String get bookDetailCleared;

  /// No description provided for @bookDetailDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除「{name}」吗？\n\n账本将移至回收站，数据不会丢失。'**
  String bookDetailDeleteConfirm(String name);

  /// No description provided for @bookDetailTypePersonal.
  ///
  /// In zh, this message translates to:
  /// **'个人账本'**
  String get bookDetailTypePersonal;

  /// No description provided for @bookDetailTypeFamily.
  ///
  /// In zh, this message translates to:
  /// **'家庭账本'**
  String get bookDetailTypeFamily;

  /// No description provided for @bookDetailTypeTravel.
  ///
  /// In zh, this message translates to:
  /// **'旅行账本'**
  String get bookDetailTypeTravel;

  /// No description provided for @bookDetailTypeBusiness.
  ///
  /// In zh, this message translates to:
  /// **'生意账本'**
  String get bookDetailTypeBusiness;

  /// No description provided for @bookDetailTypeOther.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get bookDetailTypeOther;

  /// No description provided for @reportTitle.
  ///
  /// In zh, this message translates to:
  /// **'报表分析'**
  String get reportTitle;

  /// No description provided for @reportPeriodWeek.
  ///
  /// In zh, this message translates to:
  /// **'周'**
  String get reportPeriodWeek;

  /// No description provided for @reportPeriodMonth.
  ///
  /// In zh, this message translates to:
  /// **'月'**
  String get reportPeriodMonth;

  /// No description provided for @reportPeriodYear.
  ///
  /// In zh, this message translates to:
  /// **'年'**
  String get reportPeriodYear;

  /// No description provided for @reportTypeExpense.
  ///
  /// In zh, this message translates to:
  /// **'支出'**
  String get reportTypeExpense;

  /// No description provided for @reportTypeIncome.
  ///
  /// In zh, this message translates to:
  /// **'收入'**
  String get reportTypeIncome;

  /// No description provided for @reportTotalExpense.
  ///
  /// In zh, this message translates to:
  /// **'总支出'**
  String get reportTotalExpense;

  /// No description provided for @reportTotalIncome.
  ///
  /// In zh, this message translates to:
  /// **'总收入'**
  String get reportTotalIncome;

  /// No description provided for @reportCount.
  ///
  /// In zh, this message translates to:
  /// **'笔数'**
  String get reportCount;

  /// No description provided for @reportCountUnit.
  ///
  /// In zh, this message translates to:
  /// **'{count}笔'**
  String reportCountUnit(String count);

  /// No description provided for @reportDailyAverage.
  ///
  /// In zh, this message translates to:
  /// **'日均'**
  String get reportDailyAverage;

  /// No description provided for @reportCategoryCount.
  ///
  /// In zh, this message translates to:
  /// **'分类'**
  String get reportCategoryCount;

  /// No description provided for @reportCategoryCountUnit.
  ///
  /// In zh, this message translates to:
  /// **'{count}个'**
  String reportCategoryCountUnit(String count);

  /// No description provided for @reportCategoryDistribution.
  ///
  /// In zh, this message translates to:
  /// **'分类占比'**
  String get reportCategoryDistribution;

  /// No description provided for @reportCategoryRanking.
  ///
  /// In zh, this message translates to:
  /// **'分类排行'**
  String get reportCategoryRanking;

  /// No description provided for @reportNoData.
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get reportNoData;

  /// No description provided for @reportMonthLabel.
  ///
  /// In zh, this message translates to:
  /// **'{year}年{month}月'**
  String reportMonthLabel(String year, String month);

  /// No description provided for @reportYearLabel.
  ///
  /// In zh, this message translates to:
  /// **'{year}年'**
  String reportYearLabel(String year);

  /// No description provided for @reportWeekLabel.
  ///
  /// In zh, this message translates to:
  /// **'{start} - {end}'**
  String reportWeekLabel(String start, String end);

  /// No description provided for @securityLockSettings.
  ///
  /// In zh, this message translates to:
  /// **'密码锁设置'**
  String get securityLockSettings;

  /// No description provided for @securityEnableLock.
  ///
  /// In zh, this message translates to:
  /// **'启用密码锁'**
  String get securityEnableLock;

  /// No description provided for @securityUnlockMethods.
  ///
  /// In zh, this message translates to:
  /// **'解锁方式（可多选）'**
  String get securityUnlockMethods;

  /// No description provided for @securityPinCode.
  ///
  /// In zh, this message translates to:
  /// **'数字密码'**
  String get securityPinCode;

  /// No description provided for @securityPinCodeDesc.
  ///
  /// In zh, this message translates to:
  /// **'四位数字密码解锁'**
  String get securityPinCodeDesc;

  /// No description provided for @securityBiometric.
  ///
  /// In zh, this message translates to:
  /// **'指纹解锁'**
  String get securityBiometric;

  /// No description provided for @securityBiometricDesc.
  ///
  /// In zh, this message translates to:
  /// **'使用设备指纹快速解锁'**
  String get securityBiometricDesc;

  /// No description provided for @securityPatternLock.
  ///
  /// In zh, this message translates to:
  /// **'图案解锁'**
  String get securityPatternLock;

  /// No description provided for @securityPatternLockDesc.
  ///
  /// In zh, this message translates to:
  /// **'绘制图案解锁'**
  String get securityPatternLockDesc;

  /// No description provided for @securityLockHint.
  ///
  /// In zh, this message translates to:
  /// **'勾选多种解锁方式后，解锁界面会出现切换按钮。指纹解锁需要设备支持生物识别功能。'**
  String get securityLockHint;

  /// No description provided for @securityBiometricVerify.
  ///
  /// In zh, this message translates to:
  /// **'验证指纹以启用指纹解锁'**
  String get securityBiometricVerify;

  /// No description provided for @securityBiometricFail.
  ///
  /// In zh, this message translates to:
  /// **'指纹验证失败: {error}'**
  String securityBiometricFail(String error);

  /// No description provided for @securitySetPinLock.
  ///
  /// In zh, this message translates to:
  /// **'设置密码锁'**
  String get securitySetPinLock;

  /// No description provided for @securitySetPinTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置四位数字密码'**
  String get securitySetPinTitle;

  /// No description provided for @securityConfirmPinTitle.
  ///
  /// In zh, this message translates to:
  /// **'请再次输入新密码'**
  String get securityConfirmPinTitle;

  /// No description provided for @securityEnterPin.
  ///
  /// In zh, this message translates to:
  /// **'请输入密码解锁'**
  String get securityEnterPin;

  /// No description provided for @securityPinWrong.
  ///
  /// In zh, this message translates to:
  /// **'密码错误，请重试'**
  String get securityPinWrong;

  /// No description provided for @securityPinMismatch.
  ///
  /// In zh, this message translates to:
  /// **'两次输入不一致，请重新设置'**
  String get securityPinMismatch;

  /// No description provided for @securityPinSetSuccess.
  ///
  /// In zh, this message translates to:
  /// **'密码设置成功'**
  String get securityPinSetSuccess;

  /// No description provided for @securitySetPatternLock.
  ///
  /// In zh, this message translates to:
  /// **'设置图案锁'**
  String get securitySetPatternLock;

  /// No description provided for @securityDrawPattern.
  ///
  /// In zh, this message translates to:
  /// **'绘制解锁图案'**
  String get securityDrawPattern;

  /// No description provided for @securityConfirmPattern.
  ///
  /// In zh, this message translates to:
  /// **'请再次绘制图案确认'**
  String get securityConfirmPattern;

  /// No description provided for @securityDrawToUnlock.
  ///
  /// In zh, this message translates to:
  /// **'请绘制图案解锁'**
  String get securityDrawToUnlock;

  /// No description provided for @securityPatternHint.
  ///
  /// In zh, this message translates to:
  /// **'连接至少4个点'**
  String get securityPatternHint;

  /// No description provided for @securityConfirmPatternHint.
  ///
  /// In zh, this message translates to:
  /// **'请绘制与刚才相同的图案'**
  String get securityConfirmPatternHint;

  /// No description provided for @securityRedraw.
  ///
  /// In zh, this message translates to:
  /// **'重新绘制'**
  String get securityRedraw;

  /// No description provided for @securityPatternMinDots.
  ///
  /// In zh, this message translates to:
  /// **'请至少连接4个点'**
  String get securityPatternMinDots;

  /// No description provided for @securityPatternMismatch.
  ///
  /// In zh, this message translates to:
  /// **'两次图案不一致，请重新绘制'**
  String get securityPatternMismatch;

  /// No description provided for @securityPatternSetSuccess.
  ///
  /// In zh, this message translates to:
  /// **'图案设置成功'**
  String get securityPatternSetSuccess;

  /// No description provided for @securityPatternWrong.
  ///
  /// In zh, this message translates to:
  /// **'图案错误，请重试'**
  String get securityPatternWrong;

  /// No description provided for @securityAuthRequired.
  ///
  /// In zh, this message translates to:
  /// **'请验证身份以解锁应用'**
  String get securityAuthRequired;

  /// No description provided for @securitySelectUnlockMethod.
  ///
  /// In zh, this message translates to:
  /// **'选择解锁方式'**
  String get securitySelectUnlockMethod;

  /// No description provided for @securitySwitchUnlockMethod.
  ///
  /// In zh, this message translates to:
  /// **'切换解锁方式'**
  String get securitySwitchUnlockMethod;

  /// No description provided for @securityVerifyFingerprint.
  ///
  /// In zh, this message translates to:
  /// **'请验证指纹'**
  String get securityVerifyFingerprint;

  /// No description provided for @securityTouchToUnlock.
  ///
  /// In zh, this message translates to:
  /// **'触摸指纹传感器以解锁应用'**
  String get securityTouchToUnlock;

  /// No description provided for @securityRetryFingerprint.
  ///
  /// In zh, this message translates to:
  /// **'重试指纹'**
  String get securityRetryFingerprint;

  /// No description provided for @checkinTitle.
  ///
  /// In zh, this message translates to:
  /// **'打卡日历'**
  String get checkinTitle;

  /// No description provided for @checkinAlreadyCheckedIn.
  ///
  /// In zh, this message translates to:
  /// **'今天已经打过卡了'**
  String get checkinAlreadyCheckedIn;

  /// No description provided for @checkinCheckInSuccess.
  ///
  /// In zh, this message translates to:
  /// **'打卡成功！+10 AC币'**
  String get checkinCheckInSuccess;

  /// No description provided for @checkinRewardDaily.
  ///
  /// In zh, this message translates to:
  /// **'每日打卡奖励'**
  String get checkinRewardDaily;

  /// No description provided for @checkinStreak365.
  ///
  /// In zh, this message translates to:
  /// **'连续打卡一年！+2000 AC币'**
  String get checkinStreak365;

  /// No description provided for @checkinStreak180.
  ///
  /// In zh, this message translates to:
  /// **'连续打卡半年！+1000 AC币'**
  String get checkinStreak180;

  /// No description provided for @checkinStreak30.
  ///
  /// In zh, this message translates to:
  /// **'连续打卡一个月！+300 AC币'**
  String get checkinStreak30;

  /// No description provided for @checkinStreak7.
  ///
  /// In zh, this message translates to:
  /// **'连续打卡7天！+70 AC币'**
  String get checkinStreak7;

  /// No description provided for @checkinReward365.
  ///
  /// In zh, this message translates to:
  /// **'连续打卡365天奖励'**
  String get checkinReward365;

  /// No description provided for @checkinReward180.
  ///
  /// In zh, this message translates to:
  /// **'连续打卡180天奖励'**
  String get checkinReward180;

  /// No description provided for @checkinReward30.
  ///
  /// In zh, this message translates to:
  /// **'连续打卡30天奖励'**
  String get checkinReward30;

  /// No description provided for @checkinReward7.
  ///
  /// In zh, this message translates to:
  /// **'连续打卡7天奖励'**
  String get checkinReward7;

  /// No description provided for @checkinMakeupSelectHint.
  ///
  /// In zh, this message translates to:
  /// **'请先选择一个未打卡的日期'**
  String get checkinMakeupSelectHint;

  /// No description provided for @checkinMakeupFutureError.
  ///
  /// In zh, this message translates to:
  /// **'只能补签过去的日期'**
  String get checkinMakeupFutureError;

  /// No description provided for @checkinMakeupAlreadyChecked.
  ///
  /// In zh, this message translates to:
  /// **'该日期已打卡'**
  String get checkinMakeupAlreadyChecked;

  /// No description provided for @checkinMakeupInsufficient.
  ///
  /// In zh, this message translates to:
  /// **'AC币不足，补签需要100 AC币'**
  String get checkinMakeupInsufficient;

  /// No description provided for @checkinMakeupConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'补签确认'**
  String get checkinMakeupConfirmTitle;

  /// No description provided for @checkinMakeupConfirmContent.
  ///
  /// In zh, this message translates to:
  /// **'确定要补签 {date} 吗？\n将消耗 100 AC币（当前余额: {balance}）'**
  String checkinMakeupConfirmContent(String date, String balance);

  /// No description provided for @checkinMakeupConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确认补签'**
  String get checkinMakeupConfirm;

  /// No description provided for @checkinMakeupSuccess.
  ///
  /// In zh, this message translates to:
  /// **'补签成功！'**
  String get checkinMakeupSuccess;

  /// No description provided for @checkinMakeupCost.
  ///
  /// In zh, this message translates to:
  /// **'补签 {date}'**
  String checkinMakeupCost(String date);

  /// No description provided for @checkinConsecutiveDays.
  ///
  /// In zh, this message translates to:
  /// **'连续打卡'**
  String get checkinConsecutiveDays;

  /// No description provided for @checkinAcBalance.
  ///
  /// In zh, this message translates to:
  /// **'AC币余额'**
  String get checkinAcBalance;

  /// No description provided for @checkinTodayStatus.
  ///
  /// In zh, this message translates to:
  /// **'今日状态'**
  String get checkinTodayStatus;

  /// No description provided for @checkinMakeupButton.
  ///
  /// In zh, this message translates to:
  /// **'补签 (-100 AC币)'**
  String get checkinMakeupButton;

  /// No description provided for @checkinMakeupSelectButton.
  ///
  /// In zh, this message translates to:
  /// **'选择日期后补签'**
  String get checkinMakeupSelectButton;

  /// No description provided for @checkinTodayCheckIn.
  ///
  /// In zh, this message translates to:
  /// **'已打卡'**
  String get checkinTodayCheckIn;

  /// No description provided for @checkinTodayCheckInButton.
  ///
  /// In zh, this message translates to:
  /// **'今日打卡 +10'**
  String get checkinTodayCheckInButton;

  /// No description provided for @acCoinTitle.
  ///
  /// In zh, this message translates to:
  /// **'AC币记录'**
  String get acCoinTitle;

  /// No description provided for @acCoinCurrentBalance.
  ///
  /// In zh, this message translates to:
  /// **'当前余额'**
  String get acCoinCurrentBalance;

  /// No description provided for @acCoinEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无AC币记录'**
  String get acCoinEmpty;

  /// No description provided for @catExpenseFood.
  ///
  /// In zh, this message translates to:
  /// **'餐饮美食'**
  String get catExpenseFood;

  /// No description provided for @catExpenseTransport.
  ///
  /// In zh, this message translates to:
  /// **'交通出行'**
  String get catExpenseTransport;

  /// No description provided for @catExpenseHousing.
  ///
  /// In zh, this message translates to:
  /// **'居住'**
  String get catExpenseHousing;

  /// No description provided for @catExpenseClothing.
  ///
  /// In zh, this message translates to:
  /// **'服饰美容'**
  String get catExpenseClothing;

  /// No description provided for @catExpenseDaily.
  ///
  /// In zh, this message translates to:
  /// **'日用百货'**
  String get catExpenseDaily;

  /// No description provided for @catExpenseTech.
  ///
  /// In zh, this message translates to:
  /// **'数码科技'**
  String get catExpenseTech;

  /// No description provided for @catExpenseMedical.
  ///
  /// In zh, this message translates to:
  /// **'医疗健康'**
  String get catExpenseMedical;

  /// No description provided for @catExpenseEducation.
  ///
  /// In zh, this message translates to:
  /// **'教育学习'**
  String get catExpenseEducation;

  /// No description provided for @catExpenseEntertainment.
  ///
  /// In zh, this message translates to:
  /// **'休闲娱乐'**
  String get catExpenseEntertainment;

  /// No description provided for @catExpenseSocial.
  ///
  /// In zh, this message translates to:
  /// **'社交人情'**
  String get catExpenseSocial;

  /// No description provided for @catExpenseChildren.
  ///
  /// In zh, this message translates to:
  /// **'子女养育'**
  String get catExpenseChildren;

  /// No description provided for @catExpenseElderly.
  ///
  /// In zh, this message translates to:
  /// **'赡养长辈'**
  String get catExpenseElderly;

  /// No description provided for @catExpensePet.
  ///
  /// In zh, this message translates to:
  /// **'宠物'**
  String get catExpensePet;

  /// No description provided for @catExpenseWork.
  ///
  /// In zh, this message translates to:
  /// **'工作办公'**
  String get catExpenseWork;

  /// No description provided for @catExpenseFinance.
  ///
  /// In zh, this message translates to:
  /// **'金融保险'**
  String get catExpenseFinance;

  /// No description provided for @catExpenseOther.
  ///
  /// In zh, this message translates to:
  /// **'其他支出'**
  String get catExpenseOther;

  /// No description provided for @catIncomeSalary.
  ///
  /// In zh, this message translates to:
  /// **'工资薪酬'**
  String get catIncomeSalary;

  /// No description provided for @catIncomeInvestment.
  ///
  /// In zh, this message translates to:
  /// **'投资理财'**
  String get catIncomeInvestment;

  /// No description provided for @catIncomeSideJob.
  ///
  /// In zh, this message translates to:
  /// **'副业兼职'**
  String get catIncomeSideJob;

  /// No description provided for @catIncomeGift.
  ///
  /// In zh, this message translates to:
  /// **'红包馈赠'**
  String get catIncomeGift;

  /// No description provided for @catIncomeRefund.
  ///
  /// In zh, this message translates to:
  /// **'报销退款'**
  String get catIncomeRefund;

  /// No description provided for @catIncomeAsset.
  ///
  /// In zh, this message translates to:
  /// **'租金资产'**
  String get catIncomeAsset;

  /// No description provided for @catIncomeTransferIn.
  ///
  /// In zh, this message translates to:
  /// **'转账收入'**
  String get catIncomeTransferIn;

  /// No description provided for @catIncomeOther.
  ///
  /// In zh, this message translates to:
  /// **'其他收入'**
  String get catIncomeOther;

  /// No description provided for @catOtherTransfer.
  ///
  /// In zh, this message translates to:
  /// **'转账'**
  String get catOtherTransfer;

  /// No description provided for @catOtherRepayment.
  ///
  /// In zh, this message translates to:
  /// **'还款'**
  String get catOtherRepayment;

  /// No description provided for @catOtherSocial.
  ///
  /// In zh, this message translates to:
  /// **'人情往来'**
  String get catOtherSocial;

  /// No description provided for @catSubFoodBreakfast.
  ///
  /// In zh, this message translates to:
  /// **'早餐'**
  String get catSubFoodBreakfast;

  /// No description provided for @catSubFoodLunch.
  ///
  /// In zh, this message translates to:
  /// **'午餐'**
  String get catSubFoodLunch;

  /// No description provided for @catSubFoodDinner.
  ///
  /// In zh, this message translates to:
  /// **'晚餐'**
  String get catSubFoodDinner;

  /// No description provided for @catSubFoodLateSnack.
  ///
  /// In zh, this message translates to:
  /// **'夜宵'**
  String get catSubFoodLateSnack;

  /// No description provided for @catSubFoodDelivery.
  ///
  /// In zh, this message translates to:
  /// **'外卖'**
  String get catSubFoodDelivery;

  /// No description provided for @catSubFoodMilkTea.
  ///
  /// In zh, this message translates to:
  /// **'奶茶'**
  String get catSubFoodMilkTea;

  /// No description provided for @catSubFoodCoffee.
  ///
  /// In zh, this message translates to:
  /// **'咖啡'**
  String get catSubFoodCoffee;

  /// No description provided for @catSubFoodDrinks.
  ///
  /// In zh, this message translates to:
  /// **'饮料'**
  String get catSubFoodDrinks;

  /// No description provided for @catSubFoodDessert.
  ///
  /// In zh, this message translates to:
  /// **'甜点'**
  String get catSubFoodDessert;

  /// No description provided for @catSubFoodSnacks.
  ///
  /// In zh, this message translates to:
  /// **'零食小吃'**
  String get catSubFoodSnacks;

  /// No description provided for @catSubFoodFruit.
  ///
  /// In zh, this message translates to:
  /// **'水果'**
  String get catSubFoodFruit;

  /// No description provided for @catSubFoodGroceries.
  ///
  /// In zh, this message translates to:
  /// **'买菜'**
  String get catSubFoodGroceries;

  /// No description provided for @catSubFoodDiningOut.
  ///
  /// In zh, this message translates to:
  /// **'聚餐请客'**
  String get catSubFoodDiningOut;

  /// No description provided for @catSubTransportMetro.
  ///
  /// In zh, this message translates to:
  /// **'地铁'**
  String get catSubTransportMetro;

  /// No description provided for @catSubTransportBus.
  ///
  /// In zh, this message translates to:
  /// **'公交'**
  String get catSubTransportBus;

  /// No description provided for @catSubTransportTaxi.
  ///
  /// In zh, this message translates to:
  /// **'打车'**
  String get catSubTransportTaxi;

  /// No description provided for @catSubTransportRideshare.
  ///
  /// In zh, this message translates to:
  /// **'网约车'**
  String get catSubTransportRideshare;

  /// No description provided for @catSubTransportBikeShare.
  ///
  /// In zh, this message translates to:
  /// **'共享单车'**
  String get catSubTransportBikeShare;

  /// No description provided for @catSubTransportHighSpeedRail.
  ///
  /// In zh, this message translates to:
  /// **'高铁'**
  String get catSubTransportHighSpeedRail;

  /// No description provided for @catSubTransportTrain.
  ///
  /// In zh, this message translates to:
  /// **'火车'**
  String get catSubTransportTrain;

  /// No description provided for @catSubTransportFlight.
  ///
  /// In zh, this message translates to:
  /// **'飞机'**
  String get catSubTransportFlight;

  /// No description provided for @catSubTransportFuel.
  ///
  /// In zh, this message translates to:
  /// **'加油'**
  String get catSubTransportFuel;

  /// No description provided for @catSubTransportCharging.
  ///
  /// In zh, this message translates to:
  /// **'充电'**
  String get catSubTransportCharging;

  /// No description provided for @catSubTransportParking.
  ///
  /// In zh, this message translates to:
  /// **'停车费'**
  String get catSubTransportParking;

  /// No description provided for @catSubTransportToll.
  ///
  /// In zh, this message translates to:
  /// **'过路费'**
  String get catSubTransportToll;

  /// No description provided for @catSubTransportMaintenance.
  ///
  /// In zh, this message translates to:
  /// **'车辆保养'**
  String get catSubTransportMaintenance;

  /// No description provided for @catSubTransportRepair.
  ///
  /// In zh, this message translates to:
  /// **'车辆维修'**
  String get catSubTransportRepair;

  /// No description provided for @catSubTransportInsurance.
  ///
  /// In zh, this message translates to:
  /// **'车险'**
  String get catSubTransportInsurance;

  /// No description provided for @catSubHousingRent.
  ///
  /// In zh, this message translates to:
  /// **'房租'**
  String get catSubHousingRent;

  /// No description provided for @catSubHousingMortgage.
  ///
  /// In zh, this message translates to:
  /// **'房贷'**
  String get catSubHousingMortgage;

  /// No description provided for @catSubHousingWater.
  ///
  /// In zh, this message translates to:
  /// **'水费'**
  String get catSubHousingWater;

  /// No description provided for @catSubHousingElectricity.
  ///
  /// In zh, this message translates to:
  /// **'电费'**
  String get catSubHousingElectricity;

  /// No description provided for @catSubHousingGas.
  ///
  /// In zh, this message translates to:
  /// **'燃气费'**
  String get catSubHousingGas;

  /// No description provided for @catSubHousingPropertyFee.
  ///
  /// In zh, this message translates to:
  /// **'物业费'**
  String get catSubHousingPropertyFee;

  /// No description provided for @catSubHousingInternet.
  ///
  /// In zh, this message translates to:
  /// **'宽带网费'**
  String get catSubHousingInternet;

  /// No description provided for @catSubHousingPhone.
  ///
  /// In zh, this message translates to:
  /// **'手机话费'**
  String get catSubHousingPhone;

  /// No description provided for @catSubHousingCleaning.
  ///
  /// In zh, this message translates to:
  /// **'家政保洁'**
  String get catSubHousingCleaning;

  /// No description provided for @catSubHousingRepair.
  ///
  /// In zh, this message translates to:
  /// **'房屋维修'**
  String get catSubHousingRepair;

  /// No description provided for @catSubClothingApparel.
  ///
  /// In zh, this message translates to:
  /// **'衣物'**
  String get catSubClothingApparel;

  /// No description provided for @catSubClothingShoes.
  ///
  /// In zh, this message translates to:
  /// **'鞋子'**
  String get catSubClothingShoes;

  /// No description provided for @catSubClothingHats.
  ///
  /// In zh, this message translates to:
  /// **'帽子'**
  String get catSubClothingHats;

  /// No description provided for @catSubClothingBags.
  ///
  /// In zh, this message translates to:
  /// **'包包'**
  String get catSubClothingBags;

  /// No description provided for @catSubClothingCosmetics.
  ///
  /// In zh, this message translates to:
  /// **'化妆品'**
  String get catSubClothingCosmetics;

  /// No description provided for @catSubClothingSkincare.
  ///
  /// In zh, this message translates to:
  /// **'护肤品'**
  String get catSubClothingSkincare;

  /// No description provided for @catSubClothingHaircut.
  ///
  /// In zh, this message translates to:
  /// **'理发'**
  String get catSubClothingHaircut;

  /// No description provided for @catSubClothingManicure.
  ///
  /// In zh, this message translates to:
  /// **'美甲'**
  String get catSubClothingManicure;

  /// No description provided for @catSubClothingJewelry.
  ///
  /// In zh, this message translates to:
  /// **'饰品'**
  String get catSubClothingJewelry;

  /// No description provided for @catSubClothingAccessories.
  ///
  /// In zh, this message translates to:
  /// **'配件'**
  String get catSubClothingAccessories;

  /// No description provided for @catSubDailyNecessities.
  ///
  /// In zh, this message translates to:
  /// **'日用品'**
  String get catSubDailyNecessities;

  /// No description provided for @catSubDailyCleaning.
  ///
  /// In zh, this message translates to:
  /// **'清洁用品'**
  String get catSubDailyCleaning;

  /// No description provided for @catSubDailyKitchen.
  ///
  /// In zh, this message translates to:
  /// **'厨房用品'**
  String get catSubDailyKitchen;

  /// No description provided for @catSubDailyDecor.
  ///
  /// In zh, this message translates to:
  /// **'家居装饰'**
  String get catSubDailyDecor;

  /// No description provided for @catSubDailyStorage.
  ///
  /// In zh, this message translates to:
  /// **'收纳用品'**
  String get catSubDailyStorage;

  /// No description provided for @catSubDailyBedding.
  ///
  /// In zh, this message translates to:
  /// **'床上用品'**
  String get catSubDailyBedding;

  /// No description provided for @catSubDailyTissue.
  ///
  /// In zh, this message translates to:
  /// **'纸品'**
  String get catSubDailyTissue;

  /// No description provided for @catSubTechPhone.
  ///
  /// In zh, this message translates to:
  /// **'手机'**
  String get catSubTechPhone;

  /// No description provided for @catSubTechComputer.
  ///
  /// In zh, this message translates to:
  /// **'电脑'**
  String get catSubTechComputer;

  /// No description provided for @catSubTechAccessories.
  ///
  /// In zh, this message translates to:
  /// **'配件'**
  String get catSubTechAccessories;

  /// No description provided for @catSubTechConsumables.
  ///
  /// In zh, this message translates to:
  /// **'耗材'**
  String get catSubTechConsumables;

  /// No description provided for @catSubTechStorage.
  ///
  /// In zh, this message translates to:
  /// **'存储设备'**
  String get catSubTechStorage;

  /// No description provided for @catSubMedicalRegistration.
  ///
  /// In zh, this message translates to:
  /// **'门诊挂号'**
  String get catSubMedicalRegistration;

  /// No description provided for @catSubMedicalMedicine.
  ///
  /// In zh, this message translates to:
  /// **'药品'**
  String get catSubMedicalMedicine;

  /// No description provided for @catSubMedicalHospitalization.
  ///
  /// In zh, this message translates to:
  /// **'住院'**
  String get catSubMedicalHospitalization;

  /// No description provided for @catSubMedicalCheckup.
  ///
  /// In zh, this message translates to:
  /// **'体检'**
  String get catSubMedicalCheckup;

  /// No description provided for @catSubMedicalDental.
  ///
  /// In zh, this message translates to:
  /// **'口腔'**
  String get catSubMedicalDental;

  /// No description provided for @catSubMedicalEyeCare.
  ///
  /// In zh, this message translates to:
  /// **'眼科'**
  String get catSubMedicalEyeCare;

  /// No description provided for @catSubMedicalVaccine.
  ///
  /// In zh, this message translates to:
  /// **'疫苗'**
  String get catSubMedicalVaccine;

  /// No description provided for @catSubMedicalWellness.
  ///
  /// In zh, this message translates to:
  /// **'保健养生'**
  String get catSubMedicalWellness;

  /// No description provided for @catSubMedicalFitness.
  ///
  /// In zh, this message translates to:
  /// **'健身运动'**
  String get catSubMedicalFitness;

  /// No description provided for @catSubEducationBooks.
  ///
  /// In zh, this message translates to:
  /// **'书籍'**
  String get catSubEducationBooks;

  /// No description provided for @catSubEducationTuition.
  ///
  /// In zh, this message translates to:
  /// **'学费'**
  String get catSubEducationTuition;

  /// No description provided for @catSubEducationTraining.
  ///
  /// In zh, this message translates to:
  /// **'培训费'**
  String get catSubEducationTraining;

  /// No description provided for @catSubEducationExam.
  ///
  /// In zh, this message translates to:
  /// **'考试费'**
  String get catSubEducationExam;

  /// No description provided for @catSubEducationOnlineCourse.
  ///
  /// In zh, this message translates to:
  /// **'在线课程'**
  String get catSubEducationOnlineCourse;

  /// No description provided for @catSubEducationStationery.
  ///
  /// In zh, this message translates to:
  /// **'文具用品'**
  String get catSubEducationStationery;

  /// No description provided for @catSubEntertainmentMovies.
  ///
  /// In zh, this message translates to:
  /// **'电影'**
  String get catSubEntertainmentMovies;

  /// No description provided for @catSubEntertainmentKtv.
  ///
  /// In zh, this message translates to:
  /// **'KTV'**
  String get catSubEntertainmentKtv;

  /// No description provided for @catSubEntertainmentGaming.
  ///
  /// In zh, this message translates to:
  /// **'游戏充值'**
  String get catSubEntertainmentGaming;

  /// No description provided for @catSubEntertainmentSubscription.
  ///
  /// In zh, this message translates to:
  /// **'会员订阅'**
  String get catSubEntertainmentSubscription;

  /// No description provided for @catSubEntertainmentTickets.
  ///
  /// In zh, this message translates to:
  /// **'景点门票'**
  String get catSubEntertainmentTickets;

  /// No description provided for @catSubEntertainmentHotel.
  ///
  /// In zh, this message translates to:
  /// **'酒店住宿'**
  String get catSubEntertainmentHotel;

  /// No description provided for @catSubEntertainmentTravel.
  ///
  /// In zh, this message translates to:
  /// **'旅游'**
  String get catSubEntertainmentTravel;

  /// No description provided for @catSubEntertainmentShow.
  ///
  /// In zh, this message translates to:
  /// **'演出'**
  String get catSubEntertainmentShow;

  /// No description provided for @catSubEntertainmentStreaming.
  ///
  /// In zh, this message translates to:
  /// **'流媒体'**
  String get catSubEntertainmentStreaming;

  /// No description provided for @catSubSocialGift.
  ///
  /// In zh, this message translates to:
  /// **'礼物'**
  String get catSubSocialGift;

  /// No description provided for @catSubSocialRedPacket.
  ///
  /// In zh, this message translates to:
  /// **'红包'**
  String get catSubSocialRedPacket;

  /// No description provided for @catSubSocialWeddingGift.
  ///
  /// In zh, this message translates to:
  /// **'份子钱'**
  String get catSubSocialWeddingGift;

  /// No description provided for @catSubSocialTreat.
  ///
  /// In zh, this message translates to:
  /// **'请客'**
  String get catSubSocialTreat;

  /// No description provided for @catSubSocialBirthday.
  ///
  /// In zh, this message translates to:
  /// **'生日聚会'**
  String get catSubSocialBirthday;

  /// No description provided for @catSubSocialVisit.
  ///
  /// In zh, this message translates to:
  /// **'探望慰问'**
  String get catSubSocialVisit;

  /// No description provided for @catSubSocialRespect.
  ///
  /// In zh, this message translates to:
  /// **'孝敬长辈'**
  String get catSubSocialRespect;

  /// No description provided for @catSubSocialCharity.
  ///
  /// In zh, this message translates to:
  /// **'慈善捐助'**
  String get catSubSocialCharity;

  /// No description provided for @catSubChildrenFormula.
  ///
  /// In zh, this message translates to:
  /// **'奶粉辅食'**
  String get catSubChildrenFormula;

  /// No description provided for @catSubChildrenDiapers.
  ///
  /// In zh, this message translates to:
  /// **'尿布用品'**
  String get catSubChildrenDiapers;

  /// No description provided for @catSubChildrenTuition.
  ///
  /// In zh, this message translates to:
  /// **'学费'**
  String get catSubChildrenTuition;

  /// No description provided for @catSubChildrenHobby.
  ///
  /// In zh, this message translates to:
  /// **'兴趣班'**
  String get catSubChildrenHobby;

  /// No description provided for @catSubChildrenTutoring.
  ///
  /// In zh, this message translates to:
  /// **'辅导班'**
  String get catSubChildrenTutoring;

  /// No description provided for @catSubChildrenDaycare.
  ///
  /// In zh, this message translates to:
  /// **'午托晚托'**
  String get catSubChildrenDaycare;

  /// No description provided for @catSubChildrenToys.
  ///
  /// In zh, this message translates to:
  /// **'玩具'**
  String get catSubChildrenToys;

  /// No description provided for @catSubElderlySupport.
  ///
  /// In zh, this message translates to:
  /// **'赡养费'**
  String get catSubElderlySupport;

  /// No description provided for @catSubElderlyNutrition.
  ///
  /// In zh, this message translates to:
  /// **'营养品'**
  String get catSubElderlyNutrition;

  /// No description provided for @catSubElderlyMedical.
  ///
  /// In zh, this message translates to:
  /// **'医疗费'**
  String get catSubElderlyMedical;

  /// No description provided for @catSubElderlyAllowance.
  ///
  /// In zh, this message translates to:
  /// **'孝敬金'**
  String get catSubElderlyAllowance;

  /// No description provided for @catSubPetFood.
  ///
  /// In zh, this message translates to:
  /// **'宠物食品'**
  String get catSubPetFood;

  /// No description provided for @catSubPetMedical.
  ///
  /// In zh, this message translates to:
  /// **'宠物医疗'**
  String get catSubPetMedical;

  /// No description provided for @catSubPetSupplies.
  ///
  /// In zh, this message translates to:
  /// **'宠物用品'**
  String get catSubPetSupplies;

  /// No description provided for @catSubPetGrooming.
  ///
  /// In zh, this message translates to:
  /// **'宠物美容'**
  String get catSubPetGrooming;

  /// No description provided for @catSubWorkOffice.
  ///
  /// In zh, this message translates to:
  /// **'办公用品'**
  String get catSubWorkOffice;

  /// No description provided for @catSubWorkPrinting.
  ///
  /// In zh, this message translates to:
  /// **'打印复印'**
  String get catSubWorkPrinting;

  /// No description provided for @catSubWorkShipping.
  ///
  /// In zh, this message translates to:
  /// **'快递物流'**
  String get catSubWorkShipping;

  /// No description provided for @catSubWorkTravel.
  ///
  /// In zh, this message translates to:
  /// **'差旅费'**
  String get catSubWorkTravel;

  /// No description provided for @catSubFinanceInsurance.
  ///
  /// In zh, this message translates to:
  /// **'保险费用'**
  String get catSubFinanceInsurance;

  /// No description provided for @catSubFinanceLoss.
  ///
  /// In zh, this message translates to:
  /// **'理财亏损'**
  String get catSubFinanceLoss;

  /// No description provided for @catSubFinanceFee.
  ///
  /// In zh, this message translates to:
  /// **'手续费'**
  String get catSubFinanceFee;

  /// No description provided for @catSubFinanceLoanInterest.
  ///
  /// In zh, this message translates to:
  /// **'贷款利息'**
  String get catSubFinanceLoanInterest;

  /// No description provided for @catSubFinanceTax.
  ///
  /// In zh, this message translates to:
  /// **'税费'**
  String get catSubFinanceTax;

  /// No description provided for @catSubFinanceFine.
  ///
  /// In zh, this message translates to:
  /// **'罚款'**
  String get catSubFinanceFine;

  /// No description provided for @catSubOtherExpenseGeneral.
  ///
  /// In zh, this message translates to:
  /// **'其他消费'**
  String get catSubOtherExpenseGeneral;

  /// No description provided for @catSubOtherExpenseUnexpected.
  ///
  /// In zh, this message translates to:
  /// **'意外支出'**
  String get catSubOtherExpenseUnexpected;

  /// No description provided for @catSubSalaryBase.
  ///
  /// In zh, this message translates to:
  /// **'基本工资'**
  String get catSubSalaryBase;

  /// No description provided for @catSubSalaryBonus.
  ///
  /// In zh, this message translates to:
  /// **'绩效奖金'**
  String get catSubSalaryBonus;

  /// No description provided for @catSubSalaryOvertime.
  ///
  /// In zh, this message translates to:
  /// **'加班费'**
  String get catSubSalaryOvertime;

  /// No description provided for @catSubSalaryYearEnd.
  ///
  /// In zh, this message translates to:
  /// **'年终奖'**
  String get catSubSalaryYearEnd;

  /// No description provided for @catSubSalaryBackPay.
  ///
  /// In zh, this message translates to:
  /// **'调薪补发'**
  String get catSubSalaryBackPay;

  /// No description provided for @catSubSalaryAllowance.
  ///
  /// In zh, this message translates to:
  /// **'津贴补贴'**
  String get catSubSalaryAllowance;

  /// No description provided for @catSubInvestmentFund.
  ///
  /// In zh, this message translates to:
  /// **'基金收益'**
  String get catSubInvestmentFund;

  /// No description provided for @catSubInvestmentStock.
  ///
  /// In zh, this message translates to:
  /// **'股票收益'**
  String get catSubInvestmentStock;

  /// No description provided for @catSubInvestmentInterest.
  ///
  /// In zh, this message translates to:
  /// **'利息收入'**
  String get catSubInvestmentInterest;

  /// No description provided for @catSubInvestmentWealthMgmt.
  ///
  /// In zh, this message translates to:
  /// **'理财产品'**
  String get catSubInvestmentWealthMgmt;

  /// No description provided for @catSubInvestmentCrypto.
  ///
  /// In zh, this message translates to:
  /// **'数字货币'**
  String get catSubInvestmentCrypto;

  /// No description provided for @catSubInvestmentDividend.
  ///
  /// In zh, this message translates to:
  /// **'分红'**
  String get catSubInvestmentDividend;

  /// No description provided for @catSubSideJobPartTime.
  ///
  /// In zh, this message translates to:
  /// **'兼职收入'**
  String get catSubSideJobPartTime;

  /// No description provided for @catSubSideJobFreelance.
  ///
  /// In zh, this message translates to:
  /// **'自由职业'**
  String get catSubSideJobFreelance;

  /// No description provided for @catSubSideJobRoyalty.
  ///
  /// In zh, this message translates to:
  /// **'稿费版权'**
  String get catSubSideJobRoyalty;

  /// No description provided for @catSubSideJobCommission.
  ///
  /// In zh, this message translates to:
  /// **'佣金提成'**
  String get catSubSideJobCommission;

  /// No description provided for @catSubSideJobSales.
  ///
  /// In zh, this message translates to:
  /// **'销售收入'**
  String get catSubSideJobSales;

  /// No description provided for @catSubGiftRedPacket.
  ///
  /// In zh, this message translates to:
  /// **'红包收入'**
  String get catSubGiftRedPacket;

  /// No description provided for @catSubGiftPresent.
  ///
  /// In zh, this message translates to:
  /// **'礼金馈赠'**
  String get catSubGiftPresent;

  /// No description provided for @catSubGiftFestival.
  ///
  /// In zh, this message translates to:
  /// **'节日红包'**
  String get catSubGiftFestival;

  /// No description provided for @catSubRefundReimbursement.
  ///
  /// In zh, this message translates to:
  /// **'报销到账'**
  String get catSubRefundReimbursement;

  /// No description provided for @catSubRefundReturn.
  ///
  /// In zh, this message translates to:
  /// **'退款收入'**
  String get catSubRefundReturn;

  /// No description provided for @catSubRefundMedical.
  ///
  /// In zh, this message translates to:
  /// **'医保报销'**
  String get catSubRefundMedical;

  /// No description provided for @catSubRefundInsurance.
  ///
  /// In zh, this message translates to:
  /// **'保险理赔'**
  String get catSubRefundInsurance;

  /// No description provided for @catSubAssetRent.
  ///
  /// In zh, this message translates to:
  /// **'房租收入'**
  String get catSubAssetRent;

  /// No description provided for @catSubAssetIdleSale.
  ///
  /// In zh, this message translates to:
  /// **'闲置出售'**
  String get catSubAssetIdleSale;

  /// No description provided for @catSubAssetSecondhand.
  ///
  /// In zh, this message translates to:
  /// **'二手交易'**
  String get catSubAssetSecondhand;

  /// No description provided for @catSubAssetProfit.
  ///
  /// In zh, this message translates to:
  /// **'资产收益'**
  String get catSubAssetProfit;

  /// No description provided for @catSubTransferInBank.
  ///
  /// In zh, this message translates to:
  /// **'银行转入'**
  String get catSubTransferInBank;

  /// No description provided for @catSubTransferInWallet.
  ///
  /// In zh, this message translates to:
  /// **'钱包转入'**
  String get catSubTransferInWallet;

  /// No description provided for @catSubTransferInDebt.
  ///
  /// In zh, this message translates to:
  /// **'债务回收'**
  String get catSubTransferInDebt;

  /// No description provided for @catSubIncomeOtherWindfall.
  ///
  /// In zh, this message translates to:
  /// **'意外所得'**
  String get catSubIncomeOtherWindfall;

  /// No description provided for @catSubIncomeOtherSubsidy.
  ///
  /// In zh, this message translates to:
  /// **'政府补贴'**
  String get catSubIncomeOtherSubsidy;

  /// No description provided for @catSubIncomeOtherUncategorized.
  ///
  /// In zh, this message translates to:
  /// **'未分类'**
  String get catSubIncomeOtherUncategorized;

  /// No description provided for @catSubTransferBankIn.
  ///
  /// In zh, this message translates to:
  /// **'银行卡转入'**
  String get catSubTransferBankIn;

  /// No description provided for @catSubTransferBankOut.
  ///
  /// In zh, this message translates to:
  /// **'银行卡转出'**
  String get catSubTransferBankOut;

  /// No description provided for @catSubTransferWallet.
  ///
  /// In zh, this message translates to:
  /// **'钱包互转'**
  String get catSubTransferWallet;

  /// No description provided for @catSubTransferCrossIn.
  ///
  /// In zh, this message translates to:
  /// **'跨平台转入'**
  String get catSubTransferCrossIn;

  /// No description provided for @catSubTransferCrossOut.
  ///
  /// In zh, this message translates to:
  /// **'跨平台转出'**
  String get catSubTransferCrossOut;

  /// No description provided for @catSubRepaymentCreditCard.
  ///
  /// In zh, this message translates to:
  /// **'信用卡还款'**
  String get catSubRepaymentCreditCard;

  /// No description provided for @catSubRepaymentLoan.
  ///
  /// In zh, this message translates to:
  /// **'贷款还款'**
  String get catSubRepaymentLoan;

  /// No description provided for @catSubRepaymentBorrowed.
  ///
  /// In zh, this message translates to:
  /// **'借款归还'**
  String get catSubRepaymentBorrowed;

  /// No description provided for @catSubRepaymentLent.
  ///
  /// In zh, this message translates to:
  /// **'借款借出'**
  String get catSubRepaymentLent;

  /// No description provided for @catSubOtherSocialGift.
  ///
  /// In zh, this message translates to:
  /// **'随礼份子钱'**
  String get catSubOtherSocialGift;

  /// No description provided for @catSubOtherSocialWedding.
  ///
  /// In zh, this message translates to:
  /// **'婚丧嫁娶'**
  String get catSubOtherSocialWedding;

  /// No description provided for @catSubOtherSocialBirthday.
  ///
  /// In zh, this message translates to:
  /// **'生日聚会'**
  String get catSubOtherSocialBirthday;

  /// No description provided for @catSubOtherSocialFestival.
  ///
  /// In zh, this message translates to:
  /// **'节日红包往来'**
  String get catSubOtherSocialFestival;

  /// No description provided for @weekMon.
  ///
  /// In zh, this message translates to:
  /// **'一'**
  String get weekMon;

  /// No description provided for @weekTue.
  ///
  /// In zh, this message translates to:
  /// **'二'**
  String get weekTue;

  /// No description provided for @weekWed.
  ///
  /// In zh, this message translates to:
  /// **'三'**
  String get weekWed;

  /// No description provided for @weekThu.
  ///
  /// In zh, this message translates to:
  /// **'四'**
  String get weekThu;

  /// No description provided for @weekFri.
  ///
  /// In zh, this message translates to:
  /// **'五'**
  String get weekFri;

  /// No description provided for @weekSat.
  ///
  /// In zh, this message translates to:
  /// **'六'**
  String get weekSat;

  /// No description provided for @weekSun.
  ///
  /// In zh, this message translates to:
  /// **'日'**
  String get weekSun;

  /// No description provided for @weekMonFull.
  ///
  /// In zh, this message translates to:
  /// **'周一'**
  String get weekMonFull;

  /// No description provided for @weekTueFull.
  ///
  /// In zh, this message translates to:
  /// **'周二'**
  String get weekTueFull;

  /// No description provided for @weekWedFull.
  ///
  /// In zh, this message translates to:
  /// **'周三'**
  String get weekWedFull;

  /// No description provided for @weekThuFull.
  ///
  /// In zh, this message translates to:
  /// **'周四'**
  String get weekThuFull;

  /// No description provided for @weekFriFull.
  ///
  /// In zh, this message translates to:
  /// **'周五'**
  String get weekFriFull;

  /// No description provided for @weekSatFull.
  ///
  /// In zh, this message translates to:
  /// **'周六'**
  String get weekSatFull;

  /// No description provided for @weekSunFull.
  ///
  /// In zh, this message translates to:
  /// **'周日'**
  String get weekSunFull;

  /// No description provided for @commonSelectDateTime.
  ///
  /// In zh, this message translates to:
  /// **'选择日期时间'**
  String get commonSelectDateTime;

  /// No description provided for @commonBack.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get commonBack;

  /// No description provided for @commonDone.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get commonDone;

  /// No description provided for @commonAdd.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get commonAdd;

  /// No description provided for @commonEnterHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入{field}'**
  String commonEnterHint(String field);

  /// No description provided for @txnCategorySearch.
  ///
  /// In zh, this message translates to:
  /// **'搜索分类...'**
  String get txnCategorySearch;

  /// No description provided for @txnCategoryEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无分类'**
  String get txnCategoryEmpty;

  /// No description provided for @settingsSelectLanguage.
  ///
  /// In zh, this message translates to:
  /// **'选择语言'**
  String get settingsSelectLanguage;

  /// No description provided for @settingsSelectCurrency.
  ///
  /// In zh, this message translates to:
  /// **'选择货币'**
  String get settingsSelectCurrency;

  /// No description provided for @profileDefaultNickname.
  ///
  /// In zh, this message translates to:
  /// **'用户'**
  String get profileDefaultNickname;

  /// No description provided for @catManageTitle.
  ///
  /// In zh, this message translates to:
  /// **'分类管理'**
  String get catManageTitle;

  /// No description provided for @catManageSubTitle.
  ///
  /// In zh, this message translates to:
  /// **'{name} - 子分类'**
  String catManageSubTitle(String name);

  /// No description provided for @catManageAddSub.
  ///
  /// In zh, this message translates to:
  /// **'添加子分类'**
  String get catManageAddSub;

  /// No description provided for @catManageNameExists.
  ///
  /// In zh, this message translates to:
  /// **'该分类名已存在'**
  String get catManageNameExists;

  /// No description provided for @catManageSubNameExists.
  ///
  /// In zh, this message translates to:
  /// **'该子分类名已存在'**
  String get catManageSubNameExists;

  /// No description provided for @catManageDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get catManageDeleteTitle;

  /// No description provided for @catManageDeleteWithChildren.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除分类\"{name}\"及其所有子分类吗？'**
  String catManageDeleteWithChildren(String name);

  /// No description provided for @catManageDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除分类\"{name}\"吗？'**
  String catManageDeleteConfirm(String name);

  /// No description provided for @catManageDeleteBlocked.
  ///
  /// In zh, this message translates to:
  /// **'该分类有关联数据，无法删除'**
  String get catManageDeleteBlocked;

  /// No description provided for @catManageCustomBadge.
  ///
  /// In zh, this message translates to:
  /// **'自'**
  String get catManageCustomBadge;

  /// No description provided for @catManageCustom.
  ///
  /// In zh, this message translates to:
  /// **'自定义'**
  String get catManageCustom;

  /// No description provided for @catManageAddTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加{type}分类'**
  String catManageAddTitle(String type);

  /// No description provided for @catManageNameLabel.
  ///
  /// In zh, this message translates to:
  /// **'分类名称'**
  String get catManageNameLabel;

  /// No description provided for @catManageNameHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入分类名称'**
  String get catManageNameHint;

  /// No description provided for @catManageSelectIcon.
  ///
  /// In zh, this message translates to:
  /// **'选择图标'**
  String get catManageSelectIcon;

  /// No description provided for @catManageSelectColor.
  ///
  /// In zh, this message translates to:
  /// **'选择颜色'**
  String get catManageSelectColor;

  /// No description provided for @catManageAddSubTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加子分类 - {name}'**
  String catManageAddSubTitle(String name);

  /// No description provided for @catManageSubNameLabel.
  ///
  /// In zh, this message translates to:
  /// **'子分类名称'**
  String get catManageSubNameLabel;

  /// No description provided for @catManageSubNameHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入子分类名称'**
  String get catManageSubNameHint;

  /// No description provided for @catManageEditTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑分类'**
  String get catManageEditTitle;

  /// No description provided for @bookNameLabel.
  ///
  /// In zh, this message translates to:
  /// **'账本名称'**
  String get bookNameLabel;

  /// No description provided for @bookNameHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：日常记账'**
  String get bookNameHint;

  /// No description provided for @bookTypeLabel.
  ///
  /// In zh, this message translates to:
  /// **'账本类型'**
  String get bookTypeLabel;

  /// No description provided for @bookDescLabel.
  ///
  /// In zh, this message translates to:
  /// **'备注（可选）'**
  String get bookDescLabel;

  /// No description provided for @bookDescHint.
  ///
  /// In zh, this message translates to:
  /// **'简单描述账本用途'**
  String get bookDescHint;

  /// No description provided for @bookCreateButton.
  ///
  /// In zh, this message translates to:
  /// **'创建'**
  String get bookCreateButton;

  /// No description provided for @bookDescPersonal.
  ///
  /// In zh, this message translates to:
  /// **'日常个人记账'**
  String get bookDescPersonal;

  /// No description provided for @bookDescFamily.
  ///
  /// In zh, this message translates to:
  /// **'家庭共同开支'**
  String get bookDescFamily;

  /// No description provided for @bookDescTravel.
  ///
  /// In zh, this message translates to:
  /// **'旅行花费记录'**
  String get bookDescTravel;

  /// No description provided for @bookDescBusiness.
  ///
  /// In zh, this message translates to:
  /// **'副业/小生意收支'**
  String get bookDescBusiness;

  /// No description provided for @bookDescOther.
  ///
  /// In zh, this message translates to:
  /// **'自定义用途'**
  String get bookDescOther;

  /// No description provided for @aiPresetDeepseekNote.
  ///
  /// In zh, this message translates to:
  /// **'高性价比国产大模型'**
  String get aiPresetDeepseekNote;

  /// No description provided for @aiPresetOpenaiNote.
  ///
  /// In zh, this message translates to:
  /// **'需海外网络访问'**
  String get aiPresetOpenaiNote;

  /// No description provided for @aiPresetQwenName.
  ///
  /// In zh, this message translates to:
  /// **'通义千问 (阿里)'**
  String get aiPresetQwenName;

  /// No description provided for @aiPresetQwenNote.
  ///
  /// In zh, this message translates to:
  /// **'使用兼容模式地址'**
  String get aiPresetQwenNote;

  /// No description provided for @aiPresetDoubaoName.
  ///
  /// In zh, this message translates to:
  /// **'豆包 (字节)'**
  String get aiPresetDoubaoName;

  /// No description provided for @aiPresetDoubaoNote.
  ///
  /// In zh, this message translates to:
  /// **'需在火山方舟创建推理接入点，模型名使用接入点 ID'**
  String get aiPresetDoubaoNote;

  /// No description provided for @aiPresetZhipuName.
  ///
  /// In zh, this message translates to:
  /// **'智谱AI'**
  String get aiPresetZhipuName;

  /// No description provided for @aiPresetZhipuNote.
  ///
  /// In zh, this message translates to:
  /// **'glm-4-flash 有免费额度'**
  String get aiPresetZhipuNote;

  /// No description provided for @aiPresetKimiName.
  ///
  /// In zh, this message translates to:
  /// **'月之暗面 (Kimi)'**
  String get aiPresetKimiName;

  /// No description provided for @aiPresetKimiNote.
  ///
  /// In zh, this message translates to:
  /// **'擅长长文本理解'**
  String get aiPresetKimiNote;

  /// No description provided for @aiPresetClaudeNote.
  ///
  /// In zh, this message translates to:
  /// **'使用 Anthropic Messages API'**
  String get aiPresetClaudeNote;

  /// No description provided for @aiPresetMimoName.
  ///
  /// In zh, this message translates to:
  /// **'小米 MiMo'**
  String get aiPresetMimoName;

  /// No description provided for @aiPresetMimoNote.
  ///
  /// In zh, this message translates to:
  /// **'支持 OpenAI/Anthropic 兼容协议，中国/新加坡/欧洲多集群'**
  String get aiPresetMimoNote;

  /// No description provided for @aiPresetOllamaName.
  ///
  /// In zh, this message translates to:
  /// **'Ollama (本地)'**
  String get aiPresetOllamaName;

  /// No description provided for @aiPresetOllamaNote.
  ///
  /// In zh, this message translates to:
  /// **'需本地运行 Ollama 服务，模型名取决于本地安装'**
  String get aiPresetOllamaNote;

  /// No description provided for @llmCapTextLabel.
  ///
  /// In zh, this message translates to:
  /// **'文本模型'**
  String get llmCapTextLabel;

  /// No description provided for @llmCapTextDesc.
  ///
  /// In zh, this message translates to:
  /// **'用于记账解析、AI 对话'**
  String get llmCapTextDesc;

  /// No description provided for @llmCapVisionLabel.
  ///
  /// In zh, this message translates to:
  /// **'视觉模型'**
  String get llmCapVisionLabel;

  /// No description provided for @llmCapVisionDesc.
  ///
  /// In zh, this message translates to:
  /// **'用于拍照识别小票/发票'**
  String get llmCapVisionDesc;

  /// No description provided for @llmCapAudioLabel.
  ///
  /// In zh, this message translates to:
  /// **'语音模型'**
  String get llmCapAudioLabel;

  /// No description provided for @llmCapAudioDesc.
  ///
  /// In zh, this message translates to:
  /// **'用于语音转文字'**
  String get llmCapAudioDesc;

  /// No description provided for @currencyCny.
  ///
  /// In zh, this message translates to:
  /// **'人民币'**
  String get currencyCny;

  /// No description provided for @currencyUsd.
  ///
  /// In zh, this message translates to:
  /// **'美元'**
  String get currencyUsd;

  /// No description provided for @currencyKrw.
  ///
  /// In zh, this message translates to:
  /// **'韩元'**
  String get currencyKrw;

  /// No description provided for @currencyJpy.
  ///
  /// In zh, this message translates to:
  /// **'日元'**
  String get currencyJpy;

  /// No description provided for @currencyEur.
  ///
  /// In zh, this message translates to:
  /// **'欧元'**
  String get currencyEur;

  /// No description provided for @currencyGbp.
  ///
  /// In zh, this message translates to:
  /// **'英镑'**
  String get currencyGbp;

  /// No description provided for @currencyUnitYi.
  ///
  /// In zh, this message translates to:
  /// **'亿'**
  String get currencyUnitYi;

  /// No description provided for @currencyUnitWan.
  ///
  /// In zh, this message translates to:
  /// **'万'**
  String get currencyUnitWan;

  /// No description provided for @inputSourceText.
  ///
  /// In zh, this message translates to:
  /// **'文本'**
  String get inputSourceText;

  /// No description provided for @inputSourceVoice.
  ///
  /// In zh, this message translates to:
  /// **'语音'**
  String get inputSourceVoice;

  /// No description provided for @inputSourceImage.
  ///
  /// In zh, this message translates to:
  /// **'图片'**
  String get inputSourceImage;

  /// No description provided for @reportTrendMonth.
  ///
  /// In zh, this message translates to:
  /// **'{period}月'**
  String reportTrendMonth(String period);

  /// No description provided for @reportTrendDay.
  ///
  /// In zh, this message translates to:
  /// **'{period}日'**
  String reportTrendDay(String period);

  /// No description provided for @llmSettingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'AI 服务配置'**
  String get llmSettingsTitle;

  /// No description provided for @llmExportConfig.
  ///
  /// In zh, this message translates to:
  /// **'导出配置'**
  String get llmExportConfig;

  /// No description provided for @llmImportConfig.
  ///
  /// In zh, this message translates to:
  /// **'导入配置'**
  String get llmImportConfig;

  /// No description provided for @llmProviderManagement.
  ///
  /// In zh, this message translates to:
  /// **'服务商管理'**
  String get llmProviderManagement;

  /// No description provided for @llmAddProvider.
  ///
  /// In zh, this message translates to:
  /// **'添加服务商'**
  String get llmAddProvider;

  /// No description provided for @llmEditProvider.
  ///
  /// In zh, this message translates to:
  /// **'编辑服务商'**
  String get llmEditProvider;

  /// No description provided for @llmDeleteProvider.
  ///
  /// In zh, this message translates to:
  /// **'删除服务商'**
  String get llmDeleteProvider;

  /// No description provided for @llmDeleteProviderConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定删除「{name}」？'**
  String llmDeleteProviderConfirm(String name);

  /// No description provided for @llmNotConfigured.
  ///
  /// In zh, this message translates to:
  /// **'未配置'**
  String get llmNotConfigured;

  /// No description provided for @llmConfigured.
  ///
  /// In zh, this message translates to:
  /// **'已配置'**
  String get llmConfigured;

  /// No description provided for @llmNoProviders.
  ///
  /// In zh, this message translates to:
  /// **'尚未添加任何服务商'**
  String get llmNoProviders;

  /// No description provided for @llmUnnamedProvider.
  ///
  /// In zh, this message translates to:
  /// **'未命名服务商'**
  String get llmUnnamedProvider;

  /// No description provided for @llmInUse.
  ///
  /// In zh, this message translates to:
  /// **'使用中'**
  String get llmInUse;

  /// No description provided for @llmIncomplete.
  ///
  /// In zh, this message translates to:
  /// **'未完成'**
  String get llmIncomplete;

  /// No description provided for @llmTest.
  ///
  /// In zh, this message translates to:
  /// **'测试'**
  String get llmTest;

  /// No description provided for @llmConfigIncomplete.
  ///
  /// In zh, this message translates to:
  /// **'请先完善配置（需要 API Key、地址和至少一个模型）'**
  String get llmConfigIncomplete;

  /// No description provided for @llmConnectSuccess.
  ///
  /// In zh, this message translates to:
  /// **'✅ 连接成功'**
  String get llmConnectSuccess;

  /// No description provided for @llmConnectFail.
  ///
  /// In zh, this message translates to:
  /// **'❌ 连接失败，请检查地址、Key 和模型名称'**
  String get llmConnectFail;

  /// No description provided for @llmConfigCopied.
  ///
  /// In zh, this message translates to:
  /// **'配置已复制到剪贴板'**
  String get llmConfigCopied;

  /// No description provided for @llmClipboardEmpty.
  ///
  /// In zh, this message translates to:
  /// **'剪贴板为空'**
  String get llmClipboardEmpty;

  /// No description provided for @llmImported.
  ///
  /// In zh, this message translates to:
  /// **'已导入 {count} 个服务商配置'**
  String llmImported(String count);

  /// No description provided for @llmImportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导入失败，请检查 JSON 格式'**
  String get llmImportFailed;

  /// No description provided for @llmProviderNotConfigured.
  ///
  /// In zh, this message translates to:
  /// **'该服务商未配置 API Key 或请求地址，请先编辑'**
  String get llmProviderNotConfigured;

  /// No description provided for @llmModelsFetched.
  ///
  /// In zh, this message translates to:
  /// **'获取到 {count} 个{label}'**
  String llmModelsFetched(String count, String label);

  /// No description provided for @llmModelsFetchedAll.
  ///
  /// In zh, this message translates to:
  /// **'获取到 {count} 个模型（未筛选到专用模型，显示全部）'**
  String llmModelsFetchedAll(String count);

  /// No description provided for @llmFetchFailed.
  ///
  /// In zh, this message translates to:
  /// **'获取失败，已加载预设模型列表'**
  String get llmFetchFailed;

  /// No description provided for @llmFetchError.
  ///
  /// In zh, this message translates to:
  /// **'获取模型失败: {error}'**
  String llmFetchError(String error);

  /// No description provided for @llmModelSet.
  ///
  /// In zh, this message translates to:
  /// **'已设置 {capability}：{provider} · {model}'**
  String llmModelSet(String capability, String provider, String model);

  /// No description provided for @llmInputModelName.
  ///
  /// In zh, this message translates to:
  /// **'输入{capability}名称'**
  String llmInputModelName(String capability);

  /// No description provided for @llmConnectFailed.
  ///
  /// In zh, this message translates to:
  /// **'连接失败'**
  String get llmConnectFailed;

  /// No description provided for @llmAutoDetectInterval.
  ///
  /// In zh, this message translates to:
  /// **'自动检测间隔'**
  String get llmAutoDetectInterval;

  /// No description provided for @llmIntervalOff.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get llmIntervalOff;

  /// No description provided for @llmInterval10s.
  ///
  /// In zh, this message translates to:
  /// **'10秒'**
  String get llmInterval10s;

  /// No description provided for @llmInterval30s.
  ///
  /// In zh, this message translates to:
  /// **'30秒'**
  String get llmInterval30s;

  /// No description provided for @llmInterval1m.
  ///
  /// In zh, this message translates to:
  /// **'1分钟'**
  String get llmInterval1m;

  /// No description provided for @llmInterval2m.
  ///
  /// In zh, this message translates to:
  /// **'2分钟'**
  String get llmInterval2m;

  /// No description provided for @llmInterval5m.
  ///
  /// In zh, this message translates to:
  /// **'5分钟'**
  String get llmInterval5m;

  /// No description provided for @llmInterval10m.
  ///
  /// In zh, this message translates to:
  /// **'10分钟'**
  String get llmInterval10m;

  /// No description provided for @llmInterval30m.
  ///
  /// In zh, this message translates to:
  /// **'30分钟'**
  String get llmInterval30m;

  /// No description provided for @llmInterval1h.
  ///
  /// In zh, this message translates to:
  /// **'1小时'**
  String get llmInterval1h;

  /// No description provided for @llmConfigureCap.
  ///
  /// In zh, this message translates to:
  /// **'配置{label}'**
  String llmConfigureCap(String label);

  /// No description provided for @llmCurrentUse.
  ///
  /// In zh, this message translates to:
  /// **'当前使用'**
  String get llmCurrentUse;

  /// No description provided for @llmFetch.
  ///
  /// In zh, this message translates to:
  /// **'获取'**
  String get llmFetch;

  /// No description provided for @llmTesting.
  ///
  /// In zh, this message translates to:
  /// **'检测中...'**
  String get llmTesting;

  /// No description provided for @llmTestConnection.
  ///
  /// In zh, this message translates to:
  /// **'检测连接'**
  String get llmTestConnection;

  /// No description provided for @llmFailed.
  ///
  /// In zh, this message translates to:
  /// **'失败'**
  String get llmFailed;

  /// No description provided for @llmSelectCap.
  ///
  /// In zh, this message translates to:
  /// **'选择{label}'**
  String llmSelectCap(String label);

  /// No description provided for @llmManualInput.
  ///
  /// In zh, this message translates to:
  /// **'✏️ 手动输入...'**
  String get llmManualInput;

  /// No description provided for @llmFillApiKey.
  ///
  /// In zh, this message translates to:
  /// **'请填写 API Key 和请求地址'**
  String get llmFillApiKey;

  /// No description provided for @llmCustom.
  ///
  /// In zh, this message translates to:
  /// **'自定义'**
  String get llmCustom;

  /// No description provided for @llmProviderName.
  ///
  /// In zh, this message translates to:
  /// **'服务商名称'**
  String get llmProviderName;

  /// No description provided for @llmApiUrl.
  ///
  /// In zh, this message translates to:
  /// **'请求地址'**
  String get llmApiUrl;

  /// No description provided for @llmApiUrlHintAnthropic.
  ///
  /// In zh, this message translates to:
  /// **'Anthropic API 地址，如 https://api.anthropic.com'**
  String get llmApiUrlHintAnthropic;

  /// No description provided for @llmApiUrlHelper.
  ///
  /// In zh, this message translates to:
  /// **'填入 API 的 base_url，不需要手动拼接 /chat/completions'**
  String get llmApiUrlHelper;

  /// No description provided for @llmSaveHint.
  ///
  /// In zh, this message translates to:
  /// **'保存后，请返回上一页通过能力卡片配置模型'**
  String get llmSaveHint;

  /// No description provided for @llmInputApiKey.
  ///
  /// In zh, this message translates to:
  /// **'输入 API Key'**
  String get llmInputApiKey;

  /// No description provided for @llmApiUrlExample.
  ///
  /// In zh, this message translates to:
  /// **'如：https://api.example.com'**
  String get llmApiUrlExample;

  /// No description provided for @llmAdvancedSettings.
  ///
  /// In zh, this message translates to:
  /// **'高级设置'**
  String get llmAdvancedSettings;

  /// No description provided for @llmTemperature.
  ///
  /// In zh, this message translates to:
  /// **'回答风格'**
  String get llmTemperature;

  /// No description provided for @llmTemperatureHint.
  ///
  /// In zh, this message translates to:
  /// **'越低越精确稳定，越高越发散多样'**
  String get llmTemperatureHint;

  /// No description provided for @llmTemperaturePrecise.
  ///
  /// In zh, this message translates to:
  /// **'精确'**
  String get llmTemperaturePrecise;

  /// No description provided for @llmTemperatureCreative.
  ///
  /// In zh, this message translates to:
  /// **'创意'**
  String get llmTemperatureCreative;

  /// No description provided for @llmMaxToken.
  ///
  /// In zh, this message translates to:
  /// **'最大 Token'**
  String get llmMaxToken;

  /// No description provided for @llmTimeout.
  ///
  /// In zh, this message translates to:
  /// **'超时（秒）'**
  String get llmTimeout;

  /// No description provided for @llmErrorNoModelForCapability.
  ///
  /// In zh, this message translates to:
  /// **'未配置对应能力的模型'**
  String get llmErrorNoModelForCapability;

  /// No description provided for @llmErrorNoProviderConfigured.
  ///
  /// In zh, this message translates to:
  /// **'请先在设置中添加并配置 AI 服务商'**
  String get llmErrorNoProviderConfigured;

  /// No description provided for @llmErrorNoProviderOrInput.
  ///
  /// In zh, this message translates to:
  /// **'请先在设置中添加 AI 服务商，或输入更明确的描述'**
  String get llmErrorNoProviderOrInput;

  /// No description provided for @llmErrorCannotParseResponse.
  ///
  /// In zh, this message translates to:
  /// **'无法解析 AI 响应'**
  String get llmErrorCannotParseResponse;

  /// No description provided for @llmErrorInvalidResponseFormat.
  ///
  /// In zh, this message translates to:
  /// **'AI 响应格式不正确'**
  String get llmErrorInvalidResponseFormat;

  /// No description provided for @llmErrorParseFailed.
  ///
  /// In zh, this message translates to:
  /// **'解析 AI 响应失败: {error}'**
  String llmErrorParseFailed(String error);

  /// No description provided for @llmErrorTimeout.
  ///
  /// In zh, this message translates to:
  /// **'请求超时，请检查网络连接'**
  String get llmErrorTimeout;

  /// No description provided for @llmErrorInvalidApiKey.
  ///
  /// In zh, this message translates to:
  /// **'API Key 无效，请检查设置'**
  String get llmErrorInvalidApiKey;

  /// No description provided for @llmErrorRateLimit.
  ///
  /// In zh, this message translates to:
  /// **'请求过于频繁，请稍后再试'**
  String get llmErrorRateLimit;

  /// No description provided for @llmErrorForbidden.
  ///
  /// In zh, this message translates to:
  /// **'访问被拒绝，请检查 API Key 权限'**
  String get llmErrorForbidden;

  /// No description provided for @llmErrorRequestFailed.
  ///
  /// In zh, this message translates to:
  /// **'请求失败 ({code})'**
  String llmErrorRequestFailed(String code);

  /// No description provided for @llmErrorNetworkFailed.
  ///
  /// In zh, this message translates to:
  /// **'网络连接失败，请检查网络'**
  String get llmErrorNetworkFailed;

  /// No description provided for @llmErrorRequestFailedWithMessage.
  ///
  /// In zh, this message translates to:
  /// **'请求失败: {message}'**
  String llmErrorRequestFailedWithMessage(String message);

  /// No description provided for @visionErrorNoModelConfigured.
  ///
  /// In zh, this message translates to:
  /// **'未配置视觉识别模型，请在 AI 设置中配置'**
  String get visionErrorNoModelConfigured;

  /// No description provided for @visionErrorImageNotFound.
  ///
  /// In zh, this message translates to:
  /// **'图片文件不存在'**
  String get visionErrorImageNotFound;

  /// No description provided for @visionErrorRecognitionFailed.
  ///
  /// In zh, this message translates to:
  /// **'图片识别失败: {message}'**
  String visionErrorRecognitionFailed(String message);

  /// No description provided for @voiceErrorNoModelConfigured.
  ///
  /// In zh, this message translates to:
  /// **'未配置语音识别模型，请在 AI 设置中配置'**
  String get voiceErrorNoModelConfigured;

  /// No description provided for @voiceErrorAudioNotFound.
  ///
  /// In zh, this message translates to:
  /// **'音频文件不存在'**
  String get voiceErrorAudioNotFound;

  /// No description provided for @voiceErrorInvalidResponseFormat.
  ///
  /// In zh, this message translates to:
  /// **'语音识别返回格式异常'**
  String get voiceErrorInvalidResponseFormat;

  /// No description provided for @voiceErrorTranscriptionFailed.
  ///
  /// In zh, this message translates to:
  /// **'语音识别失败: {message}'**
  String voiceErrorTranscriptionFailed(String message);

  /// No description provided for @pipelineErrorEmptyVoiceResult.
  ///
  /// In zh, this message translates to:
  /// **'语音识别结果为空，请重新录制'**
  String get pipelineErrorEmptyVoiceResult;

  /// No description provided for @pipelineErrorEmptyImageResult.
  ///
  /// In zh, this message translates to:
  /// **'图片识别结果为空，请选择更清晰的图片'**
  String get pipelineErrorEmptyImageResult;

  /// No description provided for @acCoinInitialGiftDesc.
  ///
  /// In zh, this message translates to:
  /// **'新用户注册赠送'**
  String get acCoinInitialGiftDesc;

  /// No description provided for @loadFailedPullToRefresh.
  ///
  /// In zh, this message translates to:
  /// **'加载失败，请下拉刷新'**
  String get loadFailedPullToRefresh;

  /// No description provided for @llmSettingsGetModelListError.
  ///
  /// In zh, this message translates to:
  /// **'无法获取模型列表'**
  String get llmSettingsGetModelListError;

  /// No description provided for @searchPageTitle.
  ///
  /// In zh, this message translates to:
  /// **'搜索账单'**
  String get searchPageTitle;

  /// No description provided for @searchHint.
  ///
  /// In zh, this message translates to:
  /// **'输入关键词或自然语言，如\"上月打车花了多少\"'**
  String get searchHint;

  /// No description provided for @searchAiParsing.
  ///
  /// In zh, this message translates to:
  /// **'AI 正在理解你的查询...'**
  String get searchAiParsing;

  /// No description provided for @searchNoResults.
  ///
  /// In zh, this message translates to:
  /// **'未找到匹配的账单'**
  String get searchNoResults;

  /// No description provided for @searchNoResultsHint.
  ///
  /// In zh, this message translates to:
  /// **'试试其他关键词或换个说法'**
  String get searchNoResultsHint;

  /// No description provided for @searchResultCount.
  ///
  /// In zh, this message translates to:
  /// **'找到 {count} 条结果'**
  String searchResultCount(String count);

  /// No description provided for @searchAiSummaryTitle.
  ///
  /// In zh, this message translates to:
  /// **'📊 AI 分析结果'**
  String get searchAiSummaryTitle;

  /// No description provided for @searchAiSummaryLoading.
  ///
  /// In zh, this message translates to:
  /// **'AI 正在分析...'**
  String get searchAiSummaryLoading;

  /// No description provided for @searchTotalExpense.
  ///
  /// In zh, this message translates to:
  /// **'总支出'**
  String get searchTotalExpense;

  /// No description provided for @searchTotalIncome.
  ///
  /// In zh, this message translates to:
  /// **'总收入'**
  String get searchTotalIncome;

  /// No description provided for @searchTransactionCount.
  ///
  /// In zh, this message translates to:
  /// **'共 {count} 笔'**
  String searchTransactionCount(String count);

  /// No description provided for @searchAverage.
  ///
  /// In zh, this message translates to:
  /// **'日均'**
  String get searchAverage;

  /// No description provided for @searchMaxSingle.
  ///
  /// In zh, this message translates to:
  /// **'最大单笔'**
  String get searchMaxSingle;

  /// No description provided for @searchLlmNotConfigured.
  ///
  /// In zh, this message translates to:
  /// **'未配置 AI 服务，仅支持关键词搜索'**
  String get searchLlmNotConfigured;

  /// No description provided for @searchLlmError.
  ///
  /// In zh, this message translates to:
  /// **'AI 查询解析失败，已切换为关键词搜索'**
  String get searchLlmError;

  /// No description provided for @searchQuickSuggestions.
  ///
  /// In zh, this message translates to:
  /// **'搜索建议'**
  String get searchQuickSuggestions;

  /// No description provided for @searchSuggestionLastMonthExpense.
  ///
  /// In zh, this message translates to:
  /// **'上月消费汇总'**
  String get searchSuggestionLastMonthExpense;

  /// No description provided for @searchSuggestionThisMonthFood.
  ///
  /// In zh, this message translates to:
  /// **'本月餐饮消费'**
  String get searchSuggestionThisMonthFood;

  /// No description provided for @searchSuggestionRecentLarge.
  ///
  /// In zh, this message translates to:
  /// **'最近大额消费'**
  String get searchSuggestionRecentLarge;

  /// No description provided for @searchSuggestionRecentWeek.
  ///
  /// In zh, this message translates to:
  /// **'最近一周账单'**
  String get searchSuggestionRecentWeek;

  /// No description provided for @searchFilterExpense.
  ///
  /// In zh, this message translates to:
  /// **'支出'**
  String get searchFilterExpense;

  /// No description provided for @searchFilterIncome.
  ///
  /// In zh, this message translates to:
  /// **'收入'**
  String get searchFilterIncome;

  /// No description provided for @searchFilterAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get searchFilterAll;

  /// No description provided for @searchFilterDateRange.
  ///
  /// In zh, this message translates to:
  /// **'日期范围'**
  String get searchFilterDateRange;

  /// No description provided for @searchFilterAmountRange.
  ///
  /// In zh, this message translates to:
  /// **'金额范围'**
  String get searchFilterAmountRange;

  /// No description provided for @searchFilterCategory.
  ///
  /// In zh, this message translates to:
  /// **'分类'**
  String get searchFilterCategory;

  /// No description provided for @searchFilterPayment.
  ///
  /// In zh, this message translates to:
  /// **'支付方式'**
  String get searchFilterPayment;

  /// No description provided for @searchFilterClear.
  ///
  /// In zh, this message translates to:
  /// **'清除筛选'**
  String get searchFilterClear;

  /// No description provided for @searchModeKeyword.
  ///
  /// In zh, this message translates to:
  /// **'关键词'**
  String get searchModeKeyword;

  /// No description provided for @searchModeAi.
  ///
  /// In zh, this message translates to:
  /// **'AI 搜索'**
  String get searchModeAi;

  /// No description provided for @searchKeywordPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'搜索描述、备注、金额...'**
  String get searchKeywordPlaceholder;

  /// No description provided for @searchParsingFailed.
  ///
  /// In zh, this message translates to:
  /// **'AI 解析失败'**
  String get searchParsingFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
