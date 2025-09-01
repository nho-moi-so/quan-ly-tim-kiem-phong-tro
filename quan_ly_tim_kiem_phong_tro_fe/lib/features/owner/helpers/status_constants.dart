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
  static const available = "Available";
  static const pending = "Pending";
  static const booked = "Booked";
  static const occupied = "Occupied";

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

//Kiểm tra status của yêu cầu đặt phòng: pending( chờ xác nhận), approved(đã được duyệt), canceled(đã hủy),
class BookingRequestStatus {
  static const pending = "Pending";
  static const approved = "Approved";
  static const canceled = "Canceled";

  static const values = [
    pending,
    approved,
    canceled,
  ];

  static const localized = {
    pending: "Đang chờ xác nhận",
    approved: "Đã được duyệt",
    canceled: "Đã hủy",
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
