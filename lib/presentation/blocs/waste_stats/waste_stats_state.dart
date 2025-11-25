part of 'waste_stats_cubit.dart';

class WasteStatsState extends Equatable {
  final WasteStats stats;
  final Status status;
  final String? message;
  final DateTime referenceDate;

  const WasteStatsState({
    required this.stats,
    this.status = Status.init,
    this.message,
    required this.referenceDate,
  });

  WasteStatsState copyWith({
    WasteStats? stats,
    Status? status,
    String? message,
    DateTime? referenceDate,
    bool clearMessage = false,
  }) {
    return WasteStatsState(
      stats: stats ?? this.stats,
      status: status ?? this.status,
      message: clearMessage ? null : (message ?? this.message),
      referenceDate: referenceDate ?? this.referenceDate,
    );
  }

  @override
  List<Object?> get props => [stats, status, message, referenceDate];
}

