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
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Column(
              mainAxisSize: .min,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: 12,
                      children: [
                        BlocSelector<DepartmentBloc, DepartmentState, String>(
                          selector: (state) {
                            return state.departmentModel.name;
                          },
                          builder: (context, name) {
                            return FormTextField(
                              autofocus: true,
                              value: name,
                              name: 'name',
                              label: "Tên",
                              onChanged: (value) {
                                bloc.add(
                                  UpdateFieldDepartmentEvent(
                                    key: 'name',
                                    value: value,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        FormSelect(
                          tableName: 'areas',
                          name: 'area_id',
                          valueKey: 'id',
                          lableKey: 'name',
                          label: 'Khu vực',
                          onChange: (value) {
                            bloc.add(
                              UpdateFieldDepartmentEvent(
                                key: 'area_id',
                                value: value,
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).viewInsets.bottom,
                        ),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    bloc.add(CreateDepartmentEvent());
                  },
                  child: Center(child: Text("Lưu")),
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
