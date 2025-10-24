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
                  // const TagWithIconWidget(),
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
              RoomStatusRatioWidget(),
              SizedBox(height: screenHeight * 0.02),
              MonthlyIncomeChartWidget(),
            ],
          ),
        ),
      ),
    );
  }
}