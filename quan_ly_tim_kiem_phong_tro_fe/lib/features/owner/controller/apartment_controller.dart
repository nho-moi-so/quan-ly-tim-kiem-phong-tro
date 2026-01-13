import 'dart:convert'; // Để decode JSON trả về

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http; // Để gọi API upload
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/contract_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/helpers/format_currency.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/helpers/status_constants.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/room_detail.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/amenities.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/amenity_in_apartment.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/apartment.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/contract.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/user.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/user_service.dart';

import '../../../service/owner/amenity_in_apartment_service.dart';
import '../../../service/owner/amenity_service.dart';
import '../../../service/owner/apartment_service.dart';
import '../../../service/owner/booking_request_service.dart';
import '../../../service/owner/contract_service.dart';
import '../../../service/owner/iot_otp_service.dart';
import '../viewmodel/room_card_info.dart';

class ApartmentController {
  final ApartmentService _apartmentService = ApartmentService();
  final BookingRequestService _bookingService = BookingRequestService();
  final UserService _userService = UserService();
  final AmenityInApartmentService _amenityInApartmentService = AmenityInApartmentService();
  final AmenityService _amenityService = AmenityService();
  final IotOtpService _iotOtpService = IotOtpService();
  final ContractService _contractService = ContractService();

  final ContractController _contractController = ContractController();

  //createApartment(RoomCardDetail) => RoomCardDetail - done without image
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
      // UPLOAD HÌNH ẢNH TRƯỚC (Đẩy logic này lên đầu)
      // ---------------------------------------------------------
      List<String> finalImageUrls = []; // List chứa các link ảnh từ server

      if (roomCardDetail.images.isNotEmpty) {
        print('🖼️ Đang upload ${roomCardDetail.images.length} ảnh...');
        
        for (String localPath in roomCardDetail.images) {
          // Gọi hàm upload (hàm này vẫn giữ nguyên như câu trả lời trước)
          String? serverUrl = await _uploadImageToServer(localPath);
          
          if (serverUrl != null) {
            finalImageUrls.add(serverUrl); // Thêm link vào list
            print('✅ Đã thêm ảnh: $serverUrl');
          }
        }
      }
      
