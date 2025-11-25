import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marine_analytics_platform/core/theme/app_theme.dart';
import 'package:marine_analytics_platform/data/models/department_model.dart';
import 'package:marine_analytics_platform/data/models/reminder_model.dart';
import 'package:marine_analytics_platform/data/repositories/department.dart';
import 'package:marine_analytics_platform/presentation/blocs/reminder/reminder_bloc.dart';

class CreateReminderBottomSheet extends StatefulWidget {
  const CreateReminderBottomSheet({super.key});

  @override
  State<CreateReminderBottomSheet> createState() => _CreateReminderBottomSheetState();
}

class _CreateReminderBottomSheetState extends State<CreateReminderBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  
  DepartmentModel? _selectedDepartment;
  String _frequency = 'daily';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  
  List<DepartmentModel> _departments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    try {
      final departments = await DepartmentRepository().getDepartment();
      setState(() {
        _departments = departments ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.notifications_active, color: AppTheme.primaryGreen),
                const SizedBox(width: 12),
                const Text(
                  'Thêm Nhắc nhở mới',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DropdownButtonFormField<DepartmentModel>(
                            value: _selectedDepartment,
                            decoration: const InputDecoration(
                              labelText: 'Phòng ban',
                              prefixIcon: Icon(Icons.business),
                            ),
                            items: _departments.map((dept) {
                              return DropdownMenuItem(
                                value: dept,
                                child: Text(dept.name ?? 'Không có tên'),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => _selectedDepartment = value),
                            validator: (value) =>
                                value == null ? 'Vui lòng chọn phòng ban' : null,
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: _selectedTime,
                              );
                              if (time != null) {
                                setState(() => _selectedTime = time);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Thời gian',
                                prefixIcon: Icon(Icons.access_time),
                              ),
                              child: Text(
                                _selectedTime.format(context),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _frequency,
                            decoration: const InputDecoration(
                              labelText: 'Tần suất',
                              prefixIcon: Icon(Icons.repeat),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'daily', child: Text('Hàng ngày')),
                              DropdownMenuItem(value: 'weekly', child: Text('Hàng tuần')),
                            ],
                            onChanged: (value) =>
                                setState(() => _frequency = value ?? 'daily'),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              labelText: 'Nội dung nhắc nhở (tùy chọn)',
                              prefixIcon: Icon(Icons.message),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Hủy'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _submit,
                                  child: const Text('Thêm nhắc nhở'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final timeString =
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00';

      final reminder = ReminderModel(
        id: '',
        departmentId: _selectedDepartment!.id ?? '',
        timeOfDay: timeString,
        frequency: _frequency,
        message: _messageController.text.isEmpty ? null : _messageController.text,
        enabled: true,
        createdAt: DateTime.now(),
      );

      context.read<ReminderBloc>().add(CreateReminder(reminder));
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm nhắc nhở mới')),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
