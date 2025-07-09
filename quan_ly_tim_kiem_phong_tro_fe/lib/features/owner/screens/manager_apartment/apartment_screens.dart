import 'package:flutter/material.dart';

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
              SizedBox(
              height: screenHeight * 0.05,
              ),
              Center(child: LogoWidget()),
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TagWithIconWidget(),
                ButtonAddWidget(),
              ],
              ),
              SizedBox(
              height: screenHeight * 0.01,
              ),
              SizedBox(
              height: screenHeight * 0.01,
              ),
              LabelStatusWidget(),
              SizedBox(
              height: screenHeight * 0.01,
              ),
              LabelTitleWidget(),
              CardRoomWidget(),
              CardRoomWidget(),
              CardRoomWidget(),
              CardRoomWidget(),
            ],
            ),
          ),
          ),
          
        );
        }
      }

