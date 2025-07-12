

import '../../features/owner/viewmodel/room_detail.dart';
import '../../features/owner/viewmodel/room_card_info.dart';
import '../../features/owner/viewmodel/customer_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class ApartmentService {
  //connect to firebase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //get Utility
  List<String> getUtilities() {
    return [
      'Cho Nuôi Chó Mèo',
      'Có Khóa Vân Tay, Mật Khảu',
      'Bãi Đậu Xe',
      'Wifi miễn phí',
    ];
  }

  // get Room Detail
  RoomDetail getRoomDetail() {
    return RoomDetail(
      roomCode: 'P102',
      area: '25',
      checkin: '14:00',
      checkout: '12:00',
      maxCapacity: '3',
      room_status: 'Trống',
      price: '2500000',
      description: 'Phòng mới xây, có ban công thoáng mát.',
      utilities: [
        'Cho Nuôi Chó Mèo',
        'Wifi miễn phí',
      ],
      roomType: 'Studio',
    );
  }

  //List Room Summary
  List<RoomCardInfo> getAllRoomCards() {
    return [
      RoomCardInfo(
        roomName: 'Phòng 101',
        tenantName: 'Nguyễn Văn A',
        price: '2.500.000 VNĐ',
        status: 'Trống',
        onViewDetail: () {
          // Handle view detail action
        },
        onDelete: () {
          // Handle delete action
        },
        onEdit: () {
          // Handle edit action
        },
        onContract: () {
          // Handle contract action
        },
      ),
      RoomCardInfo(
        roomName: 'Phòng 102',
        tenantName: 'Trần Thị B',
        price: '3.000.000 VNĐ',
        status: 'Đã thuê',
        onViewDetail: () {
          // Handle view detail action
        },
        onDelete: () {
          // Handle delete action
        },
        onEdit: () {
          // Handle edit action
        },
        onContract: () {
          // Handle contract action
        },
      ),
    ];
  }


}
