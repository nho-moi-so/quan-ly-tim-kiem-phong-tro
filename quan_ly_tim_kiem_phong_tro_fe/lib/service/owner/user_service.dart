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
      fullName: data['Username'],
      email: data['Email'],
      phone: data['Phone'],
    );
  }

  //createUser

  //updateUser

  //deleteUser
}