import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/data/models/waste_entry_model.dart';
import 'package:marine_analytics_platform/global.dart';
import 'package:marine_analytics_platform/presentation/blocs/waste_entry/waste_entry_bloc.dart';
import 'package:marine_analytics_platform/presentation/widgets/form_slect/form_select.dart';
import 'package:marine_analytics_platform/presentation/widgets/form_text_field.dart';

class CreateWasteEntrySheet extends StatefulWidget {
  const CreateWasteEntrySheet({super.key});

  @override
  State<CreateWasteEntrySheet> createState() => _CreateWasteEntrySheetState();
}

class _CreateWasteEntrySheetState extends State<CreateWasteEntrySheet> {
  final _formKey = GlobalKey<FormBuilderState>();

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
                "Record Waste",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
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
              FormSelect(
                name: 'waste_type_id',
                label: 'Waste Type',
                tableName: 'waste_types',
                itemLabelBuilder: (item) {
                  final name = item['name']?.toString() ?? 'Select';
                  final unit = item['unit']?.toString();
                  if (unit == null || unit.isEmpty || unit == 'null')
                    return name;
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
                  child: const Text("Save"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    final formState = _formKey.currentState;
    if (!(formState?.saveAndValidate() ?? false)) return;

    final values = formState!.value;
    final quantityString = values['quantity'] as String?;
    final quantity = _parseQuantity(quantityString);

    if (quantity == null) {
      _showSnackBar(context, 'Invalid quantity');
      return;
    }

    final entry = WasteEntryModel(
      id: '',
      userId: supabase.auth.currentUser?.id ?? '',
      areaId: values['area_id'] as String? ?? '',
      departmentId: values['department_id'] as String? ?? '',
      wasteTypeId: values['waste_type_id'] as String? ?? '',
      date: values['date'] as DateTime? ?? DateTime.now(),
      quantity: quantity,
      qrCode: (values['qr_code'] as String?)?.trim(),
      createdAt: DateTime.now(),
    );

    context.read<WasteEntryBloc>().add(CreateWasteEntry(entry));
    FocusScope.of(context).unfocus();
  }

  double? _parseQuantity(String? value) {
    if (value == null) return null;
    final sanitized = value.replaceAll(',', '.').trim();
    return double.tryParse(sanitized);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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
