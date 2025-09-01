import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/room_detail.dart';

import '../../widgets/widgets.dart';

class DetailApartmentScreen extends StatefulWidget {
  final RoomDetail? roomDetail;

  const DetailApartmentScreen({super.key, this.roomDetail});

  @override
  State<DetailApartmentScreen> createState() => _DetailApartmentScreenState();
}

class _DetailApartmentScreenState extends State<DetailApartmentScreen> {
  final ApartmentController _apartmentController = ApartmentController();
  List<Map<String, String>> roomStates = [];
  List<String> roomTypes = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final fetchedRoomStates = await _apartmentController.getRoomStatusWithKey();
    final fetchedRoomTypes = await _apartmentController.getAllRoomTypes();
    setState(() {
      roomStates = fetchedRoomStates;
      roomTypes = fetchedRoomTypes;
    });
  }

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
              const Center(child: LogoWidget()),
                LabelTitleAndQuayLaiWidget(
                title: widget.roomDetail != null ? 'Chi tiết căn hộ' : 'Tạo căn hộ',
                ),
              // SizedBox(height: screenHeight * 0.02),
              CardRoomDetailWidget(
                initialData: widget.roomDetail ?? RoomDetail(), // Provide a default RoomDetail if null
                roomStates: roomStates,
                roomTypes: roomTypes,
              ),
            ],
          ),
        ),
      ),
    );
  }
}