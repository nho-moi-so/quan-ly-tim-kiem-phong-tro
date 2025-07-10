import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postID;
  final String header;
  final String status;
  final String description;
  final DateTime creationDate;

  Post({
    required this.postID,
    required this.header,
    required this.status,
    required this.description,
    required this.creationDate,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postID: json['postID'],
      header: json['header'],
      status: json['status'],
      description: json['description'],
      creationDate: (json['creationDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postID': postID,
      'header': header,
      'status': status,
      'description': description,
      'creationDate': creationDate,
    };
  }
}
