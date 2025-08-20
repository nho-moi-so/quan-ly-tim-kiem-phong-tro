import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/amenity_in_apartment.dart';
class AmenityInApartmentService {
  //connect to firebase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  //getAll
  Future<List<AmenityInApartment>> getAll() async {
    List<AmenityInApartment> amenities = [];
    QuerySnapshot snapshot = await firestore.collection("amenityInApartment").get();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      amenities.add(AmenityInApartment.fromMap(doc.id, data));
    }
    return amenities;
    }
  
  //getAmenityInApartmentByApartmentId
  Future<List<AmenityInApartment>> getAmenityInApartmentByApartmentId(String apartmentId) async {
    List<AmenityInApartment> amenities = [];
    QuerySnapshot snapshot = await firestore.collection("amenityInApartment").where('ApartmentId', isEqualTo: apartmentId).get();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      amenities.add(AmenityInApartment.fromMap(doc.id, data));
    }
    return amenities;
  }
  
  
  //createAmenityInApartment
  Future<AmenityInApartment> createAmenityInApartment(AmenityInApartment amenityInApartment) async {
    DocumentReference docRef = await firestore.collection("amenityInApartment").add(amenityInApartment.toMap());
    DocumentSnapshot snapshot = await docRef.get();
    final data = snapshot.data() as Map<String, dynamic>;
    return AmenityInApartment.fromMap(docRef.id, data);
  }
  
  //updateAmenityInApartment
  Future<AmenityInApartment> updateAmenityInApartment(AmenityInApartment amenityInApartment) async {
    await firestore.collection("amenityInApartment").doc(amenityInApartment.amenityInApartmentID).update(amenityInApartment.toMap());
    return amenityInApartment;
  }
  
  //deleteAmenityInApartment
  Future<void> deleteAmenityInApartment(String amenityInApartmentID) async {
    await firestore.collection("amenityInApartment").doc(amenityInApartmentID).delete();
  }
}