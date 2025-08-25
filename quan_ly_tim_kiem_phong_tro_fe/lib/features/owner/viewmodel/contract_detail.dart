class ContractDetail {
  String contractId;
  String? imageUrl; // = "https://placehold.co/148x111";
  String? price; // = "4.500.000đ";
  String? deposit; // = "500.000đ";
  String? title; // = "MiniHouse Cần Thơ";
  String? address; // = "45 Nguyễn Văn Cừ, Cần Thơ";
  List<String>? features; // = [
  //     "Miễn phí wifi",
  //     "Có hồ bơi vô cực",
  //     "Có bãi đỗ xe",
  //     "Hỗ trợ trên 24/24",
  //     "Hỗ trợ mang hành lý tận phòng",
  //     "2 giường đơn",
  //     "Đặt và thanh toán tiền ngay",
  //     "Khuyến mãi chớp nhoáng",
  //   ];

  String? imageUrlMap; //: "https://your-map-image-url",
  String? ratingText; //: "9.2 Trên cả tuyệt vời",
  //String address; //: "45, Nguyễn văn cừ, an bình cần thơ",
  double? rating; //: 4, // số sao vàng

  DateTime? checkInTime; //: DateTime(2023, 10, 1, 14, 0).toString(), 
  DateTime? checkOutTime; //: DateTime(2023, 10, 2, 12, 0).toString(), 
  String? extraInfo; //: "Không có thêm thông tin",
  String? description; //: "Căn hộ rộng rãi, thoáng mát"),

  String? password; //: "12345678"

  String? pathContract;

  ContractDetail({
    required this.contractId,
    this.imageUrl,
    this.price,
    this.deposit,
    this.title,
    this.address,
    this.features,
    this.imageUrlMap,
    this.ratingText,
    this.rating,
    this.checkInTime,
    this.checkOutTime,
    this.extraInfo,
    this.description,
    this.password,
    this.pathContract,
  });
}