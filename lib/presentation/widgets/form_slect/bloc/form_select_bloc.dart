import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/presentation/widgets/form_slect/form_select_repository.dart';

part 'form_select_event.dart';
part 'form_select_state.dart';

class FormSelectBloc extends Bloc<FormSelectEvent, FormSelectState> {
  final FormSelectRepository _formSelectRepository = FormSelectRepository();
  FormSelectBloc() : super(FormSelectState(items: [])) {
    on<GetItemsFormEvent>((event, emit) async {
      emit(state.copyWith(status: Status.loading));
      final res = await _formSelectRepository.getAllItems(tableName: event.tableName);

      emit(state.copyWith(status: Status.loaded, items: res, selected: state.selected ?? "chon"));
    });
    on<UpdateFiledFormEvent>((event, emit) {
      emit(state.copyWith(items: state.items, status: Status.loaded, selected: event.value!));
    });
  }
}
