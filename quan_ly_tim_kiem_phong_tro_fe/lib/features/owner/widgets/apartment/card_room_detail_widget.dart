import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/apartment_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/helpers/status_constants.dart';

import '../../viewmodel/room_detail.dart';

class CardRoomDetailWidget extends StatefulWidget {
  final RoomDetail initialData;
  final List<Map<String, String>> roomStates;
  final List<String> roomTypes;

  const CardRoomDetailWidget({
    super.key,
    required this.initialData,
    required this.roomStates,
    required this.roomTypes,
  });

  @override
  State<CardRoomDetailWidget> createState() => _CardRoomDetailWidgetState();
}

class _CardRoomDetailWidgetState extends State<CardRoomDetailWidget> {
  late TextEditingController roomCodeController;
  late TextEditingController areaController;
  late TextEditingController checkinController;
  late TextEditingController checkoutController;
  late TextEditingController capacityController;
  late TextEditingController statusController;
  late TextEditingController priceController;
  late TextEditingController depositPriceController;
  late TextEditingController descriptionController;
  late TextEditingController addressController;
  late TextEditingController requirementController;
  late List<String> initialImages;

  List<String> selectedUtilities = [];
  String? selectedRoomType;
  String? selectedRoomState;

  List<String> allUtilities = [];
  late List<File> _images;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();
  
