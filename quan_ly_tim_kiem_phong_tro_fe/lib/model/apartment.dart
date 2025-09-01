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
  List<String>? requirement;
  String? type;

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
    this.requirement,
    this.type,
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
        requirement: List<String>.from(map['Requirements'] ?? []),
        type: map['Type'] ?? '',
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
        'Requirement': requirement,
        'Type': type,
      };
}
