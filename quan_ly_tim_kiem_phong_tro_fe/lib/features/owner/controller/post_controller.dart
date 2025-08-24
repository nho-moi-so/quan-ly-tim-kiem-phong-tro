import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/post_detail.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/post_summary.dart';

class PostController {
  //create

  //viewSummary(String ownerId) => List<PostSummary> -done /==dữ liệu giả
  Future<List<PostSummary>> viewSummary(String ownerId) async {
    
    List<PostSummary> postSummaries = [];
    //==hiện tại cho dữ liệu giả
    postSummaries = [
      PostSummary(
        postId: "1",
        roomNumber: "Phòng 101",
        postDate: DateTime(2023, 1, 1),
        status: "Đang cho thuê",
        imageUrl: "https://via.placeholder.com/150",
        onEdit: () async {
          return PostDetail();
        },
        onDelete: () async {
          return false;
        },
      ),
      PostSummary(
        postId: "2",
        roomNumber: "Phòng 102",
        postDate: DateTime(2023, 1, 2),
        status: "Đã cho thuê",
        imageUrl: "https://via.placeholder.com/150",
        onEdit: () async {
          return PostDetail();
        },
        onDelete: () async {
          return false;
        },
      ),
      PostSummary(
        postId: "3",
        roomNumber: "Phòng 103",
        postDate: DateTime(2023, 1, 3),
        status: "Đang cho thuê",
        imageUrl: "https://via.placeholder.com/150",
        onEdit: () async {
          return PostDetail();
        },
        onDelete: () async {
          return false;
        },
      ),
      PostSummary(
        postId: "4",
        roomNumber: "Phòng 104",
        postDate: DateTime(2023, 1, 4),
        status: "Đang cho thuê",
        imageUrl: "https://via.placeholder.com/150",
        onEdit: () async {
          return PostDetail();
        },
        onDelete: () async {
          return false;
        },
      ),
    ];
    //===============================


    return postSummaries;
  }

  //viewDetail(String postId) => PostDetail

  //updateInfo(PostDetail postDetail) => PostDetail

  //updateStatus(String postId) => bool

  //delete(String postId) => bool
}