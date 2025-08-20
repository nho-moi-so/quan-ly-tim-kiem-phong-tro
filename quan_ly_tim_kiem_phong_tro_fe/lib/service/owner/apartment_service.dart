import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/apartment.dart';

class ApartmentService {
  //connect to firebase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //getAllApartment => List<Apartment>
  Future<List<Apartment>> getAllApartment() async {
    List<Apartment> apartments = [];
    QuerySnapshot snapshot = await firestore.collection("apartment").get();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      apartments.add(Apartment.fromMap(doc.id, data));
    }
    return apartments;
    }

  //getApartmentById => Apartment
  Future<Apartment> getApartmentById(String id) async {
    DocumentSnapshot snapshot = await firestore.collection("apartment").doc(id).get();
    final data = snapshot.data() as Map<String, dynamic>;
    return Apartment.fromMap(snapshot.id, data);
  }

  //getApartmentByUser => List<Apartment>
  Future<List<Apartment>> getApartmentByUser(String userId) async {
    List<Apartment> apartments = [];
    QuerySnapshot snapshot = await firestore
        .collection("apartment")
        .where('UserId', isEqualTo: userId)
        .get();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      apartments.add(Apartment.fromMap(doc.id, data));
    }
    return apartments;
  }

  //createApartment => Apartment
  Future<Apartment> createApartment(Apartment apartment) async {
  DocumentReference docRef = await firestore
      .collection("apartment")
      .add(apartment.toMap());

  // Lấy lại dữ liệu vừa add từ Firestore
  DocumentSnapshot snapshot = await docRef.get();
  final data = snapshot.data() as Map<String, dynamic>;

  // Trả về Apartment mới, dùng fromMap (không cần sửa model)
  return Apartment.fromMap(docRef.id, data);
  }


  //updateApartment => Apartment
  Future<Apartment> updateApartment(Apartment apartment) async {
    await firestore.collection("apartment").doc(apartment.apartmentID).update(apartment.toMap());
    return apartment;
  }

  //deleteApartment => Apartment
  Future<void> deleteApartment(String apartmentID) async {
    await firestore.collection("apartment").doc(apartmentID).delete();
  }

  

  // //get Utility
  // Future<List<String>> getAmenities() async {
  //   List<String> amenities = [];
  //     try {
  //   QuerySnapshot snapshot = await firestore.collection('amenity').get();
  //       for (var doc in snapshot.docs) {
  //       // Giả sử mỗi tài liệu có một trường 'Description' kiểu String
  //       String? name = doc['Description'];
  //       if (name != null) {
  //           amenities.add(name);
  //       }
  //       }
  //   } catch (e) {
  //       print('Error getting amenities: $e');
  //   }
    
  //   // return [
  //   //   'Cho Nuôi Chó Mèo',
  //   //   'Có Khóa Vân Tay, Mật Khảu',
  //   //   'Bãi Đậu Xe',
  //   //   'Wifi miễn phí',
  //   // ];
  //   return amenities;
  // }





  // //List Room Summary
  // Future<List<RoomCardInfo>> getAllRoomCards(
  //   {
  //     required String userId,
  //     String? status
  //   }
  // ) async {
  //   List<RoomCardInfo> roomCards = [];
  //   QuerySnapshot snapshot = await firestore
  //       .collection("apartment")
  //       .where('UserId', isEqualTo: userId)
  //       .get();
  //   for (var doc in snapshot.docs) {

  //     // ==================================DONE================
  //     String tenantName = '';
  //     String status = doc['Status']; //=== này nữa check bên booking request nếu không có thì lấy status này 
  //     // Lấy thông tin user từ bảng 'users' dựa trên UserId và xài bảng Booking Request
  //     QuerySnapshot bookingRequestSnapshot = await firestore.collection("bookingRequest")
  //                                                     .where("ApartmentId", isEqualTo: doc.id)
  //                                                     .limit(1)
  //                                                     .get();
  //     if(bookingRequestSnapshot.docs.isNotEmpty){
  //       final UserId = bookingRequestSnapshot.docs.first["UserId"];
  //       DocumentSnapshot userSnapshot = await firestore.collection('users').doc(UserId).get();
        
  //       if (userSnapshot.exists && userSnapshot.data() != null) {
  //         tenantName = userSnapshot['Username'] ?? '';
  //         status = bookingRequestSnapshot.docs.first["Status"];
  //       }
  //       else{
  //         tenantName = 'Chưa có khách thuê';
  //       }
  //     }
  //     // ==================================
  //     RoomCardInfo roomCard = RoomCardInfo(
  //       roomName: "Phòng: ${doc['CodeApartment']}",
        

  //       tenantName: tenantName,

  //       price: '${doc['DailyRate'].toString()}/ngày',
  //       status: status, 

  //       onViewDetail: () async { 
  //             // Lấy id của document (chuỗi String mặc định của Firestore document)
  //             String roomId = '${doc.id}';
  //             // print('Room ID: $roomId');

  //             //lay thong tin cua apartment
  //             DocumentSnapshot apartmentSnapshot = await firestore.collection('apartment').doc(roomId).get();
  //             // print(apartmentSnapshot.data());

  //             //lay id cua amenity cua apartment
  //             List<String> amenities = [];
  //             QuerySnapshot amenityInApartment = await firestore.collection('amenityInApartment')
  //             .where('ApartmentId', isEqualTo: roomId)
  //             .get();
  //             print('Amenities snapshot: ${amenityInApartment.docs}');
              
  //             //lay thong tin cua amenity dua vao id cua amenity trong amenitySnapshot
  //             for (var amenityDoc in amenityInApartment.docs) {
  //               String amenityId = amenityDoc['AmenityId'];
  //               DocumentSnapshot amenitySnapshot = await firestore.collection('amenity').doc(amenityId).get();
  //               String? amenityName = amenitySnapshot['Description'];
  //               if (amenityName != null) {
  //                 amenities.add(amenityName);
  //               }
  //               break;
  //             }
  //             print('Amenities: $amenities');
              

  //             //lấy thông tin chi tiết của phòng === này là dữ liệu giả 
  //             RoomDetail roomDetail = RoomDetail(
  //               roomCode: apartmentSnapshot['CodeApartment'],
  //               area: '25',
  //               checkin: '14:00',
  //               checkout: '12:00',
  //               maxCapacity: apartmentSnapshot['maxOccupancy'].toString(),
  //               room_status: 'Trống',
  //               price: apartmentSnapshot['DailyRate'].toString(),
  //               depositPrice: apartmentSnapshot['Deposit'].toString(),
  //               description: apartmentSnapshot['Decription'],
  //               utilities: [
  //                 'Ghế sofa 4 chỗ',
  //                 'Máy lạnh mới',
  //               ],
  //               roomType: 'Studio',
  //               images: List<String>.from(apartmentSnapshot['PathImage'] ?? []),
  //             );
  //               navigationService.navigateTo(
  //               DetailApartmentScreen(
  //                 roomDetail: roomDetail,
  //               ),
  //             );
  //           print('Room ID: $roomId');
          
  //       }, 
  //       onDelete: () {  }, 
  //       onEdit: () {  }, 
  //       onContract: () {  }
  //     );
  //     roomCards.add(roomCard);
  //   }
  //   return roomCards;
  //   }


}