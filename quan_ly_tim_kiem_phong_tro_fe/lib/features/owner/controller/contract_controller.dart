import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/helpers/format_currency.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/contract_detail.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/amenity_in_apartment_service.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/amenity_service.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/apartment_service.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/contract_service.dart';


class ContractController {
  final ContractService _contractService = ContractService();
  final ApartmentService _apartmentService = ApartmentService();
  final AmenityInApartmentService _amenityInApartmentService = AmenityInApartmentService();
  final AmenityService _amenityService = AmenityService();
  //create(String bookingRequestId) => bool
  
  //viewDetail(String contractId) => ContractDetail - done //==dữ liệu giả
  Future<ContractDetail?> viewDetail(String contractId) async {
    //thong tin contract
    var contract = await _contractService.getContractById(contractId);
    //thong tin apartment
    var apartment = await _apartmentService.getApartmentById(contract.apartmentId);
    //thong tin amenity
    var amenities = await _amenityInApartmentService.getAmenityInApartmentByApartmentId(contract.apartmentId);
    amenities.sort((a, b) => a.amenityId.compareTo(b.amenityId));
    List<String> amenityNames = [];
    for (var amenity in amenities) {
      var amenityDetail = await _amenityService.getAmenityById(amenity.amenityId);
      amenityNames.add(amenityDetail.description);
    }

    // Calculate number of days
    final numberOfDays = contract.endDate.difference(contract.startDate).inDays;
    
    // Mock invoice data (you can calculate these from real data)
    final dailyRate = apartment.dailyRate ?? 0.0;
    final otherFees = 100000.0; // Phí dịch vụ, điện nước, etc.
    final taxRate = 10.0; // 10% VAT
    final discount = 200000.0; // Giảm giá khuyến mãi
    final totalPrice = dailyRate * (numberOfDays > 0 ? numberOfDays : 1) + otherFees + (dailyRate * (numberOfDays > 0 ? numberOfDays : 1) + otherFees) * (taxRate / 100) - discount;

    var contractDetail = ContractDetail(
      contractId: contract.contractID,
      imageUrl: (apartment.pathImage?.isNotEmpty ?? false) ? apartment.pathImage![0] : "https://placehold.co/148x111",
      price: formatCurrency(totalPrice),
      deposit: formatCurrency(apartment.dailyRate!),
      title: apartment.type,
      address: apartment.address,
      features: amenityNames,
      imageUrlMap: "https://maps.app.goo.gl/D9n1mdjx7YEBCBPD9",
      ratingText: "9.2 Trên cả tuyệt vời",
      rating: 4.0,
      checkInTime: contract.startDate,
      checkOutTime: contract.endDate,
      extraInfo: "Không có thêm thông tin",
      description: apartment.description,
      password: "12345678",
      // Invoice data
      dailyRate: dailyRate,
      numberOfDays: numberOfDays > 0 ? numberOfDays : 1,
      otherFees: otherFees,
      taxRate: taxRate,
      discount: discount,
    );

    return contractDetail;
  }

  //updateInfo(ContractDetail contractDetail) => bool
  
  //updateStatus(String status) => bool
  
  //delete(String contractId) => bool
}