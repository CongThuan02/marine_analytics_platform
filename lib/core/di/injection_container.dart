import 'package:get_it/get_it.dart';
import 'package:marine_analytics_platform/data/datasources/alert_remote_datasource.dart';
import 'package:marine_analytics_platform/data/datasources/area_remote_datasource.dart';
import 'package:marine_analytics_platform/data/datasources/department_remote_datasource.dart';
import 'package:marine_analytics_platform/data/datasources/reminder_remote_datasource.dart';
import 'package:marine_analytics_platform/data/datasources/waste_limit_remote_datasource.dart';
import 'package:marine_analytics_platform/data/datasources/waste_type_remote_datasource.dart';
import 'package:marine_analytics_platform/data/repositories/alert_repository_impl.dart';
import 'package:marine_analytics_platform/data/repositories/area_repository_impl.dart';
import 'package:marine_analytics_platform/data/repositories/department_repository_impl.dart';
import 'package:marine_analytics_platform/data/repositories/reminder_repository_impl.dart';
import 'package:marine_analytics_platform/data/repositories/waste_limit_repository_impl.dart';
import 'package:marine_analytics_platform/data/repositories/waste_type_repository_impl.dart';
import 'package:marine_analytics_platform/domain/repositories/alert_repository.dart';
import 'package:marine_analytics_platform/domain/repositories/area_repository.dart';
import 'package:marine_analytics_platform/domain/repositories/department_repository.dart';
import 'package:marine_analytics_platform/domain/repositories/reminder_repository.dart';
import 'package:marine_analytics_platform/domain/repositories/waste_limit_repository.dart';
import 'package:marine_analytics_platform/domain/repositories/waste_type_repository.dart';
import 'package:marine_analytics_platform/domain/usecases/alert/get_all_alerts.dart';
import 'package:marine_analytics_platform/domain/usecases/department/get_all_departments.dart';
import 'package:marine_analytics_platform/domain/usecases/reminder/create_reminder.dart';
import 'package:marine_analytics_platform/domain/usecases/reminder/delete_reminder.dart';
import 'package:marine_analytics_platform/domain/usecases/reminder/get_all_reminders.dart';
import 'package:marine_analytics_platform/domain/usecases/reminder/toggle_reminder.dart';
import 'package:marine_analytics_platform/domain/usecases/waste_limit/create_waste_limit.dart';
import 'package:marine_analytics_platform/domain/usecases/waste_limit/delete_waste_limit.dart';
import 'package:marine_analytics_platform/domain/usecases/waste_limit/get_all_waste_limits.dart';
import 'package:marine_analytics_platform/domain/usecases/waste_type/get_all_waste_types.dart';
import 'package:marine_analytics_platform/presentation/blocs/alert/alert_bloc.dart';
import 'package:marine_analytics_platform/presentation/blocs/reminder/reminder_bloc.dart';
import 'package:marine_analytics_platform/presentation/blocs/waste_limit/waste_limit_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Blocs
  sl.registerFactory(() => AlertBloc(getAllAlerts: sl()));
  sl.registerFactory(() => ReminderBloc(
        getAllReminders: sl(),
        createReminder: sl(),
        deleteReminder: sl(),
        toggleReminder: sl(),
      ));
  sl.registerFactory(() => WasteLimitBloc(
        getAllWasteLimits: sl(),
        createWasteLimit: sl(),
        deleteWasteLimit: sl(),
      ));

  // Use cases - Alert
  sl.registerLazySingleton(() => GetAllAlerts(sl()));

  // Use cases - Reminder
  sl.registerLazySingleton(() => GetAllReminders(sl()));
  sl.registerLazySingleton(() => CreateReminder(sl()));
  sl.registerLazySingleton(() => DeleteReminder(sl()));
  sl.registerLazySingleton(() => ToggleReminder(sl()));

  // Use cases - Waste Limit
  sl.registerLazySingleton(() => GetAllWasteLimits(sl()));
  sl.registerLazySingleton(() => CreateWasteLimit(sl()));
  sl.registerLazySingleton(() => DeleteWasteLimit(sl()));

  // Use cases - Waste Type
  sl.registerLazySingleton(() => GetAllWasteTypes(sl()));

  // Use cases - Department
  sl.registerLazySingleton(() => GetAllDepartments(sl()));

  // Repositories
  sl.registerLazySingleton<AlertRepository>(
    () => AlertRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ReminderRepository>(
    () => ReminderRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<WasteLimitRepository>(
    () => WasteLimitRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<WasteTypeRepository>(
    () => WasteTypeRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<DepartmentRepository>(
    () => DepartmentRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AreaRepository>(
    () => AreaRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<AlertRemoteDataSource>(
    () => AlertRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<ReminderRemoteDataSource>(
    () => ReminderRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<WasteLimitRemoteDataSource>(
    () => WasteLimitRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<WasteTypeRemoteDataSource>(
    () => WasteTypeRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<DepartmentRemoteDataSource>(
    () => DepartmentRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<AreaRemoteDataSource>(
    () => AreaRemoteDataSourceImpl(),
  );
}
