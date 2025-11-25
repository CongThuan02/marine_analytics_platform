import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';

import 'bloc/form_select_bloc.dart';

class FormSelect extends StatelessWidget {
  final String name;
  final String? label;
  final String valueKey;
  final String lableKey;
  final String? tableName;
  final List<Map<String, dynamic>>? iniItems;
  final Function(String value)? onChange;
  final List<String? Function(String?)>? validators;
  final String Function(Map<String, dynamic> item)? itemLabelBuilder;

  const FormSelect({
    this.iniItems,
    super.key,
    this.tableName,
    required this.name,
    this.label,
    this.valueKey = "id",
    this.lableKey = "name",
    this.onChange,
    this.validators,
    this.itemLabelBuilder,
  });

  List<Map<String, dynamic>> _buildItems(FormSelectState state) {
    return [
      {valueKey: 'chon', lableKey: 'Chọn'},
      ...state.items,
      ...?iniItems,
    ];
  }

  String _resolveLabel(List<Map<String, dynamic>> items, String? selectedValue) {
    if (selectedValue == null) return 'Chọn';
    final match = items.firstWhere(
      (item) => item[valueKey]?.toString() == selectedValue,
      orElse: () => {lableKey: 'Chọn'},
    );
    if (itemLabelBuilder != null) {
      return itemLabelBuilder!(match);
    }
    return match[lableKey]?.toString() ?? 'Chọn';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FormSelectBloc(),
      child: BlocBuilder<FormSelectBloc, FormSelectState>(
        builder: (context, state) {
          final bloc = context.read<FormSelectBloc>();
          final items = _buildItems(state);

          return FormBuilderField<String>(
            name: name,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: FormBuilderValidators.compose([...?validators]),
            builder: (field) {
              final selectedValue = field.value ?? state.selected;
              final displayText = _resolveLabel(items, selectedValue);

              Future<void> handleTap() async {
                if (tableName != null) {
                  bloc.add(GetItemsFormEvent(tableName: tableName!));
                  await bloc.stream.firstWhere((state) => state.status != Status.loading);
                }
                if (!context.mounted) return;

                final availableItems = _buildItems(bloc.state);
                final selected = await showModalBottomSheet<Map<String, dynamic>>(
                  context: context,
                  builder: (context) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: ListView.builder(
                        itemCount: availableItems.length,
                        itemBuilder: (context, index) {
                          final item = availableItems[index];
                          final value = item[valueKey]?.toString();
                          final text = itemLabelBuilder != null
                              ? itemLabelBuilder!(item)
                              : (item[lableKey]?.toString() ?? '');
                          return InkWell(
                            onTap: () => Navigator.pop(context, item),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              child: Row(
                                children: [
                                  Expanded(child: Text(text)),
                                  if (value == bloc.state.selected)
                                    const Icon(Icons.check, color: Colors.red, size: 18),
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
                  final value = selected[valueKey]?.toString() ?? 'chon';
                  bloc.add(UpdateFiledFormEvent(value));
                  onChange?.call(value);
                  field.didChange(value);
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: handleTap,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: label ?? name,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorText: field.errorText,
                        suffixIcon: state.status == Status.loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : const Icon(Icons.arrow_drop_down),
                      ),
                      child: Text(displayText),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
