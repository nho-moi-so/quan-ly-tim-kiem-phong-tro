import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/widgets/apartment/label_status_widget.dart';
import '../../widgets/widgets.dart';



class MainApartmentScreen extends StatelessWidget {
  const MainApartmentScreen({super.key});
  
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
              LabelStatusWidget(),
              LabelStatusWidget(),
              CardRoomWidget(),
              CardCustomerWidget(),
              CardRoomDetailWidget(),
              
            ],
          )
        ),
      ),
    );
  }


}