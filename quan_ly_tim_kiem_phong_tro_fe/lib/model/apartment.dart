import 'package:cloud_firestore/cloud_firestore.dart';

class Apartment {
  final String apartmentID;
  final String codeApartment;
  final double dailyRate;
  final double deposit;
  final int maxOccupancy;
  final String description;
  final String userId;
  final List<String> pathImage;
  final String status;
  final String password;
  final String address;
  final String type;

  Apartment({
    required this.apartmentID,
    required this.codeApartment,
    required this.dailyRate,
    required this.deposit,
    required this.maxOccupancy,
    required this.description,
    required this.pathImage,
    required this.status,
    required this.password,
    required this.userId,
    required this.address,
    required this.type,
  });

  static String _getString(Map<String, dynamic> d, List<String> keys) {
    for (final k in keys) {
      if (d.containsKey(k) && d[k] != null) return d[k].toString();
    }
    return '';
  }

  static double _getDouble(Map<String, dynamic> d, List<String> keys) {
    for (final k in keys) {
      if (d.containsKey(k) && d[k] != null) {
        final val = d[k];
        if (val is num) return val.toDouble();
        final parsed = double.tryParse(val.toString());
        if (parsed != null) return parsed;
      }
    }
    return 0.0;
  }

  static int _getInt(Map<String, dynamic> d, List<String> keys) {
    for (final k in keys) {
      if (d.containsKey(k) && d[k] != null) {
        final val = d[k];
        if (val is int) return val;
        if (val is num) return val.toInt();
        final parsed = int.tryParse(val.toString());
        if (parsed != null) return parsed;
      }
    }
    return 0;
  }

  factory Apartment.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() ?? {}) as Map<String, dynamic>;

    return Apartment(
      apartmentID: doc.id,
      codeApartment: _getString(data, ['CodeApartment', 'codeApartment']),
      description: _getString(data, ['Description', 'Decription', 'description', 'decription']),
      status: _getString(data, ['Status', 'status']),
      userId: _getString(data, ['UserId', 'userId']),
      pathImage: (data['PathImage'] is List) ? List<String>.from(data['PathImage']) : <String>[],
      dailyRate: _getDouble(data, ['DailyRate', 'dailyRate']),
      deposit: _getDouble(data, ['Deposit', 'deposit']),
      maxOccupancy: _getInt(data, ['MaxOccupancy', 'maxOccupancy']),
      password: _getString(data, ['Password', 'password']),
      address: _getString(data, ['Address', 'address']),
      type: _getString(data, ['Type', 'type']),
    );
  }
}
