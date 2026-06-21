import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../../config/database/app_database.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../../category/domain/repositories/category_repository.dart';

/// Excel 导入导出服务
class ExcelService {
  final TransactionRepository _txnRepo;
  final CategoryRepository _catRepo;

  ExcelService(this._txnRepo, this._catRepo);

  /// Excel 表头列名（中英双语，方便用户理解）
  static const List<String> headers = [
    '金额 (Amount)',
    '类型 (Type)',
    '描述 (Description)',
    '备注 (Note)',
    '分类 (Category)',
    '父分类 (Parent Category)',
    '日期 (Date)',
    '支付方式 (Pay Method)',
  ];

  /// 导出账本交易到 Excel 文件，返回文件路径
  Future<String> exportToExcel(int bookId) async {
    final txns = await _txnRepo.getAll(bookId);
    final catMap = await _buildCategoryMap();

    final excel = Excel.createExcel();
    final sheetName = 'Transactions';
    // 删除默认 Sheet1
    excel.delete('Sheet1');
    final sheet = excel[sheetName];

    // 写表头
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#4472C4'),
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        );
    }

    // 写数据行
    for (var i = 0; i < txns.length; i++) {
      final txn = txns[i];
      final cat = catMap[txn.categoryId];
      final parentCat = txn.parentCategoryId != null ? catMap[txn.parentCategoryId] : null;

      final row = i + 1;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = DoubleCellValue(txn.amount);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = TextCellValue(txn.type);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          .value = TextCellValue(txn.description);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          .value = TextCellValue(txn.note ?? '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
          .value = TextCellValue(cat?.name ?? '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
          .value = TextCellValue(parentCat?.name ?? '');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row))
          .value = TextCellValue(_formatDate(txn.transactionDate));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row))
          .value = TextCellValue(txn.payMethod ?? '');
    }

    // 自动调整列宽提示（excel 包不支持自动列宽，设置合理默认宽度）
    for (var i = 0; i < headers.length; i++) {
      sheet.setColumnWidth(i, 18.0);
    }

    // 保存文件
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toString().replaceAll(RegExp(r'[: .]'), '').substring(0, 14);
    final filePath = p.join(dir.path, 'wo_account_export_$timestamp.xlsx');
    final bytes = excel.save();
    if (bytes != null) {
      await File(filePath).writeAsBytes(bytes);
    }
    return filePath;
  }

  /// 从 Excel 文件导入交易，返回导入数量
  Future<int> importFromExcel(int bookId, String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    if (excel.tables.isEmpty) return 0;
    final sheet = excel.tables.values.first;
    if (sheet.maxRows < 2) return 0; // 只有表头或空表

    final catMap = await _buildCategoryNameMap();
    var imported = 0;

    // 从第 1 行开始（跳过表头）
    for (var row = 1; row < sheet.maxRows; row++) {
      final cells = sheet.row(row);
      if (cells.isEmpty) continue;

      final amount = _parseDouble(_cellString(cells, 0));
      if (amount == null || amount <= 0) continue;

      final type = _cellString(cells, 1).isNotEmpty
          ? _cellString(cells, 1).toLowerCase()
          : 'expense';
      final description = _cellString(cells, 2);
      final note = _cellString(cells, 3);
      final catName = _cellString(cells, 4);
      final parentCatName = _cellString(cells, 5);
      final dateStr = _cellString(cells, 6);
      final payMethod = _cellString(cells, 7);

      if (description.isEmpty && catName.isEmpty) continue;

      // 匹配分类
      int categoryId = 1; // 默认分类
      int? parentCategoryId;
      if (catName.isNotEmpty) {
        final cat = catMap[catName];
        if (cat != null) {
          categoryId = cat.id;
          parentCategoryId = cat.parentId;
        }
      }
      // 如果指定了父分类且子分类未匹配到父分类
      if (parentCatName.isNotEmpty && parentCategoryId == null) {
        final parentCat = catMap[parentCatName];
        if (parentCat != null) parentCategoryId = parentCat.id;
      }

      final txnDate = _parseDate(dateStr) ?? DateTime.now();
      final effectiveDesc = description.isNotEmpty ? description : catName;

      await _txnRepo.insert(TransactionsCompanion.insert(
        amount: amount,
        type: drift.Value(type),
        description: effectiveDesc,
        note: drift.Value(note.isNotEmpty ? note : null),
        categoryId: categoryId,
        parentCategoryId: drift.Value(parentCategoryId),
        transactionDate: txnDate,
        payMethod: drift.Value(payMethod.isNotEmpty ? payMethod : null),
        accountBookId: bookId,
      ));
      imported++;
    }
    return imported;
  }

  /// 获取 Excel 格式说明文本
  static String getFormatDescription() {
    return '''
Excel 导入格式说明：

1. 第一行为表头，从第二行开始为数据
2. 各列含义：
   A列: 金额 (Amount) — 必填，正数
   B列: 类型 (Type) — expense/income/other，默认 expense
   C列: 描述 (Description) — 交易描述
   D列: 备注 (Note) — 可选补充备注
   E列: 分类 (Category) — 分类名称，需与系统分类一致
   F列: 父分类 (Parent Category) — 可选父分类名称
   G列: 日期 (Date) — 格式 yyyy-MM-dd HH:mm 或 yyyy-MM-dd
   H列: 支付方式 (Pay Method) — cash/wechat/alipay/card

3. 注意事项：
   • 金额必须为正数，类型决定收入/支出
   • 分类名称不存在时将归入默认分类
   • 日期为空时默认为当前时间
   • 空行会自动跳过
''';
  }

  /// 构建 id → category 映射
  Future<Map<int, Category>> _buildCategoryMap() async {
    final cats = await _catRepo.getAll();
    return {for (final c in cats) c.id: c};
  }

  /// 构建 name → category 映射
  Future<Map<String, Category>> _buildCategoryNameMap() async {
    final cats = await _catRepo.getAll();
    return {for (final c in cats) c.name: c};
  }

  String _formatDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  String _cellString(List<Data?> cells, int index) {
    if (index >= cells.length) return '';
    final cell = cells[index];
    if (cell == null || cell.value == null) return '';
    return cell.value.toString().trim();
  }

  double? _parseDouble(String s) {
    if (s.isEmpty) return null;
    return double.tryParse(s.replaceAll(',', ''));
  }

  DateTime? _parseDate(String s) {
    if (s.isEmpty) return null;
    // 尝试 yyyy-MM-dd HH:mm
    try {
      return DateTime.parse(s);
    } catch (_) {}
    // 尝试 yyyy-MM-dd
    try {
      final parts = s.split('-');
      if (parts.length == 3) {
        return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      }
    } catch (_) {}
    return null;
  }
}
