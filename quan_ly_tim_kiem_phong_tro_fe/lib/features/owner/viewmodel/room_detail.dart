class RoomDetail {
  String roomCode;
  String area;
  String checkin;
  String checkout;
  String maxCapacity;
  String room_status;
  String price;
  String depositPrice;
  String description;
  List<String> utilities;
  String roomType;
  String roomState;
  List<String> images;

  RoomDetail({
    this.roomCode = '',
    this.area = '',
    this.checkin = '',
    this.checkout = '',
    this.maxCapacity = '',
    this.room_status = '',
    this.price = '',
    this.depositPrice = '',
    this.description = '',
    this.utilities = const [],
    this.roomType = '',
    this.roomState = '',
    this.images = const [],
  });
}