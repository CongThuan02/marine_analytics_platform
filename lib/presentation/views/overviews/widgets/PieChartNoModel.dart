// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// class PieChartNoModel extends StatelessWidget {
//   const PieChartNoModel({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Dữ liệu trực tiếp dưới dạng List<Map>
//     final List<Map<String, dynamic>> data = [
//       {'category': 'Food', 'value': 40},
//       {'category': 'Transport', 'value': 25},
//       {'category': 'Entertainment', 'value': 15},
//       {'category': 'Others', 'value': 20},
//     ];

//     return SizedBox(
//       width: MediaQuery.of(context).size.width * 0.9,
//       height: MediaQuery.of(context).size.width * 0.9,
//       child: SfCircularChart(

//         title: ChartTitle(text: 'Expenses Breakdown'),
//         legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
//         tooltipBehavior: TooltipBehavior(enable: false),
//         enableMultiSelection: false,

//         series: <PieSeries<Map<String, dynamic>, String>>[
//           PieSeries<Map<String, dynamic>, String>(
//             dataSource: data,
//             xValueMapper: (datum, _) => datum['category'] as String,
//             yValueMapper: (datum, _) => double.parse('${datum['value']}'),
//             dataLabelSettings: const DataLabelSettings(isVisible: true,labelPosition: .outside),
//             explode: true, // Tách miếng khi click
//             explodeIndex: 0,
//           ),
//         ],
//       ),
//     );
//   }
// }
