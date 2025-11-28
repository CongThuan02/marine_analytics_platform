import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/data/models/area_model.dart';

import '../../../data/repositories/area_repository.dart';

part 'area_event.dart';
part 'area_state.dart';

class AreaBloc extends Bloc<AreaEvent, AreaState> {
  final AreaRepository _areaRepository = AreaRepository();
  AreaBloc() : super(AreaState(name: '', message: '')) {
    on<CreateArea>(_createArea);
    on<UpdateFieldName>(_updateFileName);
    on<GetAreas>(_getAreas);
    on<DeleteArea>(_deleteAreas);
  }
  Future<void> _createArea(CreateArea event, Emitter<AreaState> emit) async {
    emit(state.copyWith(status: Status.loading));
    var res = await _areaRepository.CreateArea(
        area: AreaModel(
      id: '',
      name: state.name,
      createdAt: DateTime.now(),
    ));
    emit(state.copyWith(message: res, status: Status.success));
  }

  Future<void> _updateFileName(UpdateFieldName event, Emitter<AreaState> emit) async {
    emit(state.copyWith(name: event.name, status: Status.init));
  }

  Future<void> _getAreas(GetAreas event, Emitter<AreaState> emit) async {
    emit(state.copyWith(status: Status.loading,areas: []));
    final res = await _areaRepository.getAllArea();
    emit(state.copyWith(status: Status.loaded, areas: res ?? []));
  }
  Future<void> _deleteAreas(DeleteArea event, Emitter<AreaState> emit) async {
    emit(state.copyWith(status: Status.loading));
    var res = await _areaRepository.deleteArea(id: event.id);
    emit(state.copyWith(message: res, status: Status.success));
  }
}
