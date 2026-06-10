/// 系统默认分类配置
library;

/// 分类种子数据定义
class CategorySeed {
  final String name;
  final String icon;
  final String color;
  final bool isExpense;
  final int sortOrder;
  final String? l10nKey; // 国际化 key，用于 AppLocalizations 查翻译
  final List<CategorySeed> children;

  const CategorySeed({
    required this.name,
    required this.icon,
    required this.color,
    required this.isExpense,
    required this.sortOrder,
    this.l10nKey,
    this.children = const [],
  });
}

/// ==================== 支出分类 ====================
const expenseCategories = <CategorySeed>[
  CategorySeed(
    name: '餐饮美食', icon: '🍜', color: '#FF9800', isExpense: true, sortOrder: 1, l10nKey: 'catExpenseFood',
    children: [
      CategorySeed(name: '早餐', icon: '🌅', color: '#FF9800', isExpense: true, sortOrder: 1, l10nKey: 'catSubFoodBreakfast'),
      CategorySeed(name: '午餐', icon: '🍱', color: '#FF9800', isExpense: true, sortOrder: 2, l10nKey: 'catSubFoodLunch'),
      CategorySeed(name: '晚餐', icon: '🍲', color: '#FF9800', isExpense: true, sortOrder: 3, l10nKey: 'catSubFoodDinner'),
      CategorySeed(name: '夜宵', icon: '🌙', color: '#FF9800', isExpense: true, sortOrder: 4, l10nKey: 'catSubFoodLateSnack'),
      CategorySeed(name: '外卖', icon: '🥡', color: '#FF9800', isExpense: true, sortOrder: 5, l10nKey: 'catSubFoodDelivery'),
      CategorySeed(name: '奶茶', icon: '🧋', color: '#FF9800', isExpense: true, sortOrder: 6, l10nKey: 'catSubFoodMilkTea'),
      CategorySeed(name: '咖啡', icon: '☕', color: '#FF9800', isExpense: true, sortOrder: 7, l10nKey: 'catSubFoodCoffee'),
      CategorySeed(name: '饮料', icon: '🧃', color: '#FF9800', isExpense: true, sortOrder: 8, l10nKey: 'catSubFoodDrinks'),
      CategorySeed(name: '甜点', icon: '🍰', color: '#FF9800', isExpense: true, sortOrder: 9, l10nKey: 'catSubFoodDessert'),
      CategorySeed(name: '零食小吃', icon: '🍿', color: '#FF9800', isExpense: true, sortOrder: 10, l10nKey: 'catSubFoodSnacks'),
      CategorySeed(name: '水果', icon: '🍎', color: '#FF9800', isExpense: true, sortOrder: 11, l10nKey: 'catSubFoodFruit'),
      CategorySeed(name: '买菜', icon: '🥬', color: '#FF9800', isExpense: true, sortOrder: 12, l10nKey: 'catSubFoodGroceries'),
      CategorySeed(name: '聚餐请客', icon: '🍕', color: '#FF9800', isExpense: true, sortOrder: 13, l10nKey: 'catSubFoodDiningOut'),
    ],
  ),
  CategorySeed(
    name: '交通出行', icon: '🚌', color: '#2196F3', isExpense: true, sortOrder: 2, l10nKey: 'catExpenseTransport',
    children: [
      CategorySeed(name: '地铁', icon: '🚇', color: '#2196F3', isExpense: true, sortOrder: 1, l10nKey: 'catSubTransportMetro'),
      CategorySeed(name: '公交', icon: '🚌', color: '#2196F3', isExpense: true, sortOrder: 2, l10nKey: 'catSubTransportBus'),
      CategorySeed(name: '打车', icon: '🚕', color: '#2196F3', isExpense: true, sortOrder: 3, l10nKey: 'catSubTransportTaxi'),
      CategorySeed(name: '网约车', icon: '🚖', color: '#2196F3', isExpense: true, sortOrder: 4, l10nKey: 'catSubTransportRideshare'),
      CategorySeed(name: '共享单车', icon: '🛵', color: '#2196F3', isExpense: true, sortOrder: 5, l10nKey: 'catSubTransportBikeShare'),
      CategorySeed(name: '高铁', icon: '🚄', color: '#2196F3', isExpense: true, sortOrder: 6, l10nKey: 'catSubTransportHighSpeedRail'),
      CategorySeed(name: '火车', icon: '🚂', color: '#2196F3', isExpense: true, sortOrder: 7, l10nKey: 'catSubTransportTrain'),
      CategorySeed(name: '飞机', icon: '✈️', color: '#2196F3', isExpense: true, sortOrder: 8, l10nKey: 'catSubTransportFlight'),
      CategorySeed(name: '加油', icon: '⛽', color: '#2196F3', isExpense: true, sortOrder: 9, l10nKey: 'catSubTransportFuel'),
      CategorySeed(name: '充电', icon: '🔋', color: '#2196F3', isExpense: true, sortOrder: 10, l10nKey: 'catSubTransportCharging'),
      CategorySeed(name: '停车费', icon: '🅿️', color: '#2196F3', isExpense: true, sortOrder: 11, l10nKey: 'catSubTransportParking'),
      CategorySeed(name: '过路费', icon: '🛣️', color: '#2196F3', isExpense: true, sortOrder: 12, l10nKey: 'catSubTransportToll'),
      CategorySeed(name: '车辆保养', icon: '🚗', color: '#2196F3', isExpense: true, sortOrder: 13, l10nKey: 'catSubTransportMaintenance'),
      CategorySeed(name: '车辆维修', icon: '🔧', color: '#2196F3', isExpense: true, sortOrder: 14, l10nKey: 'catSubTransportRepair'),
      CategorySeed(name: '车险', icon: '🛡️', color: '#2196F3', isExpense: true, sortOrder: 15, l10nKey: 'catSubTransportInsurance'),
    ],
  ),
  CategorySeed(
    name: '居住', icon: '🏠', color: '#9C27B0', isExpense: true, sortOrder: 3, l10nKey: 'catExpenseHousing',
    children: [
      CategorySeed(name: '房租', icon: '🏷️', color: '#9C27B0', isExpense: true, sortOrder: 1, l10nKey: 'catSubHousingRent'),
      CategorySeed(name: '房贷', icon: '🏦', color: '#9C27B0', isExpense: true, sortOrder: 2, l10nKey: 'catSubHousingMortgage'),
      CategorySeed(name: '水费', icon: '💧', color: '#9C27B0', isExpense: true, sortOrder: 3, l10nKey: 'catSubHousingWater'),
      CategorySeed(name: '电费', icon: '⚡', color: '#9C27B0', isExpense: true, sortOrder: 4, l10nKey: 'catSubHousingElectricity'),
      CategorySeed(name: '燃气费', icon: '🔥', color: '#9C27B0', isExpense: true, sortOrder: 5, l10nKey: 'catSubHousingGas'),
      CategorySeed(name: '物业费', icon: '🏢', color: '#9C27B0', isExpense: true, sortOrder: 6, l10nKey: 'catSubHousingPropertyFee'),
      CategorySeed(name: '宽带网费', icon: '📶', color: '#9C27B0', isExpense: true, sortOrder: 7, l10nKey: 'catSubHousingInternet'),
      CategorySeed(name: '手机话费', icon: '📱', color: '#9C27B0', isExpense: true, sortOrder: 8, l10nKey: 'catSubHousingPhone'),
      CategorySeed(name: '家政保洁', icon: '🧹', color: '#9C27B0', isExpense: true, sortOrder: 9, l10nKey: 'catSubHousingCleaning'),
      CategorySeed(name: '房屋维修', icon: '🔨', color: '#9C27B0', isExpense: true, sortOrder: 10, l10nKey: 'catSubHousingRepair'),
    ],
  ),
  CategorySeed(
    name: '服饰美容', icon: '👔', color: '#E91E63', isExpense: true, sortOrder: 4, l10nKey: 'catExpenseClothing',
    children: [
      CategorySeed(name: '衣物', icon: '👕', color: '#E91E63', isExpense: true, sortOrder: 1, l10nKey: 'catSubClothingApparel'),
      CategorySeed(name: '鞋子', icon: '👟', color: '#E91E63', isExpense: true, sortOrder: 2, l10nKey: 'catSubClothingShoes'),
      CategorySeed(name: '帽子', icon: '👒', color: '#E91E63', isExpense: true, sortOrder: 3, l10nKey: 'catSubClothingHats'),
      CategorySeed(name: '包包', icon: '👜', color: '#E91E63', isExpense: true, sortOrder: 4, l10nKey: 'catSubClothingBags'),
      CategorySeed(name: '化妆品', icon: '💄', color: '#E91E63', isExpense: true, sortOrder: 5, l10nKey: 'catSubClothingCosmetics'),
      CategorySeed(name: '护肤品', icon: '🧴', color: '#E91E63', isExpense: true, sortOrder: 6, l10nKey: 'catSubClothingSkincare'),
      CategorySeed(name: '理发', icon: '💇', color: '#E91E63', isExpense: true, sortOrder: 7, l10nKey: 'catSubClothingHaircut'),
      CategorySeed(name: '美甲', icon: '💅', color: '#E91E63', isExpense: true, sortOrder: 8, l10nKey: 'catSubClothingManicure'),
      CategorySeed(name: '饰品', icon: '💎', color: '#E91E63', isExpense: true, sortOrder: 9, l10nKey: 'catSubClothingJewelry'),
      CategorySeed(name: '配件', icon: '🧣', color: '#E91E63', isExpense: true, sortOrder: 10, l10nKey: 'catSubClothingAccessories'),
    ],
  ),
  CategorySeed(
    name: '日用百货', icon: '🛒', color: '#795548', isExpense: true, sortOrder: 5, l10nKey: 'catExpenseDaily',
    children: [
      CategorySeed(name: '日用品', icon: '🧴', color: '#795548', isExpense: true, sortOrder: 1, l10nKey: 'catSubDailyNecessities'),
      CategorySeed(name: '清洁用品', icon: '🧹', color: '#795548', isExpense: true, sortOrder: 2, l10nKey: 'catSubDailyCleaning'),
      CategorySeed(name: '厨房用品', icon: '🍳', color: '#795548', isExpense: true, sortOrder: 3, l10nKey: 'catSubDailyKitchen'),
      CategorySeed(name: '家居装饰', icon: '🪴', color: '#795548', isExpense: true, sortOrder: 4, l10nKey: 'catSubDailyDecor'),
      CategorySeed(name: '收纳用品', icon: '📦', color: '#795548', isExpense: true, sortOrder: 5, l10nKey: 'catSubDailyStorage'),
      CategorySeed(name: '床上用品', icon: '🛏️', color: '#795548', isExpense: true, sortOrder: 6, l10nKey: 'catSubDailyBedding'),
      CategorySeed(name: '纸品', icon: '🧻', color: '#795548', isExpense: true, sortOrder: 7, l10nKey: 'catSubDailyTissue'),
    ],
  ),
  CategorySeed(
    name: '数码科技', icon: '📱', color: '#607D8B', isExpense: true, sortOrder: 6, l10nKey: 'catExpenseTech',
    children: [
      CategorySeed(name: '手机', icon: '📱', color: '#607D8B', isExpense: true, sortOrder: 1, l10nKey: 'catSubTechPhone'),
      CategorySeed(name: '电脑', icon: '💻', color: '#607D8B', isExpense: true, sortOrder: 2, l10nKey: 'catSubTechComputer'),
      CategorySeed(name: '配件', icon: '🎧', color: '#607D8B', isExpense: true, sortOrder: 3, l10nKey: 'catSubTechAccessories'),
      CategorySeed(name: '耗材', icon: '🖨️', color: '#607D8B', isExpense: true, sortOrder: 4, l10nKey: 'catSubTechConsumables'),
      CategorySeed(name: '存储设备', icon: '💾', color: '#607D8B', isExpense: true, sortOrder: 5, l10nKey: 'catSubTechStorage'),
    ],
  ),
  CategorySeed(
    name: '医疗健康', icon: '🏥', color: '#F44336', isExpense: true, sortOrder: 7, l10nKey: 'catExpenseMedical',
    children: [
      CategorySeed(name: '门诊挂号', icon: '🏥', color: '#F44336', isExpense: true, sortOrder: 1, l10nKey: 'catSubMedicalRegistration'),
      CategorySeed(name: '药品', icon: '💊', color: '#F44336', isExpense: true, sortOrder: 2, l10nKey: 'catSubMedicalMedicine'),
      CategorySeed(name: '住院', icon: '🛏️', color: '#F44336', isExpense: true, sortOrder: 3, l10nKey: 'catSubMedicalHospitalization'),
      CategorySeed(name: '体检', icon: '🩺', color: '#F44336', isExpense: true, sortOrder: 4, l10nKey: 'catSubMedicalCheckup'),
      CategorySeed(name: '口腔', icon: '🦷', color: '#F44336', isExpense: true, sortOrder: 5, l10nKey: 'catSubMedicalDental'),
      CategorySeed(name: '眼科', icon: '👁️', color: '#F44336', isExpense: true, sortOrder: 6, l10nKey: 'catSubMedicalEyeCare'),
      CategorySeed(name: '疫苗', icon: '💉', color: '#F44336', isExpense: true, sortOrder: 7, l10nKey: 'catSubMedicalVaccine'),
      CategorySeed(name: '保健养生', icon: '🧘', color: '#F44336', isExpense: true, sortOrder: 8, l10nKey: 'catSubMedicalWellness'),
      CategorySeed(name: '健身运动', icon: '🏋️', color: '#F44336', isExpense: true, sortOrder: 9, l10nKey: 'catSubMedicalFitness'),
    ],
  ),
  CategorySeed(
    name: '教育学习', icon: '📚', color: '#00BCD4', isExpense: true, sortOrder: 8, l10nKey: 'catExpenseEducation',
    children: [
      CategorySeed(name: '书籍', icon: '📖', color: '#00BCD4', isExpense: true, sortOrder: 1, l10nKey: 'catSubEducationBooks'),
      CategorySeed(name: '学费', icon: '🎓', color: '#00BCD4', isExpense: true, sortOrder: 2, l10nKey: 'catSubEducationTuition'),
      CategorySeed(name: '培训费', icon: '📝', color: '#00BCD4', isExpense: true, sortOrder: 3, l10nKey: 'catSubEducationTraining'),
      CategorySeed(name: '考试费', icon: '📋', color: '#00BCD4', isExpense: true, sortOrder: 4, l10nKey: 'catSubEducationExam'),
      CategorySeed(name: '在线课程', icon: '💻', color: '#00BCD4', isExpense: true, sortOrder: 5, l10nKey: 'catSubEducationOnlineCourse'),
      CategorySeed(name: '文具用品', icon: '✏️', color: '#00BCD4', isExpense: true, sortOrder: 6, l10nKey: 'catSubEducationStationery'),
    ],
  ),
  CategorySeed(
    name: '休闲娱乐', icon: '🎬', color: '#4CAF50', isExpense: true, sortOrder: 9, l10nKey: 'catExpenseEntertainment',
    children: [
      CategorySeed(name: '电影', icon: '🎬', color: '#4CAF50', isExpense: true, sortOrder: 1, l10nKey: 'catSubEntertainmentMovies'),
      CategorySeed(name: 'KTV', icon: '🎤', color: '#4CAF50', isExpense: true, sortOrder: 2, l10nKey: 'catSubEntertainmentKtv'),
      CategorySeed(name: '游戏充值', icon: '🎮', color: '#4CAF50', isExpense: true, sortOrder: 3, l10nKey: 'catSubEntertainmentGaming'),
      CategorySeed(name: '会员订阅', icon: '🎵', color: '#4CAF50', isExpense: true, sortOrder: 4, l10nKey: 'catSubEntertainmentSubscription'),
      CategorySeed(name: '景点门票', icon: '🎢', color: '#4CAF50', isExpense: true, sortOrder: 5, l10nKey: 'catSubEntertainmentTickets'),
      CategorySeed(name: '酒店住宿', icon: '🏨', color: '#4CAF50', isExpense: true, sortOrder: 6, l10nKey: 'catSubEntertainmentHotel'),
      CategorySeed(name: '旅游', icon: '🧳', color: '#4CAF50', isExpense: true, sortOrder: 7, l10nKey: 'catSubEntertainmentTravel'),
      CategorySeed(name: '演出', icon: '🎪', color: '#4CAF50', isExpense: true, sortOrder: 8, l10nKey: 'catSubEntertainmentShow'),
      CategorySeed(name: '流媒体', icon: '📺', color: '#4CAF50', isExpense: true, sortOrder: 9, l10nKey: 'catSubEntertainmentStreaming'),
    ],
  ),
  CategorySeed(
    name: '社交人情', icon: '🎁', color: '#FF5722', isExpense: true, sortOrder: 10, l10nKey: 'catExpenseSocial',
    children: [
      CategorySeed(name: '礼物', icon: '🎁', color: '#FF5722', isExpense: true, sortOrder: 1, l10nKey: 'catSubSocialGift'),
      CategorySeed(name: '红包', icon: '🧧', color: '#FF5722', isExpense: true, sortOrder: 2, l10nKey: 'catSubSocialRedPacket'),
      CategorySeed(name: '份子钱', icon: '👰', color: '#FF5722', isExpense: true, sortOrder: 3, l10nKey: 'catSubSocialWeddingGift'),
      CategorySeed(name: '请客', icon: '🤝', color: '#FF5722', isExpense: true, sortOrder: 4, l10nKey: 'catSubSocialTreat'),
      CategorySeed(name: '生日聚会', icon: '🎂', color: '#FF5722', isExpense: true, sortOrder: 5, l10nKey: 'catSubSocialBirthday'),
      CategorySeed(name: '探望慰问', icon: '💐', color: '#FF5722', isExpense: true, sortOrder: 6, l10nKey: 'catSubSocialVisit'),
      CategorySeed(name: '孝敬长辈', icon: '🙏', color: '#FF5722', isExpense: true, sortOrder: 7, l10nKey: 'catSubSocialRespect'),
      CategorySeed(name: '慈善捐助', icon: '❤️', color: '#FF5722', isExpense: true, sortOrder: 8, l10nKey: 'catSubSocialCharity'),
    ],
  ),
  CategorySeed(
    name: '子女养育', icon: '👶', color: '#FF9800', isExpense: true, sortOrder: 11, l10nKey: 'catExpenseChildren',
    children: [
      CategorySeed(name: '奶粉辅食', icon: '🍼', color: '#FF9800', isExpense: true, sortOrder: 1, l10nKey: 'catSubChildrenFormula'),
      CategorySeed(name: '尿布用品', icon: '👶', color: '#FF9800', isExpense: true, sortOrder: 2, l10nKey: 'catSubChildrenDiapers'),
      CategorySeed(name: '学费', icon: '🎒', color: '#FF9800', isExpense: true, sortOrder: 3, l10nKey: 'catSubChildrenTuition'),
      CategorySeed(name: '兴趣班', icon: '🎨', color: '#FF9800', isExpense: true, sortOrder: 4, l10nKey: 'catSubChildrenHobby'),
      CategorySeed(name: '辅导班', icon: '📚', color: '#FF9800', isExpense: true, sortOrder: 5, l10nKey: 'catSubChildrenTutoring'),
      CategorySeed(name: '午托晚托', icon: '🏫', color: '#FF9800', isExpense: true, sortOrder: 6, l10nKey: 'catSubChildrenDaycare'),
      CategorySeed(name: '玩具', icon: '🎁', color: '#FF9800', isExpense: true, sortOrder: 7, l10nKey: 'catSubChildrenToys'),
    ],
  ),
  CategorySeed(
    name: '赡养长辈', icon: '👴', color: '#8D6E63', isExpense: true, sortOrder: 12, l10nKey: 'catExpenseElderly',
    children: [
      CategorySeed(name: '赡养费', icon: '💰', color: '#8D6E63', isExpense: true, sortOrder: 1, l10nKey: 'catSubElderlySupport'),
      CategorySeed(name: '营养品', icon: '🧴', color: '#8D6E63', isExpense: true, sortOrder: 2, l10nKey: 'catSubElderlyNutrition'),
      CategorySeed(name: '医疗费', icon: '🏥', color: '#8D6E63', isExpense: true, sortOrder: 3, l10nKey: 'catSubElderlyMedical'),
      CategorySeed(name: '孝敬金', icon: '🎁', color: '#8D6E63', isExpense: true, sortOrder: 4, l10nKey: 'catSubElderlyAllowance'),
    ],
  ),
  CategorySeed(
    name: '宠物', icon: '🐱', color: '#A1887F', isExpense: true, sortOrder: 13, l10nKey: 'catExpensePet',
    children: [
      CategorySeed(name: '宠物食品', icon: '🐾', color: '#A1887F', isExpense: true, sortOrder: 1, l10nKey: 'catSubPetFood'),
      CategorySeed(name: '宠物医疗', icon: '🏥', color: '#A1887F', isExpense: true, sortOrder: 2, l10nKey: 'catSubPetMedical'),
      CategorySeed(name: '宠物用品', icon: '🧸', color: '#A1887F', isExpense: true, sortOrder: 3, l10nKey: 'catSubPetSupplies'),
      CategorySeed(name: '宠物美容', icon: '✂️', color: '#A1887F', isExpense: true, sortOrder: 4, l10nKey: 'catSubPetGrooming'),
    ],
  ),
  CategorySeed(
    name: '工作办公', icon: '🏢', color: '#546E7A', isExpense: true, sortOrder: 14, l10nKey: 'catExpenseWork',
    children: [
      CategorySeed(name: '办公用品', icon: '🖊️', color: '#546E7A', isExpense: true, sortOrder: 1, l10nKey: 'catSubWorkOffice'),
      CategorySeed(name: '打印复印', icon: '📄', color: '#546E7A', isExpense: true, sortOrder: 2, l10nKey: 'catSubWorkPrinting'),
      CategorySeed(name: '快递物流', icon: '📦', color: '#546E7A', isExpense: true, sortOrder: 3, l10nKey: 'catSubWorkShipping'),
      CategorySeed(name: '差旅费', icon: '🧳', color: '#546E7A', isExpense: true, sortOrder: 4, l10nKey: 'catSubWorkTravel'),
    ],
  ),
  CategorySeed(
    name: '金融保险', icon: '🏦', color: '#37474F', isExpense: true, sortOrder: 15, l10nKey: 'catExpenseFinance',
    children: [
      CategorySeed(name: '保险费用', icon: '🛡️', color: '#37474F', isExpense: true, sortOrder: 1, l10nKey: 'catSubFinanceInsurance'),
      CategorySeed(name: '理财亏损', icon: '📉', color: '#37474F', isExpense: true, sortOrder: 2, l10nKey: 'catSubFinanceLoss'),
      CategorySeed(name: '手续费', icon: '💳', color: '#37474F', isExpense: true, sortOrder: 3, l10nKey: 'catSubFinanceFee'),
      CategorySeed(name: '贷款利息', icon: '📊', color: '#37474F', isExpense: true, sortOrder: 4, l10nKey: 'catSubFinanceLoanInterest'),
      CategorySeed(name: '税费', icon: '💸', color: '#37474F', isExpense: true, sortOrder: 5, l10nKey: 'catSubFinanceTax'),
      CategorySeed(name: '罚款', icon: '🚨', color: '#37474F', isExpense: true, sortOrder: 6, l10nKey: 'catSubFinanceFine'),
    ],
  ),
  CategorySeed(
    name: '其他支出', icon: '🔧', color: '#78909C', isExpense: true, sortOrder: 16, l10nKey: 'catExpenseOther',
    children: [
      CategorySeed(name: '其他消费', icon: '❓', color: '#78909C', isExpense: true, sortOrder: 1, l10nKey: 'catSubOtherExpenseGeneral'),
      CategorySeed(name: '意外支出', icon: '💥', color: '#78909C', isExpense: true, sortOrder: 2, l10nKey: 'catSubOtherExpenseUnexpected'),
    ],
  ),
];

