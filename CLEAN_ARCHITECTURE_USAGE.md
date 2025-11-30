# Clean Architecture - Hướng dẫn sử dụng

## 📖 Tổng quan

Project đã được refactor theo Clean Architecture với 3 layers chính:
- **Domain Layer**: Business logic thuần túy (entities, use cases, repository interfaces)
- **Data Layer**: Xử lý data (models, datasources, repository implementations)
- **Presentation Layer**: UI và state management (BLoCs, views, widgets)

## 🚀 Cách sử dụng

### 1. Khởi tạo trong main.dart

```dart
import 'package:marine_analytics_platform/core/di/injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Dependency Injection
  await di.init();
  
  // ... other initializations
  runApp(MyApp());
}
```

### 2. Sử dụng BLoC với Dependency Injection

```dart
import 'package:marine_analytics_platform/core/di/injection_container.dart';

// Trong widget tree
BlocProvider(
  create: (_) => sl<ReminderBloc>(),
  child: ReminderPage(),
)
```

### 3. Làm việc với Entities trong UI

**Trước (sử dụng Model):**
```dart
class ReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  
  const ReminderCard({required this.reminder});
}
```

**Sau (sử dụng Entity):**
```dart
class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  
  const ReminderCard({required this.reminder});
}
```

### 4. Dispatch Events trong BLoC

**Reminder:**
```dart
// Load reminders
context.read<ReminderBloc>().add(const LoadReminders());

// Create reminder
context.read<ReminderBloc>().add(CreateReminderEvent(reminder));

// Toggle reminder
context.read<ReminderBloc>().add(ToggleReminderEvent(id, enabled));

// Delete reminder
context.read<ReminderBloc>().add(DeleteReminderEvent(id));
```

**Waste Limit:**
```dart
// Load limits
context.read<WasteLimitBloc>().add(const LoadWasteLimits());

// Create limit
context.read<WasteLimitBloc>().add(CreateWasteLimitEvent(limit));

// Delete limit
context.read<WasteLimitBloc>().add(DeleteWasteLimitEvent(id));
```

**Alert:**
```dart
// Load alerts
context.read<AlertBloc>().add(const LoadAlerts());
```

### 5. Listen to State Changes

```dart
BlocBuilder<ReminderBloc, ReminderState>(
  builder: (context, state) {
    if (state is ReminderLoading) {
      return CircularProgressIndicator();
    }
    
    if (state is ReminderLoaded) {
      return ListView.builder(
        itemCount: state.reminders.length,
        itemBuilder: (context, index) {
          final reminder = state.reminders[index];
          return ReminderCard(reminder: reminder);
        },
      );
    }
    
    if (state is ReminderError) {
      return Text('Error: ${state.message}');
    }
    
    return SizedBox();
  },
)
```

## 🔧 Tạo Feature mới

### Bước 1: Tạo Entity
```dart
// lib/domain/entities/my_entity.dart
import 'package:equatable/equatable.dart';

class MyEntity extends Equatable {
  final String id;
  final String name;

  const MyEntity({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
```

### Bước 2: Tạo Repository Interface
```dart
// lib/domain/repositories/my_repository.dart
import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/domain/entities/my_entity.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';

abstract class MyRepository {
  Future<Either<Failure, List<MyEntity>>> getAll();
  Future<Either<Failure, MyEntity>> create(MyEntity entity);
  Future<Either<Failure, void>> delete(String id);
}
```

### Bước 3: Tạo Use Cases
```dart
// lib/domain/usecases/my_feature/get_all_items.dart
import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/domain/entities/my_entity.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';
import 'package:marine_analytics_platform/domain/repositories/my_repository.dart';
import 'package:marine_analytics_platform/domain/usecases/usecase.dart';

class GetAllItems extends UseCase<List<MyEntity>, NoParams> {
  final MyRepository repository;

  GetAllItems(this.repository);

  @override
  Future<Either<Failure, List<MyEntity>>> call(NoParams params) {
    return repository.getAll();
  }
}
```

### Bước 4: Tạo Model
```dart
// lib/data/models/my_model.dart
import 'package:marine_analytics_platform/domain/entities/my_entity.dart';

class MyModel extends MyEntity {
  const MyModel({
    required super.id,
    required super.name,
  });

  factory MyModel.fromJson(Map<String, dynamic> json) {
    return MyModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  factory MyModel.fromEntity(MyEntity entity) {
    return MyModel(
      id: entity.id,
      name: entity.name,
    );
  }
}
```

