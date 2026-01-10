import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyIncomeChartWidget extends StatefulWidget {
  final Map<String, List<double>> incomeData;
  final List<String> months;
  final String? initialMonth;

  const MonthlyIncomeChartWidget({
    super.key,
    required this.incomeData,
    required this.months,
    this.initialMonth,
  });

  @override
  State<MonthlyIncomeChartWidget> createState() => _MonthlyIncomeChartState();
}

class _MonthlyIncomeChartState extends State<MonthlyIncomeChartWidget> {
  late String selectedMonth;
  List<String> availableMonths = [];

  @override
  void initState() {
    super.initState();
    // Tạo danh sách các tháng khả dụng (giữ thứ tự widget.months, bổ sung keys từ incomeData)
    final List<String> unionMonths = [];
    for (final m in widget.months) {
      if (!unionMonths.contains(m)) unionMonths.add(m);
    }
    for (final k in widget.incomeData.keys) {
      if (!unionMonths.contains(k)) unionMonths.add(k);
    }
    if (unionMonths.isNotEmpty) {
      availableMonths = unionMonths;
    } else {
      availableMonths = ['Tháng 6'];
    }

    // Chọn tháng ban đầu theo thứ tự ưu tiên:
    // 1) Nếu initialMonth được cung cấp và có dữ liệu trong incomeData -> dùng nó
    // 2) Nếu initialMonth được cung cấp và nằm trong availableMonths -> dùng nó
    // 3) Ngược lại, chọn tháng đầu tiên trong availableMonths mà có dữ liệu
    if (widget.initialMonth != null) {
      final im = widget.initialMonth!;
      if (widget.incomeData.containsKey(im) && (widget.incomeData[im]?.isNotEmpty ?? false)) {
        selectedMonth = im;
        return;
      }
      if (availableMonths.contains(im)) {
        selectedMonth = im;
        return;
      }
    }

    // Chọn tháng đầu tiên có dữ liệu, nếu không có thì lấy first
    final firstWithData = availableMonths.firstWhere(
      (m) => widget.incomeData.containsKey(m) && (widget.incomeData[m]?.isNotEmpty ?? false),
      orElse: () => availableMonths.first,
    );
    selectedMonth = firstWithData;
  }

  @override
  Widget build(BuildContext context) {
  // Lấy dữ liệu; đảm bảo luôn có ít nhất một điểm để fl_chart không lỗi
  var dailyIncome = widget.incomeData[selectedMonth] ?? [];
  if (dailyIncome.isEmpty) {
    dailyIncome = [0.0];
  }

  final maxIncome = dailyIncome.isNotEmpty
    ? dailyIncome.reduce((a, b) => a > b ? a : b)
    : 100.0;
  final avgIncome = dailyIncome.isNotEmpty
    ? dailyIncome.reduce((a, b) => a + b) / dailyIncome.length
    : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF8F9FF),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        // stronger, slightly darker outer border for more emphasis
        border: Border.all(color: const Color(0xFFBFCDE6), width: 2),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            spreadRadius: 0,
            offset: const Offset(0, 6),
            color: Colors.black.withOpacity(0.08),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thu Nhập Hàng Tháng',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Noto Sans',
                      color: Color(0xFF1A1F36),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Trung bình: ${avgIncome.toStringAsFixed(0)} triệu',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Noto Sans',
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4C6FFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF4C6FFF).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: DropdownButton<String>(
                  value: selectedMonth,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF4C6FFF), size: 20),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Noto Sans',
                    color: Color(0xFF4C6FFF),
                  ),
          items: availableMonths
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
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Chart
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxIncome * 1.2).ceilToDouble(),
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 50,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFFE3E8EF),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      interval: 5,
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value > dailyIncome.length) {
                          return const SizedBox();
                        }
                        // Chỉ hiển thị các ngày 5, 10, 15, 20, 25, 30
                        if (value % 5 != 0) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${value.toInt()}',
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'Noto Sans',
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      interval: 50,
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, _) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '${value.toInt()}',
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'Noto Sans',
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: const Color(0xFFE3E8EF), width: 1),
                    left: BorderSide(color: const Color(0xFFE3E8EF), width: 1),
                  ),
                ),
                barGroups: List.generate(
                  dailyIncome.length,
                  (index) => BarChartGroupData(
                    x: index + 1,
                    barRods: [
                      BarChartRodData(
                        toY: dailyIncome[index],
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4C6FFF), Color(0xFF7C3AED)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 8,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: (maxIncome * 1.2).ceilToDouble(),
                          color: const Color(0xFFE3E8EF).withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: const Color(0xFF1A1F36),
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        'Ngày ${group.x}\n${rod.toY.toStringAsFixed(1)} triệu',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          fontFamily: 'Noto Sans',
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
