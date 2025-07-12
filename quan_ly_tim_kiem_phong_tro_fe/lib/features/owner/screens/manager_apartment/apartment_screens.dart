import 'package:flutter/material.dart';

import '../../widgets/widgets.dart';
import '../../viewmodel/room_card_info.dart';
import '../../../../service/owner/apartment_service.dart';


class MainApartmentScreen extends StatelessWidget {
  const MainApartmentScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    //====get all list card infor
    final List<RoomCardInfo> roomCards = ApartmentService().getAllRoomCards();


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
                TagWithIconWidget(title: "Quảng lý căn hộ"),
                ButtonAddWidget(title: "Thêm căn hộ mới",),
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
              LabelTitleWidget(title:"Chung Cư Nam Long", header:"50, Trịnh Hoài Đức, Phường Vĩnh Thanh Vân TP. Rạch Giá"),
              
              //===========List of room cards
              ...roomCards.map((card) => CardRoomWidget(data: card,)).toList(),
            ],
            
            ),
          ),
          ),
          
        );
        }
      }

