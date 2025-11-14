import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/post_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/screens/manager_post/detail_post_screens.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/post_summary.dart';

import '../../widgets/widgets.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final PostController _postController = PostController();
  List<PostSummary> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final posts = await _postController.viewSummary(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      _posts = posts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: screenWidth,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.05),
              Center(child: LogoWidget()),
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TagWithIconWidget(title: "Quảng lý bài đăng"),
                ButtonAddWidget(
                  title: "Thêm bài đăng mới", 
                  screen: DetailPostScreen(postId: ''),
                  onNavigateBack: _loadPosts, // Refresh khi quay lại
                ),
              ],
              ),
              SizedBox(height: screenHeight * 0.01),
              SearchBarWidget(),
              SizedBox(height: screenHeight * 0.015),
              if (_isLoading)
                const LoadingWidget(
                  message: 'Đang tải bài đăng...',
                )
              else if (_posts.isEmpty)
                const EmptyStateWidget(
                  title: 'Chưa có bài đăng',
                  message: 'Bạn chưa có bài đăng nào',
                  icon: Icons.post_add,
                )
              else
                ..._posts.map((post) => RoomPostItemWidget(
                      postId: post.postId!,
                      roomName: post.roomNumber!,
                      postDate: "${post.postDate?.day.toString().padLeft(2, '0')}/${post.postDate?.month.toString().padLeft(2, '0')}/${post.postDate?.year}",
                      status: post.status!,
                      imageUrl: post.imageUrl!,
                      onAction: (postId, action) {
                        if (action == 'view') {
                          // Xử lý xem chi tiết
                          print("Xem chi tiết bài viết: $postId");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPostScreen(postId: postId),
                            ),
                          );
                        } else if (action == 'edit') {
                          // Xử lý chỉnh sửa
                          print("Chỉnh sửa bài viết: $postId");
                        } else if (action == 'delete') {
                          print("Xóa bài viết: $postId");
                          // Xử lý xóa bài viết
                        }
                      },
                    )),
            ],
          ),
        ),
      ),
    );
  }
}