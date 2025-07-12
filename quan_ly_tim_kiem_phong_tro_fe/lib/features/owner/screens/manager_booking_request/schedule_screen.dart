import 'package:flutter/material.dart';

import '../../widgets/widgets.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

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
              TagWithIconWidget(),
              SizedBox(height: screenHeight * 0.02),
              LabelTitleAndQuayLaiWidget(title: "Lịch Hẹn"),
              SizedBox(height: screenHeight * 0.02),
              BookingScheduleWidget(),
              SizedBox(height: screenHeight * 0.02),
              NoteBookingScheduleWidget(),
            ],
          ),
        ),
      ),
    );
  }
}