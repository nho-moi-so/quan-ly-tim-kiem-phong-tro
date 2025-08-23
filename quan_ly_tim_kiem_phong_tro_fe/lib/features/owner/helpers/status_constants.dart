//Kiểm tra status của căn hộ

//==================đầu vào status==================
// if (ApartmentStatus.values.contains(inputStatus)) {
//   apartment.status = inputStatus;
// } else {
//   throw Exception("Invalid status");
// }

//=======================đầu ra=======================
// ApartmentStatus.toVietnamese(apartment.status)

class ApartmentStatus {
  static const available = "available";
  static const pending = "pending";
  static const booked = "booked";
  static const occupied = "occupied";

  static const values = [
    available,
    pending,
    booked,
    occupied,
  ];

  static const localized = {
    available: "Đang có sẵn",
    pending: "Đang chờ",
    booked: "Đã đặt",
    occupied: "Đang ở",
  };

  static String toVietnamese(String status) {
    return localized[status] ?? status;
  }
}

//Kiểm tra status của yêu cầu đặt phòng: pending( chờ xác nhận), approved(đã được duyệt), completed(đặt phòng TC),
class BookingRequestStatus {
  static const pending = "Pending";
  static const approved = "Approved";
  static const completed = "Completed";

  static const values = [
    pending,
    approved,
    completed,
  ];

  static const localized = {
    pending: "Đang chờ xác nhận",
    approved: "Đã được duyệt",
    completed: "Đã hoàn thành",
  };

  static String toVietnamese(String status) {
    return localized[status] ?? status;
  }
}

//kiểm tra status của hóa đơn

//kiểm tra status của post

//kiểm tra status của user

//kiểm tra status của contract

//kiểm tra status của contentViolation
