import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/widgets/widgets.dart';

class ContractDetailScreen extends StatefulWidget {
  const ContractDetailScreen({super.key});

  @override
  State<ContractDetailScreen> createState() => _ContractDetailScreenState();
}

class _ContractDetailScreenState extends State<ContractDetailScreen> {
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
                  const Spacer(),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              // FliterStatusWidget(),
              SizedBox(height: screenHeight * 0.02),
              LabelTitleWidget(title: "Chi tiết hợp đồng"),
              SummaryWidget(),

              SizedBox(height: screenHeight * 0.02),
              LocationReviewWidget(
                imageUrl: "https://your-map-image-url",
                ratingText: "9.2 Trên cả tuyệt vời",
                address: "45, Nguyễn văn cừ, an bình cần thơ",
                rating: 4, // số sao vàng
              ),
              
              SizedBox(height: screenHeight * 0.02),
              ExtendInfoWidget(
                checkInTime: DateTime(2023, 10, 1, 14, 0).toString(), 
                checkOutTime: DateTime(2023, 10, 2, 12, 0).toString(), 
                extraInfo: "Không có thêm thông tin",
                description: "Căn hộ rộng rãi, thoáng mát"),
              
              SizedBox(height: screenHeight * 0.02),
              PasswordDisplayWidget(password: "12345678"),
            ],
          ),
        ),
      ),
    );
  }
}