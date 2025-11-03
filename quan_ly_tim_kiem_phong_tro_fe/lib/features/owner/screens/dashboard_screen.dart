import 'package:flutter/material.dart';

import '../widgets/widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: screenWidth,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.05),
              Center(child: LogoWidget()),
                Row(
                children: [
                  const TagWithIconWidget(title: "Trang chủ"),
                  const Spacer(),
                  // Button "Chủ trọ"
                  Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Chủ trọ',
                    style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    ),
                  ),
                  ),
                ],
                ),
              SizedBox(height: screenHeight * 0.02),
              RoomStatusRatioWidget(
                rentedCount: 12,        // Số phòng đang thuê
                availableCount: 8,      // Số phòng còn trống
                totalRooms: 20,         // Tổng số phòng
              ),
              SizedBox(height: screenHeight * 0.02),
              MonthlyIncomeChartWidget(
                incomeData: {
                  'Tháng 1': List.generate(30, (i) => [10.0, 20.0, 15.0][i % 3]),  // 30 giá trị cho 30 ngày
                  'Tháng 2': List.generate(30, (i) => [12.0, 18.0, 22.0][i % 3]),
                  'Tháng 3': List.generate(30, (i) => [15.0, 25.0, 20.0][i % 3]),
                },
                months: ['Tháng 1', 'Tháng 2', 'Tháng 3'],
                // initialMonth: 'Tháng 2',  // Optional, mặc định lấy tháng đầu
              )
            ],
          ),
        ),
      ),
    );
  }
}