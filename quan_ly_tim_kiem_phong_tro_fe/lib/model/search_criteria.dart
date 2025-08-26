// lib/model/search_criteria.dart
class SearchCriteria {
  final String? codeApartment;      // lọc theo mã phòng (CodeApartment)
  final String? status;             // ví dụ "available"
  final double? minDailyRate;       // DailyRate tối thiểu
  final double? maxDailyRate;       // DailyRate tối đa
  final int? minOccupancy;          // số người tối thiểu
  final int? maxOccupancy;          // số người tối đa
  final List<String>? amenityIds;   // DANH SÁCH ID tiện ích cần có
  final String? address;            // thêm địa chỉ
  final int? resultCount;

  final DateTime? checkIn;          // ngày checkin
  final DateTime? checkOut;         // ngày checkout
  final String? apartmentType;      // loại căn hộ (2 phòng, 3 phòng…)
  final List<String>? amenities;    // danh sách tiện ích (nếu muốn khác với amenityIds)

  SearchCriteria({
    this.codeApartment,
    this.status,
    this.minDailyRate,
    this.maxDailyRate,
    this.minOccupancy,
    this.maxOccupancy,
    this.amenityIds,
    this.address,
    this.checkIn,
    this.checkOut,
    this.apartmentType,
    this.amenities,
    this.resultCount,
  });
}