  // Trạng thái kiểm tra mã phòng
  bool? isRoomCodeUnique;
  bool isCheckingRoomCode = false;

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles.map((xfile) => File(xfile.path)));
      });
    }
  }

  // final List<String> roomTypes = [
  //   '1 Phòng Ngủ',
  //   '2 Phòng Ngủ',
  //   'Studio',
  //   '3 Phòng Ngủ',
  // ];

  // final List<String> roomStates = [
  //   'Trống',
  //   'Đã thuê',
  //   'Đang sửa',
  // ];
  Future<void> loadAmenities() async {
    final data = await ApartmentController().getAllAmenity();
    setState(() {
      allUtilities = data;
    });
  }
  @override
  void initState() {
    super.initState();
    loadAmenities();

    initialImages = widget.initialData.images;
    print("================${initialImages}===========");

    roomCodeController = TextEditingController(text: widget.initialData.roomCode);
    depositPriceController = TextEditingController(
      text: widget.initialData.depositPrice.isEmpty ? '0' : widget.initialData.depositPrice
    );
    areaController = TextEditingController(text: widget.initialData.area);
    checkinController = TextEditingController(text: widget.initialData.checkin);
    checkoutController = TextEditingController(text: widget.initialData.checkout);
    capacityController = TextEditingController(text: widget.initialData.maxCapacity);
    statusController = TextEditingController(text: widget.initialData.room_status);

    // Nếu statusController.text có dữ liệu thì gán cho selectedRoomState
    if (statusController.text.isNotEmpty) {
      selectedRoomState = statusController.text;
    } else {
      selectedRoomState = null;
    }
    priceController = TextEditingController(
      text: _formatCurrency(widget.initialData.price.replaceAll(RegExp(r'[^0-9]'), '')),
    );
    descriptionController = TextEditingController(text: widget.initialData.description);
  addressController = TextEditingController(text: widget.initialData.address);
  requirementController = TextEditingController(text: widget.initialData.requirement);

  selectedUtilities = [...widget.initialData.utilities];
  selectedRoomType = widget.initialData.roomType.isNotEmpty ? widget.initialData.roomType : (widget.roomTypes.isNotEmpty ? widget.roomTypes.first : null);
    // selectedRoomState = widget.initialData.roomState;
    _images = [];
  }

  @override
  void dispose() {
    roomCodeController.dispose();
    areaController.dispose();
    checkinController.dispose();
    checkoutController.dispose();
    capacityController.dispose();
    statusController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    requirementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mã Phòng với nút check và random (chỉ hiện khi tạo mới)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mã Phòng'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: roomCodeController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: isRoomCodeUnique == null 
                                ? const Color(0xFF4285F4)
                                : isRoomCodeUnique! 
                                  ? Colors.green 
                                  : Colors.red,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: isRoomCodeUnique == null 
                                ? const Color(0xFF4285F4)
                                : isRoomCodeUnique! 
                                  ? Colors.green 
                                  : Colors.red,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: isRoomCodeUnique != null
                            ? Icon(
                                isRoomCodeUnique! ? Icons.check_circle : Icons.error,
                                color: isRoomCodeUnique! ? Colors.green : Colors.red,
                              )
                            : null,
                        ),
                        onChanged: (_) {
                          // Reset validation khi user thay đổi
                          if (isRoomCodeUnique != null) {
                            setState(() {
                              isRoomCodeUnique = null;
                            });
                          }
                        },
                      ),
                    ),
                    // Chỉ hiện nút check và random khi đang tạo mới (roomCode rỗng ban đầu)
                    if (widget.initialData.roomCode.isEmpty) ...[
                      const SizedBox(width: 8),
                      // Nút kiểm tra
                      Material(
                        color: const Color(0xFF4C6FFF),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: isCheckingRoomCode ? null : () async {
                            if (roomCodeController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Vui lòng nhập mã phòng')),
                              );
                              return;
                            }
                            setState(() {
                              isCheckingRoomCode = true;
                            });
                            final isUnique = await ApartmentController().isRoomCodeUnique(roomCodeController.text.trim());
                            setState(() {
                              isRoomCodeUnique = isUnique;
                              isCheckingRoomCode = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: isCheckingRoomCode
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check, color: Colors.white, size: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Nút random
                      Material(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            setState(() {
                              isCheckingRoomCode = true;
                              isRoomCodeUnique = null;
                            });
                            final randomCode = await ApartmentController().generateUniqueRoomCode();
                            setState(() {
                              roomCodeController.text = randomCode;
                              isRoomCodeUnique = true;
                              isCheckingRoomCode = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: const Icon(Icons.casino, color: Colors.white, size: 24),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (isRoomCodeUnique != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    isRoomCodeUnique! 
                      ? '✓ Mã phòng này có thể sử dụng'
                      : '✗ Mã phòng đã tồn tại, vui lòng chọn mã khác',
                    style: TextStyle(
                      fontSize: 12,
                      color: isRoomCodeUnique! ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //   const Text('Diện Tích'),
            //   const SizedBox(height: 8),
            //   TextFormField(
            //     controller: areaController,
            //     keyboardType: TextInputType.number,
            //     decoration: InputDecoration(
            //     contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(15),
            //       borderSide: const BorderSide(color: Color(0xFF4285F4)),
            //     ),
            //     filled: true,
            //     fillColor: Colors.white,
            //     suffix: const Text('m²', style: TextStyle(fontWeight: FontWeight.bold)),
            //     ),
            //   ),
            //   ],
            // ),
            // const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const Text('Sức Chứa Tối Đa'),
              const SizedBox(height: 8),
              TextFormField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFF4285F4)),
                ),
                filled: true,
                fillColor: Colors.white,
                suffix: const Text('Người', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              ],
            ),
            // const SizedBox(height: 16),
            // _buildLabeledInput('Trạng Thái Phòng', statusController),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // const Text('Giá Phòng'),
              // const SizedBox(height: 8),
              Row(
                children: [
                // Giá Phòng
                Expanded(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Giá Phòng'),
                    const SizedBox(height: 8),
                    TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF4285F4)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      suffix: const Text('VND', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    onChanged: (value) {
                      String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                      if (digits.isEmpty) {
                      priceController.text = '';
                      priceController.selection = TextSelection.collapsed(offset: 0);
                      return;
                      }
                      final formatted = _formatCurrency(digits);
                      priceController.text = formatted;
                      priceController.selection = TextSelection.collapsed(offset: formatted.length);
                    },
                    ),
                  ],
                  ),
                ),
                const SizedBox(width: 16),
                // Giá Đặt Cọc
                // Expanded(
                //   child: Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     const Text('Giá Đặt Cọc'),
                //     const SizedBox(height: 8),
                //     TextFormField(
                //     controller: depositPriceController,
                //     keyboardType: TextInputType.number,
                //     decoration: InputDecoration(
                //       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                //       border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(15),
                //       borderSide: const BorderSide(color: Color(0xFF4285F4)),
                //       ),
                //       filled: true,
                //       fillColor: Colors.white,
                //       suffix: const Text('VND', style: TextStyle(fontWeight: FontWeight.bold)),
                //     ),
                //     onChanged: (value) {
                //       String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                //       if (digits.isEmpty) {
                //         depositPriceController.text = '';
                //         depositPriceController.selection = TextSelection.collapsed(offset: 0);
                //         return;
                //       }
                //       final formatted = _formatCurrency(digits);
                //       if (depositPriceController.text != formatted) {
                //         depositPriceController.text = formatted;
                //         depositPriceController.selection = TextSelection.collapsed(offset: formatted.length);
                //       }
                //     },
                //     ),
                //   ],
                //   ),
                // ),
                ],
              ),
            const SizedBox(height: 16),
            _buildLabeledInput('Mô Tả Thêm', descriptionController, maxLines: 3),
            const SizedBox(height: 16),
            _buildLabeledInput('Địa chỉ', addressController),
            const SizedBox(height: 16),
            _buildLabeledInput('Yêu cầu', requirementController, maxLines: 2),
            const SizedBox(height: 16),
            const Text('Loại phòng'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Color(0xFF4285F4)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedRoomType,
                  hint: const Text('Chọn loại phòng'),
                  items: widget.roomTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRoomType = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    String searchText = '';
                    List<String> filteredUtilities = allUtilities;
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: const Text('Thêm Tiện Ích'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Tìm kiếm tiện ích...',
                                  prefixIcon: Icon(Icons.search),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    searchText = value;
                                    filteredUtilities = allUtilities
                                        .where((u) => u.toLowerCase().contains(searchText.toLowerCase()))
                                        .toList();
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 200,
                                width: 300,
                                child: ListView(
                                  children: filteredUtilities.map((u) {
                                    final isChecked = selectedUtilities.contains(u);
                                    return CheckboxListTile(
                                      title: Text(u),
                                      value: isChecked,
                                      onChanged: (checked) {
                                        setState(() {
                                          if (checked == true) {
                                            if (!selectedUtilities.contains(u)) {
                                              selectedUtilities.add(u);
                                            }
                                          } else {
                                            selectedUtilities.remove(u);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                            actions: [
                              TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Thêm'),
                              ),
                              
                            ],
                        );
                      },
                    );
                  },
                );
                setState(() {}); // cập nhật lại tiện ích đã chọn
              },
              child: _buildOptionRow('+ Thêm Tiện Ích'),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: allUtilities
                  .where((u) => selectedUtilities.contains(u)) // chỉ hiển thị các tiện ích đã check
                  .map((u) => _buildCheckboxOption(u))
                  .toList(),
            ),

            const SizedBox(height: 24),
            // Trạng thái kết nối Khóa IOT (đơn giản)
            if (widget.initialData.roomCode.isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Trạng thái Khóa IOT'),
                  const SizedBox(height: 8),
                  StatefulBuilder(
                    builder: (context, setStateSB) {
                      // tạo future mới mỗi lần build để FutureBuilder kiểm tra lại
                      final future = ApartmentController().checkIOTConnection(roomCodeController.text);
                      return FutureBuilder<bool>(
                        future: future,
                        builder: (context, snapshot) {
                          final bool isConnected = snapshot.data == true;
                          Color bg;
                          Color border;
                          IconData icon;
                          String title;
                          String subtitle;
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            bg = Colors.grey.shade200;
                            border = Colors.grey.shade700;
                            icon = Icons.lock;
                            title = 'Đang kiểm tra';
                            subtitle = 'Vui lòng chờ...';
                          } else {
                            bg = isConnected ? Colors.green.shade50 : Colors.red.shade50;
                            border = isConnected ? Colors.green.shade700 : Colors.red.shade700;
                            icon = isConnected ? Icons.lock_open : Icons.lock;
                            title = isConnected ? 'Đã kết nối' : 'Chưa kết nối';
                            subtitle = isConnected ? 'Khóa sẵn sàng' : 'Không thể kết nối';
                          }

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: border, width: 1),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: border,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(icon, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: border)),
                                      const SizedBox(height: 4),
                                      Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                                    ],
                                  ),
                                ),
                                snapshot.connectionState == ConnectionState.waiting
                                  ? SizedBox(
                                      width: 36,
                                      height: 36,
                                      child: Center(
                                        child: SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      ),
                                    )
                                  : IconButton(
                                      icon: const Icon(Icons.refresh),
                                      tooltip: 'Cập nhật trạng thái',
                                      onPressed: () {
                                        // rebuild StatefulBuilder -> tạo lại future và kiểm tra lại
                                        setStateSB(() {});
                                      },
                                    ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            const Text('Chọn Trạng Thái Phòng'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Color(0xFF4285F4)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _buildDropdownRoomState(),
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Hình Ảnh Phòng',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    Text(
                      '${initialImages.length + _images.length} ảnh',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Grid layout cho ảnh
                if (initialImages.isEmpty && _images.isEmpty)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFBFCDE6),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Chưa có hình ảnh',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: initialImages.length + _images.length,
                    itemBuilder: (context, index) {
                      if (index < initialImages.length) {
                        return _buildImageCard(
                          initialImages[index],
                          index,
                          isNetworkImage: true,
                        );
                      } else {
                        return _buildImageCard(
                          _images[index - initialImages.length].path,
                          index,
                          isNetworkImage: false,
                        );
                      }
                    },
                  ),
                const SizedBox(height: 12),
                // Nút thêm ảnh đẹp hơn
                InkWell(
                  onTap: _pickImages,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4C6FFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF4C6FFF),
                        width: 2,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          color: Color(0xFF4C6FFF),
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Thêm Hình Ảnh',
                          style: TextStyle(
                            color: Color(0xFF4C6FFF),
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
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                GestureDetector(
                  onTap: _isSubmitting ? null : () {
                    Navigator.of(context).maybePop();
                  },
                  child: _buildActionButton('Hủy', color: Colors.white, textColor: Colors.black),
                ),
                GestureDetector(
                  onTap: _isSubmitting ? null : () async {
                  // Kiểm tra mã phòng khi tạo mới
                  if (widget.initialData.roomCode.isEmpty) {
                    if (roomCodeController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng nhập mã phòng')),
                      );
                      return;
                    }
                    if (isRoomCodeUnique == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng kiểm tra tính hợp lệ của mã phòng')),
                      );
                      return;
                    }
                    if (isRoomCodeUnique == false) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mã phòng đã tồn tại, vui lòng chọn mã khác')),
                      );
                      return;
                    }
                  }
                  
                  final message = '''Mã Phòng: ${roomCodeController.text}\nDiện Tích: ${areaController.text}\nCheckin: ${checkinController.text}\nCheckout: ${checkoutController.text}\nSức Chứa Tối Đa: ${capacityController.text}\nTrạng Thái Phòng: ${statusController.text}\nGiá Phòng: ${priceController.text}\nMô Tả Thêm: ${descriptionController.text}\nTiện Ích: ${selectedUtilities.join(', ')}\nLoại Phòng: $selectedRoomType\nTrạng Thái Phòng: $selectedRoomState''';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                    content: Text(message, style: const TextStyle(fontSize: 14)),
                    duration: const Duration(seconds: 3),
                    ),
                  );
                  // Gọi service để cập nhật thông tin phòng
                  try {
                    setState(() {
                      _isSubmitting = true;
                    });

                    RoomDetail createOrUpdateRoom = RoomDetail(
                    roomId: widget.initialData.roomId,
                    roomCode: roomCodeController.text,
                    area: areaController.text,
                    maxCapacity: capacityController.text,
                    room_status: statusController.text,
                    price: priceController.text.replaceAll(',', ''),
                    depositPrice: depositPriceController.text.replaceAll(',', ''),
                    description: descriptionController.text,
                    utilities: selectedUtilities,
                    roomState: selectedRoomState ?? '',
                    address: addressController.text,
                    requirement: requirementController.text,
                    roomType: selectedRoomType ?? '',
                    // Save all images to a writable directory with random names and return the new paths
                    images: await Future.wait(_images.map((img) async {
                      // Generate a random file name
                      final ext = img.path.split('.').last;
                      final newName = '${DateTime.now().millisecondsSinceEpoch}_${UniqueKey().toString()}.$ext';
                      // Use the app's documents directory for saving images
                      final directory = await getApplicationDocumentsDirectory();
                      final newPath = '${directory.path}/$newName';

                      // Copy file to the documents directory with the new name
                      final newFile = await img.copy(newPath);
                      return newFile.path;
                    }).toList()),
                  );
                    if (widget.initialData.roomCode.isNotEmpty) {
                      // Cập nhật phòng
                      final success = await ApartmentController().updateApartment(createOrUpdateRoom);
                      if (mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 12),
                                Text('Cập nhật phòng thành công!'),
                              ],
                            ),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                        // Pop về màn hình trước (giữ nguyên bottom nav)
                        Navigator.of(context).pop(true); // true = có thay đổi, cần refresh
                      }
                      } else {
                      // Tạo phòng mới
                      final success = await ApartmentController().createApartment(createOrUpdateRoom);
                      if (mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 12),
                                Text('Tạo phòng thành công!'),
                              ],
                            ),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                        // Pop về màn hình trước (giữ nguyên bottom nav)
                        Navigator.of(context).pop(true); // true = có thay đổi, cần refresh
                      } else if (mounted && !success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.error, color: Colors.white),
                                SizedBox(width: 12),
                                Text('Tạo phòng thất bại!'),
                              ],
                            ),
                            backgroundColor: Color(0xFFEF4444),
                          ),
                        );
                      }
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isSubmitting = false;
                      });
                    }
                  }
                  },
                  child: _buildActionButton(
                    widget.initialData.roomCode.isNotEmpty ? 'Cập Nhật' : 'Tạo',
                    color: const Color(0xFF4285F4),
                    textColor: Colors.white,
                    width: 153,
                    isLoading: _isSubmitting,
                  ),
                ),
              ],
            ),
          ],
        ),
        ]
        )
      ),
  
    );
  }

  // Hàm format số tiền theo định dạng có dấu phẩy phân cách hàng nghìn
  String _formatCurrency(String digits) {
    if (digits.isEmpty) return '';
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      int position = digits.length - i;
      buffer.write(digits[i]);
      if (position > 1 && position % 3 == 1 && i != digits.length - 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }
  
    Widget _buildDateTimePicker({
      required String label,
      required TextEditingController controller,
    }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF4285F4)),
            ),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: const Icon(Icons.calendar_today, size: 20),
          ),
          onTap: () async {
          // Bắt đầu chọn ngày
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );

          if (pickedDate != null) {
            // Sau khi chọn ngày xong, tiếp tục mở chọn giờ
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );

            if (pickedTime != null) {
              // Kết hợp ngày và giờ lại thành 1 đối tượng DateTime
              final DateTime fullDateTime = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );

              // Gán chuỗi ngày/giờ đã format vào controller
              controller.text = _formatDateTime(fullDateTime);
            }
          }
        }
        ),
      ],
    );
  }

