import 'package:cloud_firestore/cloud_firestore.dart';

class Post {

  final String postID;
  final String apartmentID;
  final String ownerId;

  final String header;
  final String status;
  final String description;

  final DateTime creationDate;

  Post({
    required this.postID,
    required this.apartmentID,
    required this.ownerId,
    required this.header,
    required this.status,
    required this.description,
    required this.creationDate,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {

    final data =
        doc.data() as Map<String, dynamic>;

    return Post(

      // nếu Firestore không lưu postID
      // thì lấy luôn doc.id
      postID: doc.id,

      apartmentID:
          data['ApartmentID'] ?? '',

      ownerId:
          data['OwnerID'] ?? '',

      header:
          data['Header'] ?? '',

      status:
          data['Status'] ?? '',

      description:
          data['Description'] ?? '',

      creationDate:
          (data['CreationDate']
                  as Timestamp)
              .toDate(),
    );
  }

  Map<String, dynamic> toJson() {

    return {

      'ApartmentID': apartmentID,

      'OwnerID': ownerId,

      'Header': header,

      'Status': status,

      'Description': description,

      'CreationDate':
          Timestamp.fromDate(
              creationDate),
    };
  }
}