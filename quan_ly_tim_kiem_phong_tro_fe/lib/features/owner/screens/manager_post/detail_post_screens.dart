import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/post_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/post_detail.dart';

import '../../widgets/widgets.dart';

class DetailPostScreen extends StatelessWidget {
  final String postId;
  final String? apartmentId; // Thêm dòng này

  const DetailPostScreen({super.key, required this.postId, this.apartmentId}); // Sửa lại constructor

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final PostController _postController = PostController();

    // Nếu postId là "new", tạo bài đăng mới
    var postDetail;
    if (postId == "new") {
      // Tạo bài đăng mới
      print("Creating new post for apartmentId: $apartmentId");
      postDetail = _postController.getCreatePost(apartmentId!); // Sử dụng apartmentId để tạo bài đăng mới
    } else {
      postDetail = _postController.viewDetail(postId);
    }

    return Scaffold(
      body: FutureBuilder<PostDetail>(
        future: postDetail,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final postDetail = snapshot.data!;
          return SingleChildScrollView(
            child: Container(
              width: screenWidth,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.white,
              
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.03),
                  Center(child: LogoWidget()),
                  // LabelTitleWidget(title: "Thông tin bài đăng"),
                  Center(child: RoomDetailCardWidget(
                    postDetail,
                    onSubmit: (isCreate, data) async {
                      if (isCreate) {
                        // Gọi API tạo mới bài đăng
                        print("Tạo mới bài đăng: ${data.postTitle}");
                        bool result = await _postController.create(data);
                        if(result){
                          print("Tạo bài đăng thành công");
                        }
                        else{
                          print("Tạo bài đăng thất bại");
                        }
                      } else {
                        // Gọi API cập nhật bài đăng
                        print("Cập nhật bài đăng: ${data.postId}");
                        bool result = await _postController.updateInfo(data);
                        if(result){
                          print("Cập nhật bài đăng thành công");
                        }
                      }
                      
                    },
                    onStatusChanged: (status, data) {
                      print("Trạng thái bài đăng thay đổi: $status");
                      _postController.updateStatus(data.postId!, status);
                    },
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}