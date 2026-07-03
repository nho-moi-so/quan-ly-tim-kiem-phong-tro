import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/helpers/format_currency.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/helpers/status_constants.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/booking_request_detail.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/booking_request_summary.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/apartment.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/contract.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/apartment_service.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/booking_request_service.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/contract_service.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/user_service.dart';
class BookingRequestController {
  final BookingRequestService _bookingRequestService = BookingRequestService();
  final ContractService _contractService = ContractService();
  final ApartmentService _apartmentService = ApartmentService();
  final UserService _userService = UserService();

  //getAllBookingRequestsSummary() => List<BookingRequestDetail> - done
  Future<List<BookingRequestSummary>> getAllBookingRequestsSummaries(String ownerId) async {
    print("==ownerId==$ownerId");
    //lấy các apartment của chủ căn hộ
    List<Apartment> apartments = await _apartmentService.getApartmentByUser(ownerId);
    print("==1==${apartments}");
    //lấy các bookingRequest có apartmentId là của các apartment trên
    List<Contract> contracts = [];
    for(var apartment in apartments) {
      var bookingRequestInApartment = await _contractService.getContractByApartmentId(apartment.apartmentID!);
      contracts.addAll(bookingRequestInApartment);
    }
    print("==2==${contracts}");
    //-> từ cái đó sắp xếp theo thời gian tạo 
    // bookingRequests.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    //-> trong cái contracts có userId là của người thuê -> lấy userId đó để lấy thông tin user
    List<BookingRequestSummary> bookingRequestSummaries = [];
    for (var contract in contracts) {
      // Skip contracts with invalid userId
      if (contract.userId.isEmpty) {
        print('Skipping contract ${contract.contractID} - empty userId');
        continue;
      }
      // lay thong tin cua apartment
      var apartment = await _apartmentService.getApartmentById(contract.apartmentId);

          // Calculate number of days (làm tròn lên để tính đủ số ngày thuê)
        final numberOfDays = (contract.endDate.difference(contract.startDate).inHours / 24).ceil();
        
        // print("==số ngày==$numberOfDays");
        // print("==ngày bắt đầu==${contract.startDate}");
        // print("==ngày kết thúc==${contract.endDate}");

        // Mock invoice data (you can calculate these from real data)
        final dailyRate = apartment.dailyRate ?? 0.0;
        final otherFees = 100000.0; // Phí dịch vụ, điện nước, etc.
        final taxRate = 10.0; // 10% VAT
        final discount = 200000.0; // Giảm giá khuyến mãi
        final totalPrice = dailyRate * (numberOfDays > 0 ? numberOfDays : 1);
        
      try {
        var user = await _userService.getUserById(contract.userId);
        BookingRequestSummary bookingRequestSummary = BookingRequestSummary(
          bookingId: contract.contractID,
          bookingCode: apartment.codeApartment,
          customerName: user.fullName,
          checkinCheckout: formatDateInCardSummary(contract.startDate, contract.endDate),
          checkinDate: contract.startDate,
          checkoutDate: contract.endDate,
          totalPrice: '${formatCurrency(totalPrice)} VND',
          status: contract.status,
        );
        bookingRequestSummaries.add(bookingRequestSummary);
      } catch (e) {
        print('Error loading user for contract ${contract.contractID}: $e');
        // Continue to next contract instead of crashing
      }
    }
    //-> trả về List<BookingRequestSummary>
    print("==3==$bookingRequestSummaries");
    return bookingRequestSummaries;
  }

  //getBookingRequestById(String bookingRequestId) => BookingRequestDetail - done
  Future<BookingRequestDetail> getBookingRequestById(String bookingRequestId) async{
    //lấy bookingRequestId -> lấy bookingRequest 
    var contract = await _contractService.getContractById(bookingRequestId);
//    print("==1==${contract.apartmentId}");
    //trong bookingRequest có apartmentId -> lấy thông tin của phòng đó
    var apartment = await _apartmentService.getApartmentById(contract.apartmentId);
//    print("==2==${apartment.maxOccupancy}");
    //-> trong cái bookingRequest có userId là của người thuê -> lấy userId đó để lấy thông tin user 
    var user = await _userService.getUserById(contract.userId);
//    print("==3==${user.fullName}");
    //-> trả về BookingRequestDetail

        // Calculate number of days
    final numberOfDays = (contract.endDate.difference(contract.startDate).inHours / 24).ceil();
    
    // print("==số ngày==$numberOfDays");
    // print("==ngày bắt đầu==${contract.startDate}");
    // print("==ngày kết thúc==${contract.endDate}");
    // Mock invoice data (you can calculate these from real data)
    final dailyRate = apartment.dailyRate ?? 0.0;
    final otherFees = 100000.0; // Phí dịch vụ, điện nước, etc.
    final taxRate = 10.0; // 10% VAT
    final discount = 200000.0; // Giảm giá khuyến mãi
    final totalPrice = dailyRate * (numberOfDays > 0 ? numberOfDays : 1);

//    print("==tổng tiền==$totalPrice");
    BookingRequestDetail bookingRequestDetail = BookingRequestDetail(
      fullName: user.fullName,
      roomNumber: apartment.codeApartment,
      email: user.email,
      phoneNumber: user.phone,
      numberOfPeople: apartment.maxOccupancy, //==này đang lấy số người ở apartment
      checkinCheckout: formatDateInCardSummary(contract.startDate, contract.endDate),
      checkInDate: contract.startDate,
      checkOutDate: contract.endDate,

      status: contract.status,
      price: apartment.dailyRate.toString(), //== này đang lấy daylyRate hình như không đúng logic
      bookingCode: contract.contractID,
      password: apartment.password, //== này đang lấy password bên apartment
      totalPrice: formatCurrency(totalPrice),
      
    );
//    print("==4==${bookingRequestDetail.checkinCheckout}");
    return bookingRequestDetail;
  }


