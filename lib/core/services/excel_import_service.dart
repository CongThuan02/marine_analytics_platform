import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:marine_analytics_platform/core/services/data_resolver_service.dart';
import 'package:marine_analytics_platform/data/models/waste_entry_model.dart';
import 'package:path_provider/path_provider.dart';

class ExcelImportService {
  static const String templateFileName = 'mau_import_chat_thai.xlsx';
  final _dataResolver = DataResolverService();

  /// Tạo file Excel mẫu để import
  Future<String> createTemplateFile() async {
    final excel = Excel.createExcel();
    final sheet = excel['Mẫu Import'];

    // Xóa sheet mặc định
    excel.delete('Sheet1');

    // Tạo header
    final headers = [
      'Loại chất thải',
      'Số lượng',
      'Đơn vị',
      'Phòng ban',
      'Khu vực',
      'Ngày (dd/mm/yyyy)',
      'Mã QR (tùy chọn)',
      'Ghi chú (tùy chọn)',
    ];

    // Thêm header vào sheet
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.lightGreen,
      );
    }

    // Đặt định dạng cho cột số lượng (cột B) để tránh hiểu nhầm thành ngày
    for (int row = 1; row <= 100; row++) {
      // Format 100 dòng đầu
      final quantityCell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row),
      );
      quantityCell.cellStyle = CellStyle(
        numberFormat:
            NumFormat.standard_2, // Định dạng số với 2 chữ số thập phân
      );
    }

    // Thêm dữ liệu mẫu
    final sampleData = [
      [
        'Nhựa',
        '10.5',
        'kg',
        'Phòng Kỹ thuật',
        'Khu A',
        '15/12/2024',
        'QR001',
        'Mẫu dữ liệu 1',
      ],
      [
        'Giấy',
        '5.2',
        'kg',
        'Phòng Hành chính',
        'Khu B',
        '15/12/2024',
        'QR002',
        'Mẫu dữ liệu 2',
      ],
      [
        'Kim loại',
        '8.0',
        'kg',
        'Phòng Sản xuất',
        'Khu C',
        '15/12/2024',
        '',
        'Mẫu dữ liệu 3',
      ],
    ];

    for (int row = 0; row < sampleData.length; row++) {
      for (int col = 0; col < sampleData[row].length; col++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1),
        );

        // Xử lý đặc biệt cho cột số lượng (cột 1)
        if (col == 1) {
          // Chuyển string thành số để tránh hiểu nhầm thành ngày
          final numberValue = double.tryParse(sampleData[row][col]);
          if (numberValue != null) {
            cell.value = DoubleCellValue(numberValue);
          } else {
            cell.value = TextCellValue(sampleData[row][col]);
          }
        } else {
          cell.value = TextCellValue(sampleData[row][col]);
        }
      }
    }

    // Thêm ghi chú hướng dẫn
    final noteCell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: 0,
        rowIndex: sampleData.length + 2,
      ),
    );
    noteCell.value = TextCellValue(
      'LƯU Ý: Cột "Số lượng" phải chứa số (VD: 10.5), không được để trống',
    );
    noteCell.cellStyle = CellStyle(italic: true, fontColorHex: ExcelColor.red);

    // Tự động điều chỉnh độ rộng cột
    for (int i = 0; i < headers.length; i++) {
      sheet.setColumnWidth(i, 20);
    }

    // Lưu file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$templateFileName';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    return filePath;
  }

  /// Chọn và đọc file Excel để import
  Future<List<WasteEntryModel>> pickAndImportExcelFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        throw Exception('Không có file nào được chọn');
      }

      final file = result.files.first;
      if (file.bytes == null && file.path == null) {
        throw Exception('Không thể đọc file');
      }

      List<int> bytes;
      if (file.bytes != null) {
        bytes = file.bytes!;
      } else {
        final fileObj = File(file.path!);
        bytes = await fileObj.readAsBytes();
      }

      return await _parseExcelData(bytes);
    } catch (e) {
      if (e.toString().contains('MissingPluginException')) {
        throw Exception(
          'Chức năng chọn file chưa sẵn sàng. Vui lòng restart ứng dụng và thử lại.',
        );
      }
      throw Exception('Lỗi khi chọn file: $e');
    }
  }

  /// Phân tích dữ liệu từ file Excel
  Future<List<WasteEntryModel>> _parseExcelData(List<int> bytes) async {
    final excel = Excel.decodeBytes(bytes);
    final entries = <WasteEntryModel>[];

    // Lấy sheet đầu tiên
    final sheetName = excel.tables.keys.first;
    final sheet = excel.tables[sheetName];

    if (sheet == null || sheet.rows.isEmpty) {
      throw Exception('File Excel trống hoặc không hợp lệ');
    }

    // Bỏ qua header (dòng đầu tiên)
    for (int i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];

      print('DEBUG: Processing row ${i + 1}, cells: ${row.length}');

      // Kiểm tra dòng có dữ liệu không
      if (row.isEmpty || _isRowEmpty(row)) {
        print('DEBUG: Skipping empty row ${i + 1}');
        continue;
      }

      // Kiểm tra dòng có đủ dữ liệu cần thiết không
      if (!_hasRequiredData(row)) {
        print('DEBUG: Skipping row ${i + 1} - missing required data');
        continue;
      }

      try {
        final entry = _parseRowToWasteEntry(row, i + 1);
        if (entry != null) {
          entries.add(entry);
          print('DEBUG: Successfully parsed row ${i + 1}');
        }
      } catch (e) {
        throw Exception('Lỗi tại dòng ${i + 1}: $e');
      }
    }

    if (entries.isEmpty) {
      throw Exception('Không tìm thấy dữ liệu hợp lệ trong file');
    }

    return entries;
  }

  /// Chuyển đổi một dòng thành WasteEntryModel (chưa resolve IDs)
  WasteEntryModel? _parseRowToWasteEntry(List<Data?> row, int rowNumber) {
    // Kiểm tra các cột bắt buộc
    final wasteTypeName = _getCellValue(row, 0);
    final quantityStr = _getCellValue(row, 1);
    final unit = _getCellValue(row, 2);
    final departmentName = _getCellValue(row, 3);
    final areaName = _getCellValue(row, 4);
    final dateStr = _getCellValue(row, 5);

    if (wasteTypeName.isEmpty) {
      throw Exception('Loại chất thải không được để trống');
    }

    if (quantityStr.isEmpty) {
      throw Exception('Số lượng không được để trống');
    }

    // Chuyển đổi số lượng với xử lý thông minh
    final quantity = _parseNumber(quantityStr);
    if (quantity == null) {
      throw Exception(
        'Không thể chuyển đổi số lượng. Giá trị: "$quantityStr". Vui lòng đảm bảo cột B chứa số hợp lệ (VD: 10, 10.5, 10,5)',
      );
    }
    if (quantity <= 0) {
      throw Exception('Số lượng phải lớn hơn 0. Giá trị hiện tại: $quantity');
    }

    // Chuyển đổi ngày
    DateTime? date;
    if (dateStr.isNotEmpty) {
      print('DEBUG: Parsing date - Input: "$dateStr"');
      date = _parseDate(dateStr);
      if (date == null) {
        throw Exception(
          'Định dạng ngày không hợp lệ. Giá trị: "$dateStr". Sử dụng dd/mm/yyyy (VD: 15/12/2024)',
        );
      }
      print('DEBUG: Parsed date successfully: $date');
    }

    // Các trường tùy chọn
    final qrCode = _getCellValue(row, 6);
    // final notes = _getCellValue(row, 7); // Chưa sử dụng

    return WasteEntryModel(
      id: '', // Sẽ được tạo khi lưu vào database
      userId: '', // Sẽ được set khi resolve
      departmentId: '', // Sẽ được resolve từ tên
      areaId: '', // Sẽ được resolve từ tên
      wasteTypeId: '', // Sẽ được resolve từ tên
      quantity: quantity,
      date: date ?? DateTime.now(),
      qrCode: qrCode.isNotEmpty ? qrCode : null,
      createdAt: DateTime.now(),
      wasteTypeName: wasteTypeName,
      wasteTypeUnit: unit.isNotEmpty ? unit : 'kg',
      departmentName: departmentName.isNotEmpty ? departmentName : null,
      areaName: areaName.isNotEmpty ? areaName : null,
    );
  }

  /// Lấy giá trị từ cell
  String _getCellValue(List<Data?> row, int index) {
    if (index >= row.length || row[index] == null) {
      return '';
    }

    final cell = row[index]!;
    if (cell.value == null) {
      return '';
    }

    // Xử lý các loại cell khác nhau từ Excel
    final cellValue = cell.value;
    String value;

    // Kiểm tra kiểu dữ liệu và xử lý phù hợp
    final cellType = cellValue.runtimeType.toString();

    if (cellType.contains('Date')) {
      // Excel hiểu nhầm dữ liệu thành ngày - xử lý khác nhau cho từng cột
      try {
        final dateStr = cellValue.toString();

        if (index == 1) {
          // Cột số lượng - lấy phần ngày làm số
          if (dateStr.contains('T') && dateStr.contains('-')) {
            final parts = dateStr.split('-');
            if (parts.length >= 3) {
              final dayPart = parts[2].split('T')[0];
              value = dayPart;
            } else {
              value = dateStr;
            }
          } else {
            // Thử truy cập thuộc tính day
            final dynamic dynamicValue = cellValue;
            if (dynamicValue.day != null) {
              value = dynamicValue.day.toString();
            } else {
              value = dateStr;
            }
          }
        } else if (index == 5) {
          // Cột ngày - chuyển về định dạng dd/mm/yyyy
          if (dateStr.contains('T') && dateStr.contains('-')) {
            // Parse ISO date: "2024-12-15T00:00:00.000Z"
            final isoDate = DateTime.parse(dateStr);
            value =
                '${isoDate.day.toString().padLeft(2, '0')}/${isoDate.month.toString().padLeft(2, '0')}/${isoDate.year}';
          } else {
            value = dateStr;
          }
        } else {
          // Các cột khác - xử lý bình thường
          value = dateStr;
        }
      } catch (e) {
        // Fallback: lấy string representation
        value = cellValue.toString();
      }
    } else {
      // Xử lý bình thường cho các kiểu khác
      value = cellValue.toString();
    }

    value = value.trim();

    // Debug: Log giá trị và kiểu dữ liệu để debug
    if (index == 1) {
      // Cột số lượng
      print(
        'DEBUG: Cột số lượng - Giá trị gốc: "$cellValue", Kiểu: ${cellValue.runtimeType}, Giá trị xử lý: "$value"',
      );
    } else if (index == 5) {
      // Cột ngày
      print(
        'DEBUG: Cột ngày - Giá trị gốc: "$cellValue", Kiểu: ${cellValue.runtimeType}, Giá trị xử lý: "$value"',
      );
    }

    return value;
  }

  /// Kiểm tra dòng có trống không
  bool _isRowEmpty(List<Data?> row) {
    for (final cell in row) {
      if (cell?.value != null && cell!.value.toString().trim().isNotEmpty) {
        return false;
      }
    }
    return true;
  }

  /// Kiểm tra dòng có đủ dữ liệu bắt buộc không (loại chất thải và số lượng)
  bool _hasRequiredData(List<Data?> row) {
    // Kiểm tra cột loại chất thải (cột 0)
    final wasteTypeName = _getCellValue(row, 0);
    print('DEBUG: Row waste type: "$wasteTypeName"');
    if (wasteTypeName.isEmpty) {
      return false;
    }

    // Kiểm tra cột số lượng (cột 1)
    final quantityStr = _getCellValue(row, 1);
    print('DEBUG: Row quantity: "$quantityStr"');
    if (quantityStr.isEmpty) {
      return false;
    }

    return true;
  }

  /// Parse số từ string với xử lý nhiều định dạng
  double? _parseNumber(String numberStr) {
    if (numberStr.isEmpty) return null;

    // Loại bỏ khoảng trắng
    String cleaned = numberStr.trim();

    // Xử lý các trường hợp đặc biệt
    if (cleaned.isEmpty ||
        cleaned == '-' ||
        cleaned == 'N/A' ||
        cleaned.toLowerCase() == 'null') {
      return null;
    }

    // Loại bỏ ký tự không phải số, dấu chấm, dấu phẩy
    cleaned = cleaned.replaceAll(RegExp(r'[^\d.,\-+]'), '');

    // Xử lý dấu phẩy và dấu chấm
    // Nếu có cả dấu phẩy và dấu chấm, xác định cái nào là phân cách thập phân
    if (cleaned.contains(',') && cleaned.contains('.')) {
      final lastComma = cleaned.lastIndexOf(',');
      final lastDot = cleaned.lastIndexOf('.');

      if (lastComma > lastDot) {
        // Dấu phẩy là phân cách thập phân (VD: 1.234,56)
        cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
      } else {
        // Dấu chấm là phân cách thập phân (VD: 1,234.56)
        cleaned = cleaned.replaceAll(',', '');
      }
    } else if (cleaned.contains(',')) {
      // Chỉ có dấu phẩy - có thể là phân cách nghìn hoặc thập phân
      final parts = cleaned.split(',');
      if (parts.length == 2 && parts[1].length <= 3) {
        // Có thể là thập phân (VD: 123,45)
        cleaned = cleaned.replaceAll(',', '.');
      } else {
        // Có thể là phân cách nghìn (VD: 1,234,567)
        cleaned = cleaned.replaceAll(',', '');
      }
    }

    // Thử parse
    final result = double.tryParse(cleaned);
    return result;
  }

  /// Chuyển đổi chuỗi ngày sang DateTime
  DateTime? _parseDate(String dateStr) {
    try {
      final cleaned = dateStr.trim();
      print('DEBUG: _parseDate input: "$cleaned"');

      // Hỗ trợ định dạng dd/mm/yyyy
      if (cleaned.contains('/')) {
        final parts = cleaned.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);

          // Validate ngày tháng
          if (day < 1 || day > 31 || month < 1 || month > 12 || year < 1900) {
            print(
              'DEBUG: Invalid date values - day: $day, month: $month, year: $year',
            );
            return null;
          }

          final result = DateTime(year, month, day);
          print('DEBUG: Parsed dd/mm/yyyy successfully: $result');
          return result;
        }
      }

      // Hỗ trợ định dạng yyyy-mm-dd
      if (cleaned.contains('-')) {
        final result = DateTime.parse(cleaned);
        print('DEBUG: Parsed yyyy-mm-dd successfully: $result');
        return result;
      }

      // Hỗ trợ định dạng dd-mm-yyyy
      if (cleaned.contains('-')) {
        final parts = cleaned.split('-');
        if (parts.length == 3 && parts[0].length <= 2) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);

          if (day < 1 || day > 31 || month < 1 || month > 12 || year < 1900) {
            return null;
          }

          final result = DateTime(year, month, day);
          print('DEBUG: Parsed dd-mm-yyyy successfully: $result');
          return result;
        }
      }

      print('DEBUG: No matching date format found');
      return null;
    } catch (e) {
      print('DEBUG: Date parsing error: $e');
      return null;
    }
  }

  /// Resolve IDs cho các entries
  Future<List<WasteEntryModel>> resolveEntryIds(
    List<WasteEntryModel> entries,
  ) async {
    final resolvedEntries = <WasteEntryModel>[];

    try {
      final userId = _dataResolver.getCurrentUserId();

      for (final entry in entries) {
        final ids = await _dataResolver.resolveWasteEntryIds(
          wasteTypeName: entry.wasteTypeName ?? '',
          unit: entry.wasteTypeUnit ?? 'kg',
          departmentName: entry.departmentName,
          areaName: entry.areaName,
        );

        final resolvedEntry = WasteEntryModel(
          id: entry.id,
          userId: userId,
          departmentId: ids['departmentId']!,
          areaId: ids['areaId']!,
          wasteTypeId: ids['wasteTypeId']!,
          quantity: entry.quantity,
          date: entry.date,
          qrCode: entry.qrCode,
          createdAt: entry.createdAt,
          wasteTypeName: entry.wasteTypeName,
          wasteTypeUnit: entry.wasteTypeUnit,
          departmentName: entry.departmentName,
          areaName: entry.areaName,
        );

        resolvedEntries.add(resolvedEntry);
      }

      return resolvedEntries;
    } catch (e) {
      throw Exception('Lỗi khi xử lý dữ liệu: $e');
    }
  }

  /// Validate dữ liệu trước khi import
  Future<Map<String, dynamic>> validateImportData(
    List<WasteEntryModel> entries,
  ) async {
    final errors = <String>[];
    final warnings = <String>[];
    final validEntries = <WasteEntryModel>[];

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final rowNumber = i + 2; // +2 vì bắt đầu từ dòng 1 và có header

      // Kiểm tra các trường bắt buộc
      if (entry.wasteTypeName == null || entry.wasteTypeName!.isEmpty) {
        errors.add('Dòng $rowNumber: Loại chất thải không được để trống');
        continue;
      }

      if (entry.quantity <= 0) {
        errors.add('Dòng $rowNumber: Số lượng phải lớn hơn 0');
        continue;
      }

      // Kiểm tra ngày
      if (entry.date.isAfter(DateTime.now())) {
        warnings.add('Dòng $rowNumber: Ngày trong tương lai');
      }

      validEntries.add(entry);
    }

    return {
      'errors': errors,
      'warnings': warnings,
      'validEntries': validEntries,
      'totalRows': entries.length,
      'validRows': validEntries.length,
    };
  }
}
