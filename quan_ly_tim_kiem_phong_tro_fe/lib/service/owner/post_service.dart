import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/post.dart';
class PostService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //=====getAllPost
  Future<List<Post>> getAllPost() async {
    List<Post> posts = [];
    QuerySnapshot snapshot = await firestore.collection("posts").get();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      posts.add(
      Post(
        postID: doc.id,
        header: data['header'] ?? '',
        status: data['status'] ?? '',
        description: data['description'] ?? '',
        creationDate: DateTime(data['creationDate'] ?? '')
      ));

    }

    return posts;
  }
  //=========getPostById
  Future<Post> getPostById(String id) async {
    DocumentSnapshot snapshot = await firestore.collection("posts").doc(id).get();
    final data = snapshot.data() as Map<String, dynamic>;
    return Post(
      postID: snapshot.id,
      header: data['header'] ?? '',
      status: data['status'] ?? '',
      description: data['description'] ?? '',
      creationDate: (data['creationDate'] as Timestamp).toDate(),
    );
  }
  //=========getPostByUserId
  Future<List<Post>> getPostByUserId(String userId) async {
    List<Post> posts = [];
    QuerySnapshot snapshot = await firestore
        .collection("posts")
        .where("userId", isEqualTo: userId)
        .get();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      posts.add(
        Post(
          postID: doc.id,
          header: data['header'] ?? '',
          status: data['status'] ?? '',
          description: data['description'] ?? '',
          creationDate: (data['creationDate'] as Timestamp).toDate(),
        ),
      );
    }
    return posts;
  }
  //===========createPost
  Future<Post> createPost(Post post) async {
    DocumentReference docRef = await firestore.collection("posts").add(post.toJson());

    // Lấy lại dữ liệu vừa add từ Firestore
    DocumentSnapshot snapshot = await docRef.get();
    final data = snapshot.data() as Map<String, dynamic>;

    // Trả về Post mới, dùng fromJson (không cần sửa model)
    return Post(
      postID: docRef.id,
      header: data['header'] ?? '',
      status: data['status'] ?? '',
      description: data['description'] ?? '',
      creationDate: (data['creationDate'] as Timestamp).toDate(),
    );
  }
  //===========updatePost
  Future<Post> updatePost(Post post) async {
    await firestore.collection("posts").doc(post.postID).update(post.toJson());
    return post;
  }

  //===========deletePost
  Future<void> deletePost(String id) async {
    await firestore.collection("posts").doc(id).delete();
  }

  Future getPostByApartmentId(String apartmentId) async {
    List<Post> posts = [];
    QuerySnapshot snapshot = await firestore
        .collection("posts")
        .where("ApartmentID", isEqualTo: apartmentId)
        .get();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      posts.add(
        Post(
          postID: doc.id,
          header: data['Header'] ?? '',
          status: data['Status'] ?? '',
          description: data['Description'] ?? '',
          creationDate: (data['CreationDate'] as Timestamp).toDate(),
        ),
      );
    }
    return posts;
  }
}