      Apartment apartment = Apartment(
        codeApartment: roomCardDetail.roomCode,
        dailyRate: double.parse(cleanPrice),
        deposit: cleanDeposit.isEmpty ? 0.0 : double.parse(cleanDeposit),
        maxOccupancy: int.parse(roomCardDetail.maxCapacity),
        description: roomCardDetail.description,
        status: roomCardDetail.room_status == '' ? 'Available' : roomCardDetail.room_status,
        address: roomCardDetail.address,
        latitude: roomCardDetail.latitude,
        longitude: roomCardDetail.longitude,
        type: roomCardDetail.roomType,
        requirement: roomCardDetail.requirement.split(',').map((e) => e.trim()).toList(),
        userID: fb_auth.FirebaseAuth.instance.currentUser!.uid,
        pathImage: finalImageUrls,
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
        foundApartment.address = roomCardDetail.address;
        foundApartment.latitude = roomCardDetail.latitude;
        foundApartment.longitude = roomCardDetail.longitude;

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
              // print("==============1============");
              //lay id cua amenity cua apartment
              List<String> amenities = [];
              List<AmenityInApartment> amenityInApartment = await _amenityInApartmentService.getAmenityInApartmentByApartmentId(apartmentId);
              // print("==============2============");
              // print(amenityInApartment.length);
              //lay thong tin cua amenity dua vao id cua amenity trong amenitySnapshot
              for (var amenityDoc in amenityInApartment) {
                // print(amenityDoc.amenityId);
                Amenity amenitySnapshot = await _amenityService.getAmenityById(amenityDoc.amenityId);
                // print(amenitySnapshot.description);
                amenities.add(amenitySnapshot.description);

              }
                // print('Amenities: $amenities');
                // print("==============3============");
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
                latitude: apartment.latitude,
                longitude: apartment.longitude,
                // roomType: apartment.type ?? 'Studio',
                requirement: (apartment.requirement != null && apartment.requirement is List<String>)
                  ? (apartment.requirement as List<String>).join(', ')
                  : '',
                roomType: apartment.type ?? '',
              );
              // print("==============4============");
              // print(roomDetail.roomType); //done
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
        List<Contract> contracts = await _contractService.getContractByApartmentId(apartment.apartmentID!);
      var contractId;
      if (contracts.isNotEmpty) {
        for(var contract in contracts){
            //nếu có booking và checkoutDate ở tương lai
          // print(contract.endDate);
          if (contract.endDate.isAfter(DateTime.now())) {
            // print(userId);
            User user = await _userService.getUserById(contract.userId);
            // print(user.email);
            tenantName = user.fullName ?? 'Chưa có khách thuê';
            contractId = contract.contractID;
            break; //== Chỉ cần lấy tên khách thuê đầu tiên có trạng thái hợp lệ
          } else {
            tenantName = "Chưa có khách thuê";
          }
        }
      }
      String price = '${formatCurrency(apartment.dailyRate!).toString()}/ngày';
      String status = tenantName != "Chưa có khách thuê" ? "Rented" : apartment.status ?? "Available";
      RoomCardInfo infoApartment = RoomCardInfo(
        roomName: roomName,
        tenantName: tenantName,
        price: price,
        status: status,
        onViewDetail: () => viewDetailApartment(apartment.apartmentID!),
        onDelete: () => deleteApartment(apartment.apartmentID!),
        onContract: () async {
          return contractId;
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

  // //==check ổ khóa có kết nối không để tạm ở đây
  // Future<Map<String, String>> checkIOTConnection(String codeRoom) async {
  //   IOTOtp otp = await _iotOtpService.getOTPbyId(codeRoom);
  //   if(otp.Status == "verified"){
  //     //call api check iot device
  //     String status = await _callAPICheckIOTDevice(codeRoom);
  //     if(status == "online"){
  //       return {"status": "online",
  //               "message": "Thiết bị đang trực tuyến"};
  //     }
  //     else{
  //       return {"status": "offline",
  //               "message": "Thiết bị không phản hồi sau 5 giây"};
  //     }
  //   }
  //   else{
  //     return {"status": "unverified",
  //             "message": "Thiết bị chưa được xác thực"};
  //   }
  // }

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

 
  Future<String?> _uploadImageToServer(String filePath) async {
    // 1. Cấu hình Domain Server (Thay bằng IP/Domain thật của bạn)
    final String? serverDomain = dotenv.env['HOST_SERVER'];
    if(serverDomain == null) {
      print('Upload failed: HOST_SERVER is not defined in .env file');
      return null;
    }
    
    try {
      // Generate random filename (chỉ chữ và số)
      String randomFileName = _generateRandomFileName(filePath);
      
      // Gọi API Upload
      var uri = Uri.parse('$serverDomain/api/util/upload'); 
      
      var request = http.MultipartRequest('POST', uri);
      
      // Đính kèm file với tên file random
      request.files.add(
        await http.MultipartFile.fromPath('file', filePath, filename: randomFileName)
      );
      
      // Gửi request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonResponse = jsonDecode(response.body);

        // ✅ LOGIC SỬA ĐỔI Ở ĐÂY:
        // Dựa vào mẫu: { "status": "success", "data": { "url": "/uploads/..." } }
        
        if (jsonResponse['status'] == 'success' && jsonResponse['data'] != null) {
          String relativePath = jsonResponse['data']['url'];
          
          // Ghép domain vào đường dẫn tương đối để thành link full
          // Kết quả sẽ là: http://192.168.1.25:3000/uploads/ten-anh.jpg
          return '$serverDomain$relativePath'; 
        }
      } 
      
      print('Upload failed: ${response.body}');
      return null;

    } catch (e) {
      print('Upload connection error: $e');
      return null;
    }
  }

  /// Generate random filename chỉ gồm chữ và số, giữ lại đuôi mở rộng
  String _generateRandomFileName(String originalPath) {
    // Lấy đuôi mở rộng từ file gốc
    String extension = '';
    if (originalPath.contains('.')) {
      extension = originalPath.substring(originalPath.lastIndexOf('.'));
    }
    
    // Generate random string chỉ gồm chữ và số
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String randomName = '';
    
    for (int i = 0; i < 12; i++) {
      randomName += chars[(random + i) % chars.length];
    }
    
    return randomName + extension;
  }

  
}