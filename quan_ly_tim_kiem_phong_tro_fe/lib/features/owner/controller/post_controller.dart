import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/helpers/format_currency.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/helpers/status_constants.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/post_detail.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/post_summary.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/apartment_service.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/post_service.dart';

class PostController {
  //create
  Future<PostDetail> create(String apartmentID) async {
    // Tạo bài đăng mới cho apartmentID
    PostDetail postDetail = PostDetail();
    // Gọi service để tạo bài đăng mới
    ApartmentService apartmentService = ApartmentService();
    var apartment = await apartmentService.getApartmentById(apartmentID);
    postDetail.roomNumber = apartment.codeApartment;
    postDetail.status = ApartmentStatus.toVietnamese(apartment.status!);
    postDetail.price = formatCurrency(apartment.dailyRate!);
    postDetail.deposit = formatCurrency(apartment.deposit!);
    postDetail.address = apartment.address;
    postDetail.imageUrls = apartment.pathImage;
    
    return postDetail;
  } 

  //viewSummary(String ownerId) => List<PostSummary> -done /==dữ liệu giả
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
    //==hiện tại cho dữ liệu giả
    // postSummaries = [
    //   PostSummary(
    //     postId: "1",
    //     roomNumber: "Phòng 101",
    //     postDate: DateTime(2023, 1, 1),
    //     status: "Đang cho thuê",
    //     imageUrl: "https://via.placeholder.com/150",
    //     onEdit: () async {
    //       return PostDetail();
    //     },
    //     onDelete: () async {
    //       return false;
    //     },
    //   ),
    //   PostSummary(
    //     postId: "2",
    //     roomNumber: "Phòng 102",
    //     postDate: DateTime(2023, 1, 2),
    //     status: "Đã cho thuê",
    //     imageUrl: "https://via.placeholder.com/150",
    //     onEdit: () async {
    //       return PostDetail();
    //     },
    //     onDelete: () async {
    //       return false;
    //     },
    //   ),
    //   PostSummary(
    //     postId: "3",
    //     roomNumber: "Phòng 103",
    //     postDate: DateTime(2023, 1, 3),
    //     status: "Đang cho thuê",
    //     imageUrl: "https://via.placeholder.com/150",
    //     onEdit: () async {
    //       return PostDetail();
    //     },
    //     onDelete: () async {
    //       return false;
    //     },
    //   ),
    //   PostSummary(
    //     postId: "4",
    //     roomNumber: "Phòng 104",
    //     postDate: DateTime(2023, 1, 4),
    //     status: "Đang cho thuê",
    //     imageUrl: "https://via.placeholder.com/150",
    //     onEdit: () async {
    //       return PostDetail();
    //     },
    //     onDelete: () async {
    //       return false;
    //     },
    //   ),
    // ];
    //===============================


    return postSummaries;
  }

  //viewDetail(String postId) => PostDetail //done /==dữ liệu giả
  Future<PostDetail> viewDetail(String postId) async {
    PostDetail postDetail = PostDetail();
    
    //==hiện tại cho dữ liệu giả
    postDetail = PostDetail(
      postId: "1",
      roomNumber: "Phòng 101",
      price: "3,000,000 VND",
      deposit: "3,000,000 VND",
      address: "123 Đường ABC, Quận 1, TP.HCM",
      status: "Trống",
      postTitle: "Phòng trọ đẹp, sạch sẽ, an ninh",
      postDescription: "Phòng rộng rãi, có ban công, gần chợ, siêu thị, trường học.",
      postStatus: "Đang chờ duyệt nha",
      imageUrls: [
        "https://via.placeholder.com/300",
        "https://via.placeholder.com/300",
        "https://via.placeholder.com/300",
      ],
    );
    //===============================
    return postDetail;
  }

  //updateInfo(PostDetail postDetail) => PostDetail

  //updateStatus(String postId) => bool

  //delete(String postId) => bool
}