// Hàm format ngày + giờ theo định dạng dd/MM HH:mm
String _formatDateTime(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return "$day/$month $hour:$minute";
}


  Widget _buildLabeledInput(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF4285F4)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionRow(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xC19E4F4F),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildCheckboxOption(String text) {
    final isSelected = selectedUtilities.contains(text);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedUtilities.remove(text);
          } else {
            selectedUtilities.add(text);
          }
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 17,
            height: 17,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4285F4) : Colors.white,
              border: Border.all(width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: isSelected ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRoomType = value;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selectedRoomType == value ? const Color(0xFF4285F4) : const Color(0xFFD9D9D9),
            ),
          ),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildDropdownRoomState() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: (selectedRoomState != null && selectedRoomState!.isNotEmpty)
            ? selectedRoomState
            : null,
        hint: const Text('Chọn trạng thái'),
        items: ApartmentStatus.values.map((status) {
          return DropdownMenuItem<String>(
            value: status,
            child: Text(ApartmentStatus.toVietnamese(status)),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedRoomState = value;
          });
        },
      ),
    );
  }

  Widget _buildActionButton(String text, {required Color color, required Color textColor, double width = 74, bool isLoading = false}) {
    return Container(
      width: width,
      height: 50.87,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(7),
        border: color == Colors.white ? Border.all(color: const Color(0xFF4285F4)) : null,
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            )
          : Text(
              text,
              style: TextStyle(color: textColor, fontSize: 19, fontWeight: FontWeight.w600),
            ),
    );
  }

  // Widget để hiển thị từng ảnh với khả năng xem fullscreen
  Widget _buildImageCard(String imagePath, int index, {required bool isNetworkImage}) {
    return GestureDetector(
      onTap: () => _showImageFullscreen(index),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFCDE6), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  isNetworkImage
                    ? Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey[600],
                            size: 40,
                          ),
                        ),
                      )
                    : Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                      ),
                  // Overlay với icon zoom
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.zoom_in,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Nút xóa
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isNetworkImage) {
                    initialImages.removeAt(index);
                  } else {
                    _images.removeAt(index - initialImages.length);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm hiển thị ảnh fullscreen
  void _showImageFullscreen(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageGalleryScreen(
          images: [...initialImages, ..._images.map((img) => img.path)],
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

// Screen hiển thị ảnh fullscreen với swipe
class ImageGalleryScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ImageGalleryScreen({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  late PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${currentIndex + 1} / ${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final imagePath = widget.images[index];
          final isNetwork = imagePath.startsWith('http');
          
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: isNetwork
                ? Image.network(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 100,
                    ),
                  )
                : Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                  ),
            ),
          );
        },
      ),
    );
  }
}
