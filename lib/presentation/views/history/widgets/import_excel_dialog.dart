import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marine_analytics_platform/core/services/excel_import_service.dart';
import 'package:marine_analytics_platform/core/services/excel_import_service_v2.dart';
import 'package:marine_analytics_platform/core/theme/app_theme.dart';
import 'package:marine_analytics_platform/data/models/waste_entry_model.dart';
import 'package:marine_analytics_platform/presentation/blocs/waste_entry/waste_entry_bloc.dart';
import 'package:share_plus/share_plus.dart';

class ImportExcelDialog extends StatefulWidget {
  const ImportExcelDialog({super.key});

  @override
  State<ImportExcelDialog> createState() => _ImportExcelDialogState();
}

class _ImportExcelDialogState extends State<ImportExcelDialog> {
  final _importService = ExcelImportService();
  final _importServiceV2 = ExcelImportServiceV2();
  bool _isLoading = false;
  List<WasteEntryModel>? _previewData;
  Map<String, dynamic>? _validationResult;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.upload_file, color: AppTheme.primaryGreen, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Import dữ liệu từ Excel', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(height: 32),

            // Content
            Expanded(child: _previewData == null ? _buildInitialView() : _buildPreviewView()),

            // Actions
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hướng dẫn
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Hướng dẫn import',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('1. Tải file Excel mẫu'),
              const Text('2. Điền dữ liệu theo định dạng mẫu'),
              const Text('3. Chọn file để import'),
              const Text('4. Kiểm tra và xác nhận import'),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Buttons
        _buildDownloadTemplateButton(),
        const SizedBox(height: 16),
        _buildSelectFileButton(),
      ],
    );
  }

  Widget _buildPreviewView() {
    if (_validationResult == null) return const SizedBox();

    final errors = _validationResult!['errors'] as List<String>;
    final warnings = _validationResult!['warnings'] as List<String>;
    final validEntries = _validationResult!['validEntries'] as List<WasteEntryModel>;
    final totalRows = _validationResult!['totalRows'] as int;
    final validRows = _validationResult!['validRows'] as int;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thống kê
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              _buildStatItem('Tổng dòng', totalRows.toString(), Colors.blue),
              _buildStatItem('Hợp lệ', validRows.toString(), Colors.green),
              _buildStatItem('Lỗi', errors.length.toString(), Colors.red),
              _buildStatItem('Cảnh báo', warnings.length.toString(), Colors.orange),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Errors và Warnings
        if (errors.isNotEmpty || warnings.isNotEmpty) ...[
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (errors.isNotEmpty) ...[_buildMessageSection('Lỗi', errors, Colors.red), const SizedBox(height: 16)],
                if (warnings.isNotEmpty) ...[
                  _buildMessageSection('Cảnh báo', warnings, Colors.orange),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ],

        // Preview data
        if (validEntries.isNotEmpty) ...[
          const Text('Dữ liệu hợp lệ (5 dòng đầu):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: validEntries.take(5).length,
                itemBuilder: (context, index) {
                  final entry = validEntries[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.wasteTypeName ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${entry.quantity} ${entry.wasteTypeUnit}'),
                        if (entry.departmentName != null) Text('Phòng ban: ${entry.departmentName}'),
                        if (entry.areaName != null) Text('Khu vực: ${entry.areaName}'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: .min,
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600), maxLines: 2),
      ],
    );
  }

  Widget _buildMessageSection(String title, List<String> messages, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(title == 'Lỗi' ? Icons.error_outline : Icons.escalator_warning, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...messages.map(
            (message) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $message', style: TextStyle(fontSize: 13, color: color.withOpacity(0.8))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadTemplateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _downloadTemplate,
        icon: const Icon(Icons.download),
        label: const Text('Tải file Excel mẫu'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSelectFileButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _selectFile,
        icon: const Icon(Icons.file_upload),
        label: const Text('Chọn file Excel để import'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: AppTheme.primaryGreen),
          foregroundColor: AppTheme.primaryGreen,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_previewData == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))],
      );
    }

    final hasErrors = _validationResult?['errors']?.isNotEmpty ?? false;
    final validEntries = _validationResult?['validEntries'] as List<WasteEntryModel>? ?? [];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // TextButton(
        //   onPressed: () {
        //     setState(() {
        //       _previewData = null;
        //       _validationResult = null;
        //     });
        //   },
        //   child: const Text('Chọn file khác'),
        // ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        ElevatedButton(
          onPressed: hasErrors || validEntries.isEmpty || _isLoading ? null : _importData,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white),
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : FittedBox(child: Text('Thêm ${validEntries.length} bản ghi')),
        ),
      ],
    );
  }

  Future<void> _downloadTemplate() async {
    setState(() => _isLoading = true);

    try {
      String filePath;

      // Try V2 service first (simpler template)
      try {
        filePath = await _importServiceV2.createSimpleTemplateFile();
        print('✅ Used V2 template service');
      } catch (e) {
        print('❌ V2 template failed, trying original: $e');
        filePath = await _importService.createTemplateFile();
        print('✅ Used original template service');
      }

      await Share.shareXFiles([XFile(filePath)], text: 'File Excel mẫu import chất thải');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã tạo file mẫu thành công'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi tạo file mẫu: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectFile() async {
    setState(() => _isLoading = true);

    try {
      List<WasteEntryModel> entries;

      // Try original service first, fallback to V2 if numFmtId error
      try {
        entries = await _importService.pickAndImportExcelFile();
        print('✅ Used original import service');
      } catch (e) {
        print('❌ Original import failed: $e');

        if (e.toString().contains('numFmtId') || e.toString().contains('custom')) {
          print('🔄 Trying V2 import service for format issues...');
          entries = await _importServiceV2.pickAndImportExcelFile();
          print('✅ Used V2 import service');
        } else {
          rethrow;
        }
      }

      final validationResult = await _importService.validateImportData(entries);

      setState(() {
        _previewData = entries;
        _validationResult = validationResult;
      });
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Lỗi khi đọc file: $e';
        Color backgroundColor = Colors.red;

        if (e.toString().contains('restart ứng dụng')) {
          backgroundColor = Colors.orange;
          errorMessage = 'Vui lòng đóng và mở lại ứng dụng, sau đó thử lại chức năng import.';
        } else if (e.toString().contains('numFmtId') || e.toString().contains('custom')) {
          backgroundColor = Colors.orange;
          errorMessage = e.toString();
        }

        // Đóng dialog trước khi hiển thị lỗi
        Navigator.pop(context);

        // Hiển thị lỗi ở màn hình chính
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: backgroundColor,
            duration: const Duration(seconds: 10),
            action: SnackBarAction(
              label: 'Thử lại',
              textColor: Colors.white,
              onPressed: () {
                // Mở lại dialog import
                _showImportDialogAgain();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showImportDialogAgain() {
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(value: context.read<WasteEntryBloc>(), child: const ImportExcelDialog()),
    );
  }

  Future<void> _importData() async {
    if (_validationResult == null) return;

    setState(() => _isLoading = true);

    try {
      final validEntries = _validationResult!['validEntries'] as List<WasteEntryModel>;

      // Resolve IDs trước khi import - try V2 service first
      List<WasteEntryModel> resolvedEntries;
      try {
        resolvedEntries = await _importServiceV2.resolveEntryIds(validEntries);
        print('✅ Used V2 resolve service');
      } catch (e) {
        print('❌ V2 resolve failed, trying original: $e');
        resolvedEntries = await _importService.resolveEntryIds(validEntries);
        print('✅ Used original resolve service');
      }

      // Import tất cả entries cùng lúc
      context.read<WasteEntryBloc>().add(ImportMultipleWasteEntries(resolvedEntries));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã import thành công ${validEntries.length} bản ghi'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        // Đóng dialog trước khi hiển thị lỗi
        Navigator.pop(context);

        // Hiển thị lỗi ở màn hình chính
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi import: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: 'Thử lại',
              textColor: Colors.white,
              onPressed: () {
                _showImportDialogAgain();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
