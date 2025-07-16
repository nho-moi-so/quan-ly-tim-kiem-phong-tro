
import 'package:flutter/material.dart';

import '../../widgets/widgets.dart';

class BookingRequestScreens extends StatelessWidget{
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
              //wiget trong đây
              //widget trong đây
              SizedBox(height: screenHeight * 0.05),
              //logo
              Center(child: LogoWidget(),),
              // TagWithIconWidget(),
              SizedBox(height: screenHeight * 0.02),
              //label title
              LabelTitleWidget(title: "Danh Sách Yêu Cầu Đặt Phòng",),
              //filter status
              FliterStatusWidget(),
              //search by date
              SearchByDateWidget(),
              SizedBox(height: screenHeight * 0.02),
              //card booking request
              Center(
                child: Column(
                  children: [
                    CardBookingRequestWidget(),
                  ],
                ),
              )
              

              
              
              

            ],
          )
        ),
      ),
    );
  
  }
}

