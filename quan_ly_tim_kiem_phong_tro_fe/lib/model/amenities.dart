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

  factory Amenity.fromMap(String id, Map<String, dynamic> map) => Amenity(
        amenityID: id,
        name: map['Name'] ?? '',
        description: map['Description'] ?? '',
        isQuantifiable: map['IsQuantifiable'] ?? false,
      );

  Map<String, dynamic> toMap() => {
        'Name': name,
        'Description': description,
        'IsQuantifiable': isQuantifiable,
      };
}
