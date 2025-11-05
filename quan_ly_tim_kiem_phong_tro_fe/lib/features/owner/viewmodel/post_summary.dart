import 'dart:ui';

import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/post_detail.dart';

class PostSummary {
  String postId;
  String? roomNumber;
  DateTime? postDate;
  String? status;
  String? imageUrl;
  Future<PostDetail> Function() onEdit;
  Future<bool> Function() onDelete;

  PostSummary({
    required this.postId,
    this.roomNumber,
    this.postDate,
    this.status,
    this.imageUrl,
    required this.onEdit,
    required this.onDelete,
  });
}