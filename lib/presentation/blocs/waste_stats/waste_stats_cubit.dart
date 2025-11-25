import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:marine_analytics_platform/core/constants/enum_status.dart';
import 'package:marine_analytics_platform/data/models/waste_stats.dart';
import 'package:marine_analytics_platform/data/repositories/waste_stats_repository.dart';

part 'waste_stats_state.dart';

class WasteStatsCubit extends Cubit<WasteStatsState> {
  final StatsPeriod period;
  final WasteStatsRepository _repository;

  WasteStatsCubit({
    required this.period,
    WasteStatsRepository? repository,
    DateTime? initialDate,
  })  : _repository = repository ?? WasteStatsRepository(),
        super(WasteStatsState(referenceDate: initialDate ?? DateTime.now(), stats: WasteStats.empty()));

  Future<void> load({DateTime? referenceDate}) async {
    final target = referenceDate ?? state.referenceDate;
    emit(state.copyWith(status: Status.loading, referenceDate: target, clearMessage: true));
    try {
      final stats = await _repository.fetchStats(period: period, reference: target);
      emit(state.copyWith(status: Status.loaded, stats: stats, referenceDate: target));
    } catch (e) {
      emit(state.copyWith(status: Status.fail, message: e.toString()));
    }
  }
}