/// ==================== 收入分类 ====================
const incomeCategories = <CategorySeed>[
  CategorySeed(
    name: '工资薪酬', icon: '💼', color: '#4CAF50', isExpense: false, sortOrder: 1, l10nKey: 'catIncomeSalary',
    children: [
      CategorySeed(name: '基本工资', icon: '💰', color: '#4CAF50', isExpense: false, sortOrder: 1, l10nKey: 'catSubSalaryBase'),
      CategorySeed(name: '绩效奖金', icon: '🎯', color: '#4CAF50', isExpense: false, sortOrder: 2, l10nKey: 'catSubSalaryBonus'),
      CategorySeed(name: '加班费', icon: '💵', color: '#4CAF50', isExpense: false, sortOrder: 3, l10nKey: 'catSubSalaryOvertime'),
      CategorySeed(name: '年终奖', icon: '🎊', color: '#4CAF50', isExpense: false, sortOrder: 4, l10nKey: 'catSubSalaryYearEnd'),
      CategorySeed(name: '调薪补发', icon: '📈', color: '#4CAF50', isExpense: false, sortOrder: 5, l10nKey: 'catSubSalaryBackPay'),
      CategorySeed(name: '津贴补贴', icon: '🎖️', color: '#4CAF50', isExpense: false, sortOrder: 6, l10nKey: 'catSubSalaryAllowance'),
    ],
  ),
  CategorySeed(
    name: '投资理财', icon: '💹', color: '#2196F3', isExpense: false, sortOrder: 2, l10nKey: 'catIncomeInvestment',
    children: [
      CategorySeed(name: '基金收益', icon: '📊', color: '#2196F3', isExpense: false, sortOrder: 1, l10nKey: 'catSubInvestmentFund'),
      CategorySeed(name: '股票收益', icon: '📉', color: '#2196F3', isExpense: false, sortOrder: 2, l10nKey: 'catSubInvestmentStock'),
      CategorySeed(name: '利息收入', icon: '🏦', color: '#2196F3', isExpense: false, sortOrder: 3, l10nKey: 'catSubInvestmentInterest'),
      CategorySeed(name: '理财产品', icon: '💎', color: '#2196F3', isExpense: false, sortOrder: 4, l10nKey: 'catSubInvestmentWealthMgmt'),
      CategorySeed(name: '数字货币', icon: '🪙', color: '#2196F3', isExpense: false, sortOrder: 5, l10nKey: 'catSubInvestmentCrypto'),
      CategorySeed(name: '分红', icon: '🏠', color: '#2196F3', isExpense: false, sortOrder: 6, l10nKey: 'catSubInvestmentDividend'),
    ],
  ),
  CategorySeed(
    name: '副业兼职', icon: '🏢', color: '#00BCD4', isExpense: false, sortOrder: 3, l10nKey: 'catIncomeSideJob',
    children: [
      CategorySeed(name: '兼职收入', icon: '💻', color: '#00BCD4', isExpense: false, sortOrder: 1, l10nKey: 'catSubSideJobPartTime'),
      CategorySeed(name: '自由职业', icon: '🎨', color: '#00BCD4', isExpense: false, sortOrder: 2, l10nKey: 'catSubSideJobFreelance'),
      CategorySeed(name: '稿费版权', icon: '📸', color: '#00BCD4', isExpense: false, sortOrder: 3, l10nKey: 'catSubSideJobRoyalty'),
      CategorySeed(name: '佣金提成', icon: '🔗', color: '#00BCD4', isExpense: false, sortOrder: 4, l10nKey: 'catSubSideJobCommission'),
      CategorySeed(name: '销售收入', icon: '🛒', color: '#00BCD4', isExpense: false, sortOrder: 5, l10nKey: 'catSubSideJobSales'),
    ],
  ),
  CategorySeed(
    name: '红包馈赠', icon: '💝', color: '#E91E63', isExpense: false, sortOrder: 4, l10nKey: 'catIncomeGift',
    children: [
      CategorySeed(name: '红包收入', icon: '🧧', color: '#E91E63', isExpense: false, sortOrder: 1, l10nKey: 'catSubGiftRedPacket'),
      CategorySeed(name: '礼金馈赠', icon: '🎁', color: '#E91E63', isExpense: false, sortOrder: 2, l10nKey: 'catSubGiftPresent'),
      CategorySeed(name: '节日红包', icon: '🎉', color: '#E91E63', isExpense: false, sortOrder: 3, l10nKey: 'catSubGiftFestival'),
    ],
  ),
  CategorySeed(
    name: '报销退款', icon: '💸', color: '#9C27B0', isExpense: false, sortOrder: 5, l10nKey: 'catIncomeRefund',
    children: [
      CategorySeed(name: '报销到账', icon: '🧾', color: '#9C27B0', isExpense: false, sortOrder: 1, l10nKey: 'catSubRefundReimbursement'),
      CategorySeed(name: '退款收入', icon: '📦', color: '#9C27B0', isExpense: false, sortOrder: 2, l10nKey: 'catSubRefundReturn'),
      CategorySeed(name: '医保报销', icon: '🏥', color: '#9C27B0', isExpense: false, sortOrder: 3, l10nKey: 'catSubRefundMedical'),
      CategorySeed(name: '保险理赔', icon: '🛡️', color: '#9C27B0', isExpense: false, sortOrder: 4, l10nKey: 'catSubRefundInsurance'),
    ],
  ),
  CategorySeed(
    name: '租金资产', icon: '🏠', color: '#FF9800', isExpense: false, sortOrder: 6, l10nKey: 'catIncomeAsset',
    children: [
      CategorySeed(name: '房租收入', icon: '🏠', color: '#FF9800', isExpense: false, sortOrder: 1, l10nKey: 'catSubAssetRent'),
      CategorySeed(name: '闲置出售', icon: '🚗', color: '#FF9800', isExpense: false, sortOrder: 2, l10nKey: 'catSubAssetIdleSale'),
      CategorySeed(name: '二手交易', icon: '📱', color: '#FF9800', isExpense: false, sortOrder: 3, l10nKey: 'catSubAssetSecondhand'),
      CategorySeed(name: '资产收益', icon: '💼', color: '#FF9800', isExpense: false, sortOrder: 4, l10nKey: 'catSubAssetProfit'),
    ],
  ),
  CategorySeed(
    name: '转账收入', icon: '💳', color: '#607D8B', isExpense: false, sortOrder: 7, l10nKey: 'catIncomeTransferIn',
    children: [
      CategorySeed(name: '银行转入', icon: '🏧', color: '#607D8B', isExpense: false, sortOrder: 1, l10nKey: 'catSubTransferInBank'),
      CategorySeed(name: '钱包转入', icon: '📱', color: '#607D8B', isExpense: false, sortOrder: 2, l10nKey: 'catSubTransferInWallet'),
      CategorySeed(name: '债务回收', icon: '🔄', color: '#607D8B', isExpense: false, sortOrder: 3, l10nKey: 'catSubTransferInDebt'),
    ],
  ),
  CategorySeed(
    name: '其他收入', icon: '🔧', color: '#78909C', isExpense: false, sortOrder: 8, l10nKey: 'catIncomeOther',
    children: [
      CategorySeed(name: '意外所得', icon: '🎰', color: '#78909C', isExpense: false, sortOrder: 1, l10nKey: 'catSubIncomeOtherWindfall'),
      CategorySeed(name: '政府补贴', icon: '🏛️', color: '#78909C', isExpense: false, sortOrder: 2, l10nKey: 'catSubIncomeOtherSubsidy'),
      CategorySeed(name: '未分类', icon: '❓', color: '#78909C', isExpense: false, sortOrder: 3, l10nKey: 'catSubIncomeOtherUncategorized'),
    ],
  ),
];

