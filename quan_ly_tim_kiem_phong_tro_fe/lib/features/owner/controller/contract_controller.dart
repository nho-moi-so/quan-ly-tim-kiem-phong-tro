import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/helpers/format_currency.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/contract_detail.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/amenity_in_apartment_service.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/amenity_service.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/apartment_service.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/contract_service.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/user_service.dart';

class ContractController {
  final ContractService _contractService = ContractService();
  final ApartmentService _apartmentService = ApartmentService();
  final AmenityInApartmentService _amenityInApartmentService =
      AmenityInApartmentService();
  final AmenityService _amenityService = AmenityService();
  final UserService _userService = UserService();
  //create(String bookingRequestId) => bool

  //viewDetail(String contractId) => ContractDetail - done //==dữ liệu giả
  Future<ContractDetail?> viewDetail(String contractId) async {
    //thong tin contract
    var contract = await _contractService.getContractById(contractId);
    //thong tin apartment
    var apartment = await _apartmentService.getApartmentById(
      contract.apartmentId,
    );
    //thong tin amenity
    var amenities = await _amenityInApartmentService
        .getAmenityInApartmentByApartmentId(contract.apartmentId);
    amenities.sort((a, b) => a.amenityId.compareTo(b.amenityId));
    List<String> amenityNames = [];
    for (var amenity in amenities) {
      var amenityDetail = await _amenityService.getAmenityById(
        amenity.amenityId,
      );
      amenityNames.add(amenityDetail.description);
    }

    // Calculate number of days
    final numberOfDays = contract.endDate.difference(contract.startDate).inDays;

    // Mock invoice data (you can calculate these from real data)
    final dailyRate = apartment.dailyRate ?? 0.0;
    final otherFees = 100000.0; // Phí dịch vụ, điện nước, etc.
    final taxRate = 10.0; // 10% VAT
    final discount = 200000.0; // Giảm giá khuyến mãi
    final totalPrice =
        dailyRate * (numberOfDays > 0 ? numberOfDays : 1);
    var contractDetail = ContractDetail(
      contractId: contract.contractID,
      imageUrl: (apartment.pathImage?.isNotEmpty ?? false)
          ? apartment.pathImage![0]
          : "https://placehold.co/148x111",
      price: formatCurrency(totalPrice),
      deposit: formatCurrency(apartment.dailyRate!),
      title: apartment.type,
      address: apartment.address,
      features: amenityNames,
      imageUrlMap: "https://maps.app.goo.gl/D9n1mdjx7YEBCBPD9",
      ratingText: "9.2 Trên cả tuyệt vời",
      rating: 4.0,
      latitude: apartment.latitude,
      longitude: apartment.longitude,
      checkInTime: contract.startDate,
      checkOutTime: contract.endDate,
      extraInfo: "Không có thêm thông tin",
      description: apartment.description,
      password: "12345678",
      // Invoice data
      dailyRate: dailyRate,
      numberOfDays: numberOfDays > 0 ? numberOfDays : 1,
      otherFees: otherFees,
      taxRate: taxRate,
      discount: discount,
    );

    return contractDetail;
  }

  //updateInfo(ContractDetail contractDetail) => bool

  //updateStatus(String status) => bool

  //delete(String contractId) => bool

  Future<bool> verifyDataOnBlockchainByOwner({
    required String contractId,
    required String apartmentCode,
    required String price,
    required String ownerEmail,
    required String guestEmail,
    required DateTime checkinDate,
    required DateTime checkoutDate,
  }) async {
    //==tìm password của contract hoặc của aparment dựa vào contractId hoặc apartmentCode
    var apartment = await _apartmentService.getApartmentByCode(apartmentCode);
    //tim email owner va guest
    var owner = await _userService.getUserByEmail(ownerEmail);
    if(owner == null) {
      print("Owner with email $ownerEmail not found.");
      return false;
    }
    var guest = await _userService.getUserByEmail(guestEmail);
    if(guest == null) {
      print("Guest with email $guestEmail not found.");
      return false;
    }
    //chuẩn bị dữ liệu để gọi api hash_blockchain

    String preparedBookingId = contractId;
    String preparedApartmentId = apartment.apartmentID!;
    String preparedPrice = double.parse(price).toInt().toString();
    String preparedOwnerId = owner!.userID!;
    String preparedGuestId = guest!.userID!;
    String preparedPassword = apartment.password!;
    String preparedCheckinDate = checkinDate
        .toUtc()
        .toIso8601String(); //chuẩn UTC
    String preparedCheckoutDate = checkoutDate
        .toUtc()
        .toIso8601String(); //chuẩn UTC
    print("bookingId: $preparedBookingId");
    print("apartmentId: $preparedApartmentId");
    print("price: $preparedPrice");
    print("ownerId: $preparedOwnerId");
    print("guestId: $preparedGuestId");
    print("password: $preparedPassword");
    print("checkinDate: $preparedCheckinDate");
    print("checkoutDate: $preparedCheckoutDate");
    //gọi api hash_blockchain (bookingId, aparmentId, price ,ownerId, guestId , password)
    String? hashFromBlockchain = await _callAPIHashBlockchain(
      bookingId: preparedBookingId,
      apartmentId: preparedApartmentId,
      price: int.parse(preparedPrice),
      ownerId: preparedOwnerId,
      guestId: preparedGuestId,
      password: preparedPassword,
    );
    print("hashFromBlockchain: $hashFromBlockchain");
    //gọi api verify
    if (hashFromBlockchain != null) {
      bool isVerified = await _callAPIVerifyBlockchain(hashFromBlockchain, checkinDate: preparedCheckinDate, checkoutDate: preparedCheckoutDate);
      print("Is Verified: $isVerified");
      return isVerified;
    }
    return false;
  }

