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

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postID: json['postID'],
      apartmentID: json['apartmentID'],
      header: json['header'],
      status: json['status'],
      description: json['description'],
      creationDate: (json['creationDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postID': postID,
      'apartmentID': apartmentID,
      'header': header,
      'status': status,
      'description': description,
      'creationDate': creationDate,
    };
  }
}
