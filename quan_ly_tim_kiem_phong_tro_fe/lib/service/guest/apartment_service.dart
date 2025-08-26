import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/apartment.dart';

class ApartmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Apartment>> getApartments() async {
    final snapshot = await _firestore.collection('apartment').get();
    return snapshot.docs.map((doc) => Apartment.fromFirestore(doc)).toList();
  }

  Future<Apartment?> getApartmentById(String id) async {
    final doc = await _firestore.collection('apartment').doc(id).get();
    if (doc.exists) {
      return Apartment.fromFirestore(doc);
    }
    return null;
  }
}
