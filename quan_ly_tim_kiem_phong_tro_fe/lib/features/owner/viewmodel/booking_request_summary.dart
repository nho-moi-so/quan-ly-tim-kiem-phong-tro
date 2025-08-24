      // 'bookingCode': '654321',
      // 'customerName': 'Trần Văn B',
      // 'checkinCheckout': '03/01 - 04/01',
      // 'status': 'Đã Thanh Toán',
class BookingRequestSummary {
  final String? bookingCode;
  final String? customerName;
  final DateTime? checkinDate;
  final String? checkinCheckout;
  final String? status;

  BookingRequestSummary({
    this.bookingCode,
    this.customerName,
    this.checkinDate,
    this.checkinCheckout,
    this.status,
  });
}