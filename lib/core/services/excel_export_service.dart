import 'dart:io';
import 'package:excel/excel.dart';
import 'package:marine_analytics_platform/data/models/waste_entry_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExcelExportService {
  static final ExcelExportService _instance = ExcelExportService._internal();
  factory ExcelExportService() => _instance;
  ExcelExportService._internal();

  /// Export waste entries to Excel file
  Future<void> exportToExcel({
    required List<WasteEntryModel> entries,
    required String period, // 'daily', 'weekly', 'monthly', 'yearly'
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      print('📊 Exporting ${entries.length} entries to Excel...');

      // Create Excel workbook
      final excel = Excel.createExcel();
      final sheet = excel['Waste Report'];

      // Style for header
      final headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#4CAF50'),
        fontColorHex: ExcelColor.white,
      );

      // Add headers
      final headers = [
        'Date',
        'Area',
        'Department',
        'Waste Type',
        'Quantity',
        'Unit',
        'QR Code',
        'Created At',
      ];

      for (var i = 0; i < headers.length; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }

      // Add data rows
      for (var i = 0; i < entries.length; i++) {
        final entry = entries[i];
        final rowIndex = i + 1;

        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          _formatDate(entry.date),
        );

        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          entry.areaName ?? '-',
        );

        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          entry.departmentName ?? '-',
        );

        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          entry.wasteTypeName ?? '-',
        );

        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex),
            )
            .value = DoubleCellValue(
          entry.quantity,
        );

        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          entry.wasteTypeUnit ?? 'kg',
        );

        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          entry.qrCode ?? '-',
        );

        sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          _formatDateTime(entry.createdAt),
        );
      }

      // Add summary section
      final summaryRowIndex = entries.length + 2;
      sheet
          .cell(
            CellIndex.indexByColumnRow(
              columnIndex: 0,
              rowIndex: summaryRowIndex,
            ),
          )
          .value = TextCellValue(
        'SUMMARY',
      );

      sheet
          .cell(
            CellIndex.indexByColumnRow(
              columnIndex: 0,
              rowIndex: summaryRowIndex + 1,
            ),
          )
          .value = TextCellValue(
        'Total Entries:',
      );
      sheet
          .cell(
            CellIndex.indexByColumnRow(
              columnIndex: 1,
              rowIndex: summaryRowIndex + 1,
            ),
          )
          .value = IntCellValue(
        entries.length,
      );

      sheet
          .cell(
            CellIndex.indexByColumnRow(
              columnIndex: 0,
              rowIndex: summaryRowIndex + 2,
            ),
          )
          .value = TextCellValue(
        'Total Quantity:',
      );
      final totalQuantity = entries.fold<double>(
        0,
        (sum, entry) => sum + entry.quantity,
      );
      sheet
          .cell(
            CellIndex.indexByColumnRow(
              columnIndex: 1,
              rowIndex: summaryRowIndex + 2,
            ),
          )
          .value = DoubleCellValue(
        totalQuantity,
      );

      sheet
          .cell(
            CellIndex.indexByColumnRow(
              columnIndex: 0,
              rowIndex: summaryRowIndex + 3,
            ),
          )
          .value = TextCellValue(
        'Period:',
      );
      sheet
          .cell(
            CellIndex.indexByColumnRow(
              columnIndex: 1,
              rowIndex: summaryRowIndex + 3,
            ),
          )
          .value = TextCellValue(
        '${_formatDate(startDate)} - ${_formatDate(endDate)}',
      );

      // Save file
      final fileName =
          'waste_report_${period}_${_formatDateForFile(startDate)}_${_formatDateForFile(endDate)}.xlsx';
      final fileBytes = excel.encode();

      if (fileBytes == null) {
        throw Exception('Failed to encode Excel file');
      }

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$fileName';

      // Write file
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      print('✅ Excel file created: $filePath');

      // Share file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Waste Report - $period',
        text:
            'Waste report from ${_formatDate(startDate)} to ${_formatDate(endDate)}',
      );

      print('✅ Excel file shared successfully');
    } catch (e) {
      print('❌ Error exporting to Excel: $e');
      rethrow;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return '-';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  String _formatDateForFile(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '${year}${month}${day}';
  }
}
