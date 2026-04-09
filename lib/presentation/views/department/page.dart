import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/core/theme/app_theme.dart';
import 'package:marine_analytics_platform/global.dart';
import 'package:marine_analytics_platform/presentation/blocs/department/department_bloc.dart';
import 'package:marine_analytics_platform/presentation/views/department/widget/create.dart';
import 'package:marine_analytics_platform/presentation/widgets/form_slect/form_select.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class DepartmentPage extends StatelessWidget {
  const DepartmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => DepartmentBloc()..add(GetDepartmentEvent()), child: const _DepartmentPage());
  }
}

class _DepartmentPage extends StatelessWidget {
  const _DepartmentPage();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<DepartmentBloc>();

    return BlocListener<DepartmentBloc, DepartmentState>(
      listener: (context, state) {
        if (state.status == Status.success) {
          showTopSnackBar(Overlay.of(context), CustomSnackBar.success(message: "${state.message}"));
          // Reload list after any success action (create or delete)
          bloc.add(GetDepartmentEvent());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Quản lý phòng"),
          actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => bloc.add(GetDepartmentEvent()))],
        ),
        body: BlocBuilder<DepartmentBloc, DepartmentState>(
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
                    Icon(Icons.business_outlined, size: 80, color: AppTheme.primaryGreenLight),
                    const SizedBox(height: 16),
                    const Text('No departments yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text('Nhấn nút + để thêm phòng mới', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => bloc.add(GetDepartmentEvent()),
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
                                color: AppTheme.primaryGreenLight.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.business, color: AppTheme.primaryGreen, size: 24),
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
                                      Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.area?.name ?? 'Không xác định',
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
                                  _showEditDialog(context, bloc, item.id ?? '', item.name ?? "", item.areaId),
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
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (context) => BlocProvider.value(value: bloc, child: CreateDepartment()),
            );

            bloc.add(GetDepartmentEvent());
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    DepartmentBloc bloc,
    String id,
    String currentName,
    String? currentAreaId,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return _EditDepartmentDialog(
          id: id,
          currentName: currentName,
          currentAreaId: currentAreaId,
          onSave: () {
            bloc.add(GetDepartmentEvent());
            Navigator.pop(dialogContext);
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, DepartmentBloc bloc, String id, String name) {
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
              Text('Bạn có chắc muốn xoá phòng "$name"?', style: const TextStyle(fontSize: 16)),
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
              onPressed: () {
                bloc.add(DeleteDepartmentEvent(id));
                Navigator.pop(dialogContext);
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

class _EditDepartmentDialog extends StatefulWidget {
  final String id;
  final String currentName;
  final String? currentAreaId;
  final VoidCallback onSave;

  const _EditDepartmentDialog({
    required this.id,
    required this.currentName,
    required this.currentAreaId,
    required this.onSave,
  });

  @override
  State<_EditDepartmentDialog> createState() => _EditDepartmentDialogState();
}

class _EditDepartmentDialogState extends State<_EditDepartmentDialog> {
  late TextEditingController _nameController;
  String? _selectedAreaId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _selectedAreaId = widget.currentAreaId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Convert 'null' string to actual null, and 'select' to null
      final areaIdValue = _selectedAreaId == 'null' || _selectedAreaId == 'select' ? null : _selectedAreaId;

      await supabase.from('departments').update({'name': newName, 'area_id': areaIdValue}).eq('id', widget.id);

      widget.onSave();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.edit, color: AppTheme.primaryGreen),
          SizedBox(width: 12),
          Text('Chỉnh sửa phòng'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Tên phòng', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            FormSelect(
              name: 'area_id',
              label: 'Khu vực (tùy chọn)',
              tableName: 'areas',
              initialValue: _selectedAreaId == null ? 'null' : _selectedAreaId,
              iniItems: const [
                {'id': 'null', 'name': '(Không thuộc khu vực nào)'},
              ],
              onChange: (value) {
                setState(() {
                  _selectedAreaId = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _isLoading ? null : () => Navigator.pop(context), child: const Text('Hủy')),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSave,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Cập nhật'),
        ),
      ],
    );
  }
}
