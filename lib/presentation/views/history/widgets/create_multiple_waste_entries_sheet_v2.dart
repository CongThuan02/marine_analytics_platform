import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:marine_analytics_platform/core/theme/app_theme.dart';
import 'package:marine_analytics_platform/global.dart';
import 'package:marine_analytics_platform/presentation/blocs/multiple_waste_entry/multiple_waste_entry_bloc.dart';
import 'package:marine_analytics_platform/presentation/blocs/waste_entry/waste_entry_bloc.dart';
import 'package:marine_analytics_platform/presentation/widgets/form_slect/form_select.dart';

class CreateMultipleWasteEntriesSheetV2 extends StatelessWidget {
  const CreateMultipleWasteEntriesSheetV2({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MultipleWasteEntryBloc(),
      child: const _CreateMultipleWasteEntriesView(),
    );
  }
}

class _CreateMultipleWasteEntriesView extends StatefulWidget {
  const _CreateMultipleWasteEntriesView();

  @override
  State<_CreateMultipleWasteEntriesView> createState() =>
      _CreateMultipleWasteEntriesViewState();
}

class _CreateMultipleWasteEntriesViewState
    extends State<_CreateMultipleWasteEntriesView> {
  final _formKey = GlobalKey<FormBuilderState>();
  final Map<int, GlobalKey<FormBuilderState>> _itemFormKeys = {};

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return BlocConsumer<MultipleWasteEntryBloc, MultipleWasteEntryState>(
      listener: (context, state) {
        if (state.status == MultipleWasteEntryStatus.success) {
          // Reload waste entries
          context.read<WasteEntryBloc>().add(const LoadWasteEntries());

          Navigator.of(context).maybePop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${state.entriesCreated} waste types'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        } else if (state.status == MultipleWasteEntryStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        // Update form keys when items change
        for (int i = 0; i < state.wasteItems.length; i++) {
          _itemFormKeys.putIfAbsent(i, () => GlobalKey<FormBuilderState>());
        }

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, state),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: bottom + 24,
                  ),
                  child: FormBuilder(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCommonFields(),
                        const SizedBox(height: 24),
                        _buildWasteItemsHeader(context),
                        const SizedBox(height: 12),
                        ..._buildWasteItemsList(context, state),
                        const SizedBox(height: 24),
                        _buildSubmitButton(context, state),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, MultipleWasteEntryState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreenLight.withOpacity(0.1),
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.add_circle_outline,
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Add Multiple Waste Types',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${state.wasteItems.length} types',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommonFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Common Information',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        FormSelect(
          name: 'area_id',
          label: 'Area',
          tableName: 'areas',
          validators: [
            (value) {
              if (value == null || value == 'select') {
                return 'Please select an area';
              }
              return null;
            },
          ],
        ),
        const SizedBox(height: 12),
        FormSelect(
          name: 'department_id',
          label: 'Department',
          tableName: 'departments',
          validators: [
            (value) {
              if (value == null || value == 'select') {
                return 'Please select a department';
              }
              return null;
            },
          ],
        ),
        const SizedBox(height: 12),
        _DateField(),
      ],
    );
  }

  Widget _buildWasteItemsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Waste List',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton.icon(
          onPressed: () {
            context.read<MultipleWasteEntryBloc>().add(
              const AddWasteItemEvent(),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Type'),
          style: TextButton.styleFrom(foregroundColor: AppTheme.primaryGreen),
        ),
      ],
    );
  }

  List<Widget> _buildWasteItemsList(
    BuildContext context,
    MultipleWasteEntryState state,
  ) {
    return List.generate(state.wasteItems.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _WasteItemCard(
          key: ValueKey(index),
          index: index,
          formKey: _itemFormKeys[index]!,
          wasteItem: state.wasteItems[index],
          canRemove: state.wasteItems.length > 1,
          onRemove: () {
            context.read<MultipleWasteEntryBloc>().add(
              RemoveWasteItemEvent(index),
            );
          },
          onWasteTypeChanged: (wasteTypeId, name, unit) {
            context.read<MultipleWasteEntryBloc>().add(
              UpdateWasteTypeEvent(
                index: index,
                wasteTypeId: wasteTypeId,
                name: name,
                unit: unit,
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildSubmitButton(
    BuildContext context,
    MultipleWasteEntryState state,
  ) {
    final isLoading = state.status == MultipleWasteEntryStatus.loading;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : () => _handleSubmit(context, state),
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save),
        label: Text(
          isLoading
              ? 'Saving...'
              : 'Save ${state.wasteItems.length} waste types',
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  void _handleSubmit(BuildContext context, MultipleWasteEntryState state) {
    // Validate common fields
    final formState = _formKey.currentState;
    if (!(formState?.saveAndValidate() ?? false)) {
      _showSnackBar(
        context,
        'Please fill in all common information',
        isError: true,
      );
      return;
    }

    // Validate all waste items and collect quantities
    final Map<int, double> quantities = {};
    bool allValid = true;

    for (int i = 0; i < state.wasteItems.length; i++) {
      final itemFormKey = _itemFormKeys[i];
      if (!(itemFormKey?.currentState?.saveAndValidate() ?? false)) {
        allValid = false;
        break;
      }

      final itemValues = itemFormKey!.currentState!.value;
      final quantityString = itemValues['quantity_$i'] as String?;
      final quantity = _parseQuantity(quantityString);

      if (quantity == null || quantity <= 0) {
        _showSnackBar(
          context,
          'Invalid quantity for waste type ${i + 1}',
          isError: true,
        );
        return;
      }

      quantities[i] = quantity;
    }

    if (!allValid) {
      _showSnackBar(
        context,
        'Please fill in all waste type information',
        isError: true,
      );
      return;
    }

    // Get common values
    final commonValues = formState!.value;
    final areaId = commonValues['area_id'] as String;
    final departmentId = commonValues['department_id'] as String;
    final date = commonValues['date'] as DateTime;

    // Submit
    context.read<MultipleWasteEntryBloc>().add(
      SubmitMultipleEntriesEvent(
        areaId: areaId,
        departmentId: departmentId,
        date: date,
        quantities: quantities,
      ),
    );
  }

  double? _parseQuantity(String? value) {
    if (value == null) return null;
    final sanitized = value.replaceAll(',', '.').trim();
    return double.tryParse(sanitized);
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppTheme.primaryGreen,
      ),
    );
  }
}

class _WasteItemCard extends StatelessWidget {
  final int index;
  final GlobalKey<FormBuilderState> formKey;
  final WasteItemState wasteItem;
  final bool canRemove;
  final VoidCallback onRemove;
  final Function(String wasteTypeId, String name, String unit)
  onWasteTypeChanged;

  const _WasteItemCard({
    super.key,
    required this.index,
    required this.formKey,
    required this.wasteItem,
    required this.canRemove,
    required this.onRemove,
    required this.onWasteTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreenLight.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      wasteItem.wasteTypeName ?? 'Waste Type ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (canRemove)
                    IconButton(
                      onPressed: onRemove,
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                      tooltip: 'Delete',
                    ),
                ],
              ),
              const SizedBox(height: 12),
              FormSelect(
                name: 'waste_type_id_$index',
                label: 'Waste Type',
                tableName: 'waste_types',
                itemLabelBuilder: (item) {
                  final name = item['name']?.toString() ?? 'Select';
                  final unit = item['unit']?.toString();
                  if (unit == null || unit.isEmpty || unit == 'null') {
                    return name;
                  }
                  return '$name ($unit)';
                },
                onChange: (value) {
                  if (value != 'select') {
                    _fetchWasteTypeDetails(value);
                  }
                },
                validators: [
                  (value) {
                    if (value == null || value == 'select') {
                      return 'Please select a waste type';
                    }
                    return null;
                  },
                ],
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'quantity_$index',
                decoration: InputDecoration(
                  labelText:
                      'Quantity${wasteItem.unit != null ? ' (${wasteItem.unit})' : ''}',
                  hintText: 'Example: 12.5',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.scale),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Please enter quantity',
                  ),
                  FormBuilderValidators.numeric(
                    errorText: 'Quantity must be a number',
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchWasteTypeDetails(String wasteTypeId) async {
    try {
      final response = await supabase
          .from('waste_types')
          .select('name, unit')
          .eq('id', wasteTypeId)
          .single();

      onWasteTypeChanged(
        wasteTypeId,
        response['name'] as String,
        response['unit'] as String? ?? '',
      );
    } catch (e) {
      print('Error fetching waste type: $e');
    }
  }
}

class _DateField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FormBuilderField<DateTime>(
      name: 'date',
      initialValue: DateTime.now(),
      validator: (value) {
        if (value == null) return 'Please select entry date';
        return null;
      },
      builder: (field) {
        Future<void> pickDate() async {
          final now = DateTime.now();
          final selectedDate = await showDatePicker(
            context: context,
            initialDate: field.value ?? now,
            firstDate: DateTime(now.year - 5),
            lastDate: DateTime(now.year + 5),
          );
          if (selectedDate != null) {
            field.didChange(selectedDate);
          }
        }

        return GestureDetector(
          onTap: pickDate,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Entry Date',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              errorText: field.errorText,
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            child: Text(_formatDate(field.value)),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}
