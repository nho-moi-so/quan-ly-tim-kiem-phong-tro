import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/apartment.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/apartment_service.dart';

import '../../widgets/widgets.dart';

class NewCustomerScreen  extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

  //====get customer data
    final customerData = ApartmentService().getCustomerInfo();

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
              SizedBox(height: screenHeight * 0.05),              
              Center(child: LogoWidget()),
              // TagWithIconWidget(),
              const LabelTitleAndQuayLaiWidget(title: "Thêm khách hàng mới",),
              
              
            ],
          )
        ),
      ),
    );
  }


}