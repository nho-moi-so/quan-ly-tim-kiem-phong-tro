import 'package:quan_ly_tim_kiem_phong_tro_fe/model/booking_request.dart';
import '/model/booking_request.dart';

class BookingService {
  Future<List<BookingRequest>> getAllBookingRequest({
    String? ownerId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Dữ liệu mẫu
    final sampleData = [
      BookingRequest(
        bookingRequestID: '1',
        requestedDate: DateTime.now(),
        checkinDate: DateTime.now().add(Duration(days: 1)),
        checkoutDate: DateTime.now().add(Duration(days: 2)),
        status: 'Đã Xác Nhận',
      ),
      
    ];

    // Có thể thêm logic lọc ở đây nếu cần

    return sampleData;
  }
}