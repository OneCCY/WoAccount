import 'package:wo_account/l10n/app_localizations.dart';
import '../../config/database/app_database.dart';

/// Returns the localized display name for a [Category].
///
/// If the category has a non-null [l10nKey] that maps to a known
/// [AppLocalizations] getter, the translated name is returned.
/// Otherwise, falls back to [Category.name].
String getCategoryDisplayName(Category category, AppLocalizations l10n) {
  final key = category.l10nKey;
  if (key == null) return category.name;
  return _l10nMap[key]?.call(l10n) ?? category.name;
}

final Map<String, String Function(AppLocalizations)> _l10nMap = {
  // Expense
  'catExpenseFood': (l) => l.catExpenseFood,
  'catExpenseTransport': (l) => l.catExpenseTransport,
  'catExpenseHousing': (l) => l.catExpenseHousing,
  'catExpenseClothing': (l) => l.catExpenseClothing,
  'catExpenseDaily': (l) => l.catExpenseDaily,
  'catExpenseTech': (l) => l.catExpenseTech,
  'catExpenseMedical': (l) => l.catExpenseMedical,
  'catExpenseEducation': (l) => l.catExpenseEducation,
  'catExpenseEntertainment': (l) => l.catExpenseEntertainment,
  'catExpenseSocial': (l) => l.catExpenseSocial,
  'catExpenseChildren': (l) => l.catExpenseChildren,
  'catExpenseElderly': (l) => l.catExpenseElderly,
  'catExpensePet': (l) => l.catExpensePet,
  'catExpenseWork': (l) => l.catExpenseWork,
  'catExpenseFinance': (l) => l.catExpenseFinance,
  'catExpenseOther': (l) => l.catExpenseOther,
  // Income
  'catIncomeSalary': (l) => l.catIncomeSalary,
  'catIncomeInvestment': (l) => l.catIncomeInvestment,
  'catIncomeSideJob': (l) => l.catIncomeSideJob,
  'catIncomeGift': (l) => l.catIncomeGift,
  'catIncomeRefund': (l) => l.catIncomeRefund,
  'catIncomeAsset': (l) => l.catIncomeAsset,
  'catIncomeTransferIn': (l) => l.catIncomeTransferIn,
  'catIncomeOther': (l) => l.catIncomeOther,
  // Other
  'catOtherTransfer': (l) => l.catOtherTransfer,
  'catOtherRepayment': (l) => l.catOtherRepayment,
  'catOtherSocial': (l) => l.catOtherSocial,
};
