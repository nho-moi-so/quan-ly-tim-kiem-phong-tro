class Apartment {
  final String? apartmentID;
  final String? codeApartment;
  final double? dailyRate;
  final double? deposit;
  final int? maxOccupancy;
  final String? description;
  final List<String>? pathImage;
  final String? status;
  final String? password;

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
      };
}
