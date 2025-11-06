import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/contract_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/helpers/format_currency.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/helpers/status_constants.dart';
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
import '../../../service/owner/booking_request_service.dart';
import '../../../service/owner/iot_otp_service.dart';
import '../viewmodel/room_card_info.dart';

class ApartmentController {
  final ApartmentService _apartmentService = ApartmentService();
  final BookingRequestService _bookingService = BookingRequestService();
  final UserService _userService = UserService();
  final AmenityInApartmentService _amenityInApartmentService = AmenityInApartmentService();
  final AmenityService _amenityService = AmenityService();
  final IotOtpService _iotOtpService = IotOtpService();

  final ContractController _contractController = ContractController();

  //createApartment(RoomCardDetail) => RoomCardDetail - done without image and user
  Future<bool> createApartment(RoomDetail roomCardDetail) async {
    try {
      // Debug: In giá trị gốc
      print('📊 DEBUG - Original price: "${roomCardDetail.price}"');
      print('📊 DEBUG - Original deposit: "${roomCardDetail.depositPrice}"');
      
      // Xóa dấu phẩy và ký tự không phải số trước khi parse
      String cleanPrice = roomCardDetail.price.replaceAll(RegExp(r'[^0-9.]'), '');
      String cleanDeposit = roomCardDetail.depositPrice.replaceAll(RegExp(r'[^0-9.]'), '');
      
      // Debug: In giá trị sau khi clean
      print('✅ DEBUG - Cleaned price: "$cleanPrice"');
      print('✅ DEBUG - Cleaned deposit: "$cleanDeposit"');
      
      // Validate trước khi parse
      if (cleanPrice.isEmpty) {
        throw Exception('Giá phòng không hợp lệ');
      }
      
      Apartment apartment = Apartment(
        codeApartment: roomCardDetail.roomCode,
        dailyRate: double.parse(cleanPrice),
        deposit: cleanDeposit.isEmpty ? 0.0 : double.parse(cleanDeposit),
        maxOccupancy: int.parse(roomCardDetail.maxCapacity),
        description: roomCardDetail.description,
        status: roomCardDetail.room_status == '' ? 'Available' : roomCardDetail.room_status,
        address: roomCardDetail.address,
        type: roomCardDetail.roomType,
        requirement: roomCardDetail.requirement.split(',').map((e) => e.trim()).toList(),
        userID: fb_auth.FirebaseAuth.instance.currentUser!.uid,
      );

      Apartment createdApartment = await _apartmentService.createApartment(apartment);
      print('Apartment created with ID: ${createdApartment.apartmentID}');

      // dò amenity để thêm vào amenityInApartment
      print('🔍 DEBUG - Utilities to add: ${roomCardDetail.utilities}');
      print('🔍 DEBUG - Number of utilities: ${roomCardDetail.utilities.length}');
      
      for (String amenityName in roomCardDetail.utilities) {
        print('➡️ Processing amenity: "$amenityName"');
        
        try {
          Amenity? amenity = await _amenityService.getAmenityByName(amenityName);
          
          if (amenity != null) {
            print('✅ Found amenity: ${amenity.description} (ID: ${amenity.amenityID})');
            
            final amenityInApartment = AmenityInApartment(
              apartmentId: createdApartment.apartmentID!,
              amenityId: amenity.amenityID,
              isAvailable: true,
            );
            
            print('📝 Creating AmenityInApartment: apartmentId=${createdApartment.apartmentID}, amenityId=${amenity.amenityID}');
            
            await _amenityInApartmentService.createAmenityInApartment(amenityInApartment);
            
            print('✅ Successfully created AmenityInApartment for "${amenityName}"');
          } else {
            print('⚠️ Amenity not found: "$amenityName"');
          }
        } catch (e, stackTrace) {
          print('❌ ERROR adding amenity "$amenityName": $e');
          print('❌ StackTrace: $stackTrace');
        }
      }
      
      print('✅ Finished processing all amenities');
      return true; // thành công
    } catch (e) {
      print('Error creating apartment: $e');
      return false; // thất bại
    }
  }

  
  //updateApartment
  Future<bool> updateApartment(RoomDetail roomCardDetail) async{
      try {
        // Xóa dấu phẩy và ký tự không phải số trước khi parse
        String cleanPrice = roomCardDetail.price.replaceAll(RegExp(r'[^0-9.]'), '');
        String cleanDeposit = roomCardDetail.depositPrice.replaceAll(RegExp(r'[^0-9.]'), '');

        //tìm thông tin của apartment
        Apartment foundApartment = await _apartmentService.getApartmentById(roomCardDetail.roomId);
        foundApartment.codeApartment = roomCardDetail.roomCode;
        foundApartment.dailyRate = double.parse(cleanPrice);
        foundApartment.deposit = cleanDeposit.isEmpty ? 0.0 : double.parse(cleanDeposit);
        foundApartment.maxOccupancy = int.parse(roomCardDetail.maxCapacity);
        foundApartment.description = roomCardDetail.description;
        foundApartment.status = roomCardDetail.room_status;

        Apartment updatedApartment = await _apartmentService.updateApartment(foundApartment);
        print('Apartment updated with ID: ${updatedApartment.apartmentID}');
        // tìm thông tin của amenity của apartment

        return true;
      } catch (e) {
        print('Error updating apartment: $e');
        return false;
      }
  }
  //deleteApartment
  Future<bool> deleteApartment(String apartmentId) async{
    try{
      await _apartmentService.deleteApartment("wDcTehYPI2siB6cj6cle");
      return true;
    }
    catch(e){
      print('Error deleting apartment: $e');
      return false;
    }
  }

