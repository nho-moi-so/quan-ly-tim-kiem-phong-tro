class BookingRequestDetail {
  String fullName;
  String roomNumber;
  String phoneNumber;
  int numberOfPeople;
  DateTime checkInDate;
  DateTime checkOutDate;
  String status;
  String price;
  String codeRoom;
  String password;

  BookingRequestDetail({
    required this.fullName,
    required this.roomNumber,
    required this.phoneNumber,
    required this.numberOfPeople,
    required this.checkInDate,
    required this.checkOutDate,
    required this.status,
    required this.price,
    required this.codeRoom,
    this.password = '',
  });
}