import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/presentation/blocs/department/department_bloc.dart';
import 'package:marine_analytics_platform/presentation/views/department/widget/create.dart';
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
  const _DepartmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<DepartmentBloc>();

    return BlocListener<DepartmentBloc, DepartmentState>(
      listener: (context, state) {
        if (state.status == Status.success) {
          showTopSnackBar(Overlay.of(context), CustomSnackBar.success(message: "Thành công"));
          bloc.add(GetDepartmentEvent());
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Danh sách phòng ban")),
        body: BlocBuilder<DepartmentBloc, DepartmentState>(
          builder: (context, state) {
            if (state.status == Status.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = state.items ?? [];

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return InkWell(
                  onLongPress: () => _showDeleteDialog(context, bloc, item.id ?? '', item.name ?? ""),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(12)),
                    child: Text(item.name ?? ""),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (context) => CreateDepartment(bloc),
            );

            bloc.add(GetDepartmentEvent());
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, DepartmentBloc bloc, String id, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Bạn có chắc muốn xoá $name?'),
          content: const Text("Lưu ý: Xoá xong bạn không thể khôi phục lại dữ liệu"),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(onPressed: () => context.pop(), child: const Text("Đóng")),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      bloc.add(DeleteDepartmentEvent(id));
                    },
                    child: const Text("Xoá"),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
