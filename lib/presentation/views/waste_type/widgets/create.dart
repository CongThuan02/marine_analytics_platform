import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/presentation/blocs/waste_type/waste_type_bloc.dart';
import 'package:marine_analytics_platform/presentation/widgets/form_slect/form_select.dart';
import 'package:marine_analytics_platform/presentation/widgets/form_text_field.dart';

class CreateWasteType extends StatelessWidget {
  const CreateWasteType({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<WasteTypeBloc>();
    return BlocListener<WasteTypeBloc, WasteTypeState>(
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
              mainAxisSize: .min,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: 12,
                      children: [
                        Text("Thêm mới loại chất thải"),
                        BlocSelector<WasteTypeBloc, WasteTypeState, String>(
                          selector: (state) {
                            return state.wasteTypeModel?.name ?? '';
                          },
                          builder: (context, name) {
                            return FormTextField(
                              autofocus: true,
                              value: name,
                              name: 'name',
                              label: "Tên loại chất thải",
                              onChanged: (value) {
                                bloc.add(UpdateFieldWasteTypeEvent(key: 'name', value: value));
                              },
                            );
                          },
                        ),
                        FormSelect(
                          label: 'Đơn vị tính',
                          // tableName: 'areas',
                          iniItems: [
                            {'id': 'kg', 'name': 'kg'},
                            {'id': 'm³', 'name': 'm³'},
                            {'id': 'L', 'name': 'L'},
                          ],
                          name: 'unit',
                          onChange: (value) {
                            bloc.add(UpdateFieldWasteTypeEvent(key: 'unit', value: value));
                          },
                        ),
                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    bloc.add(CreateWasteTypeEvent());
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
