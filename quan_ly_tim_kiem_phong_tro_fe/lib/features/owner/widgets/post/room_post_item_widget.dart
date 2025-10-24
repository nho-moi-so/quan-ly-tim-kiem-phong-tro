import 'package:flutter/material.dart';

class RoomPostItemWidget extends StatelessWidget {
  final String postId;
  final String roomName;
  final String postDate;
  final String status;
  final String imageUrl;
  final void Function(String postId, String action)? onAction; // thêm dòng này

  const RoomPostItemWidget({
    Key? key,
    required this.postId,
    required this.roomName,
    required this.postDate,
    required this.status,
    required this.imageUrl,
    this.onAction, // thêm dòng này
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh đại diện phòng
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),

          // Thông tin phòng
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roomName,
                  style: const TextStyle(
                    color: Color(0xFF1C1B1F),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ngày đăng: $postDate\nTrạng thái: $status',
                  style: const TextStyle(
                    color: Color(0xFFA09CAB),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                  ),
                ),
              ],
            ),
          ),

          // Icon menu
          const SizedBox(width: 8),
          GestureDetector(
            onTapDown: (details) {
              showDialog(
                context: context,
                barrierColor: Colors.transparent,
                builder: (_) {
                  return Stack(
                    children: [
                      Positioned(
                        left: details.globalPosition.dx - 100,
                        top: details.globalPosition.dy + 5,
                        child: _ActionMenuCard(
                          onAction: (action) {
                            Navigator.pop(context);
                            if (onAction != null) {
                              onAction!(postId, action);
                            }
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            child: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
          ),

        ],
      ),
    );
  }
}
class _ActionMenuCard extends StatelessWidget {
  final void Function(String action)? onAction;
  const _ActionMenuCard({this.onAction});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _item(
              context,
              icon: Icons.visibility_outlined,
              label: 'Xem chi tiết',
              color: Colors.blue[600],
              action: 'view',
            ),
            _divider(),
            _item(
              context,
              icon: Icons.edit_outlined,
              label: 'Chỉnh sửa',
              color: Colors.orange[700],
              action: 'edit',
            ),
            _divider(),
            _item(
              context,
              icon: Icons.delete_outline,
              label: 'Xóa bài viết',
              color: Colors.red[600],
              action: 'delete',
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0));

  Widget _item(BuildContext context, {required IconData icon, required String label, Color? color, required String action}) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bạn chọn: $label')),
        );
        if (onAction != null) onAction!(action);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color ?? Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
