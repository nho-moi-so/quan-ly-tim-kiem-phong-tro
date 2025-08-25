import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/contract_detail.dart';

class ContractController {
  //create(String bookingRequestId) => bool
  
  //viewDetail(String contractId) => ContractDetail - done //==dữ liệu giả
  Future<ContractDetail?> viewDetail(String contractId) async {
    var contractDetail = ContractDetail(
      contractId: contractId,
      imageUrl: "https://placehold.co/148x111",
      price: "4.500.000đ",
      deposit: "500.000đ",
      title: "MiniHouse Cần Thơ",
      address: "45 Nguyễn Văn Cừ, Cần Thơ",
      features: [
        "Miễn phí wifi",
        "Có hồ bơi vô cực",
        "Có bãi đỗ xe",
        "Hỗ trợ trên 24/24",
        "Hỗ trợ mang hành lý tận phòng",
        "2 giường đơn",
        "Đặt và thanh toán tiền ngay",
        "Khuyến mãi chớp nhoáng",
      ],
      imageUrlMap: "https://your-map-image-url",
      ratingText: "9.2 Trên cả tuyệt vời",
      rating: 4,
      checkInTime: DateTime(2023, 10, 1, 14, 0),
      checkOutTime: DateTime(2023, 10, 2, 12, 0),
      extraInfo: "Không có thêm thông tin",
      description: "Căn hộ rộng rãi, thoáng mát",
      password: "12345678",
    );

    return contractDetail;
  }

  //updateInfo(ContractDetail contractDetail) => bool
  
  //updateStatus(String status) => bool
  
  //delete(String contractId) => bool
}