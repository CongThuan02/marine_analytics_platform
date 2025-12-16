import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/core/theme/app_theme.dart';
import 'package:marine_analytics_platform/data/models/waste_entry_model.dart';
import 'package:marine_analytics_platform/global.dart';
import 'package:marine_analytics_platform/presentation/blocs/waste_entry/waste_entry_bloc.dart';
import 'package:marine_analytics_platform/presentation/widgets/form_slect/form_select.dart';

class WasteItem {
  String? wasteTypeId;
  String? wasteTypeName;
  String? unit;
  double? quantity;

  WasteItem({this.wasteTypeId, this.wasteTypeName, this.unit, this.quantity});
}

class CreateMultipleWasteEntriesSheet extends StatefulWidget {
  const CreateMultipleWasteEntriesSheet({super.key});

  @override
  State<CreateMultipleWasteEntriesSheet> createState() => _CreateMultipleWasteEntriesSheetState();
}

class _CreateMultipleWasteEntriesSheetState extends State<CreateMultipleWasteEntriesSheet> {
  final _formKey = GlobalKey<FormBuilderState>();
  final List<WasteItem> _wasteItems = [WasteItem()];
  final List<GlobalKey<FormBuilderState>> _itemFormKeys = [GlobalKey<FormBuilderState>()];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<WasteEntryBloc, WasteEntryState>(
      listener: (context, state) {
        if (state.status == Status.success) {
          Navigator.of(context).maybePop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm ${_wasteItems.length} loại chất thải'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        }
      },
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
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
                    decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.add_circle_outline, color: AppTheme.primaryGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Thêm nhiều loại chất thải',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_wasteItems.length} loại',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: bottom + 24),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Common fields
                      _buildCommonFields(),
                      const SizedBox(height: 24),

                      // Waste items section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Danh sách chất thải',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextButton.icon(
                            onPressed: _addWasteItem,
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm loại'),
                            style: TextButton.styleFrom(foregroundColor: AppTheme.primaryGreen),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Waste items list
                      ..._buildWasteItemsList(),

                      const SizedBox(height: 24),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _handleSubmit,
                          icon: const Icon(Icons.save),
                          label: Text('Lưu ${_wasteItems.length} loại chất thải'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Thông tin chung', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        FormSelect(
          name: 'area_id',
          label: 'Khu vực',
          tableName: 'areas',
          validators: [
            (value) {
              if (value == null || value == 'select') {
                return 'Vui lòng chọn khu vực';
              }
              return null;
            },
          ],
        ),
        const SizedBox(height: 12),
        FormSelect(name: 'department_id', label: 'Phòng ban', tableName: 'departments'),
        const SizedBox(height: 12),
        _DateField(),
      ],
    );
  }

  List<Widget> _buildWasteItemsList() {
    return List.generate(_wasteItems.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _WasteItemCard(
          key: ValueKey(index),
          index: index,
          formKey: _itemFormKeys[index],
          wasteItem: _wasteItems[index],
          onRemove: _wasteItems.length > 1 ? () => _removeWasteItem(index) : null,
          onWasteTypeChanged: (wasteTypeId, name, unit) {
            setState(() {
              _wasteItems[index].wasteTypeId = wasteTypeId;
              _wasteItems[index].wasteTypeName = name;
              _wasteItems[index].unit = unit;
            });
          },
        ),
      );
    });
  }

  void _addWasteItem() {
    setState(() {
      _wasteItems.add(WasteItem());
      _itemFormKeys.add(GlobalKey<FormBuilderState>());
    });
  }

  void _removeWasteItem(int index) {
    setState(() {
      _wasteItems.removeAt(index);
      _itemFormKeys.removeAt(index);
    });
  }

  void _handleSubmit() async {
    // Validate common fields
    final formState = _formKey.currentState;
    if (!(formState?.saveAndValidate() ?? false)) {
      _showSnackBar('Vui lòng điền đầy đủ thông tin chung', isError: true);
      return;
    }

    // Validate all waste items
    bool allValid = true;
    for (var itemFormKey in _itemFormKeys) {
      if (!(itemFormKey.currentState?.saveAndValidate() ?? false)) {
        allValid = false;
      }
    }

    if (!allValid) {
      _showSnackBar('Vui lòng điền đầy đủ thông tin loại chất thải', isError: true);
      return;
    }

    // Get common values
    final commonValues = formState!.value;
    final areaId = commonValues['area_id'] as String;
    final departmentId = commonValues['department_id'] as String;
    final date = commonValues['date'] as DateTime;

    // Create entries for each waste item
    for (int i = 0; i < _wasteItems.length; i++) {
      final itemValues = _itemFormKeys[i].currentState!.value;
      final quantityString = itemValues['quantity_$i'] as String?;
      final quantity = _parseQuantity(quantityString);

      if (quantity == null || quantity <= 0) {
        _showSnackBar('Số lượng không hợp lệ cho loại chất thải ${i + 1}', isError: true);
        return;
      }

      final entry = WasteEntryModel(
        id: '',
        userId: supabase.auth.currentUser?.id ?? '',
        areaId: areaId,
        departmentId: departmentId,
        wasteTypeId: _wasteItems[i].wasteTypeId ?? '',
        date: date,
        quantity: quantity,
        qrCode: null,
        createdAt: DateTime.now(),
      );

      context.read<WasteEntryBloc>().add(CreateWasteEntry(entry));
    }

    FocusScope.of(context).unfocus();
  }

  double? _parseQuantity(String? value) {
    if (value == null) return null;
    final sanitized = value.replaceAll(',', '.').trim();
    return double.tryParse(sanitized);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : AppTheme.primaryGreen));
  }
}

class _WasteItemCard extends StatelessWidget {
  final int index;
  final GlobalKey<FormBuilderState> formKey;
  final WasteItem wasteItem;
  final VoidCallback? onRemove;
  final Function(String wasteTypeId, String name, String unit)? onWasteTypeChanged;

  const _WasteItemCard({
    super.key,
    required this.index,
    required this.formKey,
    required this.wasteItem,
    this.onRemove,
    this.onWasteTypeChanged,
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
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      wasteItem.wasteTypeName ?? 'Loại chất thải ${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  if (onRemove != null)
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
                label: 'Loại chất thải',
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
                    // Fetch waste type details
                    _fetchWasteTypeDetails(value);
                  }
                },
                validators: [
                  (value) {
                    if (value == null || value == 'select') {
                      return 'Vui lòng chọn loại chất thải';
                    }
                    return null;
                  },
                ],
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'quantity_$index',
                decoration: InputDecoration(
                  labelText: 'Số lượng${wasteItem.unit != null ? ' (${wasteItem.unit})' : ''}',
                  hintText: 'Ví dụ: 12.5',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.scale),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'Vui lòng nhập số lượng'),
                  FormBuilderValidators.numeric(errorText: 'Số lượng phải là số'),
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
      final response = await supabase.from('waste_types').select('name, unit').eq('id', wasteTypeId).single();

      if (onWasteTypeChanged != null) {
        onWasteTypeChanged!(wasteTypeId, response['name'] as String, response['unit'] as String? ?? '');
      }
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
        if (value == null) return 'Vui lòng chọn ngày nhập';
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
              labelText: 'Ngày nhập',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
    if (date == null) return 'Chọn ngày';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}
