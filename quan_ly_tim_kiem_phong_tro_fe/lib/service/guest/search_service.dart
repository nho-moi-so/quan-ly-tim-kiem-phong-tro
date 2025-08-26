// lib/service/guest/search_service.dart
import 'package:diacritic/diacritic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../model/apartment.dart';
import '../../../model/amenities.dart';
import '../../../model/amenity_in_apartment.dart';
import '../../../model/search_criteria.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String normalize(String input) {
    return removeDiacritics(input).toLowerCase();
  }

  Future<List<Apartment>> search(SearchCriteria criteria) async {
    Query<Map<String, dynamic>> query = _firestore.collection('apartment');


    if (criteria.codeApartment != null && criteria.codeApartment!.isNotEmpty) {
      query = query.where('CodeApartment', isEqualTo: criteria.codeApartment);
    }

    if (criteria.status != null && criteria.status!.trim().isNotEmpty) {
      final s = criteria.status!.trim();
      final statusQuery = s.length > 0
          ? (s[0].toUpperCase() + s.substring(1).toLowerCase())
          : s;
      query = query.where('Status', isEqualTo: statusQuery);
    }

    if (criteria.minDailyRate != null) {
      query = query.where(
        'DailyRate',
        isGreaterThanOrEqualTo: criteria.minDailyRate,
      );
    }
    if (criteria.maxDailyRate != null) {
      query = query.where(
        'DailyRate',
        isLessThanOrEqualTo: criteria.maxDailyRate,
      );
    }


    if (criteria.minOccupancy != null) {
      query = query.where(
        'MaxOccupancy',
        isGreaterThanOrEqualTo: criteria.minOccupancy,
      );
    }
    if (criteria.maxOccupancy != null) {
      query = query.where(
        'MaxOccupancy',
        isLessThanOrEqualTo: criteria.maxOccupancy,
      );
    }

    if (criteria.apartmentType != null && criteria.apartmentType!.isNotEmpty) {
      query = query.where('Type', isEqualTo: criteria.apartmentType);
    }
    final snap = await query.get();
    List<Apartment> apartments = snap.docs
        .map((d) => Apartment.fromFirestore(d))
        .toList();


    print('Step1 (after firestore query): ${apartments.length}');
    for (var apt in apartments) {
      print(
        '  [S1] id=${apt.apartmentID}, code=${apt.codeApartment}, type=${apt.type}, status=${apt.status}, address=${apt.address}, maxOcc=${apt.maxOccupancy}, dailyRate=${apt.dailyRate}',
      );
    }

    final today = DateTime.now();
    if (criteria.checkIn != null) {
     
      if (criteria.checkIn!.isBefore(
        DateTime(today.year, today.month, today.day),
      )) {
        print(
          'Warning: checkIn is in the past (${criteria.checkIn}), skipping checkIn filter.',
        );
      } else {
        apartments = apartments.where((apt) {
          return true;
        }).toList();
      }
    }
    if (criteria.checkIn != null && criteria.checkOut != null) {
      if (criteria.checkOut!.isBefore(criteria.checkIn!)) {
        print('Warning: checkOut < checkIn, skipping date range filter.');
      } else {
       
      }
    }
    print('Step2 (after date checks): ${apartments.length}');

    final reqAmenityIds = criteria.amenityIds;
    if (reqAmenityIds != null && reqAmenityIds.isNotEmpty) {

      final batches = <List<String>>[];
      for (var i = 0; i < reqAmenityIds.length; i += 10) {
        batches.add(
          reqAmenityIds.sublist(
            i,
            (i + 10 > reqAmenityIds.length) ? reqAmenityIds.length : i + 10,
          ),
        );
      }

      final Map<String, Set<String>> aptToAmenity = {};
      for (final batch in batches) {
        final linkSnap = await _firestore
            .collection(
              'amenityInApartment',
            ) 
            .where('AmenityId', whereIn: batch)
            .get();

        for (var doc in linkSnap.docs) {
          final link = AmenityInApartment.fromFirestore(doc);
          if (link.isAvailable) {
            aptToAmenity
                .putIfAbsent(link.apartmentId, () => <String>{})
                .add(link.amenityId);
          }
        }
      }

      print('aptToAmenity map (count=${aptToAmenity.length}):');
      aptToAmenity.forEach((k, v) => print('  $k -> $v'));

      final requiredSet = reqAmenityIds.toSet();
      apartments = apartments.where((apt) {
        final have = aptToAmenity[apt.apartmentID] ?? <String>{};
        final ok = requiredSet.difference(have).isEmpty;
        if (!ok) {
          print(
            '  [amenity filter] dropping ${apt.apartmentID} (have=$have, need=$requiredSet)',
          );
        }
        return ok;
      }).toList();
    }
    print('Step3 (after amenities): ${apartments.length}');
    for (var apt in apartments) {
      print('  [S3] id=${apt.apartmentID}, code=${apt.codeApartment}');
    }
    if (criteria.address != null && criteria.address!.trim().isNotEmpty) {
      final keyword = normalize(criteria.address!);
      apartments = apartments.where((apt) {
        final addr = apt.address ?? '';
        final na = normalize(addr);
        final matched = na.contains(keyword);
        if (!matched) {
          print(
            '  [addr filter] dropping ${apt.apartmentID} (addr="$na", keyword="$keyword")',
          );
        }
        return matched;
      }).toList();
    }
    print('Step4 (after address): ${apartments.length}');
    for (var apt in apartments) {
      print('  [S4] id=${apt.apartmentID}, addr=${apt.address}');
    }

    return apartments;
  }
}
