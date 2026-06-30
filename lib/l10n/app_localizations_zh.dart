// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'WoAccount';

  @override
  String get navTransactions => '账单';

  @override
  String get navRecord => '记账';

  @override
  String get navProfile => '我的';

  @override
  String get commonCancel => '取消';

  @override
  String get commonConfirm => '确定';

  @override
  String get commonEditCategory => '修改分类';

  @override
  String get commonEditAmount => '修改金额';

  @override
  String get commonEditDescription => '修改描述';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '删除';

  @override
  String get commonEdit => '编辑';

  @override
  String get chatPageTitle => 'AI 记账';

  @override
  String get chatPageVoicePlaceholder => '🎤 语音消息';

  @override
  String get chatPageImagePlaceholder => '📷 图片消息';

  @override
  String chatPageVoiceTranscription(String text) {
    return '🎤 语音转文字：$text';
  }

  @override
  String chatPageImageRecognition(String text) {
    return '📷 图片识别结果：$text';
  }

  @override
  String get chatPageNoSubcategory => '暂无';

  @override
  String get chatPageConfigAiError => '请先在设置中添加并配置 AI 服务商';

  @override
  String chatPageParseError(String error) {
    return '❌ 解析失败：$error\n\n请尝试更明确的描述，如\"午饭拉面25\"';
  }

  @override
  String get chatPageNoCategoryError => '没有可用分类，请先在分类管理中添加分类';

  @override
  String get chatPageSaveSuccessTitle => '记账成功';

  @override
  String chatPageSaveSuccess(
    String amount,
    String category,
    String description,
    String date,
  ) {
    return '✅ 已保存\n$amount · $category\n$description · $date';
  }

  @override
  String chatPageSaveFailed(String error) {
    return '保存失败: $error';
  }

  @override
  String get chatPageEmptyTitle => '开始记账吧';

  @override
  String get chatPageEmptyHint => '试试输入 \"午饭拉面25\" 或 \"吃饭24，洗衣服34\"';

  @override
  String get chatPageEmptyInstruction => '长按记账按钮可语音输入 🎤 · 点击右侧按钮拍照识别 📷';

  @override
  String get chatPageAiParsing => 'AI 正在解析...';

  @override
  String get chatBubbleImageFailed => '图片加载失败';

  @override
  String get chatInputMicPermission => '请授权麦克风权限';

  @override
  String get chatInputRecordShort => '录音时间太短';

  @override
  String chatInputImageFailed(String error) {
    return '获取图片失败: $error';
  }

  @override
  String get chatInputCamera => '拍照';

  @override
  String get chatInputGallery => '从相册选择';

  @override
  String get chatInputVoiceHint => '松手发送，左滑取消 ↖，右滑转文字 ↗';

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
  String get voiceOverlaySwipeHint => '↑ 上滑取消或转文字';

  @override
  String get voiceOverlayCancelLabel => '松手 取消';

  @override
  String get voiceOverlayTranscribeLabel => '松手 仅转文字';

  @override
  String get chatInputTextHint => '输入文本开始记账';

  @override
  String get chatConfirmTitle => 'AI 解析结果';

  @override
  String get chatConfirmCategory => '分类';

  @override
  String get chatConfirmDescription => '描述';

  @override
  String get chatConfirmDate => '日期';

  @override
  String get chatConfirmAmount => '金额';

  @override
  String get chatConfirmSave => '确认保存';

  @override
  String get chatConfirmInputCategory => '输入分类名称';

  @override
  String get chatConfirmInputDescription => '输入描述';

  @override
  String get chatConfirmInputAmount => '输入金额';

  @override
  String get chatDeleteTitle => '清空对话';

  @override
  String get chatDeleteMessage => '确定要清空所有对话记录吗？此操作不可撤销。';

  @override
  String get chatDeleteSuccess => '对话已清空';

  @override
  String chatMultiSelectCount(String count) {
    return '已选 $count 条';
  }

  @override
  String get chatDeleteSelected => '删除选中';

  @override
  String chatDeleteSelectedConfirm(String count) {
    return '确定要删除选中的 $count 条消息吗？';
  }

  @override
  String get chatActionCopy => '复制';

  @override
  String get chatActionDelete => '删除消息';

  @override
  String get chatDeleteMsgConfirm => '确定要删除这条消息吗？';

  @override
  String get chatCopyMessage => '已复制到剪贴板';

  @override
  String get homePageAiNotConfigured => '尚未配置 AI 服务，将使用基础规则解析';

  @override
  String get homePageGoSettings => '去配置';

  @override
  String get homePageNoContent => '未识别到内容';

  @override
  String homePageRecordFailed(String error) {
    return '记账失败：$error';
  }

  @override
  String homePageRecordSuccess(String amount) {
    return '记账成功：$amount';
  }

  @override
  String homePageSaveFailed(String error) {
    return '保存失败：$error';
  }

  @override
  String get homePageBudgetAlert => '今日消费已超过日均预算的80%';

  @override
  String get homeInputManual => '手动记账';

  @override
  String get homeInputHint => '午饭吃了碗拉面25元';

  @override
  String get homeInputSubmit => '发送';

  @override
  String get homeInputCamera => '拍照识别';

  @override
  String get homeConfirmTitle => '🤖 AI解析结果';

  @override
  String homeConfirmOriginalInput(String input) {
    return '原始输入: $input';
  }

  @override
  String get homeConfirmAmount => '💰 金额';

  @override
  String get homeConfirmDate => '📅 日期';

  @override
  String get homeConfirmCategory => '🍜 分类';

  @override
  String get homeConfirmParseTime => '⏱️ 解析耗时';

  @override
  String get homeConfirmDescription => '📝 描述';

  @override
  String get homeConfirmConfidence => '置信度';

  @override
  String get homeConfirmEditDate => '修改日期';

  @override
  String get homeConfirmRecord => '确认记账';

  @override
  String get homeEntryTitle => 'AI 助手';

  @override
  String get homeEntrySubtitle => '智能记账 · 消费分析 · 问答查询';

  @override
  String get homeBudgetDetails => '详情';

  @override
  String get txnSearchHint => '搜索账单';

  @override
  String get txnBudget => '预算';

  @override
  String get txnToday => '今天';

  @override
  String get txnPeriodDay => '本日';

  @override
  String get txnPeriodWeek => '本周';

  @override
  String get txnPeriodMonth => '本月';

  @override
  String txnExpense(String period) {
    return '$period支出';
  }

  @override
  String txnIncome(String period) {
    return '$period收入';
  }

  @override
  String get txnBalance => '结余';

  @override
  String get txnSortByTime => '按时间';

  @override
  String get txnSortByAmount => '按金额';

  @override
  String get txnEmpty => '暂无账单记录';

  @override
  String get txnDayDetailEmpty => '当日无账单记录';

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
    return '收入 $amount';
  }

  @override
  String get txnGroupUncategorized => '未分类';

  @override
  String get txnGroupNoSubcategory => '暂无';

  @override
  String get viewDay => '日';

  @override
  String get viewWeek => '周';

  @override
  String get viewMonth => '月';

  @override
  String get txnDetailTitle => '账单详情';

  @override
  String get txnDetailSaved => '已保存';

  @override
  String get txnDetailDeleteConfirmTitle => '确认删除';

  @override
  String get txnDetailDeleteConfirmContent => '删除后将无法恢复，确定要删除这条账单吗？';

  @override
  String get txnDetailNotFound => '账单不存在';

  @override
  String get txnDetailUncategorized => '未分类';

  @override
  String get txnDetailCategory => '分类';

  @override
  String get txnDetailAmount => '金额';

  @override
  String get txnDetailDate => '日期';

  @override
  String get txnDetailNote => '备注';

  @override
  String get txnDetailPayMethod => '支付方式';

  @override
  String get txnDetailAddNoteHint => '点击添加备注';

  @override
  String get txnDetailAiRecord => 'AI解析记录';

  @override
  String get txnDetailOriginalInput => '原始输入';

  @override
  String get txnDetailParseSource => '解析来源';

  @override
  String get txnDetailConfidence => '置信度';

  @override
  String get txnDetailCreatedAt => '创建时间';

  @override
  String get entryTitle => '记账';

  @override
  String get entryBookType => '日常记账';

  @override
  String get entryExpense => '支出';

  @override
  String get entryIncome => '收入';

  @override
  String get entryOther => '其他';

  @override
  String entrySubCategoryTitle(String name) {
    return '$name - 子分类';
  }

  @override
  String get entryNoteHint => '添加备注...';

  @override
  String get entrySelectCategoryHint => '请选择分类';

  @override
  String get entrySelectThisCategory => '选此分类';

  @override
  String get entryNoSubCategory => '暂无子分类';

  @override
  String get payMethodDefault => '默认';

  @override
  String get payMethodCash => '现金';

  @override
  String get payMethodWechat => '微信';

  @override
  String get payMethodAlipay => '支付宝';

  @override
  String get payMethodCard => '银行卡';

  @override
  String get entryNumpadToday => '今天';

  @override
  String get entryNumpadDelete => '删除';

  @override
  String get entryNumpadDone => '完成';

  @override
  String entrySuccess(String amount) {
    return '记账成功：$amount';
  }

  @override
  String entryFailure(String error) {
    return '记账失败：$error';
  }

  @override
  String get profileCheckedIn => '已打卡';

  @override
  String get profileCheckIn => '打卡';

  @override
  String get profileConsecutiveDays => '连续打卡';

  @override
  String get profileTotalCheckInDays => '打卡总天数';

  @override
  String get profileTotalTransactions => '记账总笔数';

  @override
  String get profileFuncTheme => '主题切换';

  @override
  String get profileFuncAccountBooks => '我的账本';

  @override
  String get profileFuncBudget => '预算管理';

  @override
  String get profileFuncCategories => '分类管理';

  @override
  String get profileFuncReports => '报表分析';

  @override
  String get profileToolsAndServices => '工具与服务';

  @override
  String get profileMenuPasswordLock => '密码锁';

  @override
  String get profileMenuAcCoins => 'AC币';

  @override
  String get profileMenuAiConfig => 'AI 配置';

  @override
  String get profileMenuDataBackup => '数据备份';

  @override
  String get profileMenuImport => '账单导入';

  @override
  String get profileMenuExport => '账单导出';

  @override
  String get profileMenuFeedback => '用户反馈';

  @override
  String get profileMenuSettings => '设置';

  @override
  String profileFeatureComingSoon(String label) {
    return '$label功能即将推出';
  }

  @override
  String get profileBackupShareText => 'WoAccount 数据备份文件';

  @override
  String get profileBackupSuccess => '备份成功';

  @override
  String profileBackupFailed(String error) {
    return '备份失败: $error';
  }

  @override
  String get profileExportShareText => 'WoAccount 数据导出文件';

  @override
  String get profileExportSuccess => '导出成功';

  @override
  String profileExportFailed(String error) {
    return '导出失败: $error';
  }

  @override
  String get profileImportConfirm => '导入将覆盖当前所有数据，确定继续吗？';

  @override
  String get profileImportNoBackup => '没有找到备份文件';

  @override
  String get profileImportSuccess => '导入成功';

  @override
  String profileImportFailed(String error) {
    return '导入失败: $error';
  }

  @override
  String get profileExportExcel => '导出 Excel';

  @override
  String get profileImportExcel => '导入 Excel';

  @override
  String get profileExcelFormatTitle => 'Excel 格式说明';

  @override
  String profileImportExcelSuccess(int count) {
    return '成功导入 $count 条记录';
  }

  @override
  String get profileAlreadyCheckedIn => '今天已经打过卡了';

  @override
  String get profileCheckInSuccess => '打卡成功！';

  @override
  String profileCheckInFailure(String error) {
    return '打卡失败: $error';
  }

  @override
  String get profileThemeLight => '浅色模式';

  @override
  String get profileThemeDark => '深色模式';

  @override
  String get profileThemeSystem => '跟随系统';

  @override
  String profileUserId(String uid) {
    return 'ID: $uid';
  }

  @override
  String get profileEditTitle => '个人资料';

  @override
  String get profileEditNickname => '昵称';

  @override
  String get profileEditId => 'ID';

  @override
  String get profileEditGender => '性别';

  @override
  String get profileEditEmail => '邮箱';

  @override
  String get profileEditPhone => '手机';

  @override
  String get profileEditNotSet => '未设置';

  @override
  String get profileEditNotFound => '未找到用户资料';

  @override
  String get profileEditGenderMale => '男';

  @override
  String get profileEditGenderFemale => '女';

  @override
  String get profileEditGenderSecret => '保密';

  @override
  String get profileEditLogout => '退出登录';

  @override
  String get profileEditLogoutConfirmContent => '确定要退出登录吗？';

  @override
  String get profileEditLogoutExit => '退出';

  @override
  String get profileEditLogoutComingSoon => '退出登录功能即将完善';

  @override
  String get profileEditDeleteAccount => '申请注销账号';

  @override
  String get profileEditDeleteAccountConfirmContent => '注销账号后数据将无法恢复，确定要申请注销吗？';

  @override
  String get profileEditDeleteAccountSubmit => '申请注销';

  @override
  String get profileEditDeleteAccountSubmitted => '注销申请已提交';

  @override
  String get settingsTitle => '系统设置';

  @override
  String get settingsGeneral => '通用';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsDarkMode => '深色模式';

  @override
  String get settingsCurrency => '货币';

  @override
  String get settingsData => '数据';

  @override
  String get settingsAutoBackup => '自动备份';

  @override
  String get settingsBackupFrequency => '备份频率';

  @override
  String get settingsBackupDaily => '每天';

  @override
  String get settingsBackupWeekly => '每周';

  @override
  String get settingsBackupMonthly => '每月';

  @override
  String get settingsBackupManual => '仅手动';

  @override
  String get settingsNoBackupFound => '没有找到备份文件';

  @override
  String get settingsRestoreData => '恢复数据';

  @override
  String get settingsRestoreConfirm => '恢复将覆盖当前所有数据，确定继续吗？';

  @override
  String get settingsRestoreSuccess => '数据恢复成功';

  @override
  String settingsRestoreFailed(String error) {
    return '恢复失败: $error';
  }

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsDangerZone => '危险区';

  @override
  String get settingsClearData => '清除所有数据';

  @override
  String get settingsClearConfirm => '此操作不可恢复，确定要清除所有数据吗？';

  @override
  String get settingsClearDataSuccess => '数据已清除';

  @override
  String get settingsDeleteAccount => '注销账号';

  @override
  String get settingsDeleteConfirm => '注销后所有数据将被永久删除，确定要继续吗？';

  @override
  String get settingsDeleteAccountSuccess => '账户数据已删除';

  @override
  String get budgetTitle => '预算管理';

  @override
  String get budgetViewMonth => '月';

  @override
  String get budgetViewYear => '年';

  @override
  String budgetYearLabel(String year) {
    return '$year年';
  }

  @override
  String get budgetYearTotal => '年度总预算';

  @override
  String budgetMonthCount(String count) {
    return '$count 个月有预算';
  }

  @override
  String budgetMonthShort(String month) {
    return '$month月';
  }

  @override
  String get budgetEmpty => '暂未设置预算';

  @override
  String get budgetSetButton => '设置预算';

  @override
  String get budgetSettingTitle => '预算设置';

  @override
  String get budgetMonthlyTotal => '本月总预算';

  @override
  String budgetSpent(String amount) {
    return '已消费 $amount';
  }

  @override
  String budgetRemaining(String amount) {
    return '剩余 $amount';
  }

  @override
  String budgetOverSpent(String category, String amount) {
    return '$category预算已超支 $amount';
  }

  @override
  String get budgetUnknownCategory => '某分类';

  @override
  String get budgetUncategorized => '未分类';

  @override
  String budgetUsedPercent(String percent) {
    return '已使用 $percent%';
  }

  @override
  String budgetCategoryCount(String count) {
    return '已设置 $count 个分类预算';
  }

  @override
  String get budgetAddCategoryBudget => '添加分类预算';

  @override
  String get budgetAddCategoryBudgetDeveloping => '添加分类预算功能开发中';

  @override
  String get budgetEditBudgetDeveloping => '编辑预算功能开发中';

  @override
  String get budgetSetTotalTitle => '设置总预算';

  @override
  String get budgetEditTotalTitle => '编辑总预算';

  @override
  String get budgetEditCategoryTitle => '编辑分类预算';

  @override
  String get budgetInputAmount => '输入预算金额';

  @override
  String get budgetSelectCategory => '选择分类';

  @override
  String get budgetNoCategoryAvailable => '没有可用的分类';

  @override
  String get budgetCategoryAlreadyExists => '该分类预算已存在';

  @override
  String get budgetDeleteTitle => '删除预算';

  @override
  String get budgetDeleteConfirm => '确定要删除该分类的预算吗？';

  @override
  String get budgetNoBudgets => '暂未设置预算，点击右上角编辑按钮开始';

  @override
  String get bookTitle => '我的账本';

  @override
  String get bookCreate => '新建账本';

  @override
  String get bookDescription => '每个账本拥有独立的交易记录、预算和 AI 对话历史';

  @override
  String get bookDefault => '默认';

  @override
  String get bookCurrent => '当前';

  @override
  String get bookMonthlyExpense => '本月支出';

  @override
  String get bookMonthlyIncome => '本月收入';

  @override
  String get bookTransactionCount => '笔数';

  @override
  String get bookSetDefault => '设为默认';

  @override
  String get bookDelete => '删除';

  @override
  String bookSwitchedTo(String name) {
    return '已切换到 $name';
  }

  @override
  String get bookDeleteTitle => '删除账本';

  @override
  String bookDeleteConfirm(String name) {
    return '确定要删除「$name」吗？\n\n该账本下的所有交易记录、预算和对话历史将被清除，此操作不可撤销。';
  }

  @override
  String get bookDeleted => '账本已移至回收站';

  @override
  String get bookRecycleBin => '账本回收站';

  @override
  String get bookRecycleBinEmpty => '回收站为空';

  @override
  String get bookRestore => '恢复';

  @override
  String get bookRestored => '账本已恢复';

  @override
  String get txnRecycleBin => '账单回收站';

  @override
  String get txnRecycleBinEmpty => '回收站为空';

  @override
  String get txnRestore => '恢复';

  @override
  String get txnRestored => '交易已恢复';

  @override
  String get txnRecycleSelectAll => '全选';

  @override
  String get txnRecycleDeselectAll => '取消';

  @override
  String txnRecycleSelected(int count) {
    return '已选 $count 项';
  }

  @override
  String get txnRecyclePermanentDelete => '永久删除';

  @override
  String get txnRecyclePermanentDeleteConfirm => '确定永久删除所选交易？此操作不可恢复。';

  @override
  String txnRecycleBatchRestored(int count) {
    return '已恢复 $count 条交易';
  }

  @override
  String txnRecycleBatchDeleted(int count) {
    return '已永久删除 $count 条交易';
  }

  @override
  String get txnRecycleSortByDeleteTime => '删除时间';

  @override
  String get txnRecycleSortByAmount => '金额';

  @override
  String get txnRecycleSortByDate => '交易日期';

  @override
  String get txnRecycleGroupToday => '今天';

  @override
  String get txnRecycleGroupWeek => '本周';

  @override
  String get txnRecycleGroupEarlier => '更早';

  @override
  String get txnRecycleFilterAll => '全部';

  @override
  String get txnRecycleFilterExpense => '支出';

  @override
  String get txnRecycleFilterIncome => '收入';

  @override
  String get bookPermanentDelete => '永久删除';

  @override
  String bookPermanentDeleteConfirm(String name) {
    return '确定要永久删除「$name」吗？\n所有数据将被清除，此操作不可撤销。';
  }

  @override
  String bookCountUnit(String count) {
    return '$count 笔';
  }

  @override
  String get bookTypePersonal => '个人';

  @override
  String get bookTypeFamily => '家庭';

  @override
  String get bookTypeTravel => '旅行';

  @override
  String get bookTypeBusiness => '生意';

  @override
  String get bookTypeCouple => '情侣';

  @override
  String get bookTypeStudent => '学生';

  @override
  String get bookTypeWedding => '婚礼';

  @override
  String get bookTypeRental => '租房';

  @override
  String get bookTypeInvestment => '投资';

  @override
  String get bookTypePet => '宠物';

  @override
  String get bookTypeHealth => '医疗';

  @override
  String get bookTypeEvent => '活动';

  @override
  String get bookTypeOther => '其他';

  @override
  String get bookTypeCustom => '自定义';

  @override
  String get bookTypeCustomHint => '输入自定义类型';

  @override
  String get bookDetailTitle => '账本详情';

  @override
  String get bookDetailNotExist => '账本不存在';

  @override
  String get bookDetailExpenseCount => '交易笔数';

  @override
  String get bookDetailNormalSection => '常规操作';

  @override
  String get bookDetailSetDefault => '设为默认账本';

  @override
  String get bookDetailSwitchTo => '切换到此账本';

  @override
  String get bookDetailDangerSection => '危险操作';

  @override
  String get bookDetailClearData => '清空账本数据';

  @override
  String get bookDetailDefaultNotDeletable => '当前账本不可删除';

  @override
  String get bookDetailSetDefaultSuccess => '已设为默认账本';

  @override
  String get bookDetailClearTitle => '清空数据';

  @override
  String bookDetailClearConfirm(String name) {
    return '确定要清空「$name」的所有交易记录和对话历史吗？\n\n此操作不可撤销。';
  }

  @override
  String get bookDetailClear => '清空';

  @override
  String get bookDetailCleared => '数据已清空';

  @override
  String bookDetailDeleteConfirm(String name) {
    return '确定要删除「$name」吗？\n\n账本将移至回收站，数据不会丢失。';
  }

  @override
  String get bookDetailTypePersonal => '个人账本';

  @override
  String get bookDetailTypeFamily => '家庭账本';

  @override
  String get bookDetailTypeTravel => '旅行账本';

  @override
  String get bookDetailTypeBusiness => '生意账本';

  @override
  String get bookDetailTypeOther => '其他';

  @override
  String get reportTitle => '报表分析';

  @override
  String get reportPeriodWeek => '周';

  @override
  String get reportPeriodMonth => '月';

  @override
  String get reportPeriodYear => '年';

  @override
  String get reportTypeExpense => '支出';

  @override
  String get reportTypeIncome => '收入';

  @override
  String get reportTotalExpense => '总支出';

  @override
  String get reportTotalIncome => '总收入';

  @override
  String get reportCount => '笔数';

  @override
  String reportCountUnit(String count) {
    return '$count笔';
  }

  @override
  String get reportDailyAverage => '日均';

  @override
  String get reportCategoryCount => '分类';

  @override
  String reportCategoryCountUnit(String count) {
    return '$count个';
  }

  @override
  String get reportCategoryDistribution => '分类占比';

  @override
  String get reportCategoryRanking => '分类排行';

  @override
  String get reportNoData => '暂无数据';

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
  String get securityLockSettings => '密码锁设置';

  @override
  String get securityEnableLock => '启用密码锁';

  @override
  String get securityUnlockMethods => '解锁方式（可多选）';

  @override
  String get securityPinCode => '数字密码';

  @override
  String get securityPinCodeDesc => '四位数字密码解锁';

  @override
  String get securityBiometric => '指纹解锁';

  @override
  String get securityBiometricDesc => '使用设备指纹快速解锁';

  @override
  String get securityPatternLock => '图案解锁';

  @override
  String get securityPatternLockDesc => '绘制图案解锁';

  @override
  String get securityLockHint => '勾选多种解锁方式后，解锁界面会出现切换按钮。指纹解锁需要设备支持生物识别功能。';

  @override
  String get securityBiometricVerify => '验证指纹以启用指纹解锁';

  @override
  String securityBiometricFail(String error) {
    return '指纹验证失败: $error';
  }

  @override
  String get securitySetPinLock => '设置密码锁';

  @override
  String get securitySetPinTitle => '设置四位数字密码';

  @override
  String get securityConfirmPinTitle => '请再次输入新密码';

  @override
  String get securityEnterPin => '请输入密码解锁';

  @override
  String get securityPinWrong => '密码错误，请重试';

  @override
  String get securityPinMismatch => '两次输入不一致，请重新设置';

  @override
  String get securityPinSetSuccess => '密码设置成功';

  @override
  String get securitySetPatternLock => '设置图案锁';

  @override
  String get securityDrawPattern => '绘制解锁图案';

  @override
  String get securityConfirmPattern => '请再次绘制图案确认';

  @override
  String get securityDrawToUnlock => '请绘制图案解锁';

  @override
  String get securityPatternHint => '连接至少4个点';

  @override
  String get securityConfirmPatternHint => '请绘制与刚才相同的图案';

  @override
  String get securityRedraw => '重新绘制';

  @override
  String get securityPatternMinDots => '请至少连接4个点';

  @override
  String get securityPatternMismatch => '两次图案不一致，请重新绘制';

  @override
  String get securityPatternSetSuccess => '图案设置成功';

  @override
  String get securityPatternWrong => '图案错误，请重试';

  @override
  String get securityAuthRequired => '请验证身份以解锁应用';

  @override
  String get securitySelectUnlockMethod => '选择解锁方式';

  @override
  String get securitySwitchUnlockMethod => '切换解锁方式';

  @override
  String get securityVerifyFingerprint => '请验证指纹';

  @override
  String get securityTouchToUnlock => '触摸指纹传感器以解锁应用';

  @override
  String get securityRetryFingerprint => '重试指纹';

  @override
  String get checkinTitle => '打卡日历';

  @override
  String get checkinAlreadyCheckedIn => '今天已经打过卡了';

  @override
  String get checkinCheckInSuccess => '打卡成功！+10 AC币';

  @override
  String get checkinRewardDaily => '每日打卡奖励';

  @override
  String get checkinStreak365 => '连续打卡一年！+2000 AC币';

  @override
  String get checkinStreak180 => '连续打卡半年！+1000 AC币';

  @override
  String get checkinStreak30 => '连续打卡一个月！+300 AC币';

  @override
  String get checkinStreak7 => '连续打卡7天！+70 AC币';

  @override
  String get checkinReward365 => '连续打卡365天奖励';

  @override
  String get checkinReward180 => '连续打卡180天奖励';

  @override
  String get checkinReward30 => '连续打卡30天奖励';

  @override
  String get checkinReward7 => '连续打卡7天奖励';

  @override
  String get checkinMakeupSelectHint => '请先选择一个未打卡的日期';

  @override
  String get checkinMakeupFutureError => '只能补签过去的日期';

  @override
  String get checkinMakeupAlreadyChecked => '该日期已打卡';

  @override
  String get checkinMakeupInsufficient => 'AC币不足，补签需要100 AC币';

  @override
  String get checkinMakeupConfirmTitle => '补签确认';

  @override
  String checkinMakeupConfirmContent(String date, String balance) {
    return '确定要补签 $date 吗？\n将消耗 100 AC币（当前余额: $balance）';
  }

  @override
  String get checkinMakeupConfirm => '确认补签';

  @override
  String get checkinMakeupSuccess => '补签成功！';

  @override
  String checkinMakeupCost(String date) {
    return '补签 $date';
  }

  @override
  String get checkinConsecutiveDays => '连续打卡';

  @override
  String get checkinAcBalance => 'AC币余额';

  @override
  String get checkinTodayStatus => '今日状态';

  @override
  String get checkinMakeupButton => '补签 (-100 AC币)';

  @override
  String get checkinMakeupSelectButton => '选择日期后补签';

  @override
  String get checkinTodayCheckIn => '已打卡';

  @override
  String get checkinTodayCheckInButton => '今日打卡 +10';

  @override
  String get acCoinTitle => 'AC币记录';

  @override
  String get acCoinCurrentBalance => '当前余额';

  @override
  String get acCoinEmpty => '暂无AC币记录';

  @override
  String get catExpenseFood => '餐饮美食';

  @override
  String get catExpenseTransport => '交通出行';

  @override
  String get catExpenseHousing => '居住';

  @override
  String get catExpenseClothing => '服饰美容';

  @override
  String get catExpenseDaily => '日用百货';

  @override
  String get catExpenseTech => '数码科技';

  @override
  String get catExpenseMedical => '医疗健康';

  @override
  String get catExpenseEducation => '教育学习';

  @override
  String get catExpenseEntertainment => '休闲娱乐';

  @override
  String get catExpenseSocial => '社交人情';

  @override
  String get catExpenseChildren => '子女养育';

  @override
  String get catExpenseElderly => '赡养长辈';

  @override
  String get catExpensePet => '宠物';

  @override
  String get catExpenseWork => '工作办公';

  @override
  String get catExpenseFinance => '金融保险';

  @override
  String get catExpenseOther => '其他支出';

  @override
  String get catIncomeSalary => '工资薪酬';

  @override
  String get catIncomeInvestment => '投资理财';

  @override
  String get catIncomeSideJob => '副业兼职';

  @override
  String get catIncomeGift => '红包馈赠';

  @override
  String get catIncomeRefund => '报销退款';

  @override
  String get catIncomeAsset => '租金资产';

  @override
  String get catIncomeTransferIn => '转账收入';

  @override
  String get catIncomeOther => '其他收入';

  @override
  String get catOtherTransfer => '转账';

  @override
  String get catOtherRepayment => '还款';

  @override
  String get catOtherSocial => '人情往来';

  @override
  String get catSubFoodBreakfast => '早餐';

  @override
  String get catSubFoodLunch => '午餐';

  @override
  String get catSubFoodDinner => '晚餐';

  @override
  String get catSubFoodLateSnack => '夜宵';

  @override
  String get catSubFoodDelivery => '外卖';

  @override
  String get catSubFoodMilkTea => '奶茶';

  @override
  String get catSubFoodCoffee => '咖啡';

  @override
  String get catSubFoodDrinks => '饮料';

  @override
  String get catSubFoodDessert => '甜点';

  @override
  String get catSubFoodSnacks => '零食小吃';

  @override
  String get catSubFoodFruit => '水果';

  @override
  String get catSubFoodGroceries => '买菜';

  @override
  String get catSubFoodDiningOut => '聚餐请客';

  @override
  String get catSubTransportMetro => '地铁';

  @override
  String get catSubTransportBus => '公交';

  @override
  String get catSubTransportTaxi => '打车';

  @override
  String get catSubTransportRideshare => '网约车';

  @override
  String get catSubTransportBikeShare => '共享单车';

  @override
  String get catSubTransportHighSpeedRail => '高铁';

  @override
  String get catSubTransportTrain => '火车';

  @override
  String get catSubTransportFlight => '飞机';

  @override
  String get catSubTransportFuel => '加油';

  @override
  String get catSubTransportCharging => '充电';

  @override
  String get catSubTransportParking => '停车费';

  @override
  String get catSubTransportToll => '过路费';

  @override
  String get catSubTransportMaintenance => '车辆保养';

  @override
  String get catSubTransportRepair => '车辆维修';

  @override
  String get catSubTransportInsurance => '车险';

  @override
  String get catSubHousingRent => '房租';

  @override
  String get catSubHousingMortgage => '房贷';

  @override
  String get catSubHousingWater => '水费';

  @override
  String get catSubHousingElectricity => '电费';

  @override
  String get catSubHousingGas => '燃气费';

  @override
  String get catSubHousingPropertyFee => '物业费';

  @override
  String get catSubHousingInternet => '宽带网费';

  @override
  String get catSubHousingPhone => '手机话费';

  @override
  String get catSubHousingCleaning => '家政保洁';

  @override
  String get catSubHousingRepair => '房屋维修';

  @override
  String get catSubClothingApparel => '衣物';

  @override
  String get catSubClothingShoes => '鞋子';

  @override
  String get catSubClothingHats => '帽子';

  @override
  String get catSubClothingBags => '包包';

  @override
  String get catSubClothingCosmetics => '化妆品';

  @override
  String get catSubClothingSkincare => '护肤品';

  @override
  String get catSubClothingHaircut => '理发';

  @override
  String get catSubClothingManicure => '美甲';

  @override
  String get catSubClothingJewelry => '饰品';

  @override
  String get catSubClothingAccessories => '配件';

  @override
  String get catSubDailyNecessities => '日用品';

  @override
  String get catSubDailyCleaning => '清洁用品';

  @override
  String get catSubDailyKitchen => '厨房用品';

  @override
  String get catSubDailyDecor => '家居装饰';

  @override
  String get catSubDailyStorage => '收纳用品';

  @override
  String get catSubDailyBedding => '床上用品';

  @override
  String get catSubDailyTissue => '纸品';

  @override
  String get catSubTechPhone => '手机';

  @override
  String get catSubTechComputer => '电脑';

  @override
  String get catSubTechAccessories => '配件';

  @override
  String get catSubTechConsumables => '耗材';

  @override
  String get catSubTechStorage => '存储设备';

  @override
  String get catSubMedicalRegistration => '门诊挂号';

  @override
  String get catSubMedicalMedicine => '药品';

  @override
  String get catSubMedicalHospitalization => '住院';

  @override
  String get catSubMedicalCheckup => '体检';

  @override
  String get catSubMedicalDental => '口腔';

  @override
  String get catSubMedicalEyeCare => '眼科';

  @override
  String get catSubMedicalVaccine => '疫苗';

  @override
  String get catSubMedicalWellness => '保健养生';

  @override
  String get catSubMedicalFitness => '健身运动';

  @override
  String get catSubEducationBooks => '书籍';

  @override
  String get catSubEducationTuition => '学费';

  @override
  String get catSubEducationTraining => '培训费';

  @override
  String get catSubEducationExam => '考试费';

  @override
  String get catSubEducationOnlineCourse => '在线课程';

  @override
  String get catSubEducationStationery => '文具用品';

  @override
  String get catSubEntertainmentMovies => '电影';

  @override
  String get catSubEntertainmentKtv => 'KTV';

  @override
  String get catSubEntertainmentGaming => '游戏充值';

  @override
  String get catSubEntertainmentSubscription => '会员订阅';

  @override
  String get catSubEntertainmentTickets => '景点门票';

  @override
  String get catSubEntertainmentHotel => '酒店住宿';

  @override
  String get catSubEntertainmentTravel => '旅游';

  @override
  String get catSubEntertainmentShow => '演出';

  @override
  String get catSubEntertainmentStreaming => '流媒体';

  @override
  String get catSubSocialGift => '礼物';

  @override
  String get catSubSocialRedPacket => '红包';

  @override
  String get catSubSocialWeddingGift => '份子钱';

  @override
  String get catSubSocialTreat => '请客';

  @override
  String get catSubSocialBirthday => '生日聚会';

  @override
  String get catSubSocialVisit => '探望慰问';

  @override
  String get catSubSocialRespect => '孝敬长辈';

  @override
  String get catSubSocialCharity => '慈善捐助';

  @override
  String get catSubChildrenFormula => '奶粉辅食';

  @override
  String get catSubChildrenDiapers => '尿布用品';

  @override
  String get catSubChildrenTuition => '学费';

  @override
  String get catSubChildrenHobby => '兴趣班';

  @override
  String get catSubChildrenTutoring => '辅导班';

  @override
  String get catSubChildrenDaycare => '午托晚托';

  @override
  String get catSubChildrenToys => '玩具';

  @override
  String get catSubElderlySupport => '赡养费';

  @override
  String get catSubElderlyNutrition => '营养品';

  @override
  String get catSubElderlyMedical => '医疗费';

  @override
  String get catSubElderlyAllowance => '孝敬金';

  @override
  String get catSubPetFood => '宠物食品';

  @override
  String get catSubPetMedical => '宠物医疗';

  @override
  String get catSubPetSupplies => '宠物用品';

  @override
  String get catSubPetGrooming => '宠物美容';

  @override
  String get catSubWorkOffice => '办公用品';

  @override
  String get catSubWorkPrinting => '打印复印';

  @override
  String get catSubWorkShipping => '快递物流';

  @override
  String get catSubWorkTravel => '差旅费';

  @override
  String get catSubFinanceInsurance => '保险费用';

  @override
  String get catSubFinanceLoss => '理财亏损';

  @override
  String get catSubFinanceFee => '手续费';

  @override
  String get catSubFinanceLoanInterest => '贷款利息';

  @override
  String get catSubFinanceTax => '税费';

  @override
  String get catSubFinanceFine => '罚款';

  @override
  String get catSubOtherExpenseGeneral => '其他消费';

  @override
  String get catSubOtherExpenseUnexpected => '意外支出';

  @override
  String get catSubSalaryBase => '基本工资';

  @override
  String get catSubSalaryBonus => '绩效奖金';

  @override
  String get catSubSalaryOvertime => '加班费';

  @override
  String get catSubSalaryYearEnd => '年终奖';

  @override
  String get catSubSalaryBackPay => '调薪补发';

  @override
  String get catSubSalaryAllowance => '津贴补贴';

  @override
  String get catSubInvestmentFund => '基金收益';

  @override
  String get catSubInvestmentStock => '股票收益';

  @override
  String get catSubInvestmentInterest => '利息收入';

  @override
  String get catSubInvestmentWealthMgmt => '理财产品';

  @override
  String get catSubInvestmentCrypto => '数字货币';

  @override
  String get catSubInvestmentDividend => '分红';

  @override
  String get catSubSideJobPartTime => '兼职收入';

  @override
  String get catSubSideJobFreelance => '自由职业';

  @override
  String get catSubSideJobRoyalty => '稿费版权';

  @override
  String get catSubSideJobCommission => '佣金提成';

  @override
  String get catSubSideJobSales => '销售收入';

  @override
  String get catSubGiftRedPacket => '红包收入';

  @override
  String get catSubGiftPresent => '礼金馈赠';

  @override
  String get catSubGiftFestival => '节日红包';

  @override
  String get catSubRefundReimbursement => '报销到账';

  @override
  String get catSubRefundReturn => '退款收入';

  @override
  String get catSubRefundMedical => '医保报销';

  @override
  String get catSubRefundInsurance => '保险理赔';

  @override
  String get catSubAssetRent => '房租收入';

  @override
  String get catSubAssetIdleSale => '闲置出售';

  @override
  String get catSubAssetSecondhand => '二手交易';

  @override
  String get catSubAssetProfit => '资产收益';

  @override
  String get catSubTransferInBank => '银行转入';

  @override
  String get catSubTransferInWallet => '钱包转入';

  @override
  String get catSubTransferInDebt => '债务回收';

  @override
  String get catSubIncomeOtherWindfall => '意外所得';

  @override
  String get catSubIncomeOtherSubsidy => '政府补贴';

  @override
  String get catSubIncomeOtherUncategorized => '未分类';

  @override
  String get catSubTransferBankIn => '银行卡转入';

  @override
  String get catSubTransferBankOut => '银行卡转出';

  @override
  String get catSubTransferWallet => '钱包互转';

  @override
  String get catSubTransferCrossIn => '跨平台转入';

  @override
  String get catSubTransferCrossOut => '跨平台转出';

  @override
  String get catSubRepaymentCreditCard => '信用卡还款';

  @override
  String get catSubRepaymentLoan => '贷款还款';

  @override
  String get catSubRepaymentBorrowed => '借款归还';

  @override
  String get catSubRepaymentLent => '借款借出';

  @override
  String get catSubOtherSocialGift => '随礼份子钱';

  @override
  String get catSubOtherSocialWedding => '婚丧嫁娶';

  @override
  String get catSubOtherSocialBirthday => '生日聚会';

  @override
  String get catSubOtherSocialFestival => '节日红包往来';

  @override
  String get weekMon => '一';

  @override
  String get weekTue => '二';

  @override
  String get weekWed => '三';

  @override
  String get weekThu => '四';

  @override
  String get weekFri => '五';

  @override
  String get weekSat => '六';

  @override
  String get weekSun => '日';

  @override
  String get weekMonFull => '周一';

  @override
  String get weekTueFull => '周二';

  @override
  String get weekWedFull => '周三';

  @override
  String get weekThuFull => '周四';

  @override
  String get weekFriFull => '周五';

  @override
  String get weekSatFull => '周六';

  @override
  String get weekSunFull => '周日';

  @override
  String get commonSelectDateTime => '选择日期时间';

  @override
  String get commonBack => '返回';

  @override
  String get commonDone => '完成';

  @override
  String get commonAdd => '添加';

  @override
  String commonEnterHint(String field) {
    return '请输入$field';
  }

  @override
  String get txnCategorySearch => '搜索分类...';

  @override
  String get txnCategoryEmpty => '暂无分类';

  @override
  String get settingsSelectLanguage => '选择语言';

  @override
  String get settingsSelectCurrency => '选择货币';

  @override
  String get profileDefaultNickname => '用户';

  @override
  String get catManageTitle => '分类管理';

  @override
  String catManageSubTitle(String name) {
    return '$name - 子分类';
  }

  @override
  String get catManageAddSub => '添加子分类';

  @override
  String get catManageNameExists => '该分类名已存在';

  @override
  String get catManageSubNameExists => '该子分类名已存在';

  @override
  String get catManageDeleteTitle => '确认删除';

  @override
  String catManageDeleteWithChildren(String name) {
    return '确定要删除分类\"$name\"及其所有子分类吗？';
  }

  @override
  String catManageDeleteConfirm(String name) {
    return '确定要删除分类\"$name\"吗？';
  }

  @override
  String get catManageDeleteBlocked => '该分类有关联数据，无法删除';

  @override
  String get catManageCustomBadge => '自';

  @override
  String get catManageCustom => '自定义';

  @override
  String catManageAddTitle(String type) {
    return '添加$type分类';
  }

  @override
  String get catManageNameLabel => '分类名称';

  @override
  String get catManageNameHint => '请输入分类名称';

  @override
  String get catManageSelectIcon => '选择图标';

  @override
  String get catManageSelectColor => '选择颜色';

  @override
  String catManageAddSubTitle(String name) {
    return '添加子分类 - $name';
  }

  @override
  String get catManageSubNameLabel => '子分类名称';

  @override
  String get catManageSubNameHint => '请输入子分类名称';

  @override
  String get catManageEditTitle => '编辑分类';

  @override
  String get bookNameLabel => '账本名称';

  @override
  String get bookNameHint => '例如：日常记账';

  @override
  String get bookTypeLabel => '账本类型';

  @override
  String get bookDescLabel => '备注（可选）';

  @override
  String get bookDescHint => '简单描述账本用途';

  @override
  String get bookCreateButton => '创建';

  @override
  String get bookDescPersonal => '日常个人记账';

  @override
  String get bookDescFamily => '家庭共同开支';

  @override
  String get bookDescTravel => '旅行花费记录';

  @override
  String get bookDescBusiness => '副业/小生意收支';

  @override
  String get bookDescOther => '自定义用途';

  @override
  String get aiPresetDeepseekNote => '高性价比国产大模型';

  @override
  String get aiPresetOpenaiNote => '需海外网络访问';

  @override
  String get aiPresetQwenName => '通义千问 (阿里)';

  @override
  String get aiPresetQwenNote => '使用兼容模式地址';

  @override
  String get aiPresetDoubaoName => '豆包 (字节)';

  @override
  String get aiPresetDoubaoNote => '需在火山方舟创建推理接入点，模型名使用接入点 ID';

  @override
  String get aiPresetZhipuName => '智谱AI';

  @override
  String get aiPresetZhipuNote => 'glm-4-flash 有免费额度';

  @override
  String get aiPresetKimiName => '月之暗面 (Kimi)';

  @override
  String get aiPresetKimiNote => '擅长长文本理解';

  @override
  String get aiPresetClaudeNote => '使用 Anthropic Messages API';

  @override
  String get aiPresetMimoName => '小米 MiMo';

  @override
  String get aiPresetMimoNote => '支持 OpenAI/Anthropic 兼容协议，中国/新加坡/欧洲多集群';

  @override
  String get aiPresetOllamaName => 'Ollama (本地)';

  @override
  String get aiPresetOllamaNote => '需本地运行 Ollama 服务，模型名取决于本地安装';

  @override
  String get llmCapTextLabel => '文本模型';

  @override
  String get llmCapTextDesc => '用于记账解析、AI 对话';

  @override
  String get llmCapVisionLabel => '视觉模型';

  @override
  String get llmCapVisionDesc => '用于拍照识别小票/发票';

  @override
  String get llmCapAudioLabel => '语音模型';

  @override
  String get llmCapAudioDesc => '用于语音转文字';

  @override
  String get currencyCny => '人民币';

  @override
  String get currencyUsd => '美元';

  @override
  String get currencyKrw => '韩元';

  @override
  String get currencyJpy => '日元';

  @override
  String get currencyEur => '欧元';

  @override
  String get currencyGbp => '英镑';

  @override
  String get currencyUnitYi => '亿';

  @override
  String get currencyUnitWan => '万';

  @override
  String get inputSourceText => '文本';

  @override
  String get inputSourceVoice => '语音';

  @override
  String get inputSourceImage => '图片';

  @override
  String reportTrendMonth(String period) {
    return '$period月';
  }

  @override
  String reportTrendDay(String period) {
    return '$period日';
  }

  @override
  String get llmSettingsTitle => 'AI 服务配置';

  @override
  String get llmExportConfig => '导出配置';

  @override
  String get llmImportConfig => '导入配置';

  @override
  String get llmProviderManagement => '服务商管理';

  @override
  String get llmAddProvider => '添加服务商';

  @override
  String get llmEditProvider => '编辑服务商';

  @override
  String get llmDeleteProvider => '删除服务商';

  @override
  String llmDeleteProviderConfirm(String name) {
    return '确定删除「$name」？';
  }

  @override
  String get llmNotConfigured => '未配置';

  @override
  String get llmConfigured => '已配置';

  @override
  String get llmNoProviders => '尚未添加任何服务商';

  @override
  String get llmUnnamedProvider => '未命名服务商';

  @override
  String get llmInUse => '使用中';

  @override
  String get llmIncomplete => '未完成';

  @override
  String get llmTest => '测试';

  @override
  String get llmConfigIncomplete => '请先完善配置（需要 API Key、地址和至少一个模型）';

  @override
  String get llmConnectSuccess => '✅ 连接成功';

  @override
  String get llmConnectFail => '❌ 连接失败，请检查地址、Key 和模型名称';

  @override
  String get llmConfigCopied => '配置已复制到剪贴板';

  @override
  String get llmClipboardEmpty => '剪贴板为空';

  @override
  String llmImported(String count) {
    return '已导入 $count 个服务商配置';
  }

  @override
  String get llmImportFailed => '导入失败，请检查 JSON 格式';

  @override
  String get llmProviderNotConfigured => '该服务商未配置 API Key 或请求地址，请先编辑';

  @override
  String llmModelsFetched(String count, String label) {
    return '获取到 $count 个$label';
  }

  @override
  String llmModelsFetchedAll(String count) {
    return '获取到 $count 个模型（未筛选到专用模型，显示全部）';
  }

  @override
  String get llmFetchFailed => '获取失败，已加载预设模型列表';

  @override
  String llmFetchError(String error) {
    return '获取模型失败: $error';
  }

  @override
  String llmModelSet(String capability, String provider, String model) {
    return '已设置 $capability：$provider · $model';
  }

  @override
  String llmInputModelName(String capability) {
    return '输入$capability名称';
  }

  @override
  String get llmConnectFailed => '连接失败';

  @override
  String get llmAutoDetectInterval => '自动检测间隔';

  @override
  String get llmIntervalOff => '关闭';

  @override
  String get llmInterval10s => '10秒';

  @override
  String get llmInterval30s => '30秒';

  @override
  String get llmInterval1m => '1分钟';

  @override
  String get llmInterval2m => '2分钟';

  @override
  String get llmInterval5m => '5分钟';

  @override
  String get llmInterval10m => '10分钟';

  @override
  String get llmInterval30m => '30分钟';

  @override
  String get llmInterval1h => '1小时';

  @override
  String llmConfigureCap(String label) {
    return '配置$label';
  }

  @override
  String get llmCurrentUse => '当前使用';

  @override
  String get llmFetch => '获取';

  @override
  String get llmTesting => '检测中...';

  @override
  String get llmTestConnection => '检测连接';

  @override
  String get llmFailed => '失败';

  @override
  String llmSelectCap(String label) {
    return '选择$label';
  }

  @override
  String get llmManualInput => '✏️ 手动输入...';

  @override
  String get llmFillApiKey => '请填写 API Key 和请求地址';

  @override
  String get llmCustom => '自定义';

  @override
  String get llmProviderName => '服务商名称';

  @override
  String get llmApiUrl => '请求地址';

  @override
  String get llmApiUrlHintAnthropic =>
      'Anthropic API 地址，如 https://api.anthropic.com';

  @override
  String get llmApiUrlHelper => '填入 API 的 base_url，不需要手动拼接 /chat/completions';

  @override
  String get llmSaveHint => '保存后，请返回上一页通过能力卡片配置模型';

  @override
  String get llmInputApiKey => '输入 API Key';

  @override
  String get llmApiUrlExample => '如：https://api.example.com';

  @override
  String get llmAdvancedSettings => '高级设置';

  @override
  String get llmTemperature => '回答风格';

  @override
  String get llmTemperatureHint => '越低越精确稳定，越高越发散多样';

  @override
  String get llmTemperaturePrecise => '精确';

  @override
  String get llmTemperatureCreative => '创意';

  @override
  String get llmMaxToken => '最大 Token';

  @override
  String get llmTimeout => '超时（秒）';

  @override
  String get llmErrorNoModelForCapability => '未配置对应能力的模型';

  @override
  String get llmErrorNoProviderConfigured => '请先在设置中添加并配置 AI 服务商';

  @override
  String get llmErrorNoProviderOrInput => '请先在设置中添加 AI 服务商，或输入更明确的描述';

  @override
  String get llmErrorCannotParseResponse => '无法解析 AI 响应';

  @override
  String get llmErrorInvalidResponseFormat => 'AI 响应格式不正确';

  @override
  String llmErrorParseFailed(String error) {
    return '解析 AI 响应失败: $error';
  }

  @override
  String get llmErrorTimeout => '请求超时，请检查网络连接';

  @override
  String get llmErrorInvalidApiKey => 'API Key 无效，请检查设置';

  @override
  String get llmErrorRateLimit => '请求过于频繁，请稍后再试';

  @override
  String get llmErrorForbidden => '访问被拒绝，请检查 API Key 权限';

  @override
  String llmErrorRequestFailed(String code) {
    return '请求失败 ($code)';
  }

  @override
  String get llmErrorNetworkFailed => '网络连接失败，请检查网络';

  @override
  String llmErrorRequestFailedWithMessage(String message) {
    return '请求失败: $message';
  }

  @override
  String get visionErrorNoModelConfigured => '未配置视觉识别模型，请在 AI 设置中配置';

  @override
  String get visionErrorImageNotFound => '图片文件不存在';

  @override
  String visionErrorRecognitionFailed(String message) {
    return '图片识别失败: $message';
  }

  @override
  String get voiceErrorNoModelConfigured => '未配置语音识别模型，请在 AI 设置中配置';

  @override
  String get voiceErrorNoEngineAvailable =>
      '无可用的语音识别引擎。设备不支持原生语音识别，请在 AI 设置中配置 Whisper 云端语音模型';

  @override
  String get voiceErrorAudioNotFound => '音频文件不存在';

  @override
  String get voiceErrorInvalidResponseFormat => '语音识别返回格式异常';

  @override
  String voiceErrorTranscriptionFailed(String message) {
    return '语音识别失败: $message';
  }

  @override
  String get voiceErrorEndpointNotFound =>
      'Whisper API 端点未找到，请检查供应商 Base URL 配置';

  @override
  String get pipelineErrorEmptyVoiceResult => '语音识别结果为空，请重新录制';

  @override
  String get pipelineErrorEmptyImageResult => '图片识别结果为空，请选择更清晰的图片';

  @override
  String get acCoinInitialGiftDesc => '新用户注册赠送';

  @override
  String get loadFailedPullToRefresh => '加载失败，请下拉刷新';

  @override
  String get llmSettingsGetModelListError => '无法获取模型列表';

  @override
  String get searchPageTitle => '搜索账单';

  @override
  String get searchHint => '输入关键词或自然语言，如\"上月打车花了多少\"';

  @override
  String get searchAiParsing => 'AI 正在理解你的查询...';

  @override
  String get searchNoResults => '未找到匹配的账单';

  @override
  String get searchNoResultsHint => '试试其他关键词或换个说法';

  @override
  String searchResultCount(String count) {
    return '找到 $count 条结果';
  }

  @override
  String get searchAiSummaryTitle => '📊 AI 分析结果';

  @override
  String get searchAiSummaryLoading => 'AI 正在分析...';

  @override
  String get searchTotalExpense => '总支出';

  @override
  String get searchTotalIncome => '总收入';

  @override
  String searchTransactionCount(String count) {
    return '共 $count 笔';
  }

  @override
  String get searchAverage => '日均';

  @override
  String get searchMaxSingle => '最大单笔';

  @override
  String get searchLlmNotConfigured => '未配置 AI 服务，仅支持关键词搜索';

  @override
  String get searchLlmError => 'AI 查询解析失败，已切换为关键词搜索';

  @override
  String get searchQuickSuggestions => '搜索建议';

  @override
  String get searchSuggestionLastMonthExpense => '上月消费汇总';

  @override
  String get searchSuggestionThisMonthFood => '本月餐饮消费';

  @override
  String get searchSuggestionRecentLarge => '最近大额消费';

  @override
  String get searchSuggestionRecentWeek => '最近一周账单';

  @override
  String get searchFilterExpense => '支出';

  @override
  String get searchFilterIncome => '收入';

  @override
  String get searchFilterAll => '全部';

  @override
  String get searchFilterDateRange => '日期范围';

  @override
  String get searchFilterAmountRange => '金额范围';

  @override
  String get searchFilterCategory => '分类';

  @override
  String get searchFilterPayment => '支付方式';

  @override
  String get searchFilterClear => '清除筛选';

  @override
  String get searchModeKeyword => '关键词';

  @override
  String get searchModeAi => 'AI 搜索';

  @override
  String get searchKeywordPlaceholder => '搜索描述、备注、金额...';

  @override
  String get searchParsingFailed => 'AI 解析失败';

  @override
  String get llmSupplierManagement => '服务商管理';

  @override
  String get llmModelManagement => '模型管理';

  @override
  String get llmSelectProvider => '选择服务商';

  @override
  String get llmSelectModel => '选择模型';

  @override
  String get llmProviderIncomplete => '未配置完整';

  @override
  String get llmNone => '不使用';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get agentTransactionParser => '记账解析';

  @override
  String get agentTransactionParserDesc => '从自然语言中提取交易金额、分类、时间';

  @override
  String get agentReceiptOcr => '小票识别';

  @override
  String get agentReceiptOcrDesc => '识别小票/发票图片中的消费信息';

  @override
  String get agentVoiceTranscribe => '语音转写';

  @override
  String get agentVoiceTranscribeDesc => '将语音录音转为文字';

  @override
  String get agentFinanceSearch => '财务搜索';

  @override
  String get agentFinanceSearchDesc => '自然语言查询交易、预算、分类';

  @override
  String get agentEditTitle => '功能配置';

  @override
  String get agentEditSave => '保存';

  @override
  String get agentEditSaved => '配置已保存';

  @override
  String get agentEditSelectModel => '请先选择模型';

  @override
  String get agentEditPrimaryModel => '主模型';

  @override
  String get agentEditFallbackModel => '备选模型';

  @override
  String get agentEditEnableFallback => '启用自动降级';

  @override
  String get agentEditTestCases => '测试用例';

  @override
  String get agentEditTestCase => '用例';

  @override
  String get agentEditProvider => '供应商';

  @override
  String get agentEditModel => '模型';

  @override
  String get agentEditManualInput => '手动输入模型名';

  @override
  String get agentEditModelNameHint => '输入模型名称';

  @override
  String get aiSettingsTitle => 'AI 设置';

  @override
  String get aiSettingsAgents => '为功能配置模型';

  @override
  String get aiSettingsSuppliers => '供应商管理';

  @override
  String get aiSettingsUsage => '本月用量';

  @override
  String get aiSettingsUsageCalls => '调用';

  @override
  String get aiSettingsUsageFallback => '降级';

  @override
  String get aiSettingsNoAgents => '未配置任何功能';

  @override
  String get aiSettingsAddSupplier => '添加供应商';

  @override
  String get aiSettingsTestConnection => '测试连接';

  @override
  String get aiSettingsConnected => '已连接';

  @override
  String get aiSettingsDisconnected => '未连接';

  @override
  String get aiSettingsLatency => '延迟';

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

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => 'WoAccount';

  @override
  String get navTransactions => '帳單';

  @override
  String get navRecord => '記帳';

  @override
  String get navProfile => '我的';

  @override
  String get commonCancel => '取消';

  @override
  String get commonConfirm => '確定';

  @override
  String get commonEditCategory => '修改分類';

  @override
  String get commonEditAmount => '修改金額';

  @override
  String get commonEditDescription => '修改描述';

  @override
  String get commonSave => '儲存';

  @override
  String get commonDelete => '刪除';

  @override
  String get commonEdit => '編輯';

  @override
  String get chatPageTitle => 'AI 記帳';

  @override
  String get chatPageVoicePlaceholder => '🎤 語音訊息';

  @override
  String get chatPageImagePlaceholder => '📷 圖片訊息';

  @override
  String chatPageVoiceTranscription(String text) {
    return '🎤 語音轉文字：$text';
  }

  @override
  String chatPageImageRecognition(String text) {
    return '📷 圖片辨識結果：$text';
  }

  @override
  String get chatPageNoSubcategory => '暫無';

  @override
  String get chatPageConfigAiError => '請先在設定中新增並配置 AI 服務商';

  @override
  String chatPageParseError(String error) {
    return '❌ 解析失敗：$error\n\n請嘗試更明確的描述，如\"午餐拉麵25\"';
  }

  @override
  String get chatPageNoCategoryError => '沒有可用分類，請先在分類管理中新增分類';

  @override
  String get chatPageSaveSuccessTitle => '記帳成功';

  @override
  String chatPageSaveSuccess(
    String amount,
    String category,
    String description,
    String date,
  ) {
    return '✅ 已儲存\n$amount · $category\n$description · $date';
  }

  @override
  String chatPageSaveFailed(String error) {
    return '儲存失敗: $error';
  }

  @override
  String get chatPageEmptyTitle => '開始記帳吧';

  @override
  String get chatPageEmptyHint => '試試輸入 \"午餐拉麵25\" 或 \"吃飯24，洗衣服34\"';

  @override
  String get chatPageEmptyInstruction => '長按記帳按鈕可語音輸入 🎤 · 點擊右側按鈕拍照辨識 📷';

  @override
  String get chatPageAiParsing => 'AI 正在解析...';

  @override
  String get chatBubbleImageFailed => '圖片載入失敗';

  @override
  String get chatInputMicPermission => '請授權麥克風權限';

  @override
  String get chatInputRecordShort => '錄音時間太短';

  @override
  String chatInputImageFailed(String error) {
    return '取得圖片失敗: $error';
  }

  @override
  String get chatInputCamera => '拍照';

  @override
  String get chatInputGallery => '從相簿選擇';

  @override
  String get chatInputVoiceHint => '鬆手傳送，左滑取消 ↖，右滑轉文字 ↗';

  @override
  String get voiceOverlaySwipeHint => '↑ 上滑取消或轉文字';

  @override
  String get voiceOverlayCancelLabel => '鬆手 取消';

  @override
  String get voiceOverlayTranscribeLabel => '鬆手 僅轉文字';

  @override
  String get chatInputTextHint => '輸入文字開始記帳';

  @override
  String get chatConfirmTitle => 'AI 解析結果';

  @override
  String get chatConfirmCategory => '分類';

  @override
  String get chatConfirmDescription => '描述';

  @override
  String get chatConfirmDate => '日期';

  @override
  String get chatConfirmAmount => '金額';

  @override
  String get chatConfirmSave => '確認儲存';

  @override
  String get chatConfirmInputCategory => '輸入分類名稱';

  @override
  String get chatConfirmInputDescription => '輸入描述';

  @override
  String get chatConfirmInputAmount => '輸入金額';

  @override
  String get chatDeleteTitle => '清空對話';

  @override
  String get chatDeleteMessage => '確定要清空所有對話記錄嗎？此操作不可撤銷。';

  @override
  String get chatDeleteSuccess => '對話已清空';

  @override
  String chatMultiSelectCount(String count) {
    return '已選 $count 條';
  }

  @override
  String get chatDeleteSelected => '刪除選取';

  @override
  String chatDeleteSelectedConfirm(String count) {
    return '確定要刪除選取的 $count 條訊息嗎？';
  }

  @override
  String get chatActionCopy => '複製';

  @override
  String get chatActionDelete => '刪除訊息';

  @override
  String get chatDeleteMsgConfirm => '確定要刪除這條訊息嗎？';

  @override
  String get chatCopyMessage => '已複製到剪貼簿';

  @override
  String get homePageAiNotConfigured => '尚未配置 AI 服務，將使用基礎規則解析';

  @override
  String get homePageGoSettings => '前往設定';

  @override
  String get homePageNoContent => '未辨識到內容';

  @override
  String homePageRecordFailed(String error) {
    return '記帳失敗：$error';
  }

  @override
  String homePageRecordSuccess(String amount) {
    return '記帳成功：$amount';
  }

  @override
  String homePageSaveFailed(String error) {
    return '儲存失敗：$error';
  }

  @override
  String get homePageBudgetAlert => '今日消費已超過日均預算的80%';

  @override
  String get homeInputManual => '手動記帳';

  @override
  String get homeInputHint => '午餐吃了碗拉麵25元';

  @override
  String get homeInputSubmit => '發送';

  @override
  String get homeInputCamera => '拍照辨識';

  @override
  String get homeConfirmTitle => '🤖 AI解析結果';

  @override
  String homeConfirmOriginalInput(String input) {
    return '原始輸入: $input';
  }

  @override
  String get homeConfirmAmount => '💰 金額';

  @override
  String get homeConfirmDate => '📅 日期';

  @override
  String get homeConfirmCategory => '🍜 分類';

  @override
  String get homeConfirmParseTime => '⏱️ 解析耗時';

  @override
  String get homeConfirmDescription => '📝 描述';

  @override
  String get homeConfirmConfidence => '信心度';

  @override
  String get homeConfirmEditDate => '修改日期';

  @override
  String get homeConfirmRecord => '確認記帳';

  @override
  String get homeEntryTitle => 'AI 助手';

  @override
  String get homeEntrySubtitle => '智慧記帳 · 消費分析 · 問答查詢';

  @override
  String get homeBudgetDetails => '詳情';

  @override
  String get txnSearchHint => '搜尋帳單';

  @override
  String get txnBudget => '預算';

  @override
  String get txnToday => '今天';

  @override
  String get txnPeriodDay => '本日';

  @override
  String get txnPeriodWeek => '本週';

  @override
  String get txnPeriodMonth => '本月';

  @override
  String txnExpense(String period) {
    return '$period支出';
  }

  @override
  String txnIncome(String period) {
    return '$period收入';
  }

  @override
  String get txnBalance => '結餘';

  @override
  String get txnSortByTime => '按時間';

  @override
  String get txnSortByAmount => '按金額';

  @override
  String get txnEmpty => '暫無帳單記錄';

  @override
  String get txnDayDetailEmpty => '當日無帳單記錄';

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
    return '收入 $amount';
  }

  @override
  String get txnGroupUncategorized => '未分類';

  @override
  String get txnGroupNoSubcategory => '暫無';

  @override
  String get viewDay => '日';

  @override
  String get viewWeek => '週';

  @override
  String get viewMonth => '月';

  @override
  String get txnDetailTitle => '帳單詳情';

  @override
  String get txnDetailSaved => '已儲存';

  @override
  String get txnDetailDeleteConfirmTitle => '確認刪除';

  @override
  String get txnDetailDeleteConfirmContent => '刪除後將無法恢復，確定要刪除這條帳單嗎？';

  @override
  String get txnDetailNotFound => '帳單不存在';

  @override
  String get txnDetailUncategorized => '未分類';

  @override
  String get txnDetailCategory => '分類';

  @override
  String get txnDetailAmount => '金額';

  @override
  String get txnDetailDate => '日期';

  @override
  String get txnDetailNote => '備註';

  @override
  String get txnDetailPayMethod => '支付方式';

  @override
  String get txnDetailAddNoteHint => '點擊新增備註';

  @override
  String get txnDetailAiRecord => 'AI解析記錄';

  @override
  String get txnDetailOriginalInput => '原始輸入';

  @override
  String get txnDetailParseSource => '解析來源';

  @override
  String get txnDetailConfidence => '信心度';

  @override
  String get txnDetailCreatedAt => '建立時間';

  @override
  String get entryTitle => '記帳';

  @override
  String get entryBookType => '日常記帳';

  @override
  String get entryExpense => '支出';

  @override
  String get entryIncome => '收入';

  @override
  String get entryOther => '其他';

  @override
  String entrySubCategoryTitle(String name) {
    return '$name - 子分類';
  }

  @override
  String get entryNoteHint => '新增備註...';

  @override
  String get entrySelectCategoryHint => '請選擇分類';

  @override
  String get entrySelectThisCategory => '選此分類';

  @override
  String get entryNoSubCategory => '暫無子分類';

  @override
  String get payMethodDefault => '預設';

  @override
  String get payMethodCash => '現金';

  @override
  String get payMethodWechat => '微信';

  @override
  String get payMethodAlipay => '支付寶';

  @override
  String get payMethodCard => '銀行卡';

  @override
  String get entryNumpadToday => '今天';

  @override
  String get entryNumpadDelete => '刪除';

  @override
  String get entryNumpadDone => '完成';

  @override
  String entrySuccess(String amount) {
    return '記帳成功：$amount';
  }

  @override
  String entryFailure(String error) {
    return '記帳失敗：$error';
  }

  @override
  String get profileCheckedIn => '已打卡';

  @override
  String get profileCheckIn => '打卡';

  @override
  String get profileConsecutiveDays => '連續打卡';

  @override
  String get profileTotalCheckInDays => '打卡總天數';

  @override
  String get profileTotalTransactions => '記帳總筆數';

  @override
  String get profileFuncTheme => '主題切換';

  @override
  String get profileFuncAccountBooks => '我的帳本';

  @override
  String get profileFuncBudget => '預算管理';

  @override
  String get profileFuncCategories => '分類管理';

  @override
  String get profileFuncReports => '報表分析';

  @override
  String get profileToolsAndServices => '工具與服務';

  @override
  String get profileMenuPasswordLock => '密碼鎖';

  @override
  String get profileMenuAcCoins => 'AC幣';

  @override
  String get profileMenuAiConfig => 'AI 配置';

  @override
  String get profileMenuDataBackup => '資料備份';

  @override
  String get profileMenuImport => '帳單匯入';

  @override
  String get profileMenuExport => '帳單匯出';

  @override
  String get profileMenuFeedback => '使用者回饋';

  @override
  String get profileMenuSettings => '設定';

  @override
  String profileFeatureComingSoon(String label) {
    return '$label功能即將推出';
  }

  @override
  String get profileBackupShareText => 'WoAccount 資料備份檔案';

  @override
  String get profileBackupSuccess => '備份成功';

  @override
  String profileBackupFailed(String error) {
    return '備份失敗: $error';
  }

  @override
  String get profileExportShareText => 'WoAccount 資料匯出檔案';

  @override
  String get profileExportSuccess => '匯出成功';

  @override
  String profileExportFailed(String error) {
    return '匯出失敗: $error';
  }

  @override
  String get profileImportConfirm => '匯入將覆蓋所有現有資料，確定繼續嗎？';

  @override
  String get profileImportNoBackup => '沒有找到備份檔案';

  @override
  String get profileImportSuccess => '匯入成功';

  @override
  String profileImportFailed(String error) {
    return '匯入失敗: $error';
  }

  @override
  String get profileExportExcel => '匯出 Excel';

  @override
  String get profileImportExcel => '匯入 Excel';

  @override
  String get profileExcelFormatTitle => 'Excel 格式說明';

  @override
  String profileImportExcelSuccess(int count) {
    return '成功匯入 $count 筆記錄';
  }

  @override
  String get profileAlreadyCheckedIn => '今天已經打過卡了';

  @override
  String get profileCheckInSuccess => '打卡成功！';

  @override
  String profileCheckInFailure(String error) {
    return '打卡失敗: $error';
  }

  @override
  String get profileThemeLight => '淺色模式';

  @override
  String get profileThemeDark => '深色模式';

  @override
  String get profileThemeSystem => '跟隨系統';

  @override
  String profileUserId(String uid) {
    return 'ID: $uid';
  }

  @override
  String get profileEditTitle => '個人資料';

  @override
  String get profileEditNickname => '暱稱';

  @override
  String get profileEditId => 'ID';

  @override
  String get profileEditGender => '性別';

  @override
  String get profileEditEmail => '信箱';

  @override
  String get profileEditPhone => '手機';

  @override
  String get profileEditNotSet => '未設定';

  @override
  String get profileEditNotFound => '未找到使用者資料';

  @override
  String get profileEditGenderMale => '男';

  @override
  String get profileEditGenderFemale => '女';

  @override
  String get profileEditGenderSecret => '保密';

  @override
  String get profileEditLogout => '登出';

  @override
  String get profileEditLogoutConfirmContent => '確定要登出嗎？';

  @override
  String get profileEditLogoutExit => '登出';

  @override
  String get profileEditLogoutComingSoon => '登出功能即將完善';

  @override
  String get profileEditDeleteAccount => '申請註銷帳號';

  @override
  String get profileEditDeleteAccountConfirmContent => '註銷帳號後資料將無法恢復，確定要申請註銷嗎？';

  @override
  String get profileEditDeleteAccountSubmit => '申請註銷';

  @override
  String get profileEditDeleteAccountSubmitted => '註銷申請已提交';

  @override
  String get settingsTitle => '系統設定';

  @override
  String get settingsGeneral => '一般';

  @override
  String get settingsLanguage => '語言';

  @override
  String get settingsDarkMode => '深色模式';

  @override
  String get settingsCurrency => '貨幣';

  @override
  String get settingsData => '資料';

  @override
  String get settingsAutoBackup => '自動備份';

  @override
  String get settingsBackupFrequency => '備份頻率';

  @override
  String get settingsBackupDaily => '每天';

  @override
  String get settingsBackupWeekly => '每週';

  @override
  String get settingsBackupMonthly => '每月';

  @override
  String get settingsBackupManual => '僅手動';

  @override
  String get settingsNoBackupFound => '沒有找到備份檔案';

  @override
  String get settingsRestoreData => '還原資料';

  @override
  String get settingsRestoreConfirm => '還原將覆蓋當前所有資料，確定繼續嗎？';

  @override
  String get settingsRestoreSuccess => '資料還原成功';

  @override
  String settingsRestoreFailed(String error) {
    return '還原失敗: $error';
  }

  @override
  String get settingsAbout => '關於';

  @override
  String get settingsDangerZone => '危險區';

  @override
  String get settingsClearData => '清除所有資料';

  @override
  String get settingsClearConfirm => '此操作不可恢復，確定要清除所有資料嗎？';

  @override
  String get settingsClearDataSuccess => '資料已清除';

  @override
  String get settingsDeleteAccount => '註銷帳號';

  @override
  String get settingsDeleteConfirm => '註銷後所有資料將被永久刪除，確定要繼續嗎？';

  @override
  String get settingsDeleteAccountSuccess => '帳戶資料已刪除';

  @override
  String get budgetTitle => '預算管理';

  @override
  String get budgetViewMonth => '月';

  @override
  String get budgetViewYear => '年';

  @override
  String budgetYearLabel(String year) {
    return '$year年';
  }

  @override
  String get budgetYearTotal => '年度總預算';

  @override
  String budgetMonthCount(String count) {
    return '$count 個月有預算';
  }

  @override
  String budgetMonthShort(String month) {
    return '$month月';
  }

  @override
  String get budgetEmpty => '暫未設定預算';

  @override
  String get budgetSetButton => '設定預算';

  @override
  String get budgetSettingTitle => '預算設定';

  @override
  String get budgetMonthlyTotal => '本月總預算';

  @override
  String budgetSpent(String amount) {
    return '已消費 $amount';
  }

  @override
  String budgetRemaining(String amount) {
    return '剩餘 $amount';
  }

  @override
  String budgetOverSpent(String category, String amount) {
    return '$category預算已超支 $amount';
  }

  @override
  String get budgetUnknownCategory => '某分類';

  @override
  String get budgetUncategorized => '未分類';

  @override
  String budgetUsedPercent(String percent) {
    return '已使用 $percent%';
  }

  @override
  String budgetCategoryCount(String count) {
    return '已設定 $count 個分類預算';
  }

  @override
  String get budgetAddCategoryBudget => '新增分類預算';

  @override
  String get budgetAddCategoryBudgetDeveloping => '新增分類預算功能開發中';

  @override
  String get budgetEditBudgetDeveloping => '編輯預算功能開發中';

  @override
  String get budgetSetTotalTitle => '設定總預算';

  @override
  String get budgetEditTotalTitle => '編輯總預算';

  @override
  String get budgetEditCategoryTitle => '編輯分類預算';

  @override
  String get budgetInputAmount => '輸入預算金額';

  @override
  String get budgetSelectCategory => '選擇分類';

  @override
  String get budgetNoCategoryAvailable => '沒有可用的分類';

  @override
  String get budgetCategoryAlreadyExists => '該分類預算已存在';

  @override
  String get budgetDeleteTitle => '刪除預算';

  @override
  String get budgetDeleteConfirm => '確定要刪除該分類的預算嗎？';

  @override
  String get budgetNoBudgets => '暫未設定預算，點擊右上角編輯按鈕開始';

  @override
  String get bookTitle => '我的帳本';

  @override
  String get bookCreate => '新建帳本';

  @override
  String get bookDescription => '每個帳本擁有獨立的交易記錄、預算和 AI 對話歷史';

  @override
  String get bookDefault => '預設';

  @override
  String get bookCurrent => '當前';

  @override
  String get bookMonthlyExpense => '本月支出';

  @override
  String get bookMonthlyIncome => '本月收入';

  @override
  String get bookTransactionCount => '筆數';

  @override
  String get bookSetDefault => '設為預設';

  @override
  String get bookDelete => '刪除';

  @override
  String bookSwitchedTo(String name) {
    return '已切換到 $name';
  }

  @override
  String get bookDeleteTitle => '刪除帳本';

  @override
  String bookDeleteConfirm(String name) {
    return '確定要刪除「$name」嗎？\n\n該帳本下的所有交易記錄、預算和對話歷史將被清除，此操作不可撤銷。';
  }

  @override
  String get bookDeleted => '帳本已移至回收站';

  @override
  String get bookRecycleBin => '帳本回收站';

  @override
  String get bookRecycleBinEmpty => '回收站為空';

  @override
  String get bookRestore => '恢復';

  @override
  String get bookRestored => '帳本已恢復';

  @override
  String get txnRecycleBin => '交易回收站';

  @override
  String get txnRecycleBinEmpty => '回收站為空';

  @override
  String get txnRestore => '恢復';

  @override
  String get txnRestored => '交易已恢復';

  @override
  String get txnRecycleSelectAll => '全選';

  @override
  String get txnRecycleDeselectAll => '取消';

  @override
  String txnRecycleSelected(int count) {
    return '已選 $count 項';
  }

  @override
  String get txnRecyclePermanentDelete => '永久刪除';

  @override
  String get txnRecyclePermanentDeleteConfirm => '確定永久刪除所選交易？此操作不可恢復。';

  @override
  String txnRecycleBatchRestored(int count) {
    return '已恢復 $count 條交易';
  }

  @override
  String txnRecycleBatchDeleted(int count) {
    return '已永久刪除 $count 條交易';
  }

  @override
  String get txnRecycleSortByDeleteTime => '刪除時間';

  @override
  String get txnRecycleSortByAmount => '金額';

  @override
  String get txnRecycleSortByDate => '交易日期';

  @override
  String get txnRecycleGroupToday => '今天';

  @override
  String get txnRecycleGroupWeek => '本週';

  @override
  String get txnRecycleGroupEarlier => '更早';

  @override
  String get txnRecycleFilterAll => '全部';

  @override
  String get txnRecycleFilterExpense => '支出';

  @override
  String get txnRecycleFilterIncome => '收入';

  @override
  String get bookPermanentDelete => '永久刪除';

  @override
  String bookPermanentDeleteConfirm(String name) {
    return '確定要永久刪除「$name」嗎？\n所有資料將被清除，此操作不可撤銷。';
  }

  @override
  String bookCountUnit(String count) {
    return '$count 筆';
  }

  @override
  String get bookTypePersonal => '個人';

  @override
  String get bookTypeFamily => '家庭';

  @override
  String get bookTypeTravel => '旅行';

  @override
  String get bookTypeBusiness => '生意';

  @override
  String get bookTypeCouple => '情侶';

  @override
  String get bookTypeStudent => '學生';

  @override
  String get bookTypeWedding => '婚禮';

  @override
  String get bookTypeRental => '租房';

  @override
  String get bookTypeInvestment => '投資';

  @override
  String get bookTypePet => '寵物';

  @override
  String get bookTypeHealth => '醫療';

  @override
  String get bookTypeEvent => '活動';

  @override
  String get bookTypeOther => '其他';

  @override
  String get bookTypeCustom => '自定義';

  @override
  String get bookTypeCustomHint => '輸入自定義類型';

  @override
  String get bookDetailTitle => '帳本詳情';

  @override
  String get bookDetailNotExist => '帳本不存在';

  @override
  String get bookDetailExpenseCount => '交易筆數';

  @override
  String get bookDetailNormalSection => '常規操作';

  @override
  String get bookDetailSetDefault => '設為預設帳本';

  @override
  String get bookDetailSwitchTo => '切換到此帳本';

  @override
  String get bookDetailDangerSection => '危險操作';

  @override
  String get bookDetailClearData => '清空帳本資料';

  @override
  String get bookDetailDefaultNotDeletable => '當前帳本不可刪除';

  @override
  String get bookDetailSetDefaultSuccess => '已設為預設帳本';

  @override
  String get bookDetailClearTitle => '清空資料';

  @override
  String bookDetailClearConfirm(String name) {
    return '確定要清空「$name」的所有交易記錄和對話歷史嗎？\n\n此操作不可撤銷。';
  }

  @override
  String get bookDetailClear => '清空';

  @override
  String get bookDetailCleared => '資料已清空';

  @override
  String bookDetailDeleteConfirm(String name) {
    return '確定要刪除「$name」嗎？\n\n帳本將移至回收站，資料不會遺失。';
  }

  @override
  String get bookDetailTypePersonal => '個人帳本';

  @override
  String get bookDetailTypeFamily => '家庭帳本';

  @override
  String get bookDetailTypeTravel => '旅行帳本';

  @override
  String get bookDetailTypeBusiness => '生意帳本';

  @override
  String get bookDetailTypeOther => '其他';

  @override
  String get reportTitle => '報表分析';

  @override
  String get reportPeriodWeek => '週';

  @override
  String get reportPeriodMonth => '月';

  @override
  String get reportPeriodYear => '年';

  @override
  String get reportTypeExpense => '支出';

  @override
  String get reportTypeIncome => '收入';

  @override
  String get reportTotalExpense => '總支出';

  @override
  String get reportTotalIncome => '總收入';

  @override
  String get reportCount => '筆數';

  @override
  String reportCountUnit(String count) {
    return '$count筆';
  }

  @override
  String get reportDailyAverage => '日均';

  @override
  String get reportCategoryCount => '分類';

  @override
  String reportCategoryCountUnit(String count) {
    return '$count個';
  }

  @override
  String get reportCategoryDistribution => '分類佔比';

  @override
  String get reportCategoryRanking => '分類排行';

  @override
  String get reportNoData => '暫無資料';

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
  String get securityLockSettings => '密碼鎖設定';

  @override
  String get securityEnableLock => '啟用密碼鎖';

  @override
  String get securityUnlockMethods => '解鎖方式（可多選）';

  @override
  String get securityPinCode => '數字密碼';

  @override
  String get securityPinCodeDesc => '四位數字密碼解鎖';

  @override
  String get securityBiometric => '指紋解鎖';

  @override
  String get securityBiometricDesc => '使用裝置指紋快速解鎖';

  @override
  String get securityPatternLock => '圖案解鎖';

  @override
  String get securityPatternLockDesc => '繪製圖案解鎖';

  @override
  String get securityLockHint => '勾選多種解鎖方式後，解鎖介面會出現切換按鈕。指紋解鎖需要裝置支援生物辨識功能。';

  @override
  String get securityBiometricVerify => '驗證指紋以啟用指紋解鎖';

  @override
  String securityBiometricFail(String error) {
    return '指紋驗證失敗: $error';
  }

  @override
  String get securitySetPinLock => '設定密碼鎖';

  @override
  String get securitySetPinTitle => '設定四位數字密碼';

  @override
  String get securityConfirmPinTitle => '請再次輸入新密碼';

  @override
  String get securityEnterPin => '請輸入密碼解鎖';

  @override
  String get securityPinWrong => '密碼錯誤，請重試';

  @override
  String get securityPinMismatch => '兩次輸入不一致，請重新設定';

  @override
  String get securityPinSetSuccess => '密碼設定成功';

  @override
  String get securitySetPatternLock => '設定圖案鎖';

  @override
  String get securityDrawPattern => '繪製解鎖圖案';

  @override
  String get securityConfirmPattern => '請再次繪製圖案確認';

  @override
  String get securityDrawToUnlock => '請繪製圖案解鎖';

  @override
  String get securityPatternHint => '連接至少4個點';

  @override
  String get securityConfirmPatternHint => '請繪製與剛才相同的圖案';

  @override
  String get securityRedraw => '重新繪製';

  @override
  String get securityPatternMinDots => '請至少連接4個點';

  @override
  String get securityPatternMismatch => '兩次圖案不一致，請重新繪製';

  @override
  String get securityPatternSetSuccess => '圖案設定成功';

  @override
  String get securityPatternWrong => '圖案錯誤，請重試';

  @override
  String get securityAuthRequired => '請驗證身份以解鎖應用程式';

  @override
  String get securitySelectUnlockMethod => '選擇解鎖方式';

  @override
  String get securitySwitchUnlockMethod => '切換解鎖方式';

  @override
  String get securityVerifyFingerprint => '請驗證指紋';

  @override
  String get securityTouchToUnlock => '觸摸指紋感測器以解鎖應用程式';

  @override
  String get securityRetryFingerprint => '重試指紋';

  @override
  String get checkinTitle => '打卡日曆';

  @override
  String get checkinAlreadyCheckedIn => '今天已經打過卡了';

  @override
  String get checkinCheckInSuccess => '打卡成功！+10 AC幣';

  @override
  String get checkinRewardDaily => '每日打卡獎勵';

  @override
  String get checkinStreak365 => '連續打卡一年！+2000 AC幣';

  @override
  String get checkinStreak180 => '連續打卡半年！+1000 AC幣';

  @override
  String get checkinStreak30 => '連續打卡一個月！+300 AC幣';

  @override
  String get checkinStreak7 => '連續打卡7天！+70 AC幣';

  @override
  String get checkinReward365 => '連續打卡365天獎勵';

  @override
  String get checkinReward180 => '連續打卡180天獎勵';

  @override
  String get checkinReward30 => '連續打卡30天獎勵';

  @override
  String get checkinReward7 => '連續打卡7天獎勵';

  @override
  String get checkinMakeupSelectHint => '請先選擇一個未打卡的日期';

  @override
  String get checkinMakeupFutureError => '只能補簽過去的日期';

  @override
  String get checkinMakeupAlreadyChecked => '該日期已打卡';

  @override
  String get checkinMakeupInsufficient => 'AC幣不足，補簽需要100 AC幣';

  @override
  String get checkinMakeupConfirmTitle => '補簽確認';

  @override
  String checkinMakeupConfirmContent(String date, String balance) {
    return '確定要補簽 $date 嗎？\n將消耗 100 AC幣（目前餘額: $balance）';
  }

  @override
  String get checkinMakeupConfirm => '確認補簽';

  @override
  String get checkinMakeupSuccess => '補簽成功！';

  @override
  String checkinMakeupCost(String date) {
    return '補簽 $date';
  }

  @override
  String get checkinConsecutiveDays => '連續打卡';

  @override
  String get checkinAcBalance => 'AC幣餘額';

  @override
  String get checkinTodayStatus => '今日狀態';

  @override
  String get checkinMakeupButton => '補簽 (-100 AC幣)';

  @override
  String get checkinMakeupSelectButton => '選擇日期後補簽';

  @override
  String get checkinTodayCheckIn => '已打卡';

  @override
  String get checkinTodayCheckInButton => '今日打卡 +10';

  @override
  String get acCoinTitle => 'AC幣記錄';

  @override
  String get acCoinCurrentBalance => '目前餘額';

  @override
  String get acCoinEmpty => '暫無AC幣記錄';

  @override
  String get catExpenseFood => '餐飲美食';

  @override
  String get catExpenseTransport => '交通出行';

  @override
  String get catExpenseHousing => '居住';

  @override
  String get catExpenseClothing => '服飾美容';

  @override
  String get catExpenseDaily => '日用百貨';

  @override
  String get catExpenseTech => '數碼科技';

  @override
  String get catExpenseMedical => '醫療健康';

  @override
  String get catExpenseEducation => '教育學習';

  @override
  String get catExpenseEntertainment => '休閒娛樂';

  @override
  String get catExpenseSocial => '社交人情';

  @override
  String get catExpenseChildren => '子女養育';

  @override
  String get catExpenseElderly => '贍養長輩';

  @override
  String get catExpensePet => '寵物';

  @override
  String get catExpenseWork => '工作辦公';

  @override
  String get catExpenseFinance => '金融保險';

  @override
  String get catExpenseOther => '其他支出';

  @override
  String get catIncomeSalary => '工資薪酬';

  @override
  String get catIncomeInvestment => '投資理財';

  @override
  String get catIncomeSideJob => '副業兼職';

  @override
  String get catIncomeGift => '紅包饋贈';

  @override
  String get catIncomeRefund => '報銷退款';

  @override
  String get catIncomeAsset => '租金資產';

  @override
  String get catIncomeTransferIn => '轉賬收入';

  @override
  String get catIncomeOther => '其他收入';

  @override
  String get catOtherTransfer => '轉賬';

  @override
  String get catOtherRepayment => '還款';

  @override
  String get catOtherSocial => '人情往來';

  @override
  String get catSubFoodBreakfast => '早餐';

  @override
  String get catSubFoodLunch => '午餐';

  @override
  String get catSubFoodDinner => '晚餐';

  @override
  String get catSubFoodLateSnack => '夜宵';

  @override
  String get catSubFoodDelivery => '外賣';

  @override
  String get catSubFoodMilkTea => '奶茶';

  @override
  String get catSubFoodCoffee => '咖啡';

  @override
  String get catSubFoodDrinks => '飲料';

  @override
  String get catSubFoodDessert => '甜點';

  @override
  String get catSubFoodSnacks => '零食小吃';

  @override
  String get catSubFoodFruit => '水果';

  @override
  String get catSubFoodGroceries => '買菜';

  @override
  String get catSubFoodDiningOut => '聚餐請客';

  @override
  String get catSubTransportMetro => '地鐵';

  @override
  String get catSubTransportBus => '公車';

  @override
  String get catSubTransportTaxi => '計程車';

  @override
  String get catSubTransportRideshare => '網約車';

  @override
  String get catSubTransportBikeShare => '共享單車';

  @override
  String get catSubTransportHighSpeedRail => '高鐵';

  @override
  String get catSubTransportTrain => '火車';

  @override
  String get catSubTransportFlight => '飛機';

  @override
  String get catSubTransportFuel => '加油';

  @override
  String get catSubTransportCharging => '充電';

  @override
  String get catSubTransportParking => '停車費';

  @override
  String get catSubTransportToll => '過路費';

  @override
  String get catSubTransportMaintenance => '車輛保養';

  @override
  String get catSubTransportRepair => '車輛維修';

  @override
  String get catSubTransportInsurance => '車險';

  @override
  String get catSubHousingRent => '房租';

  @override
  String get catSubHousingMortgage => '房貸';

  @override
  String get catSubHousingWater => '水費';

  @override
  String get catSubHousingElectricity => '電費';

  @override
  String get catSubHousingGas => '燃氣費';

  @override
  String get catSubHousingPropertyFee => '物業費';

  @override
  String get catSubHousingInternet => '寬頻網路費';

  @override
  String get catSubHousingPhone => '手機話費';

  @override
  String get catSubHousingCleaning => '家政保潔';

  @override
  String get catSubHousingRepair => '房屋維修';

  @override
  String get catSubClothingApparel => '衣物';

  @override
  String get catSubClothingShoes => '鞋子';

  @override
  String get catSubClothingHats => '帽子';

  @override
  String get catSubClothingBags => '包包';

  @override
  String get catSubClothingCosmetics => '化妝品';

  @override
  String get catSubClothingSkincare => '護膚品';

  @override
  String get catSubClothingHaircut => '理髮';

  @override
  String get catSubClothingManicure => '美甲';

  @override
  String get catSubClothingJewelry => '飾品';

  @override
  String get catSubClothingAccessories => '配件';

  @override
  String get catSubDailyNecessities => '日用品';

  @override
  String get catSubDailyCleaning => '清潔用品';

  @override
  String get catSubDailyKitchen => '廚房用品';

  @override
  String get catSubDailyDecor => '家居裝飾';

  @override
  String get catSubDailyStorage => '收納用品';

  @override
  String get catSubDailyBedding => '床上用品';

  @override
  String get catSubDailyTissue => '紙品';

  @override
  String get catSubTechPhone => '手機';

  @override
  String get catSubTechComputer => '電腦';

  @override
  String get catSubTechAccessories => '配件';

  @override
  String get catSubTechConsumables => '耗材';

  @override
  String get catSubTechStorage => '儲存裝置';

  @override
  String get catSubMedicalRegistration => '門診掛號';

  @override
  String get catSubMedicalMedicine => '藥品';

  @override
  String get catSubMedicalHospitalization => '住院';

  @override
  String get catSubMedicalCheckup => '體檢';

  @override
  String get catSubMedicalDental => '口腔';

  @override
  String get catSubMedicalEyeCare => '眼科';

  @override
  String get catSubMedicalVaccine => '疫苗';

  @override
  String get catSubMedicalWellness => '保健養生';

  @override
  String get catSubMedicalFitness => '健身運動';

  @override
  String get catSubEducationBooks => '書籍';

  @override
  String get catSubEducationTuition => '學費';

  @override
  String get catSubEducationTraining => '培訓費';

  @override
  String get catSubEducationExam => '考試費';

  @override
  String get catSubEducationOnlineCourse => '線上課程';

  @override
  String get catSubEducationStationery => '文具用品';

  @override
  String get catSubEntertainmentMovies => '電影';

  @override
  String get catSubEntertainmentKtv => 'KTV';

  @override
  String get catSubEntertainmentGaming => '遊戲充值';

  @override
  String get catSubEntertainmentSubscription => '會員訂閱';

  @override
  String get catSubEntertainmentTickets => '景點門票';

  @override
  String get catSubEntertainmentHotel => '酒店住宿';

  @override
  String get catSubEntertainmentTravel => '旅遊';

  @override
  String get catSubEntertainmentShow => '演出';

  @override
  String get catSubEntertainmentStreaming => '串流媒體';

  @override
  String get catSubSocialGift => '禮物';

  @override
  String get catSubSocialRedPacket => '紅包';

  @override
  String get catSubSocialWeddingGift => '份子錢';

  @override
  String get catSubSocialTreat => '請客';

  @override
  String get catSubSocialBirthday => '生日聚會';

  @override
  String get catSubSocialVisit => '探望慰問';

  @override
  String get catSubSocialRespect => '孝敬長輩';

  @override
  String get catSubSocialCharity => '慈善捐助';

  @override
  String get catSubChildrenFormula => '奶粉輔食';

  @override
  String get catSubChildrenDiapers => '尿布用品';

  @override
  String get catSubChildrenTuition => '學費';

  @override
  String get catSubChildrenHobby => '興趣班';

  @override
  String get catSubChildrenTutoring => '輔導班';

  @override
  String get catSubChildrenDaycare => '午托晚托';

  @override
  String get catSubChildrenToys => '玩具';

  @override
  String get catSubElderlySupport => '贍養費';

  @override
  String get catSubElderlyNutrition => '營養品';

  @override
  String get catSubElderlyMedical => '醫療費';

  @override
  String get catSubElderlyAllowance => '孝敬金';

  @override
  String get catSubPetFood => '寵物食品';

  @override
  String get catSubPetMedical => '寵物醫療';

  @override
  String get catSubPetSupplies => '寵物用品';

  @override
  String get catSubPetGrooming => '寵物美容';

  @override
  String get catSubWorkOffice => '辦公用品';

  @override
  String get catSubWorkPrinting => '列印複印';

  @override
  String get catSubWorkShipping => '快遞物流';

  @override
  String get catSubWorkTravel => '差旅費';

  @override
  String get catSubFinanceInsurance => '保險費用';

  @override
  String get catSubFinanceLoss => '理財虧損';

  @override
  String get catSubFinanceFee => '手續費';

  @override
  String get catSubFinanceLoanInterest => '貸款利息';

  @override
  String get catSubFinanceTax => '稅費';

  @override
  String get catSubFinanceFine => '罰款';

  @override
  String get catSubOtherExpenseGeneral => '其他消費';

  @override
  String get catSubOtherExpenseUnexpected => '意外支出';

  @override
  String get catSubSalaryBase => '基本工資';

  @override
  String get catSubSalaryBonus => '績效獎金';

  @override
  String get catSubSalaryOvertime => '加班費';

  @override
  String get catSubSalaryYearEnd => '年終獎';

  @override
  String get catSubSalaryBackPay => '調薪補發';

  @override
  String get catSubSalaryAllowance => '津貼補貼';

  @override
  String get catSubInvestmentFund => '基金收益';

  @override
  String get catSubInvestmentStock => '股票收益';

  @override
  String get catSubInvestmentInterest => '利息收入';

  @override
  String get catSubInvestmentWealthMgmt => '理財產品';

  @override
  String get catSubInvestmentCrypto => '數位貨幣';

  @override
  String get catSubInvestmentDividend => '分紅';

  @override
  String get catSubSideJobPartTime => '兼職收入';

  @override
  String get catSubSideJobFreelance => '自由職業';

  @override
  String get catSubSideJobRoyalty => '稿費版權';

  @override
  String get catSubSideJobCommission => '佣金提成';

  @override
  String get catSubSideJobSales => '銷售收入';

  @override
  String get catSubGiftRedPacket => '紅包收入';

  @override
  String get catSubGiftPresent => '禮金饋贈';

  @override
  String get catSubGiftFestival => '節日紅包';

  @override
  String get catSubRefundReimbursement => '報銷到帳';

  @override
  String get catSubRefundReturn => '退款收入';

  @override
  String get catSubRefundMedical => '醫保報銷';

  @override
  String get catSubRefundInsurance => '保險理賠';

  @override
  String get catSubAssetRent => '房租收入';

  @override
  String get catSubAssetIdleSale => '閒置出售';

  @override
  String get catSubAssetSecondhand => '二手交易';

  @override
  String get catSubAssetProfit => '資產收益';

  @override
  String get catSubTransferInBank => '銀行轉入';

  @override
  String get catSubTransferInWallet => '錢包轉入';

  @override
  String get catSubTransferInDebt => '債務回收';

  @override
  String get catSubIncomeOtherWindfall => '意外所得';

  @override
  String get catSubIncomeOtherSubsidy => '政府補貼';

  @override
  String get catSubIncomeOtherUncategorized => '未分類';

  @override
  String get catSubTransferBankIn => '銀行卡轉入';

  @override
  String get catSubTransferBankOut => '銀行卡轉出';

  @override
  String get catSubTransferWallet => '錢包互轉';

  @override
  String get catSubTransferCrossIn => '跨平台轉入';

  @override
  String get catSubTransferCrossOut => '跨平台轉出';

  @override
  String get catSubRepaymentCreditCard => '信用卡還款';

  @override
  String get catSubRepaymentLoan => '貸款還款';

  @override
  String get catSubRepaymentBorrowed => '借款歸還';

  @override
  String get catSubRepaymentLent => '借款借出';

  @override
  String get catSubOtherSocialGift => '隨禮份子錢';

  @override
  String get catSubOtherSocialWedding => '婚喪嫁娶';

  @override
  String get catSubOtherSocialBirthday => '生日聚會';

  @override
  String get catSubOtherSocialFestival => '節日紅包往來';

  @override
  String get weekMon => '一';

  @override
  String get weekTue => '二';

  @override
  String get weekWed => '三';

  @override
  String get weekThu => '四';

  @override
  String get weekFri => '五';

  @override
  String get weekSat => '六';

  @override
  String get weekSun => '日';

  @override
  String get weekMonFull => '週一';

  @override
  String get weekTueFull => '週二';

  @override
  String get weekWedFull => '週三';

  @override
  String get weekThuFull => '週四';

  @override
  String get weekFriFull => '週五';

  @override
  String get weekSatFull => '週六';

  @override
  String get weekSunFull => '週日';

  @override
  String get commonSelectDateTime => '選擇日期時間';

  @override
  String get commonBack => '返回';

  @override
  String get commonDone => '完成';

  @override
  String get commonAdd => '添加';

  @override
  String commonEnterHint(String field) {
    return '請輸入$field';
  }

  @override
  String get txnCategorySearch => '搜尋分類...';

  @override
  String get txnCategoryEmpty => '暫無分類';

  @override
  String get settingsSelectLanguage => '選擇語言';

  @override
  String get settingsSelectCurrency => '選擇貨幣';

  @override
  String get profileDefaultNickname => '用戶';

  @override
  String get catManageTitle => '分類管理';

  @override
  String catManageSubTitle(String name) {
    return '$name - 子分類';
  }

  @override
  String get catManageAddSub => '添加子分類';

  @override
  String get catManageNameExists => '該分類名已存在';

  @override
  String get catManageSubNameExists => '該子分類名已存在';

  @override
  String get catManageDeleteTitle => '確認刪除';

  @override
  String catManageDeleteWithChildren(String name) {
    return '確定要刪除分類\"$name\"及其所有子分類嗎？';
  }

  @override
  String catManageDeleteConfirm(String name) {
    return '確定要刪除分類\"$name\"嗎？';
  }

  @override
  String get catManageDeleteBlocked => '該分類有關聯資料，無法刪除';

  @override
  String get catManageCustomBadge => '自';

  @override
  String get catManageCustom => '自訂';

  @override
  String catManageAddTitle(String type) {
    return '添加$type分類';
  }

  @override
  String get catManageNameLabel => '分類名稱';

  @override
  String get catManageNameHint => '請輸入分類名稱';

  @override
  String get catManageSelectIcon => '選擇圖示';

  @override
  String get catManageSelectColor => '選擇顏色';

  @override
  String catManageAddSubTitle(String name) {
    return '添加子分類 - $name';
  }

  @override
  String get catManageSubNameLabel => '子分類名稱';

  @override
  String get catManageSubNameHint => '請輸入子分類名稱';

  @override
  String get catManageEditTitle => '編輯分類';

  @override
  String get bookNameLabel => '帳本名稱';

  @override
  String get bookNameHint => '例如：日常記帳';

  @override
  String get bookTypeLabel => '帳本類型';

  @override
  String get bookDescLabel => '備註（可選）';

  @override
  String get bookDescHint => '簡單描述帳本用途';

  @override
  String get bookCreateButton => '建立';

  @override
  String get bookDescPersonal => '日常個人記帳';

  @override
  String get bookDescFamily => '家庭共同開支';

  @override
  String get bookDescTravel => '旅行花費記錄';

  @override
  String get bookDescBusiness => '副業/小生意收支';

  @override
  String get bookDescOther => '自訂用途';

  @override
  String get aiPresetDeepseekNote => '高性價比國產大模型';

  @override
  String get aiPresetOpenaiNote => '需海外網路存取';

  @override
  String get aiPresetQwenName => '通義千問 (阿里)';

  @override
  String get aiPresetQwenNote => '使用相容模式地址';

  @override
  String get aiPresetDoubaoName => '豆包 (位元組)';

  @override
  String get aiPresetDoubaoNote => '需在火山方舟建立推理接入點，模型名使用接入點 ID';

  @override
  String get aiPresetZhipuName => '智譜AI';

  @override
  String get aiPresetZhipuNote => 'glm-4-flash 有免費額度';

  @override
  String get aiPresetKimiName => '月之暗面 (Kimi)';

  @override
  String get aiPresetKimiNote => '擅長長文本理解';

  @override
  String get aiPresetClaudeNote => '使用 Anthropic Messages API';

  @override
  String get aiPresetMimoName => '小米 MiMo';

  @override
  String get aiPresetMimoNote => '支援 OpenAI/Anthropic 相容協定，中國/新加坡/歐洲多叢集';

  @override
  String get aiPresetOllamaName => 'Ollama (本地)';

  @override
  String get aiPresetOllamaNote => '需本地執行 Ollama 服務，模型名取決於本地安裝';

  @override
  String get llmCapTextLabel => '文字模型';

  @override
  String get llmCapTextDesc => '用於記帳解析、AI 對話';

  @override
  String get llmCapVisionLabel => '視覺模型';

  @override
  String get llmCapVisionDesc => '用於拍照識別收據/發票';

  @override
  String get llmCapAudioLabel => '語音模型';

  @override
  String get llmCapAudioDesc => '用於語音轉文字';

  @override
  String get currencyCny => '人民幣';

  @override
  String get currencyUsd => '美元';

  @override
  String get currencyKrw => '韓元';

  @override
  String get currencyJpy => '日圓';

  @override
  String get currencyEur => '歐元';

  @override
  String get currencyGbp => '英鎊';

  @override
  String get currencyUnitYi => '億';

  @override
  String get currencyUnitWan => '萬';

  @override
  String get inputSourceText => '文字';

  @override
  String get inputSourceVoice => '語音';

  @override
  String get inputSourceImage => '圖片';

  @override
  String reportTrendMonth(String period) {
    return '$period月';
  }

  @override
  String reportTrendDay(String period) {
    return '$period日';
  }

  @override
  String get llmSettingsTitle => 'AI 服務配置';

  @override
  String get llmExportConfig => '匯出配置';

  @override
  String get llmImportConfig => '匯入配置';

  @override
  String get llmProviderManagement => '服務商管理';

  @override
  String get llmAddProvider => '新增服務商';

  @override
  String get llmEditProvider => '編輯服務商';

  @override
  String get llmDeleteProvider => '刪除服務商';

  @override
  String llmDeleteProviderConfirm(String name) {
    return '確定刪除「$name」？';
  }

  @override
  String get llmNotConfigured => '未配置';

  @override
  String get llmConfigured => '已配置';

  @override
  String get llmNoProviders => '尚未新增任何服務商';

  @override
  String get llmUnnamedProvider => '未命名服務商';

  @override
  String get llmInUse => '使用中';

  @override
  String get llmIncomplete => '未完成';

  @override
  String get llmTest => '測試';

  @override
  String get llmConfigIncomplete => '請先完善配置（需要 API Key、地址和至少一個模型）';

  @override
  String get llmConnectSuccess => '✅ 連線成功';

  @override
  String get llmConnectFail => '❌ 連線失敗，請檢查地址、Key 和模型名稱';

  @override
  String get llmConfigCopied => '配置已複製到剪貼簿';

  @override
  String get llmClipboardEmpty => '剪貼簿為空';

  @override
  String llmImported(String count) {
    return '已匯入 $count 個服務商配置';
  }

  @override
  String get llmImportFailed => '匯入失敗，請檢查 JSON 格式';

  @override
  String get llmProviderNotConfigured => '該服務商未配置 API Key 或請求地址，請先編輯';

  @override
  String llmModelsFetched(String count, String label) {
    return '擷取到 $count 個$label';
  }

  @override
  String llmModelsFetchedAll(String count) {
    return '擷取到 $count 個模型（未篩選到專用模型，顯示全部）';
  }

  @override
  String get llmFetchFailed => '擷取失敗，已載入預設模型列表';

  @override
  String llmFetchError(String error) {
    return '擷取模型失敗: $error';
  }

  @override
  String llmModelSet(String capability, String provider, String model) {
    return '已設定 $capability：$provider · $model';
  }

  @override
  String llmInputModelName(String capability) {
    return '輸入$capability名稱';
  }

  @override
  String get llmConnectFailed => '連線失敗';

  @override
  String get llmAutoDetectInterval => '自動偵測間隔';

  @override
  String get llmIntervalOff => '關閉';

  @override
  String get llmInterval10s => '10秒';

  @override
  String get llmInterval30s => '30秒';

  @override
  String get llmInterval1m => '1分鐘';

  @override
  String get llmInterval2m => '2分鐘';

  @override
  String get llmInterval5m => '5分鐘';

  @override
  String get llmInterval10m => '10分鐘';

  @override
  String get llmInterval30m => '30分鐘';

  @override
  String get llmInterval1h => '1小時';

  @override
  String llmConfigureCap(String label) {
    return '配置$label';
  }

  @override
  String get llmCurrentUse => '目前使用';

  @override
  String get llmFetch => '擷取';

  @override
  String get llmTesting => '偵測中...';

  @override
  String get llmTestConnection => '偵測連線';

  @override
  String get llmFailed => '失敗';

  @override
  String llmSelectCap(String label) {
    return '選擇$label';
  }

  @override
  String get llmManualInput => '✏️ 手動輸入...';

  @override
  String get llmFillApiKey => '請填寫 API Key 和請求地址';

  @override
  String get llmCustom => '自訂';

  @override
  String get llmProviderName => '服務商名稱';

  @override
  String get llmApiUrl => '請求地址';

  @override
  String get llmApiUrlHintAnthropic =>
      'Anthropic API 地址，如 https://api.anthropic.com';

  @override
  String get llmApiUrlHelper => '填入 API 的 base_url，不需要手動拼接 /chat/completions';

  @override
  String get llmSaveHint => '儲存後，請返回上一頁透過能力卡片配置模型';

  @override
  String get llmInputApiKey => '輸入 API Key';

  @override
  String get llmApiUrlExample => '如：https://api.example.com';

  @override
  String get llmAdvancedSettings => '進階設定';

  @override
  String get llmTemperature => '回答風格';

  @override
  String get llmTemperatureHint => '越低越精確穩定，越發散多樣';

  @override
  String get llmTemperaturePrecise => '精確';

  @override
  String get llmTemperatureCreative => '創意';

  @override
  String get llmMaxToken => '最大 Token';

  @override
  String get llmTimeout => '逾時（秒）';

  @override
  String get llmErrorNoModelForCapability => '未配置對應能力的模型';

  @override
  String get llmErrorNoProviderConfigured => '請先在設定中新增並配置 AI 服務商';

  @override
  String get llmErrorNoProviderOrInput => '請先在設定中新增 AI 服務商，或輸入更明確的描述';

  @override
  String get llmErrorCannotParseResponse => '無法解析 AI 回應';

  @override
  String get llmErrorInvalidResponseFormat => 'AI 回應格式不正確';

  @override
  String llmErrorParseFailed(String error) {
    return '解析 AI 回應失敗: $error';
  }

  @override
  String get llmErrorTimeout => '請求逾時，請檢查網路連線';

  @override
  String get llmErrorInvalidApiKey => 'API Key 無效，請檢查設定';

  @override
  String get llmErrorRateLimit => '請求過於頻繁，請稍後再試';

  @override
  String get llmErrorForbidden => '存取被拒絕，請檢查 API Key 權限';

  @override
  String llmErrorRequestFailed(String code) {
    return '請求失敗 ($code)';
  }

  @override
  String get llmErrorNetworkFailed => '網路連線失敗，請檢查網路';

  @override
  String llmErrorRequestFailedWithMessage(String message) {
    return '請求失敗: $message';
  }

  @override
  String get visionErrorNoModelConfigured => '未配置視覺識別模型，請在 AI 設定中配置';

  @override
  String get visionErrorImageNotFound => '圖片檔案不存在';

  @override
  String visionErrorRecognitionFailed(String message) {
    return '圖片識別失敗: $message';
  }

  @override
  String get voiceErrorNoModelConfigured => '未配置語音識別模型，請在 AI 設定中配置';

  @override
  String get voiceErrorNoEngineAvailable => '未配置語音識別引擎，請檢查 AI 設定或裝置語音支援';

  @override
  String get voiceErrorAudioNotFound => '音訊檔案不存在';

  @override
  String get voiceErrorInvalidResponseFormat => '語音識別回傳格式異常';

  @override
  String voiceErrorTranscriptionFailed(String message) {
    return '語音識別失敗: $message';
  }

  @override
  String get voiceErrorEndpointNotFound =>
      'Whisper API 端點未找到，請檢查供應商 Base URL 配置';

  @override
  String get pipelineErrorEmptyVoiceResult => '語音識別結果為空，請重新錄製';

  @override
  String get pipelineErrorEmptyImageResult => '圖片識別結果為空，請選擇更清晰的圖片';

  @override
  String get acCoinInitialGiftDesc => '新會員註冊贈送';

  @override
  String get loadFailedPullToRefresh => '載入失敗，請下拉重新整理';

  @override
  String get llmSettingsGetModelListError => '無法取得模型列表';

  @override
  String get searchPageTitle => '搜尋帳單';

  @override
  String get searchHint => '輸入關鍵詞或自然語言，如「上月搭計程車花了多少」';

  @override
  String get searchAiParsing => 'AI 正在理解您的查詢...';

  @override
  String get searchNoResults => '未找到匹配的帳單';

  @override
  String get searchNoResultsHint => '試試其他關鍵詞或換個說法';

  @override
  String searchResultCount(String count) {
    return '找到 $count 條結果';
  }

  @override
  String get searchAiSummaryTitle => '📊 AI 分析結果';

  @override
  String get searchAiSummaryLoading => 'AI 正在分析...';

  @override
  String get searchTotalExpense => '總支出';

  @override
  String get searchTotalIncome => '總收入';

  @override
  String searchTransactionCount(String count) {
    return '共 $count 筆';
  }

  @override
  String get searchAverage => '日均';

  @override
  String get searchMaxSingle => '最大單筆';

  @override
  String get searchLlmNotConfigured => '未配置 AI 服務，僅支援關鍵詞搜尋';

  @override
  String get searchLlmError => 'AI 查詢解析失敗，已切換為關鍵詞搜尋';

  @override
  String get searchQuickSuggestions => '搜尋建議';

  @override
  String get searchSuggestionLastMonthExpense => '上月消費匯總';

  @override
  String get searchSuggestionThisMonthFood => '本月餐飲消費';

  @override
  String get searchSuggestionRecentLarge => '最近大額消費';

  @override
  String get searchSuggestionRecentWeek => '最近一週帳單';

  @override
  String get searchFilterExpense => '支出';

  @override
  String get searchFilterIncome => '收入';

  @override
  String get searchFilterAll => '全部';

  @override
  String get searchFilterDateRange => '日期範圍';

  @override
  String get searchFilterAmountRange => '金額範圍';

  @override
  String get searchFilterCategory => '分類';

  @override
  String get searchFilterPayment => '支付方式';

  @override
  String get searchFilterClear => '清除篩選';

  @override
  String get searchModeKeyword => '關鍵詞';

  @override
  String get searchModeAi => 'AI 搜尋';

  @override
  String get searchKeywordPlaceholder => '搜尋描述、備註、金額...';

  @override
  String get searchParsingFailed => 'AI 解析失敗';

  @override
  String get llmSupplierManagement => '服務商管理';

  @override
  String get llmModelManagement => '模型管理';

  @override
  String get llmSelectProvider => '選擇服務商';

  @override
  String get llmSelectModel => '選擇模型';

  @override
  String get llmProviderIncomplete => '未配置完整';

  @override
  String get llmNone => '不使用';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '確認';

  @override
  String get agentTransactionParser => '記帳解析';

  @override
  String get agentTransactionParserDesc => '從自然語言中提取交易金額、分類、時間';

  @override
  String get agentReceiptOcr => '小票識別';

  @override
  String get agentReceiptOcrDesc => '識別小票/發票圖片中的消費資訊';

  @override
  String get agentVoiceTranscribe => '語音轉寫';

  @override
  String get agentVoiceTranscribeDesc => '將語音錄音轉為文字';

  @override
  String get agentFinanceSearch => '財務搜尋';

  @override
  String get agentFinanceSearchDesc => '自然語言查詢交易、預算、分類';

  @override
  String get agentEditTitle => '功能配置';

  @override
  String get agentEditSave => '儲存';

  @override
  String get agentEditSaved => '配置已儲存';

  @override
  String get agentEditSelectModel => '請先選擇模型';

  @override
  String get agentEditPrimaryModel => '主模型';

  @override
  String get agentEditFallbackModel => '備選模型';

  @override
  String get agentEditEnableFallback => '啟用自動降級';

  @override
  String get agentEditTestCases => '測試用例';

  @override
  String get agentEditTestCase => '用例';

  @override
  String get agentEditProvider => '供應商';

  @override
  String get agentEditModel => '模型';

  @override
  String get agentEditManualInput => '手動輸入模型名';

  @override
  String get agentEditModelNameHint => '輸入模型名稱';

  @override
  String get aiSettingsTitle => 'AI 設定';

  @override
  String get aiSettingsAgents => '功能配置';

  @override
  String get aiSettingsSuppliers => '供應商管理';

  @override
  String get aiSettingsUsage => '本月用量';

  @override
  String get aiSettingsUsageCalls => '次調用';

  @override
  String get aiSettingsUsageFallback => '次降級';

  @override
  String get aiSettingsNoAgents => '未配置任何功能';

  @override
  String get aiSettingsAddSupplier => '新增供應商';

  @override
  String get aiSettingsTestConnection => '測試連線';

  @override
  String get aiSettingsConnected => '已連線';

  @override
  String get aiSettingsDisconnected => '未連線';

  @override
  String get aiSettingsLatency => '延遲';
}
