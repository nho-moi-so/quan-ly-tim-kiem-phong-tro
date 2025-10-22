import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class RoomStatusRatioWidget extends StatelessWidget {
  const RoomStatusRatioWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> dataMap = {
      "Đã Cọc": 30,
      "Đang Thuê": 30,
      "Còn Trống": 40,
    };

    final List<Color> colorList = [
      const Color(0xFF198754), // xanh
      const Color(0xFFFFC107), // vàng
      const Color(0xFFDC3545), // đỏ
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFBFBFBF)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tỉ Lệ Phòng Trống',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Noto Sans',
            ),
          ),
          const SizedBox(height: 12),
          PieChart(
            dataMap: dataMap,
            animationDuration: const Duration(milliseconds: 800),
            chartType: ChartType.ring,
            colorList: colorList,
            chartLegendSpacing: 32,
            legendOptions: const LegendOptions(
              showLegends: true,
              legendPosition: LegendPosition.right,
              legendTextStyle: TextStyle(
                fontSize: 14,
                fontFamily: 'Noto Sans',
                fontWeight: FontWeight.w400,
              ),
            ),
            chartValuesOptions: const ChartValuesOptions(
              showChartValues: true,
              showChartValuesInPercentage: true,
              chartValueStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            totalValue: 100,
            ringStrokeWidth: 40,
          ),
        ],
      ),
    );
  }
}
