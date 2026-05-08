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
  static const fixing = "Fixing";
  static const rented = "Rented";

  static const values = [
    available,
    fixing,
    rented,
  ];

  static const localized = {
    available: "Đang có sẵn",
    fixing: "Đang sửa chữa",
    rented: "Đã cho thuê",
  };

  static String toVietnamese(String status) {
    return localized[status] ?? status;
  }

  static String fromVietnamese(String vietnamese) {
    return localized.entries
        .firstWhere(
          (entry) => entry.value == vietnamese,
          orElse: () => MapEntry(vietnamese, vietnamese),
        )
        .key;
  }
}

//Kiểm tra status của yêu cầu đặt phòng: pending( chờ xác nhận), approved(đã được duyệt), cancelled(đã hủy),
class BookingRequestStatus {
  static const pending = "Pending";
  static const approved = "Approved";
  static const cancelled = "Cancelled";

  static const values = [
    pending,
    approved,
    cancelled,
  ];

  static const localized = {
    pending: "Đang chờ xác nhận",
    approved: "Đã được duyệt",
    cancelled: "Đã hủy",
  };

  static String toVietnamese(String status) {
    return localized[status] ?? status;
  }
}

//kiểm tra status của hóa đơn

//kiểm tra status của post
class PostStatus {
  static const draft = "Draft";
  static const hidden = "Hidden";
  static const pending = "Pending";
  static const approved = "Approved";
  static const rejected = "Rejected";

  static const values = [
    draft,
    hidden,
    pending,
    approved,
    rejected,
  ];

  static const localized = {
    draft: "Nháp",
    hidden: "Đã ẩn",
    pending: "Đang chờ duyệt",
    approved: "Đã duyệt",
    rejected: "Bị từ chối",
  };

  static String toVietnamese(String status) {
    return localized[status] ?? status;
  }

  static String fromVietnamese(String vietnamese) {
    return localized.entries
        .firstWhere(
          (entry) => entry.value == vietnamese,
          orElse: () => MapEntry(vietnamese, vietnamese),
        )
        .key;
  }
}


  // các hàm status
  String getStatusDisplayProfileScreen(String? status) {
      switch (status?.toLowerCase()) {
        case 'approved':
          return 'Đã xác minh';
        case 'pending':
          return 'Đang chờ duyệt';
        case 'rejected':
          return 'Bị từ chối';
        case 'active':
          return 'Chờ xác minh';
        default:
          return 'Chưa xác minh';
      }
  }
  
  String getStatusInVietnameseCardRoomWidget(String status) {
    if (status.contains('Available')) {
      return 'Còn trống';
    } else if (status.contains('Rented')) {
      return 'Đang ở';
    }
    return status;
  }

    String getStatusInVietnameseCardBookingRequestDetailWidget(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Đang chờ';
      case 'approved':
        return 'Đã thanh toán';
      case 'cancelled':
        return 'Đã hủy';
      case 'completed':
        return 'Hoàn thành';
      default:
        return status;
    }
  }

    String getStatusInVietnameseRoomPostItemWidget(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Đang chờ duyệt';
      case 'approved':
        return 'Đã duyệt';
      case 'rejected':
        return 'Đã từ chối';
      case 'hidden':
        return 'Đã ẩn';
      default:
        return status;
    }
  }
  
