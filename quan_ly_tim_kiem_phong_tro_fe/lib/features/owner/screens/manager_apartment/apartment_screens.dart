import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/screens/manager_apartment/detail_apartment_screen.dart';

import '../../../../service/owner/apartment_service.dart';
import '../../viewmodel/room_card_info.dart';
import '../../widgets/widgets.dart';
import 'dart:developer';


class MainApartmentScreen extends StatefulWidget {
  const MainApartmentScreen({super.key});
  
  @override
  State<MainApartmentScreen> createState() => _MainApartmentScreenState();
}

class _MainApartmentScreenState extends State<MainApartmentScreen> {
  //====get all list card infor
  Future<List<RoomCardInfo>> roomCards = ApartmentService().getAllRoomCards(userId: "dYSjvUDL2vwRrSgqiDHy");

  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    //====get all list card infor
    Future<List<RoomCardInfo>> roomCards = ApartmentService().getAllRoomCards(userId: "dYSjvUDL2vwRrSgqiDHy");


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
                ButtonAddWidget(title: "Thêm căn hộ mới", screen: DetailApartmentScreen(),),
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
              // LabelTitleWidget(title:"Chung Cư Nam Long", header:"50, Trịnh Hoài Đức, Phường Vĩnh Thanh Vân TP. Rạch Giá"),
              
              //===========List of room cards
               FutureBuilder<List<RoomCardInfo>>(
                future: roomCards,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: snapshot.data!.map((card) => CardRoomWidget(data: card,)).toList(),
                    );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return const CircularProgressIndicator();
                })
            ],
            
            ),
          ),
          ),
          
        );
        }
      }

