import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/core/services/excel_export_service.dart';
import 'package:marine_analytics_platform/core/theme/app_theme.dart';
import 'package:marine_analytics_platform/data/models/waste_entry_model.dart';
import 'package:marine_analytics_platform/global.dart';
import 'package:marine_analytics_platform/presentation/blocs/waste_entry/waste_entry_bloc.dart';
import 'package:marine_analytics_platform/presentation/views/history/widgets/create_multiple_waste_entries_sheet_v2.dart';
import 'package:marine_analytics_platform/presentation/views/history/widgets/create_waste_entry_sheet.dart';
import 'package:marine_analytics_platform/presentation/views/history/widgets/edit_waste_entry_sheet.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WasteEntryBloc()..add(const LoadWasteEntries()),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatefulWidget {
  const _HistoryView();

  @override
  State<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<_HistoryView> {
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    return BlocListener<WasteEntryBloc, WasteEntryState>(
      listener: (context, state) {
        final overlay = context.loaderOverlay;
        if (state.status == Status.loading && state.entries.isNotEmpty) {
          overlay.show();
        } else {
          overlay.hide();
        }

        if (state.status == Status.success && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state.status == Status.fail && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Waste History"),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showDateRangePicker(context),
            ),
            IconButton(
              icon: const Icon(Icons.file_download),
              onPressed: () => _showExportDialog(context),
            ),
          ],
        ),
        body: BlocBuilder<WasteEntryBloc, WasteEntryState>(
          builder: (context, state) {
            // Filter entries by date range
            final filteredEntries = _selectedDateRange == null
                ? state.entries
                : state.entries.where((entry) {
                    if (entry.date == null) return false;
                    final entryDate = entry.date!;
                    return entryDate.isAfter(
                          _selectedDateRange!.start.subtract(
                            const Duration(days: 1),
                          ),
                        ) &&
                        entryDate.isBefore(
                          _selectedDateRange!.end.add(const Duration(days: 1)),
                        );
                  }).toList();

            if (filteredEntries.isEmpty) {
              if (state.status == Status.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedDateRange == null
                          ? 'No waste data yet'
                          : 'No entries found in selected date range',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    if (_selectedDateRange != null) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () =>
                            setState(() => _selectedDateRange = null),
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear Filter'),
                      ),
                    ],
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Filter indicator
                if (_selectedDateRange != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.filter_list,
                          size: 20,
                          color: AppTheme.primaryGreen,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Filtered: ${_formatDateShort(_selectedDateRange!.start)} - ${_formatDateShort(_selectedDateRange!.end)} (${filteredEntries.length} entries)',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () =>
                              setState(() => _selectedDateRange = null),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<WasteEntryBloc>().add(
                        const LoadWasteEntries(),
                      );
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: filteredEntries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final entry = filteredEntries[index];
                        return _WasteEntryTile(entry: entry);
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.extended(
              onPressed: () => _showAddMultipleSheet(context),
              heroTag: 'add_multiple',
              label: const Text('Multiple types'),
              icon: const Icon(Icons.add_circle_outline),
              backgroundColor: AppTheme.primaryGreen,
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              onPressed: () => _showAddSingleSheet(context),
              heroTag: 'add_single',
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSingleSheet(BuildContext context) async {
    final bloc = context.read<WasteEntryBloc>();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return BlocProvider.value(
          value: bloc,
          child: const CreateWasteEntrySheet(),
        );
      },
    );
  }

  void _showAddMultipleSheet(BuildContext context) async {
    final bloc = context.read<WasteEntryBloc>();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return BlocProvider.value(
          value: bloc,
          child: const CreateMultipleWasteEntriesSheetV2(),
        );
      },
    );
  }

  void _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _showExportDialog(BuildContext context) {
    final state = context.read<WasteEntryBloc>().state;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.file_download, color: AppTheme.primaryGreen),
            SizedBox(width: 12),
            Text('Export to Excel'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select export period:'),
            const SizedBox(height: 16),
            _ExportPeriodButton(
              label: 'Today',
              icon: Icons.today,
              onTap: () {
                Navigator.pop(dialogContext);
                _exportData(context, 'daily', DateTime.now(), DateTime.now());
              },
            ),
            _ExportPeriodButton(
              label: 'This Week',
              icon: Icons.date_range,
              onTap: () {
                Navigator.pop(dialogContext);
                _exportData(context, 'weekly', _getWeekStart(), DateTime.now());
              },
            ),
            _ExportPeriodButton(
              label: 'This Month',
              icon: Icons.calendar_month,
              onTap: () {
                Navigator.pop(dialogContext);
                _exportData(
                  context,
                  'monthly',
                  _getMonthStart(),
                  DateTime.now(),
                );
              },
            ),
            _ExportPeriodButton(
              label: 'This Year',
              icon: Icons.calendar_today,
              onTap: () {
                Navigator.pop(dialogContext);
                _exportData(context, 'yearly', _getYearStart(), DateTime.now());
              },
            ),
            _ExportPeriodButton(
              label: 'Custom Range',
              icon: Icons.date_range_outlined,
              onTap: () {
                Navigator.pop(dialogContext);
                _exportCustomRange(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(
    BuildContext context,
    String period,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (!context.mounted) return;
      context.loaderOverlay.show();

      final state = context.read<WasteEntryBloc>().state;
      final entries = state.entries.where((entry) {
        if (entry.date == null) return false;
        return entry.date!.isAfter(
              startDate.subtract(const Duration(days: 1)),
            ) &&
            entry.date!.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();

      if (entries.isEmpty) {
        throw Exception('No data found for selected period');
      }

      await ExcelExportService().exportToExcel(
        entries: entries,
        period: period,
        startDate: startDate,
        endDate: endDate,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Excel file exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (context.mounted) {
        context.loaderOverlay.hide();
      }
    }
  }

  Future<void> _exportCustomRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null && context.mounted) {
      await _exportData(context, 'custom', picked.start, picked.end);
    }
  }

  DateTime _getWeekStart() {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1));
  }

  DateTime _getMonthStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  DateTime _getYearStart() {
    final now = DateTime.now();
    return DateTime(now.year, 1, 1);
  }

  String _formatDateShort(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _WasteEntryTile extends StatelessWidget {
  final WasteEntryModel entry;

  const _WasteEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.wasteTypeName ?? 'Waste Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: AppTheme.primaryGreen,
                onPressed: () => _showEditDialog(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Colors.red,
                onPressed: () => _showDeleteDialog(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.balance,
            label: 'Quantity',
            value: _formatQuantity(entry.quantity, entry.wasteTypeUnit),
          ),
          _InfoRow(
            icon: Icons.factory,
            label: 'Department',
            value: entry.departmentName ?? '--',
          ),
          _InfoRow(
            icon: Icons.map,
            label: 'Area',
            value: entry.areaName ?? '--',
          ),
          _InfoRow(
            icon: Icons.today,
            label: 'Day',
            value: _formatDate(entry.date),
          ),
          if ((entry.qrCode ?? '').isNotEmpty)
            _InfoRow(icon: Icons.qr_code, label: 'QR', value: entry.qrCode!),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) async {
    final bloc = context.read<WasteEntryBloc>();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: EditWasteEntrySheet(entry: entry),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 12),
            Text('Delete Entry'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this waste entry?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                print('🗑️ Deleting entry ${entry.id}');
                await supabase
                    .from('waste_entries')
                    .delete()
                    .eq('id', entry.id);
                print('✅ Delete successful');

                if (context.mounted) {
                  context.read<WasteEntryBloc>().add(const LoadWasteEntries());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Waste entry deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                Navigator.pop(dialogContext);
              } catch (e) {
                print('❌ Delete error: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting entry: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  static String _formatQuantity(double? quantity, String? unit) {
    if (quantity == null) return '--';
    final isInt = quantity % 1 == 0;
    final value = isInt
        ? quantity.toStringAsFixed(0)
        : quantity.toStringAsFixed(2);
    return unit != null && unit.isNotEmpty ? '$value $unit' : value;
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return '--';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(
            '$label:',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _ExportPeriodButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ExportPeriodButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryGreen),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
