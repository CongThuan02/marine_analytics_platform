import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/data/models/waste_type_model.dart';
import 'package:marine_analytics_platform/data/repositories/waste_type_repository.dart';

import '../../../data/models/waste_type_model.dart';

part 'waste_type_event.dart';
part 'waste_type_state.dart';

class WasteTypeBloc extends Bloc<WasteTypeEvent, WasteTypeState> {
  final WasteTypeRepository _repository = WasteTypeRepository();
  WasteTypeBloc() : super(WasteTypeState()) {
    on<CreateWasteTypeEvent>((event, emit) async {
      emit(state.copyWith(status: Status.loading));
      var res = await _repository.createWasteType(wasteType: state.wasteTypeModel!);
      emit(state.copyWith(status: Status.success, message: res, wasteTypeModel: WasteTypeModel()));
    });
    on<UpdateFieldWasteTypeEvent>((event, emit) {
      final data = state.wasteTypeModel?.toMap();
      data![event.key] = event.value;
      emit(state.copyWith(wasteTypeModel: WasteTypeModel.fromMap(data), status: Status.init));
    });
    on<GetWasteTypeEvent>((event, emit) async {
      emit(state.copyWith(status: Status.loading));
      final res = await _repository.getWasteType();
      emit(state.copyWith(status: Status.loaded, items: res));
    });
    on<DeleteWasteTypeEvent>((event, emit) async {
      emit(state.copyWith(status: Status.loading));
      var res = await _repository.deleteWasteType(id: event.id);
      emit(state.copyWith(message: res, status: Status.success));
    });
  }
}
