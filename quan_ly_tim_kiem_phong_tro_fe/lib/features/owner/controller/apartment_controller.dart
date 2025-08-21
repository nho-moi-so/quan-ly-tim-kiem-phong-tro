import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/screens/manager_apartment/detail_apartment_screen.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/room_detail.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/amenities.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/amenity_in_apartment.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/apartment.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/booking_request.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/user.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/navigation_service.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/user_service.dart';

import '../../../service/owner/amenity_in_apartment_service.dart';
import '../../../service/owner/amenity_service.dart';
import '../../../service/owner/apartment_service.dart';
import '../../../service/owner/booking_service.dart';
import '../viewmodel/room_card_info.dart';

class ApartmentController {
  final ApartmentService _apartmentService = ApartmentService();
  final BookingService _bookingService = BookingService();
  final UserService _userService = UserService();
  final AmenityInApartmentService _amenityInApartmentService = AmenityInApartmentService();
  final AmenityService _amenityService = AmenityService();

  //createApartment(RoomCardDetail) => RoomCardDetail
  void createApartment(RoomDetail roomCardDetail) {

    try {
      Apartment apartment = Apartment(
        codeApartment: roomCardDetail.roomCode,
        dailyRate: double.parse(roomCardDetail.price),
        deposit: double.parse(roomCardDetail.depositPrice),
        maxOccupancy: int.parse(roomCardDetail.maxCapacity),
        description: roomCardDetail.description,
      status: roomCardDetail.room_status,
    );

      Future<Apartment> createdApartment = _apartmentService.createApartment(apartment);
      createdApartment.then((apartment) {
        print('Apartment created with ID: ${apartment.apartmentID}');
        //dò amenity để thêm vào amenityInApartment
        for (String amenityName in roomCardDetail.utilities) {
          // print('Amenity: $amenityName'); //done
          Future<Amenity?> amenity = _amenityService.getAmenityByName(amenityName);
          amenity.then((value) {
            if (value != null) {
              // print('Amenity found: ${value.description}'); //done
              _amenityInApartmentService.createAmenityInApartment(AmenityInApartment(
                apartmentId: apartment.apartmentID!,
                amenityId: value.amenityID,
                isAvailable: true,
              ));
            }
          });
        }
      }).catchError((error) {
        print('Error creating apartment: $error');
      });
    } catch (e) {
      print('Error creating apartment: $e');
    }
  }
  //updateApartment
  void updateApartment(RoomDetail roomCardDetail) {
    print('Updating apartment with details: ${roomCardDetail.toString()}');
  }
  //deleteApartment
  //viewDetailApartment




  // Future<List<RoomCardInfo>> getAllRoomCards(
  //   {
  //     required String userId,
  //     String? status
  //   }
  // ) async {
  //   List<RoomCardInfo> roomCards = [];
  //   List<Apartment> snapshot = await _apartmentService.getApartmentByUser(userId);
  //   for (var doc in snapshot) {
  //     String tenantName = '';
  //     String status = doc.status; //=== này nữa check bên booking request nếu không có thì lấy status này 
  //     // Lấy thông tin user từ bảng 'users' dựa trên UserId và xài bảng Booking Request

  //     List<BookingRequest> bookingRequests = await _bookingService.getBookingRequestByApartmentId(doc.apartmentID ?? '');
      
  //     if(bookingRequests.isNotEmpty){
        
  //       final userIdBooking = bookingRequests.first.userId;
  //       if(userIdBooking == null){
  //         tenantName = 'Chưa có khách thuê';
  //       }
  //       else{
  //         User userSnapshot = await _userService.getUserById(userIdBooking);
  //         tenantName = userSnapshot.username ?? '';
  //         status = bookingRequests.first.status;
  //       }

  //     }
  //     // ==================================
  //     RoomCardInfo roomCard = RoomCardInfo(
  //       roomName: "Phòng: ${doc.codeApartment}",       

  //       tenantName: tenantName,

  //       price: '${doc.dailyRate.toString()}/ngày',
  //       status: status, 

  //       onViewDetail: () async { 
  //             // Lấy id của document (chuỗi String mặc định của Firestore document)
  //             String roomId = '${doc.apartmentID}';
  //             // print('Room ID: $roomId');

  //             //lay thong tin cua apartment
  //             Apartment apartmentSnapshot = await _apartmentService.getApartmentById(roomId);
  //             // print(apartmentSnapshot.data());

  //             //lay id cua amenity cua apartment
  //             List<String> amenities = [];
  //             List<AmenityInApartment> amenityInApartment = _amenityInApartmentService.getAmenityInApartmentByApartmentId(roomId) as List<AmenityInApartment>;
              
  //             //lay thong tin cua amenity dua vao id cua amenity trong amenitySnapshot
  //             for (var amenityDoc in amenityInApartment) {
  //               String amenityId = amenityDoc.amenityId;
  //               Amenity amenitySnapshot = _amenityService.getAmenityById( amenityId) as Amenity;
  //               // print(amenitySnapshot.data())
  //               String? amenityName = amenitySnapshot.description;
  //                 amenities.add(amenityName);
  //               break;
  //             }
  //             print('Amenities: $amenities');
              

  //             //lấy thông tin chi tiết của phòng === này là dữ liệu giả 
  //             RoomDetail roomDetail = RoomDetail(
  //               roomCode: apartmentSnapshot.codeApartment,
  //               area: '25',
  //               checkin: '14:00',
  //               checkout: '12:00',
  //               maxCapacity: apartmentSnapshot.maxOccupancy.toString(),
  //               room_status: 'Trống',
  //               price: apartmentSnapshot.dailyRate.toString(),
  //               depositPrice: apartmentSnapshot.deposit.toString(),
  //               description: apartmentSnapshot.description,
  //               utilities: [
  //                 'Ghế sofa 4 chỗ',
  //                 'Máy lạnh mới',
  //               ],
  //               roomType: 'Studio',
  //               images: List<String>.from(apartmentSnapshot.pathImage),
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

  /// Lấy danh sách tất cả tiện nghi
  Future<List<String>> getAllAmenity() async {
    List<Amenity> amenities = await _amenityService.getAllAmenity();
    List<String> allUtilities = [];
    for (var amenity in amenities) {
      allUtilities.add(amenity.description);
    }
    return allUtilities;
  }

}