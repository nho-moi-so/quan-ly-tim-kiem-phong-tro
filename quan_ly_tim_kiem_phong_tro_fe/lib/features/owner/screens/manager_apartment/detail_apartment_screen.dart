import 'package:flutter/material.dart';

import '../../widgets/widgets.dart';
import '../../../../service/owner/apartment_service.dart';

class DetailApartmentScreen extends StatelessWidget {
  const DetailApartmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Example data for testing
    final roomDetailSample = ApartmentService().getRoomDetail();


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
              const Center(child: LogoWidget()),
              // TagWithIconWidget(),
              const LabelTitleAndQuayLaiWidget(title: 'Chi tiết phòng trọ'),

              //===============test=================              
              CardRoomDetailWidget(initialData: roomDetailSample),
              //===============test=================

            ],
          ),
        ),
      ),
    );
  }
}