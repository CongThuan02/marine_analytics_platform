import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/data/models/waste_entry_model.dart';
import 'package:marine_analytics_platform/presentation/blocs/waste_entry/waste_entry_bloc.dart';
import 'package:marine_analytics_platform/presentation/views/history/widgets/create_waste_entry_sheet.dart';

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

class _HistoryView extends StatelessWidget {
  const _HistoryView();

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
            SnackBar(content: Text(state.message!), backgroundColor: Colors.green),
          );
        }
        if (state.status == Status.fail && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Lịch sử chất thải")),
        body: BlocBuilder<WasteEntryBloc, WasteEntryState>(
          builder: (context, state) {
            if (state.entries.isEmpty) {
              if (state.status == Status.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              return const Center(child: Text('Chưa có dữ liệu chất thải'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<WasteEntryBloc>().add(const LoadWasteEntries());
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: state.entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final entry = state.entries[index];
                  return _WasteEntryTile(entry: entry);
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
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
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
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
          Text(
            entry.wasteTypeName ?? 'Loại chất thải',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.balance,
            label: 'Số lượng',
            value: _formatQuantity(entry.quantity, entry.wasteTypeUnit),
          ),
          _InfoRow(
            icon: Icons.factory,
            label: 'Phòng ban',
            value: entry.departmentName ?? '--',
          ),
          _InfoRow(
            icon: Icons.map,
            label: 'Khu vực',
            value: entry.areaName ?? '--',
          ),
          _InfoRow(
            icon: Icons.today,
            label: 'Ngày',
            value: _formatDate(entry.date),
          ),
          if ((entry.qrCode ?? '').isNotEmpty)
            _InfoRow(
              icon: Icons.qr_code,
              label: 'QR',
              value: entry.qrCode!,
            ),
        ],
      ),
    );
  }

  static String _formatQuantity(double? quantity, String? unit) {
    if (quantity == null) return '--';
    final isInt = quantity % 1 == 0;
    final value = isInt ? quantity.toStringAsFixed(0) : quantity.toStringAsFixed(2);
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

  const _InfoRow({required this.icon, required this.label, required this.value});

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
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
