import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/core/utils/value_sanitizer.dart';

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
  final String? initialValue;
  final String? filterColumn;
  final String? filterValue;

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
    this.initialValue,
    this.filterColumn,
    this.filterValue,
  });

  List<Map<String, dynamic>> _buildItems(FormSelectState state) {
    final allItems = [
      {valueKey: 'select', lableKey: 'Chọn'},
      ...state.items,
      ...?iniItems,
    ];

    // Remove duplicates based on valueKey (id)
    final seen = <String>{};
    final uniqueItems = <Map<String, dynamic>>[];

    for (final item in allItems) {
      final id = item[valueKey]?.toString();
      if (id != null && !seen.contains(id)) {
        seen.add(id);
        uniqueItems.add(item);
      }
    }

    return uniqueItems;
  }

  String _resolveLabel(
    List<Map<String, dynamic>> items,
    String? selectedValue,
  ) {
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

          // Auto-load data if initialValue is set and items not loaded yet
          if (initialValue != null &&
              tableName != null &&
              state.items.isEmpty &&
              state.status != Status.loading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              bloc.add(GetItemsFormEvent(tableName: tableName!));
            });
          }

          return FormBuilderField<String>(
            name: name,
            initialValue: initialValue,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: FormBuilderValidators.compose([...?validators]),
            builder: (field) {
              // Debug log
              if (initialValue != null) {
                print(
                  '🔍 FormSelect[$name] - initialValue: $initialValue, field.value: ${field.value}, state.selected: ${state.selected}, items: ${items.length}',
                );
              }

              // Initialize bloc state with field value if not set
              if (field.value != null && state.selected != field.value) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  bloc.add(UpdateFiledFormEvent(field.value!));
                });
              }

              final selectedValue = field.value ?? state.selected;
              final displayText = _resolveLabel(items, selectedValue);

              Future<void> handleTap() async {
                if (tableName != null) {
                  bloc.add(
                    GetItemsFormEvent(
                      tableName: tableName!,
                      filterColumn: filterColumn,
                      filterValue: filterValue,
                    ),
                  );
                  await bloc.stream.firstWhere(
                    (state) => state.status != Status.loading,
                  );
                }
                if (!context.mounted) return;

                final availableItems = _buildItems(bloc.state);
                final selected =
                    await showModalBottomSheet<Map<String, dynamic>>(
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(text)),
                                      if (value == bloc.state.selected)
                                        const Icon(
                                          Icons.check,
                                          color: Colors.red,
                                          size: 18,
                                        ),
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
                  final rawValue = selected[valueKey]?.toString() ?? 'chọn';

                  // Sanitize the value - if it's "select", convert to empty string
                  final sanitizedValue = ValueSanitizer.sanitizeString(
                    rawValue,
                  );
                  final finalValue = sanitizedValue.isEmpty ? '' : rawValue;

                  print(
                    '🧹 FormSelect: Raw value: "$rawValue", Sanitized: "$finalValue"',
                  );

                  bloc.add(UpdateFiledFormEvent(finalValue));
                  onChange?.call(finalValue);
                  field.didChange(finalValue);
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
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
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
