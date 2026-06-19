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
      unionMonths.sort((a, b) => b.compareTo(a));
      availableMonths = unionMonths;
    } else {
      availableMonths = ['Năm ${DateTime.now().year}'];
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
  var monthlyIncome = widget.incomeData[selectedMonth] ?? [];
  if (monthlyIncome.isEmpty) {
    monthlyIncome = List.filled(12, 0.0);
  }

  final maxIncome = monthlyIncome.isNotEmpty
    ? monthlyIncome.reduce((a, b) => a > b ? a : b)
    : 0.0;
  // Tính trung bình chỉ trên các tháng có dữ liệu > 0
  final nonZeroMonths = monthlyIncome.where((v) => v > 0).toList();
  final avgIncome = nonZeroMonths.isNotEmpty
    ? nonZeroMonths.reduce((a, b) => a + b) / nonZeroMonths.length
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
                    'Thu Nhập Hàng Năm',
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
                    'Trung bình tháng: ${avgIncome == 0 ? '0' : avgIncome < 10 ? avgIncome.toStringAsFixed(1) : avgIncome.toStringAsFixed(0)} triệu',
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
            child: LineChart(
              LineChartData(
                minX: 1,
                maxX: 12,
                minY: 0,
                maxY: maxIncome == 0 ? 5 : (maxIncome * 1.2).ceilToDouble(),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      12,
                      (index) => FlSpot((index + 1).toDouble(), monthlyIncome.length > index ? monthlyIncome[index] : 0.0),
                    ),
                    isCurved: true,
                    color: const Color(0xFF4C6FFF),
                    barWidth: 4,
                    dotData: const FlDotData(show: true),
                  ),
                ],
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxIncome == 0 ? 1 : ((maxIncome * 1.2) / 4).clamp(0.5, double.infinity),
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
                      interval: 1,
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value > 12) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'T${value.toInt()}',
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
                      interval: maxIncome == 0 ? 1 : ((maxIncome * 1.2) / 4).clamp(0.5, double.infinity),
                      showTitles: true,
                      reservedSize: 48,
                      getTitlesWidget: (value, _) {
                        // Hiển thị với 1 chữ số thập phân nếu giá trị nhỏ hơn 10
                        final label = value == 0
                            ? '0'
                            : value < 10
                                ? value.toStringAsFixed(1)
                                : value.toInt().toString();
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            label,
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
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: const Color(0xFF1A1F36),
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        return LineTooltipItem(
                          'Tháng ${touchedSpot.x.toInt()}\n${touchedSpot.y.toStringAsFixed(1)} triệu',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            fontFamily: 'Noto Sans',
                          ),
                        );
                      }).toList();
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
