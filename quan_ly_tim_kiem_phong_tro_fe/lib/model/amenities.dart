import 'package:cloud_firestore/cloud_firestore.dart';

class Amenity {
  final String amenityID;
  final String name;
  final String description;
  final bool isQuantifiable;

  Amenity({
    required this.amenityID,
    required this.name,
    required this.description,
    required this.isQuantifiable,
  });

  /// Tạo từ Map (ví dụ lấy từ Firestore)
  factory Amenity.fromMap(String id, Map<String, dynamic>? map) {
    if (map == null) {
      return Amenity(
        amenityID: id,
        name: '',
        description: '',
        isQuantifiable: false,
      );
    }
    return Amenity(
      amenityID: id,
      name: map['Name'] ?? map['name'] ?? '',                // 🔥 đồng bộ với Firestore (N hoa)
      description: map['Description'] ?? map['description'] ?? '',
      isQuantifiable: map['IsQuantifiable'] ?? map['isQuantifiable'] ?? false,
    );
  }

  /// Tạo từ Firestore DocumentSnapshot
  factory Amenity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return Amenity.fromMap(doc.id, data);
  }

  /// Convert ngược lại để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'Name': name,
      'Description': description,
      'IsQuantifiable': isQuantifiable,
    };
  }
}
