import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/post_controller.dart';
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
    List<Map<String, String>> allStatuses = PostController().getAllPostStatus();
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
                  const Text('Thông tin bài đăng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _infoField(label: 'Tiêu đề', controller: postTitleController, fullWidth: true, icon: Icons.title, hint: 'Nhập tiêu đề bài đăng...'),
                  
                  const SizedBox(height: 12),
                  _infoField(label: 'Mô tả', controller: postDescriptionController, fullWidth: true, multiline: true, icon: Icons.description, hint: 'Nhập mô tả bài đăng...'),
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
                  const Text('Thông tin phòng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _infoField(label: 'Phòng', controller: roomController, icon: Icons.meeting_room, hint: 'Số phòng...', readOnly: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _infoField(label: 'Trạng Thái', controller: statusController, icon: Icons.info_outline, hint: 'Nhập trạng thái...', readOnly: true)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _infoField(label: 'Tiền Phòng', controller: priceController, icon: Icons.attach_money, hint: 'Nhập tiền phòng...', readOnly: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _infoField(label: 'Tiền Đặt Cọc', controller: depositController, icon: Icons.savings, hint: 'Nhập tiền đặt cọc...', readOnly: true)),
                    ],
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
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Hủy', style: TextStyle(color: Colors.black)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final info = '''Tiêu đề: ${postTitleController.text}\nMô tả: ${postDescriptionController.text}\nPhòng: ${roomController.text}\nTiền phòng: ${priceController.text}\nTiền đặt cọc: ${depositController.text}\nĐịa chỉ: ${addressController.text}''';
                            bool isCreate = widget.postDetail.postId == null || widget.postDetail.postId!.isEmpty || widget.postDetail.postId == "new";
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(isCreate ? 'Xác nhận tạo bài viết' : 'Xác nhận cập nhật'),
                                content: Text(info),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Đóng'),
                                  ),
                                  TextButton(
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
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4285F4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            widget.postDetail.postId == null || widget.postDetail.postId!.isEmpty || widget.postDetail.postId == "new" ? 'Tạo' : 'Cập Nhật',
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