  //viewDetailApartment - done
  Future<RoomDetail> viewDetailApartment(String apartmentId) async{
              String roomId = apartmentId;

              Apartment apartment = await _apartmentService.getApartmentById(roomId);
              print("==============1============");
              //lay id cua amenity cua apartment
              List<String> amenities = [];
              List<AmenityInApartment> amenityInApartment = await _amenityInApartmentService.getAmenityInApartmentByApartmentId(apartmentId);
              print("==============2============");
              print(amenityInApartment.length);
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
                roomId: apartmentId,
                roomCode: apartment.codeApartment!,
                area: '25',
                maxCapacity: apartment.maxOccupancy.toString(),
                room_status: apartment.status!,
                price: formatCurrency(apartment.dailyRate!).toString(),
                depositPrice: formatCurrency(apartment.deposit!).toString(),
                description: apartment.description!,
                utilities: amenities,
                images: List<String>.from(apartment.pathImage as Iterable),
                address: apartment.address ?? '',
                // roomType: apartment.type ?? 'Studio',
                requirement: (apartment.requirement != null && apartment.requirement is List<String>)
                  ? (apartment.requirement as List<String>).join(', ')
                  : '',
                roomType: apartment.type ?? '',
              );
              print("==============4============");
              print(roomDetail.roomType); //done
    return roomDetail;
  }



  //getSummaryRoom - done
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
          print(booking.userId);
          if (booking.checkoutDate.isAfter(DateTime.now())) {
            //nếu có booking và checkoutDate ở tương lai
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
      String price = '${formatCurrency(apartment.dailyRate!).toString()}/ngày';
      RoomCardInfo infoApartment = RoomCardInfo(
        roomName: roomName,
        tenantName: tenantName,
        price: price,
        status: apartment.status!,
        onViewDetail: () => viewDetailApartment(apartment.apartmentID!),
        onDelete: () => deleteApartment(apartment.apartmentID!),
        onContract: () async {
          //==lấy id của contract của phòng này
          return "exampleContractId";
        },
      );

      roomCards.add(infoApartment);
    }
    return roomCards;
  }

  /// Lấy danh sách tất cả tiện nghi - done
  Future<List<String>> getAllAmenity() async {
    List<Amenity> amenities = await _amenityService.getAllAmenity();
    List<String> allUtilities = [];
    for (var amenity in amenities) {
      allUtilities.add(amenity.description);
    }
    return allUtilities;
  }

  //trạng thái phòng
  Future<List<Map<String, String>>> getRoomStatusWithKey() async {
  return ApartmentStatus.values.map((status) {
    return {
      "key": status,
      "label": ApartmentStatus.toVietnamese(status),
    };
  }).toList();
}


  // Lấy danh sách tất cả loại phòng
  Future<List<String>> getAllRoomTypes() async {
    //==đang lấy theo tiếng việt
    List<String> roomTypes = [
      'Căn hộ 2 phòng ngủ',
      'Căn hộ 1 phòng ngủ',
      'Căn hộ Studio',
      'Căn hộ 3 phòng ngủ',
    ];
    return roomTypes;
  }

  //lấy danh sách các roomcCode của người dùng
  Future<List<String>> getRoomCodesByUser(String userId) async {
    List<Apartment> apartments = await _apartmentService.getApartmentByUser(userId);
    return apartments
        .where((apt) => apt.codeApartment != null && apt.codeApartment!.isNotEmpty)
        .map((apt) => apt.codeApartment!)
        .toList();
  }

  //==check ổ khóa có kết nối không để tạm ở đây
  Future<bool> checkIOTConnection(String codeRoom) async {
    IOTOtp otp = await _iotOtpService.getOTPbyId(codeRoom);
    if(otp.status == "verified"){
      return true;
    }
    else{
      return false;
    }
  }

  // Kiểm tra mã phòng có unique không
  Future<bool> isRoomCodeUnique(String roomCode) async {
    try {
      List<Apartment> apartments = await _apartmentService.getAllApartment();
      return !apartments.any((apt) => apt.codeApartment == roomCode);
    } catch (e) {
      print('Error checking room code uniqueness: $e');
      return false;
    }
  }

  // Tạo mã phòng ngẫu nhiên unique
  Future<String> generateUniqueRoomCode() async {
    String code;
    bool isUnique = false;
    int attempts = 0;
    
    do {
      // Format: P + 3 chữ số ngẫu nhiên (P101, P234, etc.)
      final random = DateTime.now().millisecondsSinceEpoch % 1000;
      code = 'P${random.toString().padLeft(3, '0')}';
      isUnique = await isRoomCodeUnique(code);
      attempts++;
    } while (!isUnique && attempts < 10);
    
    return code;
  }
}