  /// Lấy dữ liệu đầy đủ của contract để verify blockchain
  /// Bao gồm: contractId, apartmentName, price, ownerName, guestName, password, checkin, checkout
  Future<Map<String, dynamic>> getDetailContractForBlockchainVerify(
    String contractId,
  ) async {
    // Lấy thông tin contract
    var contract = await _contractService.getContractById(contractId);

    // Lấy thông tin apartment
    var apartment = await _apartmentService.getApartmentById(
      contract.apartmentId,
    );

    // Tính toán giá tổng
    final numberOfDays = contract.endDate.difference(contract.startDate).inDays;
    final dailyRate = apartment.dailyRate ?? 0.0;
    final otherFees = 100000.0;
    final taxRate = 10.0;
    final discount = 200000.0;
    final totalPrice =
        dailyRate * (numberOfDays > 0 ? numberOfDays : 1) +
        otherFees +
        (dailyRate * (numberOfDays > 0 ? numberOfDays : 1) + otherFees) *
            (taxRate / 100) -
        discount;

    // Lấy thông tin owner và guest
    var owner = await _userService.getUserById(apartment.userID!);
    var guest = await _userService.getUserById(contract.userId);

    return {
      'contractId': contract.contractID,
      'apartmentId': apartment.apartmentID,
      'price': totalPrice,
      'apartmentCode': apartment.codeApartment ?? '',
      'ownerEmail': owner.email ?? '',
      'guestEmail': guest.email ?? '',
      'password': apartment.password ?? '',
      'checkinDate': contract.startDate,
      'checkoutDate': contract.endDate,
    };
  }

  //call api hash blockchain
  Future<String?> _callAPIHashBlockchain({
    required String bookingId,
    required String apartmentId,
    required int price,
    required String ownerId,
    required String guestId,
    required String password,
  }) async {
    // 1. Cấu hình Domain Server
    final String? serverDomain = dotenv.env['HOST_SERVER'];
    if (serverDomain == null) {
      print('Blockchain hash failed: HOST_SERVER is not defined in .env file');
      return null;
    }

    try {
      // 2. Tạo URI
      var uri = Uri.parse('$serverDomain/api/blockchain/hash');

      // 3. Chuẩn bị Body (Dữ liệu gửi đi)
      Map<String, dynamic> body = {
        "bookingId": bookingId,
        "apartmentId": apartmentId,
        "price": price,
        "ownerId": ownerId,
        "guestId": guestId,
        "password": password
      };

      // 4. Gửi Request (Dùng http.post thay vì MultipartRequest vì đây là JSON)
      var response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json", // Bắt buộc để server hiểu đây là JSON
        },
        body: jsonEncode(body), // Chuyển đổi Map sang chuỗi JSON
      );

      // 5. Xử lý phản hồi
      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonResponse = jsonDecode(response.body);

        // Check logic success theo mẫu response bạn cung cấp
        if (jsonResponse['status'] == 'success' && 
            jsonResponse['data'] != null &&
            jsonResponse['data']['hash'] != null) {
          
          String hash = jsonResponse['data']['hash'];
          print('Hash created: $hash');
          return hash; // Trả về chuỗi hash
        }
      }

      print('Blockchain hash failed: ${response.body}');
      return null;

    } catch (e) {
      print('Connection error: $e');
      return null;
    }
  }

  // call api verify blockchain
  Future<bool> _callAPIVerifyBlockchain(String hashBlockchain, {required String checkinDate, required String checkoutDate}) async {
    // 1. Cấu hình Domain Server
    final String? serverDomain = dotenv.env['HOST_SERVER'];
    if (serverDomain == null) {
      print('Verify failed: HOST_SERVER is not defined in .env file');
      return false;
    }

    try {
      var uri = Uri.parse('$serverDomain/api/blockchain/verify');

      // 3. Chuẩn bị Body
      Map<String, String> body = {
        "contract_hash": hashBlockchain
      };

      // 4. Gửi Request POST
      var response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      // 5. Xử lý phản hồi
      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonResponse = jsonDecode(response.body);

        print("Server Response: $jsonResponse"); // Log để debug

        // Kiểm tra logic theo cấu trúc JSON bạn cung cấp
        if (jsonResponse['status'] == 'success' && 
            jsonResponse['data'] != null) {
          
          // Lấy trạng thái verified từ data
          if(jsonResponse['data']['contract_info'] != null &&
            jsonResponse['data']['contract_info']["checkinDate"] != null &&
            jsonResponse['data']['contract_info']["checkoutDate"] != null) {
            String serverCheckinDate = jsonResponse['data']['contract_info']["checkinDate"];
            String serverCheckoutDate = jsonResponse['data']['contract_info']["checkoutDate"];

            // So sánh ngày checkin và checkout
            if (serverCheckinDate != checkinDate || serverCheckoutDate != checkoutDate) {
              print('❌ Date mismatch: Server Check-in: $serverCheckinDate, Provided Check-in: $checkinDate');
              print('❌ Date mismatch: Server Check-out: $serverCheckoutDate, Provided Check-out: $checkoutDate');
              return false;
            }
          }
          
          bool isVerified = jsonResponse['data']['verified'] ?? false;
          
          if (isVerified) {
            // Có thể log thêm thông tin hợp đồng nếu cần
            var contractInfo = jsonResponse['data']['contract_info'];
            print('✅ Contract Validated. Status: ${contractInfo['statusText']}');
            return true;
          }
        }
      }

      print('❌ Verify failed or Invalid Hash: ${response.body}');
      return false;

    } catch (e) {
      print('Verify connection error: $e');
      return false;
    }
  }


}


