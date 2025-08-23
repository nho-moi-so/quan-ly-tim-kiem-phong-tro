import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/helpers/status_constants.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/booking_request_detail.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/booking_request_summary.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/apartment.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/booking_request.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/apartment_service.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/booking_request_service.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/user_service.dart';
class BookingRequestController {
  final BookingRequestService _bookingRequestService = BookingRequestService();
  final ApartmentService _apartmentService = ApartmentService();
  final UserService _userService = UserService();

  //getAllBookingRequestsSummary() => List<BookingRequestDetail> - done
  Future<List<BookingRequestSummary>> getAllBookingRequestsSummaries(String ownerId) async {
    List<BookingRequest> bookingRequests = [];
    //lấy các apartment của chủ căn hộ
    List<Apartment> apartments = await _apartmentService.getApartmentByUser(ownerId);
    print("==1==${apartments}");
    //lấy các bookingRequest có apartmentId là của các apartment trên
    for(var apartment in apartments) {
      var bookingRequestInApartment = await _bookingRequestService.getBookingRequestByApartmentId(apartment.apartmentID!);
      bookingRequests.addAll(bookingRequestInApartment);
    }
    print("==2==${bookingRequests}");
    //-> từ cái đó sắp xếp theo thời gian tạo 
    // bookingRequests.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    //-> trong cái bookingRequests có userId là của người thuê -> lấy userId đó để lấy thông tin user
    List<BookingRequestSummary> bookingRequestSummaries = [];
    for (var bookingRequest in bookingRequests) {
      var user = await _userService.getUserById(bookingRequest.userId);
      BookingRequestSummary bookingRequestSummary = BookingRequestSummary(
        bookingCode: bookingRequest.bookingRequestID,
        customerName: user.fullName,
        checkinCheckout: formatDateInCardSummary(bookingRequest.checkinDate, bookingRequest.checkoutDate),
        status: bookingRequest.status,
      );
      bookingRequestSummaries.add(bookingRequestSummary);
    }
    //-> trả về List<BookingRequestSummary>
    print("==3==$bookingRequestSummaries");
    return bookingRequestSummaries;
  }

  //getBookingRequestById(String bookingRequestId) => BookingRequestDetail - done
  Future<BookingRequestDetail> getBookingRequestById(String bookingRequestId) async{
    //lấy bookingRequestId -> lấy bookingRequest 
    var bookingRequest = await _bookingRequestService.getBookingRequestById(bookingRequestId);
    print("==1==${bookingRequest.apartmentID}");
    //trong bookingRequest có apartmentId -> lấy thông tin của phòng đó
    var apartment = await _apartmentService.getApartmentById(bookingRequest.apartmentID);
    print("==2==${apartment.maxOccupancy}");
    //-> trong cái bookingRequest có userId là của người thuê -> lấy userId đó để lấy thông tin user 
    var user = await _userService.getUserById(bookingRequest.userId);
    print("==3==${user.fullName}");
    //-> trả về BookingRequestDetail
    BookingRequestDetail bookingRequestDetail = BookingRequestDetail(
      fullName: user.fullName,
      roomNumber: apartment.codeApartment,
      email: user.email,
      phoneNumber: user.phone,
      numberOfPeople: apartment.maxOccupancy, //==này đang lấy số người ở apartment
      checkinCheckout: formatDateInCardSummary(bookingRequest.checkinDate, bookingRequest.checkoutDate),
      status: bookingRequest.status,
      price: apartment.dailyRate.toString(), //== này đang lấy daylyRate hình như không đúng logic
      bookingCode: bookingRequest.bookingRequestID,
      password: apartment.password //== này đang lấy password bên apartment
    );
    print("==4==${bookingRequestDetail.checkinCheckout}");
    return bookingRequestDetail;
  }


  //updateBookingRequestStatus(String bookingRequestId, String status) => bool
  //lấy bookingRequestId -> lấy bookingRequest -> cập nhật status -> trả về bool

  //viewBookingRequestPassword(String bookingRequestId) => String
  //lấy bookingRequestId -> lấy bookingRequest -> trong cái bookingRequest có userId là của người thuê -> lấy userId đó để lấy thông tin user -> trả về password

  //updateBookingRequestPassword(String bookingRequestId, String newPassword) => bool
  //lấy bookingRequestId -> lấy bookingRequest -> cập nhật password -> trả về bool

  //sendBookingRequestPassword() => bool


  //searchBookingRequestByStartDateAndEndDate(DateTime startDate, DateTime endDate) => List<BookingRequestDetail>
  //lấy startDate và endDate -> lọc bookingRequest theo khoảng thời gian -> trong cái bookingRequest có userId là của người thuê -> lấy userId đó để lấy thông tin user -> trả về List<BookingRequestDetail>
  

  String formatDateInCardSummary(DateTime checkinDate, DateTime checkoutDate) {
    return '${checkinDate.day.toString().padLeft(2, '0')}/${checkinDate.month.toString().padLeft(2, '0')} - ${checkoutDate.day.toString().padLeft(2, '0')}/${checkoutDate.month.toString().padLeft(2, '0')}';
  }
  List<String> getStatusList() {
    return BookingRequestStatus.values;
  }
}