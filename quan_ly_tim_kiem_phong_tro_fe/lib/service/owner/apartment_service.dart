
import '../../features/owner/viewmodel/room_detail.dart';
import '../../features/owner/viewmodel/room_card_info.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
class ApartmentService {
  //connect to firebase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //get Utility
  Future<List<String>> getAmenities() async {
    List<String> amenities = [];
      try {
    QuerySnapshot snapshot = await firestore.collection('amenity').get();
        for (var doc in snapshot.docs) {
        // Giả sử mỗi tài liệu có một trường 'Description' kiểu String
        String? name = doc['Description'];
        if (name != null) {
            amenities.add(name);
        }
        }
    } catch (e) {
        print('Error getting amenities: $e');
    }
    
    // return [
    //   'Cho Nuôi Chó Mèo',
    //   'Có Khóa Vân Tay, Mật Khảu',
    //   'Bãi Đậu Xe',
    //   'Wifi miễn phí',
    // ];
    return amenities;
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
  Future<List<RoomCardInfo>> getAllRoomCards(
    {
      required String userId,
      String? status
    }
  ) async {
    List<RoomCardInfo> roomCards = [];
    QuerySnapshot snapshot = await firestore
        .collection("apartment")
        .where('UserId', isEqualTo: userId)
        .get();
    for (var doc in snapshot.docs) {
      RoomCardInfo roomCard = RoomCardInfo(
        roomName: doc['CodeApartment'],
        tenantName: doc['UserId'],
        price: doc['Decription'],
        status: doc['UserId'], onViewDetail: () {  }, onDelete: () {  }, onEdit: () {  }, onContract: () {  }
      );
      roomCards.add(roomCard);
    }
    return roomCards;
    }
    
    
  }

