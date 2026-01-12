class Apartment {
  String? apartmentID;
  String? codeApartment;
  double? dailyRate;
  double? deposit;
  int? maxOccupancy;
  String? description;
  List<String>? pathImage;
  String? status;
  String? password;
  String? address;
  double? latitude;
  double? longitude;
  List<String>? requirement;
  String? type;
  String? userID;

  Apartment({
    this.apartmentID,
    this.codeApartment,
    this.dailyRate,
    this.deposit,
    this.maxOccupancy,
    this.description,
    this.pathImage,
    this.status,
    this.password,
    this.address,
    this.latitude,
    this.longitude,
    this.requirement,
    this.type,
    this.userID,
  });

  factory Apartment.fromMap(String id, Map<String, dynamic> map) => Apartment(
        apartmentID: id,
        codeApartment: map['CodeApartment'] ?? '',
        dailyRate: (map['DailyRate'] as num).toDouble(),
        deposit: (map['Deposit'] as num).toDouble(),
        maxOccupancy: map['MaxOccupancy'] ?? 0,
        description: map['Decription'] ?? '',
        pathImage: List<String>.from(map['PathImage'] ?? []),
        status: map['Status'] ?? '',
        password: map['Password'] ?? '',
        address: map['Address'] ?? '',
        latitude: map['Latitude']?.toDouble(),
        longitude: map['Longitude']?.toDouble(),
        requirement: List<String>.from(map['Requirements'] ?? []),
        type: map['Type'] ?? '',
        userID: map['UserID'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'CodeApartment': codeApartment,
        'DailyRate': dailyRate,
        'Deposit': deposit,
        'MaxOccupancy': maxOccupancy,
        'Decription': description,
        'PathImage': pathImage,
        'Status': status,
        'Password': password,
        'Address': address,
        'Latitude': latitude,
        'Longitude': longitude,
        'Requirements': requirement,
        'Type': type,
        'UserID': userID,
      };
}
