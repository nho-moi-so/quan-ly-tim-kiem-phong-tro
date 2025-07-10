class AmenityInApartment {
  final String amenityInApartmentID;
  final int quantity;
  final bool isAvailable;

  AmenityInApartment({
    required this.amenityInApartmentID,
    required this.quantity,
    required this.isAvailable,
  });

  factory AmenityInApartment.fromMap(String id, Map<String, dynamic> map) => AmenityInApartment(
        amenityInApartmentID: id,
        quantity: map['Quantity'] ?? 0,
        isAvailable: map['IsAvailable'] ?? false,
      );

  Map<String, dynamic> toMap() => {
        'Quantity': quantity,
        'IsAvailable': isAvailable,
      };
}