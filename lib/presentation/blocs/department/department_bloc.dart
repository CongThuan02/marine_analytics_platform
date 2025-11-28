import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/data/models/department_model.dart';
import 'package:marine_analytics_platform/data/repositories/department.dart';

part 'department_event.dart';
part 'department_state.dart';

class DepartmentBloc extends Bloc<DepartmentEvent, DepartmentState> {
  final DepartmentRepository _repository = DepartmentRepository();
  DepartmentBloc() : super(DepartmentState()) {
    on<CreateDepartmentEvent>((event, emit) async {
      emit(state.copyWith(status: Status.loading));
      var res = await _repository.createDepartment(department: state.departmentModel);
      emit(state.copyWith(
          status: Status.success,
          message: res,
          departmentModel: DepartmentModel(
            id: '',
            name: '',
            areaId: '',
            createdAt: DateTime.now(),
          )));
    });
    on<UpdateFieldDepartmentEvent>((event, emit) {
      final data = state.departmentModel.toMap();
      data[event.key] = event.value;
      emit(state.copyWith(departmentModel: DepartmentModel.fromMap(data), status: Status.init));
    });
    on<GetDepartmentEvent>((event, emit) async {
      emit(state.copyWith(status: Status.loading));
      final res = await _repository.getDepartment();
      emit(state.copyWith(status: Status.loaded, items: res));
    });
    on<DeleteDepartmentEvent>((event, emit) async {
      emit(state.copyWith(status: Status.loading));
      var res = await _repository.deleteDepartment(id: event.id);
      emit(state.copyWith(message: res, status: Status.success));
    });
  }
}
