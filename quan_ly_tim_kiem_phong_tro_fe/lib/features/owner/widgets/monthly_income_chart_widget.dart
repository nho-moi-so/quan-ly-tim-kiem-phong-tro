import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlyIncomeChartWidget extends StatefulWidget {
  const MonthlyIncomeChartWidget({super.key});

  @override
  State<MonthlyIncomeChartWidget> createState() => _MonthlyIncomeChartState();
}

class _MonthlyIncomeChartState extends State<MonthlyIncomeChartWidget> {
  String selectedMonth = 'June';

  final List<String> months = ['June', 'July', 'August'];

  final Map<String, List<double>> incomeData = {
    'June': List.generate(30, (index) => (index + 1) * 5.0),
    'July': List.generate(30, (index) => 150 - index * 2.0),
    'August': List.generate(30, (index) => (index % 2 == 0 ? 100 : 50)),
  };

  @override
  Widget build(BuildContext context) {
    final List<double> dailyIncome = incomeData[selectedMonth]!;

    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(blurRadius: 12, color: Colors.black12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Thu Nhập Mỗi Tháng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF243465),
                ),
              ),
              DropdownButton<String>(
                value: selectedMonth,
                items: months
                    .map((month) => DropdownMenuItem(
                          value: month,
                          child: Text(month),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMonth = value!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      interval: 5,
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      interval: 50,
                      showTitles: true,
                      getTitlesWidget: (value, _) => Text('${value.toInt()}'),
                      reservedSize: 35,
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      dailyIncome.length,
                      (index) => FlSpot(index + 1, dailyIncome[index]),
                    ),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                minX: 1,
                maxX: 30,
                minY: 0,
                maxY: 250,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
