import 'package:flutter/material.dart';

import '../../widgets/widgets.dart';

class DetailPostScreen extends StatelessWidget {
  const DetailPostScreen({super.key});

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
              SizedBox(height: screenHeight * 0.03), // Giảm xuống
              Center(child: LogoWidget()),
              Row(
                children: [
                  const TagWithIconWidget(),
                  const Spacer(),
                  ButtonAddWidget(),
                ],
              ),
              SizedBox(height: screenHeight * 0.01), // Giảm xuống
              FliterStatusWidget(),
              SizedBox(height: screenHeight * 0.01), // Giảm xuống
              LabelTitleWidget(title: "Thông tin bài đăng"),
              Center(child: RoomDetailCardWidget()),
              // Remove unnecessary SizedBox here
            ],
          ),
        ),
      ),
    );
  }
}