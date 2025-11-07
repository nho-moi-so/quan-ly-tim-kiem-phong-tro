      // 'bookingCode': '654321',
      // 'customerName': 'Trần Văn B',
      // 'checkinCheckout': '03/01 - 04/01',
      // 'status': 'Đã Thanh Toán',
class BookingRequestSummary {
  final String? bookingId;
  final String? bookingCode;
  final String? customerName;
  final DateTime? checkinDate;
  final DateTime? checkoutDate;
  final String? checkinCheckout;
  final String? status;
  final String? totalPrice;

  BookingRequestSummary({
    this.bookingId,
    this.bookingCode,
    this.customerName,
    this.checkinDate,
    this.checkoutDate,
    this.checkinCheckout,
    this.status,
    this.totalPrice,
  });
}