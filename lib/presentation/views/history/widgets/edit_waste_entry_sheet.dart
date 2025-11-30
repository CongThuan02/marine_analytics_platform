import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/core/services/local_notification_service.dart';
import 'package:marine_analytics_platform/data/models/waste_entry_model.dart';
import 'package:marine_analytics_platform/global.dart';
import 'package:marine_analytics_platform/presentation/blocs/waste_entry/waste_entry_bloc.dart';
import 'package:marine_analytics_platform/presentation/widgets/form_slect/form_select.dart';
import 'package:marine_analytics_platform/presentation/widgets/form_text_field.dart';

class EditWasteEntrySheet extends StatefulWidget {
  final WasteEntryModel entry;

  const EditWasteEntrySheet({super.key, required this.entry});

  @override
  State<EditWasteEntrySheet> createState() => _EditWasteEntrySheetState();
}

class _EditWasteEntrySheetState extends State<EditWasteEntrySheet> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    print('📝 Edit Sheet - Entry data:');
    print('   Area ID: ${widget.entry.areaId}');
    print('   Department ID: ${widget.entry.departmentId}');
    print('   Waste Type ID: ${widget.entry.wasteTypeId}');
    print('   Date: ${widget.entry.date}');
    print('   Quantity: ${widget.entry.quantity}');
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<WasteEntryBloc, WasteEntryState>(
      listener: (context, state) {
        if (state.status == Status.success) {
          Navigator.of(context).maybePop();
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: bottom + 24,
        ),
        child: FormBuilder(
          key: _formKey,
          initialValue: {
            'area_id': widget.entry.areaId,
            'department_id': widget.entry.departmentId,
            'waste_type_id': widget.entry.wasteTypeId,
            'date': widget.entry.date ?? DateTime.now(),
            'quantity': widget.entry.quantity.toString(),
            'qr_code': widget.entry.qrCode ?? '',
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Text(
                "Edit Waste Entry",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              FormSelect(
                name: 'area_id',
                label: 'Area',
                tableName: 'areas',
                initialValue: widget.entry.areaId,
                validators: [
                  (value) {
                    if (value == null || value == 'select') {
                      return 'Please select an area';
                    }
                    return null;
                  },
                ],
              ),
              FormSelect(
                name: 'department_id',
                label: 'Department',
                tableName: 'departments',
                initialValue: widget.entry.departmentId,
                validators: [
                  (value) {
                    if (value == null || value == 'select') {
                      return 'Please select a department';
                    }
                    return null;
                  },
                ],
              ),
              FormSelect(
                name: 'waste_type_id',
                label: 'Waste Type',
                tableName: 'waste_types',
                initialValue: widget.entry.wasteTypeId,
                itemLabelBuilder: (item) {
                  final name = item['name']?.toString() ?? 'Select';
                  final unit = item['unit']?.toString();
                  if (unit == null || unit.isEmpty || unit == 'null') {
                    return name;
                  }
                  return '$name ($unit)';
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
              _DateField(),
              FormTextField(
                name: 'quantity',
                label: 'Quantity',
                hintText: 'Example: 12.5',
                validators: [
                  FormBuilderValidators.required(
                    errorText: 'Please enter quantity',
                  ),
                  FormBuilderValidators.numeric(
                    errorText: 'Quantity must be a number',
                  ),
                ],
              ),
              FormTextField(name: 'qr_code', label: 'QR Code (optional)'),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  child: const Text("Update"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() async {
    final formState = _formKey.currentState;
    if (!(formState?.saveAndValidate() ?? false)) return;

    final values = formState!.value;
    final quantityString = values['quantity'] as String?;
    final quantity = _parseQuantity(quantityString);

    if (quantity == null) {
      _showSnackBar(context, 'Invalid quantity');
      return;
    }

    try {
      print('🔄 Updating waste entry ${widget.entry.id}');

      await supabase
          .from('waste_entries')
          .update({
            'area_id': values['area_id'],
            'department_id': values['department_id'],
            'waste_type_id': values['waste_type_id'],
            'date': (values['date'] as DateTime).toIso8601String().split(
              'T',
            )[0],
            'quantity': quantity,
            'qr_code': (values['qr_code'] as String?)?.trim(),
          })
          .eq('id', widget.entry.id);

      print('✅ Update successful');

      // Check waste limit and show local notification if exceeded
      await _checkWasteLimit(
        areaId: values['area_id'] as String,
        wasteTypeId: values['waste_type_id'] as String,
        quantity: quantity,
      );

      if (context.mounted) {
        context.read<WasteEntryBloc>().add(const LoadWasteEntries());
        _showSnackBar(
          context,
          'Waste entry updated successfully',
          isError: false,
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('❌ Update error: $e');
      if (context.mounted) {
        _showSnackBar(context, 'Error updating entry: $e');
      }
    }

    FocusScope.of(context).unfocus();
  }

  double? _parseQuantity(String? value) {
    if (value == null) return null;
    final sanitized = value.replaceAll(',', '.').trim();
    return double.tryParse(sanitized);
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _checkWasteLimit({
    required String areaId,
    required String wasteTypeId,
    required double quantity,
  }) async {
    try {
      // Get area and waste type names
      final areaResponse = await supabase
          .from('areas')
          .select('name')
          .eq('id', areaId)
          .maybeSingle();

      final wasteTypeResponse = await supabase
          .from('waste_types')
          .select('name')
          .eq('id', wasteTypeId)
          .maybeSingle();

      if (areaResponse == null || wasteTypeResponse == null) {
        print('⚠️ Could not fetch area or waste type names');
        return;
      }

      final areaName = areaResponse['name'] as String;
      final wasteTypeName = wasteTypeResponse['name'] as String;

      // Check limit using local notification service
      await LocalNotificationService().checkAndNotifyWasteLimit(
        areaId: areaId,
        wasteTypeId: wasteTypeId,
        quantity: quantity,
        areaName: areaName,
        wasteTypeName: wasteTypeName,
      );
    } catch (e) {
      print('❌ Error checking waste limit: $e');
    }
  }
}

class _DateField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FormBuilderField<DateTime>(
      name: 'date',
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
