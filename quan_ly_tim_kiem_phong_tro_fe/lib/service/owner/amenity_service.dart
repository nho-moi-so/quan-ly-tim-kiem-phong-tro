import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/amenities.dart';
class AmenityService {
    //connect to firebase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //getAllAmenity => List<Amenity>
  Future<List<Amenity>> getAllAmenity() async {
    List<Amenity> amenities = [];
    QuerySnapshot snapshot = await firestore.collection("amenity").get();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      amenities.add(Amenity.fromMap(doc.id, data));
    }
    return amenities;
  }

  //getAmenityById => Amenity
  Future<Amenity> getAmenityById(String id) async {
    DocumentSnapshot snapshot = await firestore.collection("amenity").doc(id).get();
    final data = snapshot.data() as Map<String, dynamic>;
    return Amenity.fromMap(snapshot.id, data);
  }

  //createAmenity => Amenity
  Future<Amenity> createAmenity(Amenity amenity) async {
    DocumentReference docRef = await firestore.collection("amenity").add(amenity.toMap());
    DocumentSnapshot snapshot = await docRef.get();
    final data = snapshot.data() as Map<String, dynamic>;
    return Amenity.fromMap(docRef.id, data);
  }

  //updateAmenity => Amenity
  Future<Amenity> updateAmenity(Amenity amenity) async {
    await firestore.collection("amenity").doc(amenity.amenityID).update(amenity.toMap());
    return amenity;
  }

  //deleteAmenity => Amenity
  Future<void> deleteAmenity(String amenityID) async {
    await firestore.collection("amenity").doc(amenityID).delete();
  }

  //getAmenityByName
  Future<Amenity?> getAmenityByName(String amenityName) async {
    List<Amenity> amenities = await firestore.collection("amenity")
        .where("Description", isEqualTo: amenityName)
        .get()
        .then((snapshot) => snapshot.docs.map((doc) => Amenity.fromMap(doc.id, doc.data())).toList());
    return amenities.isNotEmpty ? amenities.first : null;
  }

}