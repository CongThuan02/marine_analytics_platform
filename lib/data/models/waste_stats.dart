import 'package:equatable/equatable.dart';

enum StatsPeriod { day, month, year }

class WasteBreakdown extends Equatable {
  final String name;
  final String? unit;
  final double quantity;

  const WasteBreakdown({required this.name, this.unit, required this.quantity});

  @override
  List<Object?> get props => [name, unit, quantity];
}

class WasteStats extends Equatable {
  final double totalQuantity;
  final int entryCount;
  final List<WasteBreakdown> breakdowns;

  const WasteStats({
    required this.totalQuantity,
    required this.entryCount,
    required this.breakdowns,
  });

  factory WasteStats.empty() => const WasteStats(totalQuantity: 0, entryCount: 0, breakdowns: []);

  @override
  List<Object?> get props => [totalQuantity, entryCount, breakdowns];
}

