class AmenityInApartment {
  final String? amenityInApartmentID;
  final String amenityId;
  final String apartmentId;
  final int? quantity;
  final bool isAvailable;

  AmenityInApartment({
    this.amenityInApartmentID,
    required this.apartmentId,
    required this.amenityId,
    this.quantity,
    required this.isAvailable,
  });

  factory AmenityInApartment.fromMap(String id, Map<String, dynamic> map) => AmenityInApartment(
        amenityInApartmentID: id,
        apartmentId: map['ApartmentId'] ?? '',
        amenityId: map['AmenityId'] ?? '',
        quantity: map['Quantity'] ?? 0,
        isAvailable: map['IsAvailable'] ?? false,
      );

  Map<String, dynamic> toMap() => {
        'Quantity': quantity,
        'IsAvailable': isAvailable,
      };
}