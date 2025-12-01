import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marine_analytics_platform/core/theme/app_theme.dart';
import 'package:marine_analytics_platform/data/models/area_model.dart';
import 'package:marine_analytics_platform/data/models/waste_limit_model.dart';
import 'package:marine_analytics_platform/data/models/waste_type_model.dart';
import 'package:marine_analytics_platform/data/repositories/area_repository.dart';
import 'package:marine_analytics_platform/data/repositories/waste_type_repository.dart';
import 'package:marine_analytics_platform/presentation/blocs/waste_limit/waste_limit_bloc.dart';

class CreateLimitBottomSheet extends StatefulWidget {
  const CreateLimitBottomSheet({super.key});

  @override
  State<CreateLimitBottomSheet> createState() => _CreateLimitBottomSheetState();
}

class _CreateLimitBottomSheetState extends State<CreateLimitBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();

  AreaModel? _selectedArea;
  WasteTypeModel? _selectedWasteType;

  List<AreaModel> _areas = [];
  List<WasteTypeModel> _wasteTypes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final areas = await AreaRepository().getAllArea();
      final wasteTypes = await WasteTypeRepository().getWasteType();
      setState(() {
        _areas = areas ?? [];
        _wasteTypes = wasteTypes ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e')));
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
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.add_circle_outline, color: AppTheme.primaryGreen),
                const SizedBox(width: 12),
                const Text('Thêm mới hạn mức', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
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
                          DropdownButtonFormField<AreaModel>(
                            initialValue: _selectedArea,
                            decoration: const InputDecoration(
                              labelText: 'Khu vực',
                              prefixIcon: Icon(Icons.location_on),
                            ),
                            items: _areas.map((area) {
                              return DropdownMenuItem(value: area, child: Text(area.name ?? 'No name'));
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedArea = value),
                            validator: (value) => value == null ? 'Vui lòng chọn khu vực' : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<WasteTypeModel>(
                            initialValue: _selectedWasteType,
                            decoration: const InputDecoration(
                              labelText: 'Loại chất thải',
                              prefixIcon: Icon(Icons.delete_outline),
                            ),
                            items: _wasteTypes.map((type) {
                              return DropdownMenuItem(value: type, child: Text('${type.name} (${type.unit})'));
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedWasteType = value),
                            validator: (value) => value == null ? 'Vui lòng chọn loại chất thải' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _limitController,
                            decoration: InputDecoration(
                              labelText: 'Giới hạn hàng ngày',
                              prefixIcon: const Icon(Icons.speed),
                              suffixText: _selectedWasteType?.unit ?? 'kg',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter limit value';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter valid number';
                              }
                              if (double.parse(value) <= 0) {
                                return 'Limit must be greater than 0';
                              }
                              return null;
                            },
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
                                  child: const Text('Thêm hạn mức'),
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
      final limit = WasteLimitModel(
        id: '',
        areaId: _selectedArea!.id ?? '',
        wasteTypeId: _selectedWasteType!.id ?? '',
        dailyLimit: double.parse(_limitController.text),
        createdAt: DateTime.now(),
      );

      context.read<WasteLimitBloc>().add(CreateWasteLimitEvent(limit));
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm hạn mức mới')));
    }
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }
}