### Bước 5: Tạo DataSource
```dart
// lib/data/datasources/my_remote_datasource.dart
import 'package:marine_analytics_platform/data/models/my_model.dart';
import 'package:marine_analytics_platform/global.dart';

abstract class MyRemoteDataSource {
  Future<List<MyModel>> getAll();
  Future<void> create(MyModel model);
  Future<void> delete(String id);
}

class MyRemoteDataSourceImpl implements MyRemoteDataSource {
  @override
  Future<List<MyModel>> getAll() async {
    final response = await supabase.from('my_table').select();
    return (response as List).map((e) => MyModel.fromJson(e)).toList();
  }

  @override
  Future<void> create(MyModel model) async {
    await supabase.from('my_table').insert(model.toJson());
  }

  @override
  Future<void> delete(String id) async {
    await supabase.from('my_table').delete().eq('id', id);
  }
}
```

### Bước 6: Implement Repository
```dart
// lib/data/repositories/my_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:marine_analytics_platform/data/datasources/my_remote_datasource.dart';
import 'package:marine_analytics_platform/data/models/my_model.dart';
import 'package:marine_analytics_platform/domain/entities/my_entity.dart';
import 'package:marine_analytics_platform/domain/failures/failure.dart';
import 'package:marine_analytics_platform/domain/repositories/my_repository.dart';

class MyRepositoryImpl implements MyRepository {
  final MyRemoteDataSource remoteDataSource;

  MyRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<MyEntity>>> getAll() async {
    try {
      final result = await remoteDataSource.getAll();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MyEntity>> create(MyEntity entity) async {
    try {
      final model = MyModel.fromEntity(entity);
      await remoteDataSource.create(model);
      return Right(entity);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      await remoteDataSource.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

### Bước 7: Tạo BLoC
```dart
// lib/presentation/blocs/my_feature/my_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:marine_analytics_platform/domain/entities/my_entity.dart';
import 'package:marine_analytics_platform/domain/usecases/my_feature/get_all_items.dart';
import 'package:marine_analytics_platform/domain/usecases/usecase.dart';

part 'my_event.dart';
part 'my_state.dart';

class MyBloc extends Bloc<MyEvent, MyState> {
  final GetAllItems getAllItems;

  MyBloc({required this.getAllItems}) : super(MyInitial()) {
    on<LoadItems>(_onLoadItems);
  }

  Future<void> _onLoadItems(
    LoadItems event,
    Emitter<MyState> emit,
  ) async {
    emit(MyLoading());
    final result = await getAllItems(NoParams());
    result.fold(
      (failure) => emit(MyError(failure.message)),
      (items) => emit(MyLoaded(items)),
    );
  }
}
```

### Bước 8: Register trong DI Container
```dart
// lib/core/di/injection_container.dart

// Blocs
sl.registerFactory(() => MyBloc(getAllItems: sl()));

// Use cases
sl.registerLazySingleton(() => GetAllItems(sl()));

// Repositories
sl.registerLazySingleton<MyRepository>(
  () => MyRepositoryImpl(sl()),
);

// Data sources
sl.registerLazySingleton<MyRemoteDataSource>(
  () => MyRemoteDataSourceImpl(),
);
```

## 🎯 Best Practices

1. **Entities không phụ thuộc vào bất kỳ layer nào khác**
2. **Use Cases chỉ chứa business logic thuần túy**
3. **Repository interfaces ở Domain, implementations ở Data**
4. **Models extend Entities và thêm serialization logic**
5. **BLoCs chỉ gọi Use Cases, không gọi trực tiếp Repositories**
6. **Sử dụng Either<Failure, Success> để handle errors**
7. **Tất cả dependencies được inject qua constructor**

## 🧪 Testing

### Test Use Case
```dart
test('should get all items from repository', () async {
  // Arrange
  when(mockRepository.getAll())
      .thenAnswer((_) async => Right(tItemList));
  
  // Act
  final result = await usecase(NoParams());
  
  // Assert
  expect(result, Right(tItemList));
  verify(mockRepository.getAll());
  verifyNoMoreInteractions(mockRepository);
});
```

### Test BLoC
```dart
blocTest<MyBloc, MyState>(
  'emits [MyLoading, MyLoaded] when LoadItems is added',
  build: () {
    when(mockGetAllItems(any))
        .thenAnswer((_) async => Right(tItemList));
    return MyBloc(getAllItems: mockGetAllItems);
  },
  act: (bloc) => bloc.add(LoadItems()),
  expect: () => [
    MyLoading(),
    MyLoaded(tItemList),
  ],
);
```

## 📚 Tài liệu tham khảo

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Dartz Package](https://pub.dev/packages/dartz)
- [Get It Package](https://pub.dev/packages/get_it)
