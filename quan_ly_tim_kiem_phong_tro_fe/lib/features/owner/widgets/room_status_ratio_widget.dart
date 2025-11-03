import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class RoomStatusRatioWidget extends StatefulWidget {
  final int rentedCount;
  final int availableCount;
  final int totalRooms;

  const RoomStatusRatioWidget({
    super.key,
    required this.rentedCount,
    required this.availableCount,
    required this.totalRooms,
  });

  @override
  State<RoomStatusRatioWidget> createState() => _RoomStatusRatioWidgetState();
}

class _RoomStatusRatioWidgetState extends State<RoomStatusRatioWidget> {
  @override
  Widget build(BuildContext context) {
    // Tính toán phần trăm từ dữ liệu thực
    final rentedPercentage = widget.totalRooms > 0
        ? (widget.rentedCount / widget.totalRooms * 100)
        : 0.0;
    final availablePercentage = widget.totalRooms > 0
        ? (widget.availableCount / widget.totalRooms * 100)
        : 0.0;

    final Map<String, double> dataMap = {
      "Đang Thuê": rentedPercentage,
      "Còn Trống": availablePercentage,
    };

    final List<Color> colorList = [
      const Color(0xFFEF4444), // đỏ hiện đại (Đang Thuê)
      const Color(0xFF10B981), // xanh hiện đại (Còn Trống)
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFAFBFF),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
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
          // Header với icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4C6FFF), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4C6FFF).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.pie_chart_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tỉ Lệ Phòng Trống',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Noto Sans',
                        color: Color(0xFF1A1F36),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tình trạng phòng hiện tại',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Noto Sans',
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Pie Chart với layout cải tiến
          Row(
            children: [
              // Pie chart
              Expanded(
                flex: 3,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: PieChart(
                    dataMap: dataMap,
                    animationDuration: const Duration(milliseconds: 1000),
                    chartType: ChartType.ring,
                    colorList: colorList,
                    chartRadius: MediaQuery.of(context).size.width / 3.5,
                    ringStrokeWidth: 32,
                    centerText: "${widget.totalRooms}",
                    centerTextStyle: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Noto Sans',
                      color: Color(0xFF1A1F36),
                    ),
                    legendOptions: const LegendOptions(
                      showLegends: false,
                    ),
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValues: true,
                      showChartValuesInPercentage: true,
                      showChartValuesOutside: false,
                      // chartValueStyle: TextStyle(
                      //   fontSize: 13,
                      //   fontWeight: FontWeight.w700,
                      //   color: Colors.white,
                      //   fontFamily: 'Noto Sans',
                      // ),
                      decimalPlaces: 0,
                    ),
                    totalValue: 100,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              
              // Custom legend với stats
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Đang Thuê
                    _buildLegendItem(
                      color: colorList[0],
                      label: 'Đang Thuê',
                      percentage: dataMap["Đang Thuê"]!,
                      count: widget.rentedCount,
                      icon: Icons.home_rounded,
                    ),
                    const SizedBox(height: 16),
                    
                    // Còn Trống
                    _buildLegendItem(
                      color: colorList[1],
                      label: 'Còn Trống',
                      percentage: dataMap["Còn Trống"]!,
                      count: widget.availableCount,
                      icon: Icons.door_front_door_rounded,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Footer với tổng kết
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4C6FFF).withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF4C6FFF).withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: const Color(0xFF4C6FFF).withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  'Tổng số ${widget.totalRooms} phòng • ${widget.availableCount} phòng còn trống',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Noto Sans',
                    color: const Color(0xFF4C6FFF).withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required double percentage,
    required int count,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Noto Sans',
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.9),
                  ),
                ),
              ),
              Icon(
                icon,
                size: 16,
                color: color.withOpacity(0.7),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${percentage.toInt()}%',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Noto Sans',
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '($count phòng)',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Noto Sans',
                    color: color.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
