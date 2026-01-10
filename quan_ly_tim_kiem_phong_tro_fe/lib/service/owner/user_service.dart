import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/user.dart';
class UserService {
    //connect to firebase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //getAllUser => List<User>
  Future<List<User>> getAllUser() async {
    List<User> users = [];
    QuerySnapshot snapshot = await firestore.collection("users").get();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      users.add(
        User(
          userID: doc.id,
          fullName: data['Username'],
          email: data['Email'],
          phone: data['Phone'],
        ),
      );
    }

    return users;
  }

  //getUserById
  Future<User> getUserById(String id) async {
    DocumentSnapshot snapshot = await firestore.collection("users").doc(id).get();
    final data = snapshot.data() as Map<String, dynamic>;
    return User(
      userID: snapshot.id,
      fullName: data['Fullname'],
      email: data['Email'],
      phone: data['Phone'],
    );
  }

  //getUserByFullname
  Future<User?> getUserByFullname(String fullName) async {
    QuerySnapshot snapshot = await firestore
        .collection("users")
        .where('Fullname', isEqualTo: fullName)
        .get();
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      return User(
        userID: doc.id,
        fullName: data['Fullname'],
        email: data['Email'],
        phone: data['Phone'],
      );
    }
    return null; // Trả về null nếu không tìm thấy người dùng
  }

  //getUserByEmail
  Future<User?> getUserByEmail(String email) async {
    QuerySnapshot snapshot = await firestore
        .collection("users")
        .where('Email', isEqualTo: email)
        .get();
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      return User(
        userID: doc.id,
        fullName: data['Fullname'],
        email: data['Email'],
        phone: data['Phone'],
      );
    }
    return null; // Trả về null nếu không tìm thấy người dùng
  }


  //createUser

  //updateUser

  //deleteUser
}