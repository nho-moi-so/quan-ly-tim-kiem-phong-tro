class RoomDetail {
  String roomCode;
  String area;
  String checkin;
  String checkout;
  String maxCapacity;
  String room_status;
  String price;
  String description;
  List<String> utilities;
  String roomType;
  String roomState;

  RoomDetail({
    this.roomCode = '',
    this.area = '',
    this.checkin = '',
    this.checkout = '',
    this.maxCapacity = '',
    this.room_status = '',
    this.price = '',
    this.description = '',
    this.utilities = const [],
    this.roomType = '',
    this.roomState = '',
  });
}