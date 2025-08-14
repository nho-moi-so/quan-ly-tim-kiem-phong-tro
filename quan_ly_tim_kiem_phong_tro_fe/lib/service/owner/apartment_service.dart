
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/owner/screens/manager_apartment/detail_apartment_screen.dart';
import '../../features/owner/viewmodel/room_card_info.dart';
import '../../features/owner/viewmodel/room_detail.dart';
import '../../service/navigation_service.dart';
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

      // ==================================DONE================
      String tenantName = '';
      String status = doc['Status']; //=== này nữa check bên booking request nếu không có thì lấy status này 
      // Lấy thông tin user từ bảng 'users' dựa trên UserId và xài bảng Booking Request
      QuerySnapshot bookingRequestSnapshot = await firestore.collection("bookingRequest")
                                                      .where("ApartmentId", isEqualTo: doc.id)
                                                      .limit(1)
                                                      .get();
      if(bookingRequestSnapshot.docs.isNotEmpty){
        final UserId = bookingRequestSnapshot.docs.first["UserId"];
        DocumentSnapshot userSnapshot = await firestore.collection('users').doc(UserId).get();
        
        if (userSnapshot.exists && userSnapshot.data() != null) {
          tenantName = userSnapshot['Username'] ?? '';
          status = bookingRequestSnapshot.docs.first["Status"];
        }
        else{
          tenantName = 'Chưa có khách thuê';
        }
      }
      // ==================================
      RoomCardInfo roomCard = RoomCardInfo(
        roomName: "Phòng: ${doc['CodeApartment']}",
        

        tenantName: tenantName,

        price: '${doc['DailyRate'].toString()}/ngày',
        status: status, 

        onViewDetail: () async { 
              // Lấy id của document (chuỗi String mặc định của Firestore document)
              String roomId = '${doc.id}';
              // print('Room ID: $roomId');

              //lay thong tin cua apartment
              DocumentSnapshot apartmentSnapshot = await firestore.collection('apartment').doc(roomId).get();
              // print(apartmentSnapshot.data());

              //lay id cua amenity cua apartment
              List<String> amenities = [];
              QuerySnapshot amenityInApartment = await firestore.collection('amenityInApartment')
              .where('ApartmentId', isEqualTo: roomId)
              .get();
              print('Amenities snapshot: ${amenityInApartment.docs}');
              
              //lay thong tin cua amenity dua vao id cua amenity trong amenitySnapshot
              for (var amenityDoc in amenityInApartment.docs) {
                String amenityId = amenityDoc['AmenityId'];
                DocumentSnapshot amenitySnapshot = await firestore.collection('amenity').doc(amenityId).get();
                String? amenityName = amenitySnapshot['Description'];
                if (amenityName != null) {
                  amenities.add(amenityName);
                }
                break;
              }
              print('Amenities: $amenities');
              

              //lấy thông tin chi tiết của phòng === này là dữ liệu giả 
              RoomDetail roomDetail = RoomDetail(
                roomCode: apartmentSnapshot['CodeApartment'],
                area: '25',
                checkin: '14:00',
                checkout: '12:00',
                maxCapacity: apartmentSnapshot['maxOccupancy'].toString(),
                room_status: 'Trống',
                price: apartmentSnapshot['DailyRate'].toString(),
                depositPrice: apartmentSnapshot['Deposit'].toString(),
                description: apartmentSnapshot['Decription'],
                utilities: [
                  'Ghế sofa 4 chỗ',
                  'Máy lạnh mới',
                ],
                roomType: 'Studio',
                images: List<String>.from(apartmentSnapshot['PathImage'] ?? []),
              );
                navigationService.navigateTo(
                DetailApartmentScreen(
                  roomDetail: roomDetail,
                ),
              );
            print('Room ID: $roomId');
          
        }, 
        onDelete: () {  }, 
        onEdit: () {  }, 
        onContract: () {  }
      );
      roomCards.add(roomCard);
    }
    return roomCards;
    }

  //Create New Room
  Future<void> createOrUpdateRoom(RoomDetail roomDetail, String userId, String method) async {
    // try {
    //   // Tạo một tài liệu mới trong Firestore
    //   DocumentReference docRef = await firestore.collection('apartment').add({
    //     'CodeApartment': roomDetail.roomCode,
    //     'Area': roomDetail.area,
    //     'Checkin': roomDetail.checkin,
    //     'Checkout': roomDetail.checkout,
    //     'MaxOccupancy': roomDetail.maxCapacity,
    //     'Status': roomDetail.room_status,
    //     'DailyRate': roomDetail.price,
    //     'Decription': roomDetail.description,
    //     'UserId': userId, // Lưu ID người dùng
    //   });

    //   // Lưu các tiện ích liên quan đến phòng
    //   for (String utility in roomDetail.utilities) {
    //     await firestore.collection('amenityInApartment').add({
    //       'ApartmentId': docRef.id,
    //       'AmenityId': utility, // Giả sử utility là ID của tiện ích
    //     });
    //   }
    // } catch (e) {
    //   print('Error creating new room: $e');
    // }
    print('New room created with code: ${roomDetail.roomCode}');
  }    
    
}

