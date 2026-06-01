import 'package:cloud_firestore/cloud_firestore.dart';

class Apartment {
  final String ApartmentID;
  final String CodeApartment;
  final double DailyRate;
  final double Deposit;
  final int maxOccupancy;
  final String description;
  final String userId;
  final List<String> PathImage;
  final String status;
  final String password;
  final String address;
  final String Type;
  final List<String> Requirements;
  final String Bedroom;
  final String Bathroom;
  final List<String>? amenities;
  final double? latitude;
  final double? longitude;

  Apartment({
    required this.ApartmentID,
    required this.CodeApartment,
    required this.DailyRate,
    required this.Deposit,
    required this.maxOccupancy,
    required this.description,
    required this.PathImage,
    required this.status,
    required this.password,
    required this.userId,
    required this.address,
    required this.Type,
    required this.Requirements,
    required this.Bathroom,
    required this.Bedroom,
    this.amenities,
    this.latitude,
    this.longitude,
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
      ApartmentID: data['ApartmentID'] ?? doc.id,
      CodeApartment: _getString(data, ['CodeApartment', 'codeApartment']),
      description: _getString(data, [
        'Description',
        'Decription',
        'description',
        'decription',
      ]),
      status: _getString(data, ['Status', 'status']),
      userId: _getString(data, ['UserId', 'userId']),
      PathImage: (data['PathImage'] is List)
          ? List<String>.from(data['PathImage'])
          : <String>[],
      DailyRate: _getDouble(data, ['DailyRate', 'dailyRate']),
      Deposit: _getDouble(data, ['Deposit', 'deposit']),
      maxOccupancy: _getInt(data, ['MaxOccupancy', 'maxOccupancy']),
      password: _getString(data, ['Password', 'password']),
      address: _getString(data, ['Address', 'address']),
      Type: _getString(data, ['Type', 'type']),
      Requirements: (data['Requirements'] is List)
          ? List<String>.from(data['Requirements'])
          : <String>[],
      Bathroom: _getString(data, ['Bathroom', 'bathroom']),
      Bedroom: _getString(data, ['Bedroom', 'bedroom']),
      amenities: (data['amenities'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      latitude: _getDouble(data, ['latitude', 'Latitude']),
      longitude: _getDouble(data, ['longitude', 'Longitude']),
    );
  }
}

String formatVND(int? value) {
  if (value == null) return '-';
  final s = value.toString();
  final rev = s.split('').reversed.join();
  final groups = <String>[];
  for (var i = 0; i < rev.length; i += 3) {
    final end = (i + 3 > rev.length) ? rev.length : i + 3;
    groups.add(rev.substring(i, end));
  }
  final joined = groups.join('.');
  final normal = joined.split('').reversed.join();
  return '$normalđ';
}
