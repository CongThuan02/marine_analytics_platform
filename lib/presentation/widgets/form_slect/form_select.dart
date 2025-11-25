import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';

import 'bloc/form_select_bloc.dart';

class FormSelect extends StatelessWidget {
  final String name;
  final String label;
  final String valueKey;
  final String lableKey;
  final String? tableName;
  final List<Map<String, dynamic>>? iniItems;
  final Function(String)? onChange;

  const FormSelect({
    this.iniItems,
    super.key,
    this.tableName,
    required this.name,
    this.label = 'Chọn khu vực',
    required this.valueKey,
    required this.lableKey,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FormSelectBloc(),
      child: BlocBuilder<FormSelectBloc, FormSelectState>(
        builder: (context, state) {
          return Container(
            padding: .symmetric(horizontal: 16),
            decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadiusGeometry.circular(12)),
            child: FormBuilderField<String>(
              name: name,
              builder: (field) {
                return GestureDetector(
                  onTap: () async {
                    final bloc = context.read<FormSelectBloc>();

                    if (tableName != null) {
                      bloc.add(GetItemsFormEvent(tableName: tableName!));

                      /// Chờ load xong
                      await bloc.stream.firstWhere((state) => state.status != Status.loading);
                    }
                    if (!context.mounted) return;
                    final items = [
                      {valueKey: 'chon', lableKey: 'Chọn'},
                      ...bloc.state.items,
                      ...?iniItems,
                    ];

                    final selected = await showModalBottomSheet<Map<String, dynamic>>(
                      context: context,
                      builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return InkWell(
                                onTap: () => Navigator.pop(context, item),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(item[lableKey] ?? '')),
                                      if (item[valueKey] == bloc.state.selected)
                                        Icon(Icons.check, color: Colors.red, size: 18),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );

                    if (selected != null) {
                      bloc.add(UpdateFiledFormEvent(selected[valueKey]));
                      onChange?.call(selected[valueKey]);
                      field.didChange(selected[lableKey]);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      border: .none,
                      labelText: label,
                      suffixIcon: state.status == Status.loading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                    ),
                    child: Text(field.value ?? label),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
