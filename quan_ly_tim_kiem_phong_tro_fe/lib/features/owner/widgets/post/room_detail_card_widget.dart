import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/post_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/screens/main_screen.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/post_detail.dart';

class RoomDetailCardWidget extends StatefulWidget {
  final PostDetail postDetail;
  final void Function(bool isCreate, PostDetail data)? onSubmit;
  final void Function(String status, PostDetail data)? onStatusChanged;
  

  const RoomDetailCardWidget(this.postDetail, {super.key, this.onSubmit, this.onStatusChanged});

  @override
  State<RoomDetailCardWidget> createState() => _RoomDetailCardWidgetState();
}

class _RoomDetailCardWidgetState extends State<RoomDetailCardWidget> {
  late TextEditingController roomController;
  late TextEditingController priceController;
  late TextEditingController depositController;
  late TextEditingController addressController;
  late TextEditingController statusController;
  late TextEditingController postTitleController;
  late TextEditingController postDescriptionController;
  late TextEditingController postStatusController;
  
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    roomController = TextEditingController(text: widget.postDetail.roomNumber ?? '');
    priceController = TextEditingController(text: widget.postDetail.price ?? '');
    depositController = TextEditingController(text: widget.postDetail.deposit ?? '');
    addressController = TextEditingController(text: widget.postDetail.address ?? '');
    statusController = TextEditingController(text: widget.postDetail.status ?? '');
    postTitleController = TextEditingController(text: widget.postDetail.postTitle ?? '');
    postDescriptionController = TextEditingController(text: widget.postDetail.postDescription ?? '');
    postStatusController = TextEditingController(text: widget.postDetail.postStatus);
  imageUrls = widget.postDetail.imageUrls ?? [];
  }

  @override
  void dispose() {
  roomController.dispose();
  priceController.dispose();
  depositController.dispose();
  addressController.dispose();
  postTitleController.dispose();
  postDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: Container(
            width: screenWidth < 400 ? screenWidth * 0.98 : 378,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xD8756A6A),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: Text('Thông tin bài đăng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 12),
                  _infoField(label: 'Tiêu đề', controller: postTitleController, fullWidth: true, icon: Icons.title, hint: 'Nhập tiêu đề bài đăng...'),
                  
                  const SizedBox(height: 12),
                  _infoField(label: 'Nội dung', controller: postDescriptionController, fullWidth: true, multiline: true, icon: Icons.description, hint: 'Nhập nội dung bài đăng...'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: postStatusController.text.isNotEmpty ? postStatusController.text : 'Draft',
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.info, color: Color(0xFF4285F4)),
                      labelText: 'Trạng Thái',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Color(0xFF4285F4)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Color(0xFF4285F4)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Color(0xFF4285F4), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: PostController().getAllPostStatus().map((status) {
                      return DropdownMenuItem<String>(
                        value: status['value'],
                        child: Text(status['label'] ?? status['value'] ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        postStatusController.text = value ?? 'Draft';
                      });
                      if (widget.onStatusChanged != null && value != null) {
                        widget.onStatusChanged!(value, widget.postDetail);
                      }
                    },
                    disabledHint: Text(
                      postStatusController.text.isNotEmpty ? postStatusController.text : 'Nháp',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(child: Text('Thông tin phòng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _infoField(label: 'Phòng', controller: roomController, icon: Icons.meeting_room, hint: 'Số phòng...', readOnly: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _infoField(label: 'Trạng Thái', controller: statusController, icon: Icons.info_outline, hint: 'Nhập trạng thái...', readOnly: true)),
                    ],
                  ),
                  const SizedBox(height: 12),
                    _infoField(
                    label: 'Tiền Phòng (1 ngày):',
                    controller: priceController,
                    icon: Icons.attach_money,
                    fullWidth: true,
                    readOnly: true,
                    hint: '1 ngày - VND',
                    ),
                  const SizedBox(height: 12),
                  _infoField(label: 'Địa Chỉ', controller: addressController, fullWidth: true, icon: Icons.location_on, hint: 'Nhập địa chỉ phòng...', readOnly: true),
                  const SizedBox(height: 20),
                  const Text('Hình ảnh phòng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageUrls.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 160,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                            image: DecorationImage(
                              image: NetworkImage(imageUrls[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                        Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Close any dialog (if this widget was shown in a dialog)
                            Navigator.of(context, rootNavigator: true).pop();
                            // Then navigate to OwnerMainScreen with the Posts tab selected (index 3)
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const OwnerMainScreen(initialIndex: 3),
                            ));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Quay lại', style: TextStyle(color: Colors.black)),
                        ),
                        ),
                      const SizedBox(width: 16),
                        Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                          bool isCreate = widget.postDetail.postId == null || widget.postDetail.postId!.isEmpty || widget.postDetail.postId == "new";
                          _showConfirmationDialog(context, isCreate);
                          },
                          style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4285F4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          ),
                          child: Text(
                          widget.postDetail.postId == null || widget.postDetail.postId!.isEmpty || widget.postDetail.postId == "new" ? 'Tạo' : 'Cập Nhật',
                          style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  File? imageFile;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  void _showConfirmationDialog(BuildContext context, bool isCreate) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth < 400 ? screenWidth * 0.95 : 380.0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: dialogWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4285F4),
                      const Color(0xFF0D47A1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCreate ? Icons.add_circle_outline : Icons.edit_note,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        isCreate ? 'Xác nhận tạo bài viết' : 'Xác nhận cập nhật',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF4285F4).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            icon: Icons.title,
                            label: 'Tiêu đề',
                            value: postTitleController.text,
                            iconColor: const Color(0xFF4285F4),
                          ),
                          const Divider(height: 20),
                          _buildInfoRow(
                            icon: Icons.description,
                            label: 'Mô tả',
                            value: postDescriptionController.text,
                            iconColor: const Color(0xFF34A853),
                            maxLines: 3,
                          ),
                          const Divider(height: 20),
                          _buildInfoRow(
                            icon: Icons.meeting_room,
                            label: 'Phòng',
                            value: roomController.text,
                            iconColor: const Color(0xFFEA4335),
                          ),
                          const Divider(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoRow(
                                  icon: Icons.attach_money,
                                  label: 'Tiền phòng',
                                  value: priceController.text,
                                  iconColor: const Color(0xFFFBBC04),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInfoRow(
                                  icon: Icons.savings,
                                  label: 'Tiền cọc',
                                  value: depositController.text,
                                  iconColor: const Color(0xFFFBBC04),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          _buildInfoRow(
                            icon: Icons.location_on,
                            label: 'Địa chỉ',
                            value: addressController.text,
                            iconColor: const Color(0xFFEA4335),
                            maxLines: 2,
                          ),
                          const Divider(height: 20),
                          _buildInfoRow(
                            icon: Icons.info,
                            label: 'Trạng thái bài đăng',
                            value: _getStatusLabel(postStatusController.text),
                            iconColor: const Color(0xFF9C27B0),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Warning message
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFFFC107),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFFF57C00),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isCreate 
                                ? 'Bạn có chắc chắn muốn tạo bài viết này?'
                                : 'Bạn có chắc chắn muốn cập nhật thông tin này?',
                              style: const TextStyle(
                                color: Color(0xFFF57C00),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action buttons
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.close, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Hủy',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          // Cập nhật lại dữ liệu PostDetail từ controller trước khi submit
                          widget.postDetail.postTitle = postTitleController.text;
                          widget.postDetail.postDescription = postDescriptionController.text;
                          widget.postDetail.postStatus = postStatusController.text;
                          // Các trường khác nếu cần
                          if (widget.onSubmit != null) {
                            widget.onSubmit!(isCreate, widget.postDetail);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4285F4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(isCreate ? Icons.check_circle : Icons.update, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              isCreate ? 'Tạo mới' : 'Cập nhật',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : 'Chưa có thông tin',
                style: TextStyle(
                  fontSize: 14,
                  color: value.isNotEmpty ? Colors.black87 : Colors.grey[400],
                  fontWeight: FontWeight.w600,
                ),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStatusLabel(String value) {
    final statuses = PostController().getAllPostStatus();
    final status = statuses.firstWhere(
      (s) => s['value'] == value,
      orElse: () => {'value': value, 'label': value},
    );
    return status['label'] ?? value;
  }

  Widget _infoField({
    required String label,
    required TextEditingController controller,
    bool fullWidth = false,
    bool multiline = false,
    IconData? icon,
    String? hint,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black.withOpacity(0.7),
            fontSize: 14,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: fullWidth ? null : 166,
          height: multiline ? 94 : 41,
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          alignment: Alignment.centerLeft,
          child: TextFormField(
            controller: controller,
            maxLines: multiline ? 4 : 1,
            readOnly: readOnly,
            decoration: InputDecoration(
              prefixIcon: icon != null ? Icon(icon, color: Color(0xFF4285F4)) : null,
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFF4285F4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFF4285F4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFF4285F4), width: 2),
              ),
            ),
            style: const TextStyle(fontSize: 14, fontFamily: 'Noto Sans'),
          ),
        ),
      ],
    );
  }
}
