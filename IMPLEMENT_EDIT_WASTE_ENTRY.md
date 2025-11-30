# Implement Edit Waste Entry Feature

## Summary
Thêm chức năng sửa lịch sử chất thải (edit waste entry) với local notification khi vượt giới hạn.

## ✅ Đã có sẵn
- `WasteEntryRepository.updateWasteEntry()` - Method update với notification check
- `LocalNotificationService` - Service notification hoạt động tốt
- UI list waste entries trong History page

## 🔧 Cần implement

### 1. Thêm UpdateWasteEntry Event
**File**: `lib/presentation/blocs/waste_entry/waste_entry_event.dart`

```dart
class UpdateWasteEntry extends WasteEntryEvent {
  final String id;
  final WasteEntryModel entry;
  
  const UpdateWasteEntry({
    required this.id,
    required this.entry,
  });
  
  @override
  List<Object?> get props => [id, entry];
}
```

### 2. Thêm handler trong Bloc
**File**: `lib/presentation/blocs/waste_entry/waste_entry_bloc.dart`

```dart
// Trong constructor
WasteEntryBloc() : super(...) {
  on<LoadWasteEntries>(_onLoadWasteEntries);
  on<CreateWasteEntry>(_onCreateWasteEntry);
  on<UpdateWasteEntry>(_onUpdateWasteEntry); // ADD THIS
  on<DeleteWasteEntry>(_onDeleteWasteEntry);
}

// Thêm handler method
Future<void> _onUpdateWasteEntry(
  UpdateWasteEntry event,
  Emitter<WasteEntryState> emit,
) async {
  try {
    emit(state.copyWith(status: Status.loading));
    
    final message = await _repository.updateWasteEntry(
      id: event.id,
      entry: event.entry,
    );
    
    // Reload entries
    final entries = await _repository.fetchWasteEntries();
    
    emit(state.copyWith(
      status: Status.success,
      message: message,
      entries: entries,
    ));
  } catch (e) {
    emit(state.copyWith(
      status: Status.fail,
      message: e.toString(),
    ));
  }
}
```

### 3. Thêm Edit Button vào List Item
**File**: `lib/presentation/views/history_page.dart`

Tìm phần hiển thị waste entry item và thêm edit button:

```dart
ListTile(
  title: Text('${entry.wasteTypeName} - ${entry.quantity} kg'),
  subtitle: Text('${entry.areaName} • ${_formatDate(entry.date)}'),
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      // ADD EDIT BUTTON
      IconButton(
        icon: Icon(Icons.edit, color: AppTheme.primaryGreen),
        onPressed: () => _showEditSheet(context, entry),
      ),
      // Existing delete button
      IconButton(
        icon: Icon(Icons.delete, color: Colors.red),
        onPressed: () => _showDeleteDialog(context, entry),
      ),
    ],
  ),
)
```

### 4. Tạo Edit Bottom Sheet
**File**: `lib/presentation/views/history/widgets/edit_waste_entry_sheet.dart`

```dart
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

class EditWasteEntrySheet extends StatefulWidget {
  final WasteEntryModel entry;
  
  const EditWasteEntrySheet({super.key, required this.entry});

  @override
  State<EditWasteEntrySheet> createState() => _EditWasteEntrySheetState();
}

class _EditWasteEntrySheetState extends State<EditWasteEntrySheet> {
  final _formKey = GlobalKey<FormBuilderState>();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.entry.date ?? DateTime.now();
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
            'quantity': widget.entry.quantity.toString(),
            'qr_code': widget.entry.qrCode ?? '',
            'date': _selectedDate,
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
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
              _DateField(
                initialDate: _selectedDate,
                onDateChanged: (date) => _selectedDate = date,
              ),
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
              FormTextField(
                name: 'qr_code',
                label: 'QR Code (optional)',
              ),
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

    final updatedEntry = WasteEntryModel(
      id: widget.entry.id,
      userId: supabase.auth.currentUser?.id ?? '',
      areaId: values['area_id'] as String? ?? '',
      departmentId: values['department_id'] as String? ?? '',
      wasteTypeId: values['waste_type_id'] as String? ?? '',
      date: _selectedDate,
      quantity: quantity,
      qrCode: (values['qr_code'] as String?)?.trim(),
      createdAt: widget.entry.createdAt,
    );

    context.read<WasteEntryBloc>().add(
      UpdateWasteEntry(
        id: widget.entry.id,
        entry: updatedEntry,
      ),
    );
    
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

class _DateField extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateChanged;

  const _DateField({
    required this.initialDate,
    required this.onDateChanged,
  });

  @override
  State<_DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<_DateField> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<DateTime>(
      name: 'date',
      initialValue: _selectedDate,
      validator: (value) {
        if (value == null) return 'Please select entry date';
        return null;
      },
      builder: (field) {
        Future<void> pickDate() async {
          final now = DateTime.now();
          final selectedDate = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(now.year - 5),
            lastDate: DateTime(now.year + 5),
          );
          if (selectedDate != null) {
            setState(() {
              _selectedDate = selectedDate;
            });
            widget.onDateChanged(selectedDate);
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
            child: Text(_formatDate(_selectedDate)),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}
```

### 5. Thêm method _showEditSheet
**File**: `lib/presentation/views/history_page.dart`

```dart
void _showEditSheet(BuildContext context, WasteEntryModel entry) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (bottomSheetContext) => BlocProvider.value(
      value: context.read<WasteEntryBloc>(),
      child: EditWasteEntrySheet(entry: entry),
    ),
  );
}
```

## 🧪 Testing

1. Chạy app: `flutter run`
2. Vào History page
3. Tap icon edit trên một waste entry
4. Sửa quantity thành số lớn hơn limit
5. Tap Update
6. Kiểm tra:
   - Data được update ✅
   - Notification hiển thị nếu vượt giới hạn ✅
   - Navigate đến Alerts khi tap notification ✅

## ✅ Kết quả

Sau khi implement:
- Có thể sửa waste entry
- Notification tự động khi sửa vượt giới hạn
- UI consistent với create sheet
- Code reuse tối đa

## 📝 Notes

- Repository method `updateWasteEntry()` đã có sẵn với notification check
- Chỉ cần thêm UI và Bloc event
- Notification sẽ tự động hoạt động khi update
