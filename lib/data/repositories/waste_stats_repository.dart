import 'package:marine_analytics_platform/data/models/waste_stats.dart';
import 'package:marine_analytics_platform/global.dart';

class WasteStatsRepository {
  /// Fetch trend data for comparison across periods
  Future<List<TrendDataPoint>> fetchTrendData({
    required TrendPeriod trendPeriod,
    required DateTime endDate,
    int periodsCount = 12,
  }) async {
    final List<TrendDataPoint> trendData = [];

    for (int i = periodsCount - 1; i >= 0; i--) {
      final DateTime periodDate;
      final String periodLabel;

      switch (trendPeriod) {
        case TrendPeriod.monthly:
          periodDate = DateTime(endDate.year, endDate.month - i, 1);
          periodLabel =
              '${periodDate.month.toString().padLeft(2, '0')}/${periodDate.year}';
          break;
        case TrendPeriod.yearly:
          periodDate = DateTime(endDate.year - i, 1, 1);
          periodLabel = '${periodDate.year}';
          break;
      }

      final stats = await fetchStats(
        period: trendPeriod == TrendPeriod.monthly
            ? StatsPeriod.month
            : StatsPeriod.year,
        reference: periodDate,
      );

      trendData.add(
        TrendDataPoint(
          period: periodLabel,
          quantity: stats.totalQuantity,
          date: periodDate,
          entryCount: stats.entryCount,
        ),
      );
    }

    return trendData;
  }

  Future<WasteStats> fetchStats({
    required StatsPeriod period,
    required DateTime reference,
  }) async {
    final range = _calculateRange(period, reference);

    String formatDate(DateTime date) =>
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    try {
      // Use RPC function to bypass RLS and get data from all users
      final response = await supabase.rpc(
        'get_waste_stats_all_users',
        params: {
          'start_date': formatDate(range.start),
          'end_date': formatDate(range.end),
        },
      );

      final data = (response as List<dynamic>).cast<Map<String, dynamic>>();
      return _buildStatsFromRpc(data);
    } catch (e) {
      // Fallback: If function not deployed yet, use direct query
      print('⚠️ RPC function not found, using direct query. Error: $e');
      print(
        '📝 Please deploy supabase_stats_all_users.sql to see all users data',
      );

      final response = await supabase
          .from('waste_entries')
          .select('''
        quantity,
        date,
        waste_types(name, unit)
      ''')
          .gte('date', formatDate(range.start))
          .lte('date', formatDate(range.end));

      final data = (response as List<dynamic>).cast<Map<String, dynamic>>();
      return _buildStats(data);
    }
  }

  _DateRange _calculateRange(StatsPeriod period, DateTime reference) {
    switch (period) {
      case StatsPeriod.day:
        final start = DateTime(reference.year, reference.month, reference.day);
        return _DateRange(start, start);
      case StatsPeriod.month:
        final start = DateTime(reference.year, reference.month);
        final end = DateTime(
          reference.year,
          reference.month + 1,
        ).subtract(const Duration(days: 1));
        return _DateRange(start, end);
      case StatsPeriod.year:
        final start = DateTime(reference.year);
        final end = DateTime(
          reference.year + 1,
        ).subtract(const Duration(days: 1));
        return _DateRange(start, end);
    }
  }

  WasteStats _buildStats(List<Map<String, dynamic>> rows) {
    double total = 0;
    final Map<String, WasteBreakdown> breakdownMap = {};

    for (final row in rows) {
      final qty = (row['quantity'] as num?)?.toDouble() ?? 0;
      final wasteType = (row['waste_types'] as Map<String, dynamic>?) ?? {};
      final unit = wasteType['unit']?.toString().toLowerCase();

      // Convert all to kg
      final qtyInKg = _convertToKg(qty, unit);
      total += qtyInKg;

      final name = (wasteType['name'] ?? 'Unspecified').toString();
      final key = name; // No need for unit in key since everything is in kg

      final existing = breakdownMap[key];
      if (existing == null) {
        breakdownMap[key] = WasteBreakdown(
          name: name,
          unit: 'kg',
          quantity: qtyInKg,
        );
      } else {
        breakdownMap[key] = WasteBreakdown(
          name: name,
          unit: 'kg',
          quantity: existing.quantity + qtyInKg,
        );
      }
    }

    final breakdowns = breakdownMap.values.toList()
      ..sort((a, b) => b.quantity.compareTo(a.quantity));

    return WasteStats(
      totalQuantity: total,
      entryCount: rows.length,
      breakdowns: breakdowns,
    );
  }

  WasteStats _buildStatsFromRpc(List<Map<String, dynamic>> rows) {
    double total = 0;
    final Map<String, WasteBreakdown> breakdownMap = {};

    for (final row in rows) {
      final qty = (row['quantity'] as num?)?.toDouble() ?? 0;
      final unit = row['waste_type_unit']?.toString().toLowerCase();

      // Convert all to kg
      final qtyInKg = _convertToKg(qty, unit);
      total += qtyInKg;

      final name = (row['waste_type_name'] ?? 'Unspecified').toString();
      final key = name; // No need for unit in key since everything is in kg

      final existing = breakdownMap[key];
      if (existing == null) {
        breakdownMap[key] = WasteBreakdown(
          name: name,
          unit: 'kg',
          quantity: qtyInKg,
        );
      } else {
        breakdownMap[key] = WasteBreakdown(
          name: name,
          unit: 'kg',
          quantity: existing.quantity + qtyInKg,
        );
      }
    }

    final breakdowns = breakdownMap.values.toList()
      ..sort((a, b) => b.quantity.compareTo(a.quantity));

    return WasteStats(
      totalQuantity: total,
      entryCount: rows.length,
      breakdowns: breakdowns,
    );
  }

  /// Convert different units to kg
  double _convertToKg(double quantity, String? unit) {
    if (unit == null || unit.isEmpty) return quantity;

    final unitLower = unit.toLowerCase().trim();

    // Weight units
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
      case 'ton': // Metric ton
        return quantity * 1000;
      case 'lb':
      case 'pound':
        return quantity * 0.453592;
      case 'oz':
      case 'ounce':
        return quantity * 0.0283495;
      default:
        // If unit not recognized, assume kg
        return quantity;
    }
  }
}

class _DateRange {
  final DateTime start;
  final DateTime end;

  const _DateRange(this.start, this.end);
}

enum TrendPeriod { monthly, yearly }

class TrendDataPoint {
  final String period;
  final double quantity;
  final DateTime date;
  final int entryCount;

  TrendDataPoint({
    required this.period,
    required this.quantity,
    required this.date,
    required this.entryCount,
  });
}
