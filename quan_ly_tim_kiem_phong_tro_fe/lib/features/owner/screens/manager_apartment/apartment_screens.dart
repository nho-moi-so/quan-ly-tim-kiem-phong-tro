import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/apartment_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/screens/manager_apartment/detail_apartment_screen.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/room_card_info.dart';

import '../../widgets/widgets.dart';


class ApartmentScreen extends StatefulWidget {
  const ApartmentScreen({super.key});
  
  @override
  State<ApartmentScreen> createState() => _MainApartmentScreenState();
}

class _MainApartmentScreenState extends State<ApartmentScreen> {
  
  //get all list card infor
  Future<List<RoomCardInfo>> roomCards = ApartmentController().getSummaryRoom( FirebaseAuth.instance.currentUser!.uid);
  RoomFilter currentFilter = RoomFilter.all;

  List<RoomCardInfo> _filterRooms(List<RoomCardInfo> rooms) {
    switch (currentFilter) {
      case RoomFilter.all:
        return rooms;
      case RoomFilter.rented:
        // Lọc phòng đang ở (có khách thuê)
        return rooms.where((room) => 
          room.tenantName != "Chưa có khách thuê" && 
          (room.status == 'Đang Ở' || room.status == 'rented')
        ).toList();
      case RoomFilter.available:
        // Lọc phòng còn trống (chưa có khách thuê hoặc status là đang trống)
        return rooms.where((room) => 
          room.tenantName == "Chưa có khách thuê" || 
          room.status == 'Đang Trống' || 
          room.status == 'available'
        ).toList();
    }
  }

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
              LabelStatusWidget(
                initialFilter: currentFilter,
                onFilterChanged: (filter) {
                  setState(() {
                    currentFilter = filter;
                  });
                },
              ),
              SizedBox(
              height: screenHeight * 0.01,
              ),
              // LabelTitleWidget(title:"Chung Cư Nam Long", header:"50, Trịnh Hoài Đức, Phường Vĩnh Thanh Vân TP. Rạch Giá"),
              
              // ===========List of room cards
              FutureBuilder<List<RoomCardInfo>>(
                future: roomCards,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingWidget(
                      message: 'Đang tải danh sách phòng...',
                    );
                  } else if (snapshot.hasError) {
                    return EmptyStateWidget(
                      title: 'Có lỗi xảy ra',
                      message: 'Không thể tải danh sách phòng\n${snapshot.error}',
                      icon: Icons.error_outline,
                    );
                  } else if (snapshot.hasData) {
                    final filteredRooms = _filterRooms(snapshot.data!);
                    if (filteredRooms.isEmpty) {
                      String message = 'Chưa có phòng nào';
                      if (currentFilter == RoomFilter.rented) {
                        message = 'Chưa có phòng nào đang được thuê';
                      } else if (currentFilter == RoomFilter.available) {
                        message = 'Chưa có phòng trống';
                      }
                      return EmptyStateWidget(
                        title: 'Không có phòng',
                        message: message,
                        icon: Icons.home_outlined,
                      );
                    }
                    return Column(
                      children: filteredRooms.map((card) => CardRoomWidget(data: card,)).toList(),
                    );
                  }
                  return const SizedBox.shrink();
                })
            ],
            
            ),
          ),
          ),
          
        );
        }
      }

