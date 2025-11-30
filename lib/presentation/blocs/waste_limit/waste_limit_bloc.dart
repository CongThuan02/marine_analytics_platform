import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:marine_analytics_platform/domain/entities/waste_limit.dart';
import 'package:marine_analytics_platform/domain/usecases/usecase.dart';
import 'package:marine_analytics_platform/domain/usecases/waste_limit/create_waste_limit.dart';
import 'package:marine_analytics_platform/domain/usecases/waste_limit/delete_waste_limit.dart';
import 'package:marine_analytics_platform/domain/usecases/waste_limit/get_all_waste_limits.dart';

part 'waste_limit_event.dart';
part 'waste_limit_state.dart';

class WasteLimitBloc extends Bloc<WasteLimitEvent, WasteLimitState> {
  final GetAllWasteLimits getAllWasteLimits;
  final CreateWasteLimit createWasteLimit;
  final DeleteWasteLimit deleteWasteLimit;

  WasteLimitBloc({
    required this.getAllWasteLimits,
    required this.createWasteLimit,
    required this.deleteWasteLimit,
  }) : super(WasteLimitInitial()) {
    on<LoadWasteLimits>(_onLoadWasteLimits);
    on<CreateWasteLimitEvent>(_onCreateWasteLimit);
    on<DeleteWasteLimitEvent>(_onDeleteWasteLimit);
  }

  Future<void> _onLoadWasteLimits(
    LoadWasteLimits event,
    Emitter<WasteLimitState> emit,
  ) async {
    emit(WasteLimitLoading());
    final result = await getAllWasteLimits(NoParams());
    result.fold(
      (failure) => emit(WasteLimitError(failure.message)),
      (limits) => emit(WasteLimitLoaded(limits)),
    );
  }

  Future<void> _onCreateWasteLimit(
    CreateWasteLimitEvent event,
    Emitter<WasteLimitState> emit,
  ) async {
    final result = await createWasteLimit(CreateWasteLimitParams(event.limit));
    result.fold(
      (failure) => emit(WasteLimitError(failure.message)),
      (_) => add(const LoadWasteLimits()),
    );
  }

  Future<void> _onDeleteWasteLimit(
    DeleteWasteLimitEvent event,
    Emitter<WasteLimitState> emit,
  ) async {
    final result = await deleteWasteLimit(DeleteWasteLimitParams(event.id));
    result.fold(
      (failure) => emit(WasteLimitError(failure.message)),
      (_) => add(const LoadWasteLimits()),
    );
  }
}
