import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/core/theme/app_theme.dart';
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
  const _WasteTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<WasteTypeBloc>();

    return BlocListener<WasteTypeBloc, WasteTypeState>(
      listener: (context, state) {
        if (state.status == Status.success) {
          showTopSnackBar(Overlay.of(context), CustomSnackBar.success(message: "Thành công"));
          bloc.add(GetWasteTypeEvent());
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Quản lý Loại chất thải"),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => bloc.add(GetWasteTypeEvent()),
            ),
          ],
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
                    Icon(
                      Icons.delete_outline,
                      size: 80,
                      color: AppTheme.primaryGreenLight,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Chưa có loại chất thải nào',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nhấn nút + để thêm loại chất thải mới',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
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
                              child: const Icon(
                                Icons.recycling,
                                color: AppTheme.secondaryTeal,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name ?? 'Không có tên',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.straighten,
                                        size: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Đơn vị: ${item.unit ?? 'Chưa có'}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _showDeleteDialog(
                                context,
                                bloc,
                                item.id ?? '',
                                item.name ?? "",
                              ),
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
              Text(
                'Bạn có chắc muốn xóa loại chất thải "$name"?',
                style: const TextStyle(fontSize: 16),
              ),
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
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                bloc.add(DeleteWasteTypeEvent(id));
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }
}
