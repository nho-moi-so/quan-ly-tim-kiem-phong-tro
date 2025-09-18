import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String? postID;
  String? apartmentID;
  String header;
  String status;
  String description;
  DateTime creationDate;

  Post({
    this.postID,
    this.apartmentID,
    required this.header,
    required this.status,
    required this.description,
    required this.creationDate,
  });

  factory Post.fromJson(String id, Map<String, dynamic> json) {
    return Post(
      postID: id,
      apartmentID: json['ApartmentID'],
      header: json['Header'],
      status: json['Status'],
      description: json['Description'],
      creationDate: (json['CreationDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postID': postID,
      'ApartmentID': apartmentID,
      'Header': header,
      'Status': status,
      'Description': description,
      'CreationDate': creationDate,
    };
  }
}