/// ==================== 其他分类 ====================
const otherCategories = <CategorySeed>[
  CategorySeed(
    name: '转账', icon: '💳', color: '#607D8B', isExpense: false, sortOrder: 1, l10nKey: 'catOtherTransfer',
    children: [
      CategorySeed(name: '银行卡转入', icon: '🏧', color: '#607D8B', isExpense: false, sortOrder: 1, l10nKey: 'catSubTransferBankIn'),
      CategorySeed(name: '银行卡转出', icon: '🏧', color: '#607D8B', isExpense: false, sortOrder: 2, l10nKey: 'catSubTransferBankOut'),
      CategorySeed(name: '钱包互转', icon: '📱', color: '#607D8B', isExpense: false, sortOrder: 3, l10nKey: 'catSubTransferWallet'),
      CategorySeed(name: '跨平台转入', icon: '💻', color: '#607D8B', isExpense: false, sortOrder: 4, l10nKey: 'catSubTransferCrossIn'),
      CategorySeed(name: '跨平台转出', icon: '💻', color: '#607D8B', isExpense: false, sortOrder: 5, l10nKey: 'catSubTransferCrossOut'),
    ],
  ),
  CategorySeed(
    name: '还款', icon: '🤝', color: '#F44336', isExpense: false, sortOrder: 2, l10nKey: 'catOtherRepayment',
    children: [
      CategorySeed(name: '信用卡还款', icon: '💳', color: '#F44336', isExpense: false, sortOrder: 1, l10nKey: 'catSubRepaymentCreditCard'),
      CategorySeed(name: '贷款还款', icon: '🏦', color: '#F44336', isExpense: false, sortOrder: 2, l10nKey: 'catSubRepaymentLoan'),
      CategorySeed(name: '借款归还', icon: '🤝', color: '#F44336', isExpense: false, sortOrder: 3, l10nKey: 'catSubRepaymentBorrowed'),
      CategorySeed(name: '借款借出', icon: '💰', color: '#F44336', isExpense: false, sortOrder: 4, l10nKey: 'catSubRepaymentLent'),
    ],
  ),
  CategorySeed(
    name: '人情往来', icon: '🎭', color: '#FF5722', isExpense: false, sortOrder: 3, l10nKey: 'catOtherSocial',
    children: [
      CategorySeed(name: '随礼份子钱', icon: '💐', color: '#FF5722', isExpense: false, sortOrder: 1, l10nKey: 'catSubOtherSocialGift'),
      CategorySeed(name: '婚丧嫁娶', icon: '🎊', color: '#FF5722', isExpense: false, sortOrder: 2, l10nKey: 'catSubOtherSocialWedding'),
      CategorySeed(name: '生日聚会', icon: '🎂', color: '#FF5722', isExpense: false, sortOrder: 3, l10nKey: 'catSubOtherSocialBirthday'),
      CategorySeed(name: '节日红包往来', icon: '🧧', color: '#FF5722', isExpense: false, sortOrder: 4, l10nKey: 'catSubOtherSocialFestival'),
    ],
  ),
];
