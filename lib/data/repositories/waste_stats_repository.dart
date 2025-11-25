import 'package:marine_analytics_platform/data/models/waste_stats.dart';
import 'package:marine_analytics_platform/global.dart';

class WasteStatsRepository {
  Future<WasteStats> fetchStats({required StatsPeriod period, required DateTime reference}) async {
    final range = _calculateRange(period, reference);

    String _formatDate(DateTime date) =>
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final response = await supabase
        .from('waste_entries')
        .select(
          '''
        quantity,
        date,
        waste_types(name, unit)
      ''',
        )
        .gte('date', _formatDate(range.start))
        .lte('date', _formatDate(range.end));

    final data = (response as List<dynamic>).cast<Map<String, dynamic>>();
    return _buildStats(data);
  }

  _DateRange _calculateRange(StatsPeriod period, DateTime reference) {
    switch (period) {
      case StatsPeriod.day:
        final start = DateTime(reference.year, reference.month, reference.day);
        return _DateRange(start, start);
      case StatsPeriod.month:
        final start = DateTime(reference.year, reference.month);
        final end = DateTime(reference.year, reference.month + 1).subtract(const Duration(days: 1));
        return _DateRange(start, end);
      case StatsPeriod.year:
        final start = DateTime(reference.year);
        final end = DateTime(reference.year + 1).subtract(const Duration(days: 1));
        return _DateRange(start, end);
    }
  }

  WasteStats _buildStats(List<Map<String, dynamic>> rows) {
    double total = 0;
    final Map<String, WasteBreakdown> breakdownMap = {};

    for (final row in rows) {
      final qty = (row['quantity'] as num?)?.toDouble() ?? 0;
      final wasteType = (row['waste_types'] as Map<String, dynamic>?) ?? {};
      final unit = wasteType['unit']?.toString()?.toLowerCase();
      
      // Chuyển đổi tất cả về kg
      final qtyInKg = _convertToKg(qty, unit);
      total += qtyInKg;

      final name = (wasteType['name'] ?? 'Không xác định').toString();
      final key = name; // Không cần unit trong key vì tất cả đều là kg

      final existing = breakdownMap[key];
      if (existing == null) {
        breakdownMap[key] = WasteBreakdown(name: name, unit: 'kg', quantity: qtyInKg);
      } else {
        breakdownMap[key] = WasteBreakdown(name: name, unit: 'kg', quantity: existing.quantity + qtyInKg);
      }
    }

    final breakdowns = breakdownMap.values.toList()
      ..sort((a, b) => b.quantity.compareTo(a.quantity));

    return WasteStats(totalQuantity: total, entryCount: rows.length, breakdowns: breakdowns);
  }

  /// Chuyển đổi các đơn vị khác nhau về kg
  double _convertToKg(double quantity, String? unit) {
    if (unit == null || unit.isEmpty) return quantity;
    
    final unitLower = unit.toLowerCase().trim();
    
    // Đơn vị khối lượng
    switch (unitLower) {
      case 'kg':
      case 'kilogram':
      case 'kilo':
        return quantity;
      case 'g':
      case 'gram':
        return quantity / 1000;
      case 'mg':
      case 'milligram':
        return quantity / 1000000;
      case 't':
      case 'ton':
      case 'tonne':
      case 'tấn':
        return quantity * 1000;
      case 'lb':
      case 'pound':
        return quantity * 0.453592;
      case 'oz':
      case 'ounce':
        return quantity * 0.0283495;
      default:
        // Nếu không nhận diện được đơn vị, giả định là kg
        return quantity;
    }
  }
}

class _DateRange {
  final DateTime start;
  final DateTime end;

  const _DateRange(this.start, this.end);
}

