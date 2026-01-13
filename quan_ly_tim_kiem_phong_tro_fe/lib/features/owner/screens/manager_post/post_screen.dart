import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/post_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/screens/manager_post/detail_post_screens.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/post_summary.dart';

import '../../widgets/common/filter_chip_widget.dart';
import '../../widgets/widgets.dart';

enum PostFilter { pending, approved, rejected }

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final PostController _postController = PostController();
  List<PostSummary> _posts = [];
  bool _isLoading = true;
  PostFilter currentFilter = PostFilter.pending;

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

  List<PostSummary> _filterPosts(List<PostSummary> posts) {
    switch (currentFilter) {
      case PostFilter.pending:
        return posts.where((post) => 
          post.status?.toLowerCase() == 'pending' || 
          post.status?.toLowerCase() == 'đang chờ duyệt'
        ).toList();
      case PostFilter.approved:
        return posts.where((post) => 
          post.status?.toLowerCase() == 'approved' || 
          post.status?.toLowerCase() == 'đã duyệt'
        ).toList();
      case PostFilter.rejected:
        return posts.where((post) => 
          post.status?.toLowerCase() == 'rejected' || 
          post.status?.toLowerCase() == 'bị từ chối'
        ).toList();
    }
  }

  String _getEmptyMessage() {
    switch (currentFilter) {
      case PostFilter.pending:
        return 'Không có bài đăng đang chờ duyệt';
      case PostFilter.approved:
        return 'Không có bài đăng đã được duyệt';
      case PostFilter.rejected:
        return 'Không có bài đăng bị từ chối';
    }
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
                // ButtonAddWidget(
                //   title: "Thêm bài đăng mới", 
                //   screen: DetailPostScreen(postId: ''),
                // ),
              ],
              ),
              SizedBox(height: screenHeight * 0.01),
              // SearchBarWidget(),
              SizedBox(height: screenHeight * 0.015),
              FilterChipWidget<PostFilter>(
                currentFilter: currentFilter,
                options: [
                  FilterOption(
                    label: 'Chờ duyệt',
                    icon: Icons.schedule_rounded,
                    color: const Color(0xFFF59E0B),
                    value: PostFilter.pending,
                  ),
                  FilterOption(
                    label: 'Đã duyệt',
                    icon: Icons.check_circle_rounded,
                    color: const Color(0xFF10B981),
                    value: PostFilter.approved,
                  ),
                  FilterOption(
                    label: 'Từ chối',
                    icon: Icons.cancel_rounded,
                    color: const Color(0xFFEF4444),
                    value: PostFilter.rejected,
                  ),
                ],
                onFilterChanged: (filter) {
                  setState(() {
                    currentFilter = filter;
                  });
                },
              ),
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
              else if (_filterPosts(_posts).isEmpty)
                EmptyStateWidget(
                  title: 'Không có bài đăng',
                  message: _getEmptyMessage(),
                  icon: Icons.post_add,
                )
              else
                ..._filterPosts(_posts).map((post) => RoomPostItemWidget(
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