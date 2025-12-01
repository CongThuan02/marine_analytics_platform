import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/core/theme/app_theme.dart';
import 'package:marine_analytics_platform/global.dart';
import 'package:marine_analytics_platform/presentation/blocs/waste_type/waste_type_bloc.dart';
import 'package:marine_analytics_platform/presentation/views/waste_type/widgets/create.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class WasteTypePage extends StatelessWidget {
  const WasteTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => WasteTypeBloc()..add(GetWasteTypeEvent()), child: const _WasteTypePage());
  }
}

class _WasteTypePage extends StatelessWidget {
  const _WasteTypePage();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<WasteTypeBloc>();

    return BlocListener<WasteTypeBloc, WasteTypeState>(
      listener: (context, state) {
        if (state.status == Status.success) {
          showTopSnackBar(Overlay.of(context), CustomSnackBar.success(message: "Thêm mới thành công"));
          // Reload list after any success action (create or delete)
          bloc.add(GetWasteTypeEvent());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Quản lý loại chất thải"),
          actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => bloc.add(GetWasteTypeEvent()))],
        ),
        body: BlocBuilder<WasteTypeBloc, WasteTypeState>(
          builder: (context, state) {
            if (state.status == Status.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = state.items ?? [];

            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline, size: 80, color: AppTheme.primaryGreenLight),
                    const SizedBox(height: 16),
                    const Text('Không có dữ liệu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text('Nhấn nút + để thêm loại chất thải mới', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => bloc.add(GetWasteTypeEvent()),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: InkWell(
                      onLongPress: () => _showDeleteDialog(context, bloc, item.id ?? '', item.name ?? ""),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryTealLight.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.recycling, color: AppTheme.secondaryTeal, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name ?? 'No name',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.straighten, size: 16, color: Colors.grey.shade600),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Đơn vị tính: ${item.unit ?? 'Not yet'}',
                                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryGreen),
                              onPressed: () =>
                                  _showEditDialog(context, bloc, item.id ?? '', item.name ?? "", item.unit ?? ""),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _showDeleteDialog(context, bloc, item.id ?? '', item.name ?? ""),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final bloc = context.read<WasteTypeBloc>();
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (context) => BlocProvider.value(value: bloc, child: CreateWasteType()),
            );

            bloc.add(GetWasteTypeEvent());
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WasteTypeBloc bloc, String id, String currentName, String currentUnit) {
    final TextEditingController nameController = TextEditingController(text: currentName);
    final TextEditingController unitController = TextEditingController(text: currentUnit);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.edit, color: AppTheme.primaryGreen),
              SizedBox(width: 12),
              Text('Chỉnh sửa loại chất thải'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Tên loại chất thải', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(labelText: 'Đơn vị (ví dụ: kg, tấn)', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                final newUnit = unitController.text.trim();
                if (newName.isEmpty || newUnit.isEmpty) return;

                await supabase.from('waste_types').update({'name': newName, 'Đơn vị tính': newUnit}).eq('id', id);

                bloc.add(GetWasteTypeEvent());
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white),
              child: const Text('Cập nhật'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, WasteTypeBloc bloc, String id, String name) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red),
              const SizedBox(width: 12),
              const Expanded(child: Text('Xác nhận xóa')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bạn có muốn xoá "$name"?', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dữ liệu không thể khôi phục sau khi xóa',
                        style: TextStyle(fontSize: 13, color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                // Check if waste type is being used
                final alertsResponse = await supabase.from('alerts').select().eq('waste_type_id', id);
                final alertsCount = (alertsResponse as List).length;

                final entriesResponse = await supabase.from('waste_entries').select().eq('waste_type_id', id);
                final entriesCount = (entriesResponse as List).length;

                final limitsResponse = await supabase.from('waste_limits').select().eq('waste_type_id', id);
                final limitsCount = (limitsResponse as List).length;

                if (alertsCount > 0 || entriesCount > 0 || limitsCount > 0) {
                  // Show error dialog
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.orange),
                          SizedBox(width: 12),
                          Text('Không thể xóa'),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Loại chất thải này đang được sử dụng và không thể xóa:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          if (alertsCount > 0) Text('• $alertsCount cảnh báo'),
                          if (entriesCount > 0) Text('• $entriesCount bản ghi'),
                          if (limitsCount > 0) Text('• $limitsCount giới hạn'),
                          const SizedBox(height: 12),
                          const Text(
                            'Vui lòng xóa các tham chiếu này trước, hoặc sử dụng Chỉnh sửa để thay đổi loại chất thải.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đồng ý'))],
                    ),
                  );
                } else {
                  // Safe to delete
                  bloc.add(DeleteWasteTypeEvent(id));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }
}
