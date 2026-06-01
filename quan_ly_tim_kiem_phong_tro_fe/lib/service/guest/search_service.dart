// lib/service/guest/search_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diacritic/diacritic.dart';

import '../../../model/apartment.dart';
import '../../../model/amenity_in_apartment.dart';
import '../../../model/post.dart';
import '../../../model/contract.dart';
import '../../../model/search_criteria.dart';
import '../../../model/search_result.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String normalize(String input) {
    return removeDiacritics(input).toLowerCase();
  }

  Future<SearchResult> search(SearchCriteria criteria) async {
    // =========================
    // QUERY APARTMENT
    // =========================

    Query<Map<String, dynamic>> query = _firestore.collection('apartment');

    // CodeApartment
    if (criteria.codeApartment != null && criteria.codeApartment!.isNotEmpty) {
      query = query.where('CodeApartment', isEqualTo: criteria.codeApartment);
    }

    // Status
    if (criteria.status != null && criteria.status!.trim().isNotEmpty) {
      query = query.where('Status', isEqualTo: criteria.status);
    }

    // Min price
    if (criteria.minDailyRate != null) {
      query = query.where(
        'DailyRate',
        isGreaterThanOrEqualTo: criteria.minDailyRate,
      );
    }

    // Max price
    if (criteria.maxDailyRate != null) {
      query = query.where(
        'DailyRate',
        isLessThanOrEqualTo: criteria.maxDailyRate,
      );
    }

    // Min occupancy
    if (criteria.minOccupancy != null) {
      query = query.where(
        'MaxOccupancy',
        isGreaterThanOrEqualTo: criteria.minOccupancy,
      );
    }

    // Max occupancy
    if (criteria.maxOccupancy != null) {
      query = query.where(
        'MaxOccupancy',
        isLessThanOrEqualTo: criteria.maxOccupancy,
      );
    }

    // Apartment type
    if (criteria.apartmentType != null && criteria.apartmentType!.isNotEmpty) {
      query = query.where('Type', isEqualTo: criteria.apartmentType);
    }

    // =========================
    // GET APARTMENTS
    // =========================

    final snap = await query.get();

    List<Apartment> apartments = snap.docs
        .map((d) => Apartment.fromFirestore(d))
        .toList();

    print('Step1 apartments: ${apartments.length}');

    // =========================
    // FILTER ADDRESS
    // =========================

    if (criteria.address != null && criteria.address!.trim().isNotEmpty) {
      final keyword = normalize(criteria.address!);

      apartments = apartments.where((apt) {
        final addr = normalize(apt.address ?? '');

        return addr.contains(keyword);
      }).toList();
    }

    print('Step2 address filter: ${apartments.length}');

    // =========================
    // FILTER AMENITIES
    // =========================

    final reqAmenityIds = criteria.amenityIds;

    if (reqAmenityIds != null && reqAmenityIds.isNotEmpty) {
      final Map<String, Set<String>> aptToAmenity = {};

      final linkSnap = await _firestore
          .collection('amenityInApartment')
          .where('AmenityId', whereIn: reqAmenityIds)
          .get();

      for (var doc in linkSnap.docs) {
        final link = AmenityInApartment.fromFirestore(doc);

        if (link.isAvailable) {
          aptToAmenity
              .putIfAbsent(link.apartmentId, () => <String>{})
              .add(link.amenityId);
        }
      }

      final requiredSet = reqAmenityIds.toSet();

      apartments = apartments.where((apt) {
        final currentAmenities = aptToAmenity[apt.ApartmentID] ?? <String>{};

        return requiredSet.difference(currentAmenities).isEmpty;
      }).toList();
    }

    print('Step3 amenities filter: ${apartments.length}');

    // =========================
    // FILTER AVAILABLE DATE
    // =========================

    if (criteria.checkIn != null && criteria.checkOut != null) {
      List<Apartment> availableApartments = [];

      for (final apt in apartments) {
        // Lấy contract của apartment

        final contractSnap = await _firestore
            .collection('contract')
            .where('ApartmentId', isEqualTo: apt.ApartmentID)
            .where('Status', whereIn: ['approved', 'active'])
            .get();

        bool isConflict = false;

        for (final doc in contractSnap.docs) {
          final contract = Contract.fromMap(doc.id, doc.data());

          final contractStart = contract.startDate;

          final contractEnd = contract.endDate!;

          // overlap date

          final overlap =
              contractStart.isBefore(criteria.checkOut!) &&
              contractEnd.isAfter(criteria.checkIn!);

          if (overlap) {
            isConflict = true;

            print('Apartment ${apt.ApartmentID} bị trùng lịch');

            break;
          }
        }

        // nếu không trùng lịch

        if (!isConflict) {
          print('Apartment ${apt.ApartmentID} available');

          availableApartments.add(apt);
        }
      }

      apartments = availableApartments;
    }

    print('Step4 available apartments: ${apartments.length}');

    // =========================
    // GET APARTMENT IDS
    // =========================

    final apartmentIds = apartments.map((e) => e.ApartmentID).toList();

    if (apartmentIds.isEmpty) {
      print('Không có apartment khả dụng');

      return SearchResult(posts: [], apartments: []);
    }

    // =========================
    // QUERY POSTS
    // =========================

    final postsSnap = await _firestore
        .collection('posts')
        .where('ApartmentID', whereIn: apartmentIds)
        .get();

    // =========================
    // FILTER APPROVED POSTS
    // =========================

    final posts = postsSnap.docs
        .map((e) => Post.fromFirestore(e))
        .where((p) => p.status.trim() == 'Approved')
        .toList();

    print('FINAL POSTS: ${posts.length}');

    return SearchResult(posts: posts, apartments: apartments);
  }
}
