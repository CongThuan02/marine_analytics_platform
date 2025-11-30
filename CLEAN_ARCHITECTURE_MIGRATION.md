# Clean Architecture Migration Guide

## ✅ Đã hoàn thành

### 1. Domain Layer
- ✅ Entities (7 files)
  - `lib/domain/entities/alert.dart`
  - `lib/domain/entities/area.dart`
  - `lib/domain/entities/department.dart`
  - `lib/domain/entities/reminder.dart`
  - `lib/domain/entities/waste_entry.dart`
  - `lib/domain/entities/waste_limit.dart`
  - `lib/domain/entities/waste_type.dart`

- ✅ Repository Interfaces (7 files)
  - `lib/domain/repositories/alert_repository.dart`
  - `lib/domain/repositories/area_repository.dart`
  - `lib/domain/repositories/department_repository.dart`
  - `lib/domain/repositories/reminder_repository.dart`
  - `lib/domain/repositories/waste_entry_repository.dart`
  - `lib/domain/repositories/waste_limit_repository.dart`
  - `lib/domain/repositories/waste_type_repository.dart`

- ✅ Use Cases (11 files)
  - Alert: `get_all_alerts.dart`
  - Reminder: `get_all_reminders.dart`, `create_reminder.dart`, `delete_reminder.dart`, `toggle_reminder.dart`
  - Waste Limit: `get_all_waste_limits.dart`, `create_waste_limit.dart`, `delete_waste_limit.dart`
  - Waste Type: `get_all_waste_types.dart`
  - Department: `get_all_departments.dart`

- ✅ Failures
  - `lib/domain/failures/failure.dart`

### 2. Data Layer
- ✅ Models (7 files) - Refactored to extend Entities
  - `lib/data/models/alert_model.dart`
  - `lib/data/models/area_model.dart`
  - `lib/data/models/department_model.dart`
  - `lib/data/models/reminder_model.dart`
  - `lib/data/models/waste_entry_model.dart`
  - `lib/data/models/waste_limit_model.dart`
  - `lib/data/models/waste_type_model.dart`

- ✅ Data Sources (6 files)
  - `lib/data/datasources/alert_remote_datasource.dart`
  - `lib/data/datasources/area_remote_datasource.dart`
  - `lib/data/datasources/department_remote_datasource.dart`
  - `lib/data/datasources/reminder_remote_datasource.dart`
  - `lib/data/datasources/waste_limit_remote_datasource.dart`
  - `lib/data/datasources/waste_type_remote_datasource.dart`

- ✅ Repository Implementations (6 files)
  - `lib/data/repositories/alert_repository_impl.dart`
  - `lib/data/repositories/area_repository_impl.dart`
  - `lib/data/repositories/department_repository_impl.dart`
  - `lib/data/repositories/reminder_repository_impl.dart`
  - `lib/data/repositories/waste_limit_repository_impl.dart`
  - `lib/data/repositories/waste_type_repository_impl.dart`

### 3. Presentation Layer
- ✅ ReminderBloc - Refactored to use Use Cases
- ✅ Dependency Injection Container
  - `lib/core/di/injection_container.dart`

## 🔄 Cần hoàn thành

### 1. Refactor các BLoC còn lại
- [ ] `lib/presentation/blocs/waste_limit/waste_limit_bloc.dart`
- [ ] `lib/presentation/blocs/alert/alert_bloc.dart`
- [ ] `lib/presentation/blocs/waste_type/waste_type_bloc.dart`
- [ ] `lib/presentation/blocs/department/department_bloc.dart`
- [ ] `lib/presentation/blocs/area/area_bloc.dart`
- [ ] `lib/presentation/blocs/waste_entry/waste_entry_bloc.dart`

### 2. Cập nhật UI Pages
Các page cần cập nhật để sử dụng entities thay vì models:
- [ ] `lib/presentation/views/reminder/page.dart`
- [ ] `lib/presentation/views/waste_limit/page.dart`
- [ ] `lib/presentation/views/alerts/page.dart`
- [ ] `lib/presentation/views/waste_type/page.dart`
- [ ] `lib/presentation/views/department/page.dart`

### 3. Cập nhật main.dart
- [ ] Initialize Dependency Injection trong `main.dart`
- [ ] Cập nhật BlocProvider để sử dụng `sl()` (Service Locator)

### 4. Xóa các file cũ không dùng
- [ ] `lib/data/repositories/reminder_repository.dart` (old)
- [ ] `lib/data/repositories/waste_limit_repository.dart` (old)
- [ ] `lib/data/repositories/alert_repository.dart` (old)
- [ ] `lib/data/repositories/department.dart` (old)
- [ ] `lib/data/repositories/waste_type_repository.dart` (old)
- [ ] `lib/data/repositories/area_repository.dart` (old)

## 📝 Hướng dẫn sử dụng

### 1. Khởi tạo DI trong main.dart
```dart
import 'package:marine_analytics_platform/core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init(); // Initialize DI
  runApp(MyApp());
}
```

### 2. Sử dụng BLoC với DI
```dart
BlocProvider(
  create: (_) => sl<ReminderBloc>(),
  child: ReminderPage(),
)
```

### 3. Pattern để refactor BLoC
```dart
// Old
class MyBloc extends Bloc<MyEvent, MyState> {
  final MyRepository _repository;
  
  MyBloc({MyRepository? repository})
      : _repository = repository ?? MyRepository(),
        super(MyInitial());
}

// New
class MyBloc extends Bloc<MyEvent, MyState> {
  final GetAllItems getAllItems;
  final CreateItem createItem;
  
  MyBloc({
    required this.getAllItems,
    required this.createItem,
  }) : super(MyInitial());
}
```

## 🎯 Benefits

1. **Separation of Concerns**: Business logic tách biệt khỏi UI và Data
2. **Testability**: Dễ dàng test từng layer độc lập
3. **Maintainability**: Code dễ maintain và scale
4. **Dependency Inversion**: Phụ thuộc vào abstractions, không phụ thuộc vào implementations
5. **Reusability**: Use cases có thể tái sử dụng ở nhiều nơi

## 📚 Cấu trúc thư mục

```
lib/
├── core/
│   ├── constants/
│   ├── di/
│   │   └── injection_container.dart
│   ├── services/
│   ├── theme/
│   └── utils/
├── domain/
│   ├── entities/
│   ├── failures/
│   ├── repositories/
│   └── usecases/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
└── presentation/
    ├── blocs/
    ├── views/
    └── widgets/
```
