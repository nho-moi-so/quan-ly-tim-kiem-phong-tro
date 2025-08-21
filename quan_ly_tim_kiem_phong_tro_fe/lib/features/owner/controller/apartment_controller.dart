import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/room_detail.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/amenities.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/amenity_in_apartment.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/apartment.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/booking_request.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/user.dart';
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

  //createApartment(RoomCardDetail) => RoomCardDetail - done without image and user
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
  Future<RoomDetail> viewDetailApartment(String apartmentId) async{
              String roomId = apartmentId;

              Apartment apartment = await _apartmentService.getApartmentById(roomId);
              print("==============1============");
              //lay id cua amenity cua apartment
              List<String> amenities = [];
              List<AmenityInApartment> amenityInApartment = await _amenityInApartmentService.getAmenityInApartmentByApartmentId(apartmentId);
              print("==============2============");
              //lay thong tin cua amenity dua vao id cua amenity trong amenitySnapshot
              for (var amenityDoc in amenityInApartment) {
                print(amenityDoc.amenityId);
                Amenity amenitySnapshot = await _amenityService.getAmenityById(amenityDoc.amenityId);
                print(amenitySnapshot.description);
                amenities.add(amenitySnapshot.description);

              }
              print('Amenities: $amenities');
              print("==============3============");
              //lấy thông tin chi tiết của phòng === này là dữ liệu giả
              RoomDetail roomDetail = RoomDetail(
                roomCode: apartment.codeApartment,
                area: '25',
                maxCapacity: apartment.maxOccupancy.toString(),
                room_status: apartment.status,
                price: apartment.dailyRate.toString(),
                depositPrice: apartment.deposit.toString(),
                description: apartment.description,
                utilities: amenities,
                images: List<String>.from(apartment.pathImage as Iterable),
              );
              print("==============4============");
    return roomDetail;
  }



  //getSummaryRoom
  Future<List<RoomCardInfo>> getSummaryRoom(String userId) async{
    List<RoomCardInfo> roomCards = [];
    List<Apartment> apartmentsOfUser = await _apartmentService.getApartmentByUser(userId);
    for(var apartment in apartmentsOfUser) {
      String roomName = "Phòng: ${apartment.codeApartment}";
      
      String tenantName = "Chưa có khách thuê";
      //xử lý lấy thông tin của người thuê:
        // Lấy danh sách yêu cầu đặt phòng cho căn hộ này
        // Gán tên khách thuê nếu có một bookingRequest có CheckoutDate ở tương lai
        // Ngược lại gán "Chưa có khách thuê"
        List<BookingRequest> bookingRequests = await _bookingService.getBookingRequestByApartmentId(apartment.apartmentID!);
      if (bookingRequests.isNotEmpty) {
        for(var booking in bookingRequests){
          print(booking.status);
          if (booking.checkoutDate.isAfter(DateTime.now())) {
            // print(userId);
            User user = await _userService.getUserById(booking.userId);
            // print(user.email);
            tenantName = user.fullName ?? 'Chưa có khách thuê';
            break; // Chỉ cần lấy tên khách thuê đầu tiên có trạng thái hợp lệ
          } else {
            tenantName = "Chưa có khách thuê";
          }
        }
      }


      String price = '${apartment.dailyRate.toString()}/ngày';


      RoomCardInfo infoApartment = RoomCardInfo(
        roomName: roomName,
        tenantName: tenantName,
        price: price,
        status: apartment.status,
        onViewDetail: () => viewDetailApartment(apartment.apartmentID!),
        onDelete: () {},
        onEdit: () {},
        onContract: () {});
        
        roomCards.add(infoApartment);
    }
    return roomCards;
  }



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