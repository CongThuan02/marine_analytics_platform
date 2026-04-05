import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/presentation/blocs/department/department_bloc.dart';
import 'package:marine_analytics_platform/presentation/widgets/form_slect/form_select.dart';
import 'package:marine_analytics_platform/presentation/widgets/form_text_field.dart';

class CreateDepartment extends StatelessWidget {
  const CreateDepartment({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<DepartmentBloc>();
    return BlocListener<DepartmentBloc, DepartmentState>(
      listener: (context, state) {
        // Close bottom sheet when create is successful
        if (state.status == Status.success) {
          Navigator.of(context).pop();
        }
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: 12,
                      children: [
                        Text("Thêm mới phòng"),
                        BlocSelector<DepartmentBloc, DepartmentState, String>(
                          selector: (state) {
                            return state.departmentModel.name;
                          },
                          builder: (context, name) {
                            return FormTextField(
                              autofocus: true,
                              value: name,
                              name: 'name',
                              label: "Tên phòng",
                              validators: [
                                (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Vui lòng nhập tên phòng';
                                  }
                                  return null;
                                },
                              ],
                              onChanged: (value) {
                                bloc.add(UpdateFieldDepartmentEvent(key: 'name', value: value));
                              },
                            );
                          },
                        ),
                        FormSelect(
                          tableName: 'areas',
                          name: 'area_id',
                          valueKey: 'id',
                          lableKey: 'name',
                          label: 'Khu vực (tùy chọn)',
                          iniItems: const [
                            {'id': 'null', 'name': '(Không thuộc khu vực nào)'},
                          ],
                          onChange: (value) {
                            // Convert 'null' string to actual null for database
                            final areaId = value == 'null' || value == 'select' ? null : value;
                            bloc.add(UpdateFieldDepartmentEvent(key: 'area_id', value: areaId));
                          },
                        ),
                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                      ],
                    ),
                  ),
                ),
                BlocBuilder<DepartmentBloc, DepartmentState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state.status == Status.loading
                          ? null
                          : () {
                              // Validate name is not empty
                              final name = bloc.state.departmentModel.name.trim();
                              if (name.isEmpty) {
                                // Show dialog instead of snackbar for better visibility
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Thiếu thông tin'),
                                    content: const Text('Vui lòng nhập tên phòng'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đồng ý')),
                                    ],
                                  ),
                                );
                                return;
                              }
                              bloc.add(CreateDepartmentEvent());
                            },
                      child: state.status == Status.loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Center(child: Text("Lưu")),
                    );
                  },
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
