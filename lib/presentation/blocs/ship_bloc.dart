import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marine_analytics_platform/data/models/ship_model.dart';
import 'package:marine_analytics_platform/data/repositories/ship_repository.dart';
import 'package:marine_analytics_platform/domain/usecases/get_all_ships_usecase.dart';

part 'ship_event.dart';
part 'ship_state.dart';

class ShipBloc extends Bloc<ShipEvent, ShipState> {
  final GetAllShipsUseCase useCase = GetAllShipsUseCase();
  ShipBloc() : super(ShipState()) {
    on<LoadShipsEvent>(_onLoadShips);
  }

  Future<void> _onLoadShips(LoadShipsEvent event, Emitter<ShipState> emit) async {
    emit(state.copyWith(loading: true));

    try {
      final ships = await useCase.call();
      emit(state.copyWith(loading: false, ships: ships));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
