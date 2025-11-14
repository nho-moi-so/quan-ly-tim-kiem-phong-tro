class BookingRequestDetail {
  String? bookingCode;
  String? fullName;
  String? roomNumber;
  String? email;
  String? phoneNumber;
  int? numberOfPeople;
  DateTime? checkInDate;
  DateTime? checkOutDate;
  String? checkinCheckout;
  String? status;
  String? price;
  String? codeRoom;
  String? password;
  String? totalPrice;

  BookingRequestDetail({
    this.bookingCode,
    this.fullName,
    this.roomNumber,
    this.email,
    this.phoneNumber,
    this.numberOfPeople,
    this.checkInDate,
    this.checkOutDate,
    this.checkinCheckout,
    this.status,
    this.price,
    this.codeRoom,
    this.password = '',
    this.totalPrice,
  });
}