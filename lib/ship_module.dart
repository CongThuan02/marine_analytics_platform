// import 'package:get_it/get_it.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:marine_analytics_platform/presentation/blocs/ship_bloc.dart';
//
// import 'data/repositories/ship_repository.dart';
// import 'domain/usecases/get_all_ships_usecase.dart';
//
// final sl = GetIt.instance;
//
// void setupShipModule() {
//   sl.registerLazySingleton(() => FirebaseFirestore.instance);
//
//   sl.registerLazySingleton(() => ShipRepository(sl()));
//   sl.registerLazySingleton(() => GetAllShipsUseCase(sl()));
//
//   sl.registerFactory(() => ShipBloc(sl()));
// }
