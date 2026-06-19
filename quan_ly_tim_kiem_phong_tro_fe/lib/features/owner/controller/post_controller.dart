import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/helpers/format_currency.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/helpers/status_constants.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/post_detail.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/post_summary.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/post.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/apartment_service.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/post_service.dart';

class PostController {

  //create
  ////lay giao dien tao bai dang moi -done
  Future<PostDetail> getCreatePost(String apartmentID) async {
    // Tạo bài đăng mới cho apartmentID
    PostDetail postDetail = PostDetail();
    // Gọi service để tạo bài đăng mới
    ApartmentService apartmentService = ApartmentService();
    var apartment = await apartmentService.getApartmentById(apartmentID);
    postDetail.roomNumber = apartment.codeApartment;
    postDetail.status = ApartmentStatus.toVietnamese(ApartmentStatus.mapBackendStatus(apartment.status));
    postDetail.price = formatCurrency(apartment.dailyRate!);
    postDetail.deposit = formatCurrency(apartment.deposit!);
    postDetail.apartmentId = apartmentID;
    postDetail.address = apartment.address;
    postDetail.imageUrls = apartment.pathImage;
    
    return postDetail;
  }
  ////gọi service tạo bài đăng mới
  Future<bool> create(PostDetail postDetail) async {
      // Gọi service để tạo bài đăng mới
      PostService postService = PostService();
      postService.createPost(Post(
        apartmentID: postDetail.apartmentId!,
        header: postDetail.postTitle!, //header la title
        description: postDetail.postDescription!,
        status: "Pending",
        creationDate: DateTime.now(),
      ));
      return true;
  }

  //viewSummary(String ownerId) => List<PostSummary> -done 
  Future<List<PostSummary>> viewSummary(String ownerId) async {
    List<PostSummary> postSummaries = [];
    //lấy danh sách apartment của ownerId
    ApartmentService apartmentService = ApartmentService();
    var apartments = await apartmentService.getApartmentsByOwnerId(ownerId);
    print("Apartments count: ${apartments.length}");
    // lấy danh sách post của apartment
    for(var apartment in apartments) {
      PostService postService = PostService();
      var posts = await postService.getPostByApartmentId(apartment.apartmentID!);
      // print("Apartment ${apartment.apartmentID} has ${posts.length} posts");
      for (var post in posts) {
        PostSummary postSummary = PostSummary(
          postId: post.postID!,
          roomNumber: "Phòng ${apartment.codeApartment!}",
          postDate: post.creationDate!,
          status: post.status!,
          imageUrl: (apartment.pathImage != null && apartment.pathImage!.isNotEmpty) ? apartment.pathImage!.first : "https://via.placeholder.com/150",
          onEdit: () async {
            return PostDetail();
          }, 
          onDelete: () async { 
            return false;
          },
        );
        postSummaries.add(postSummary);
      }
      // print(apartment.apartmentID);
    }


    return postSummaries;
  }

  //viewDetail(String postId) => PostDetail //done 
  Future<PostDetail> viewDetail(String postId) async {
    PostDetail postDetail = PostDetail();
    // print("Viewing post detail for postId: $postId");
    // Gọi service để lấy chi tiết bài đăng
    PostService postService = PostService();
    var post = await postService.getPostById(postId);
    //lay thong tin apartment
    ApartmentService apartmentService = ApartmentService();
    var apartment = await apartmentService.getApartmentById(post.apartmentID!);
    // tao PostDetail
    // print("post.status: ${post.status}");
    postDetail = PostDetail(
      postId: post.postID,
      apartmentId: post.apartmentID,
      roomNumber: apartment.codeApartment!,
      price: formatCurrency(apartment.dailyRate!),
      deposit: formatCurrency(apartment.deposit!),
      address: apartment.address,
      status: ApartmentStatus.toVietnamese(ApartmentStatus.mapBackendStatus(apartment.status)),
      postTitle: post.header,
      postDescription: post.description,
      postStatus: PostStatus.toVietnamese(post.status ?? ''),
      imageUrls: apartment.pathImage,
    );
    // print("postDetail.postStatus: ${postDetail.postStatus}");

    //==hiện tại cho dữ liệu giả
    // postDetail = PostDetail(
    //   postId: "1",
    //   roomNumber: "Phòng 101",
    //   price: "3,000,000 VND",
    //   deposit: "3,000,000 VND",
    //   address: "123 Đường ABC, Quận 1, TP.HCM",
    //   status: "Trống",
    //   postTitle: "Phòng trọ đẹp, sạch sẽ, an ninh",
    //   postDescription: "Phòng rộng rãi, có ban công, gần chợ, siêu thị, trường học.",
    //   postStatus: "Draft",
    //   imageUrls: [
    //     "https://via.placeholder.com/300",
    //     "https://via.placeholder.com/300",
    //     "https://via.placeholder.com/300",
    //   ],
    // );
    //===============================
    return postDetail;
  }

  //updateInfo(PostDetail postDetail) => PostDetail
  Future<bool> updateInfo(PostDetail postDetail) async {
    try{
      // Gọi service để cập nhật bài đăng
      PostService postService = PostService();
      postService.updatePost(Post(
        postID: postDetail.postId!,
        apartmentID: postDetail.apartmentId!,
        header: postDetail.postTitle!, //header la title
        description: postDetail.postDescription!,
        status: "Approved", //===mặc định là Approved
        creationDate: DateTime.now(),
      ));
      return true;
    } catch (e) {
      print("Error updating post: $e");
      return false;
    }
  }

  //updateStatus(String postId, String status) => bool
  Future<bool> updateStatus(String postId, String status) async {
    try{
      // Gọi service để cập nhật trạng thái bài đăng
      PostService postService = PostService();
      var post = await postService.getPostById(postId);
      post.status = status;
      await postService.updatePost(post);
      return true;
    } catch (e) {
      print("Error updating post status: $e");
      return false;
    }
  }

  //delete(String postId) => bool

  //getAllPostStatus () => List<String>
  List<Map<String, String>> getAllPostStatus() {
    return PostStatus.values.map((status) => {
      'value': status,
      'label': PostStatus.toVietnamese(status),
    }).toList();
  }
}