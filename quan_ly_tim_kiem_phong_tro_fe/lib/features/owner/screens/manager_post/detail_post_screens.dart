import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/post_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/post_detail.dart';

import '../../widgets/widgets.dart';

class DetailPostScreen extends StatelessWidget {
  final String postId; // Thêm dòng này

  const DetailPostScreen({super.key, required this.postId}); // Sửa lại constructor

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final PostController _postController = PostController();

    return Scaffold(
      body: FutureBuilder<PostDetail>(
        future: _postController.viewDetail(postId),
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
                  Row(
                    children: [
                      const Spacer(),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  LabelTitleWidget(title: "Thông tin bài đăng"),
                  Center(child: RoomDetailCardWidget(postDetail)), // Truyền postDetail vào đây
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}