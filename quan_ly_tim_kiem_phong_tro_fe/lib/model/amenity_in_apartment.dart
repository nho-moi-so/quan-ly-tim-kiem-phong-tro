import 'package:cloud_firestore/cloud_firestore.dart';

class AmenityInApartment {
  final String amenityInApartmentID;
  final String amenityId;
  final String apartmentId;
  final int quantity;
  final bool isAvailable;

  AmenityInApartment({
    required this.amenityInApartmentID,
    required this.amenityId,
    required this.apartmentId,
    required this.quantity,
    required this.isAvailable,
  });

  factory AmenityInApartment.fromMap(String id, Map<String, dynamic> map) {
    return AmenityInApartment(
      amenityInApartmentID: id,
      amenityId: map['AmenityId'] ?? '',
      apartmentId: map['ApartmentId'] ?? '',
      quantity: int.tryParse(map['Quantity']?.toString() ?? '0') ?? 0,
      isAvailable: map['IsAvailable'] ?? false,
    );
  }

  factory AmenityInApartment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AmenityInApartment.fromMap(doc.id, data);
  }

  Map<String, dynamic> toMap() => {
        'AmenityId': amenityId,
        'ApartmentId': apartmentId,
        'Quantity': quantity,
        'IsAvailable': isAvailable,
      };
}