  //updateBookingRequestStatus(String bookingRequestId, String status) => bool
  Future<bool> updateBookingRequestStatus(String bookingRequestId, String status)async{
    //lấy bookingRequestId -> lấy bookingRequest 
    var contract = await _contractService.getContractById(bookingRequestId);
    try {
       //-> cập nhật status 
      if (!BookingRequestStatus.values.contains(status)) {
        throw Exception("Invalid status");
      }
      contract.status = status;
      await _contractService.updateContract(contract);
      //-> trả về bool
      return true;
    } catch (e) {
      print('Error updating booking request status: $e');
      return false;
    }
  }


  //viewBookingRequestPassword(String bookingRequestId) => String
  //lấy bookingRequestId -> lấy bookingRequest -> trong cái bookingRequest có userId là của người thuê -> lấy userId đó để lấy thông tin user -> trả về password

  //updateBookingRequestPassword(String bookingRequestId, String newPassword) => bool - done
  Future<bool> updateBookingRequestPassword(String? bookingRequestId, String? newPassword) async{
    //lấy bookingRequestId -> lấy bookingRequest 
    var contract = await _contractService.getContractById(bookingRequestId!);
    print("==1==${contract.apartmentId}");
    var apartment = await _apartmentService.getApartmentById(contract.apartmentId); //==hiện tại password đang ở apartment
    print("==2==${apartment.password}");
    //-> cập nhật password
    apartment.password = newPassword;
    //-> trả về bool
    try {
      await _apartmentService.updateApartment(apartment);
      print("==3==${apartment.password}");
      return true;
    } catch (e) {
      print('Error updating apartment password: $e');
      return false;
    }
  }
  //sendBookingRequestPassword() => bool //==


  //searchBookingRequestByStartDateAndEndDate(String ownerId, DateTime startDate, DateTime endDate) => List<BookingRequestSummary> - done
  Future<List<BookingRequestSummary>> searchBookingRequestByStartDateAndEndDate (String ownerId, DateTime? startDate, DateTime? endDate) async {
    //lấy startDate và endDate
    //lấy apartment của ownerId
    List<Apartment> apartments = await _apartmentService.getApartmentByUser(ownerId);
    print("==1==${apartments}");
    //-> lấy các bookingRequest có apartmentId là của các apartment trên 
    List<Contract> contracts = [];
    for(var apartment in apartments) {
      var contractInApartment = await _contractService.getContractByApartmentId(apartment.apartmentID!);
      contracts.addAll(contractInApartment);
    }
    print("==2==${contracts}");
    //-> lọc bookingRequest theo khoảng thời gian 
    contracts = contracts.where((contract) {
      return contract.startDate.isAfter(startDate!) &&
          contract.endDate.isBefore(endDate!);
    }).toList();
    //-> trong cái bookingRequest có userId là của người thuê -> lấy userId đó để lấy thông tin user 
    List<BookingRequestSummary> bookingRequestSummaries = [];
    for (var contract in contracts) {
      // Skip contracts with invalid userId
      if (contract.userId.isEmpty) {
        print('Skipping contract ${contract.contractID} - empty userId');
        continue;
      }
      
      try {
        var user = await _userService.getUserById(contract.userId);
        BookingRequestSummary bookingRequestSummary = BookingRequestSummary(
          bookingCode: contract.contractID,
          customerName: user.fullName,
          checkinCheckout: formatDateInCardSummary(contract.startDate, contract.endDate),
          checkinDate: contract.startDate,
          status: contract.status,
        );
        bookingRequestSummaries.add(bookingRequestSummary);
      } catch (e) {
        print('Error loading user for contract ${contract.contractID}: $e');
        // Continue to next contract instead of crashing
      }
    }
    //-> trả về List<BookingRequestSummary>
    print("==3==$bookingRequestSummaries");
    return bookingRequestSummaries;
  }

  

  String formatDateInCardSummary(DateTime checkinDate, DateTime checkoutDate) {
    return '${checkinDate.day.toString().padLeft(2, '0')}/${checkinDate.month.toString().padLeft(2, '0')} - ${checkoutDate.day.toString().padLeft(2, '0')}/${checkoutDate.month.toString().padLeft(2, '0')}';
  }
  List<String> getStatusList() {
    return BookingRequestStatus.values;
  }
}