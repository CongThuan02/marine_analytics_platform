import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marine_analytics_platform/presentation/blocs/waste_type/waste_type_bloc.dart';
import 'package:marine_analytics_platform/presentation/widgets/form_slect/form_select.dart';
import 'package:marine_analytics_platform/presentation/widgets/form_text_field.dart';

class CreateWasteType extends StatelessWidget {
  const CreateWasteType({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<WasteTypeBloc>();
    return ConstrainedBox(
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
                      BlocSelector<WasteTypeBloc, WasteTypeState, String>(
                        selector: (state) {
                          return state.wasteTypeModel?.name ?? '';
                        },
                        builder: (context, name) {
                          return FormTextField(
                            autofocus: true,
                            value: name,
                            name: 'name',
                            label: "Name",
                            onChanged: (value) {
                              bloc.add(UpdateFieldWasteTypeEvent(key: 'name', value: value));
                            },
                          );
                        },
                      ),
                      FormSelect(
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
                child: Center(child: Text("Save")),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }
}
