import 'package:flutter/material.dart';

import '../../widgets/widgets.dart';

class NewCustomerScreen  extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

  //====get customer data
    // final customerData = ApartmentService().getCustomerInfo();

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
              SizedBox(height: screenHeight * 0.02),
              //===============test=================
              const CardCustomerWidget(),
              //===============test=================
              
              
            ],
          )
        ),
      ),
    );
  }


}