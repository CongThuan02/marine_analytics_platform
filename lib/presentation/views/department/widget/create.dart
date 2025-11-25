import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marine_analytics_platform/presentation/blocs/department/department_bloc.dart';
import 'package:marine_analytics_platform/presentation/widgets/form_slect/form_select.dart';
import 'package:marine_analytics_platform/presentation/widgets/form_text_field.dart';

class CreateDepartment extends StatelessWidget {
  final DepartmentBloc bloc;

  const CreateDepartment(this.bloc, {super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      child: BlocProvider.value(
        value: bloc,
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
                            return state.departmentModel.name ?? '';
                          },
                          builder: (context, name) {
                            return FormTextField(
                              autofocus: true,
                              value: name,
                              name: 'name',
                              label: "Name",
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
                          onChange: (value) {
                            bloc.add(UpdateFieldDepartmentEvent(key: 'area_id', value: value));
                          },
                        ),
                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom ?? 20),
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
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom ?? 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
