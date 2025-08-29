import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/apartment.dart';

class ApartmentService {
  //connect to firebase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //getAllApartment => List<Apartment>
  Future<List<Apartment>> getAllApartment() async {
    List<Apartment> apartments = [];
    QuerySnapshot snapshot = await firestore.collection("apartment").get();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      apartments.add(Apartment.fromMap(doc.id, data));
    }
    return apartments;
    }

  //getApartmentById => Apartment
  Future<Apartment> getApartmentById(String id) async {
    DocumentSnapshot snapshot = await firestore.collection("apartment").doc(id).get();
    final data = snapshot.data() as Map<String, dynamic>;
    return Apartment.fromMap(snapshot.id, data);
  }

  //getApartmentByUser => List<Apartment>
  Future<List<Apartment>> getApartmentByUser(String userId) async {
    List<Apartment> apartments = [];
    QuerySnapshot snapshot = await firestore
        .collection("apartment")
        .where('UserID', isEqualTo: userId)
        .get();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      apartments.add(Apartment.fromMap(doc.id, data));
    }
    return apartments;
  }

  //createApartment => Apartment
  Future<Apartment> createApartment(Apartment apartment) async {
  DocumentReference docRef = await firestore
      .collection("apartment")
      .add(apartment.toMap());

  // Lấy lại dữ liệu vừa add từ Firestore
  DocumentSnapshot snapshot = await docRef.get();
  final data = snapshot.data() as Map<String, dynamic>;

  // Trả về Apartment mới, dùng fromMap (không cần sửa model)
  return Apartment.fromMap(docRef.id, data);
  }


  //updateApartment => Apartment
  Future<Apartment> updateApartment(Apartment apartment) async {
    await firestore.collection("apartment").doc(apartment.apartmentID).update(apartment.toMap());
    return apartment;
  }

  //deleteApartment => bool
  Future<bool> deleteApartment(String apartmentID) async {
    try {
      await firestore.collection("apartment").doc(apartmentID).delete();
      return true;
    } catch (e) {
      return false;
    }
  }


}