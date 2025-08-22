import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/apartment_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/screens/manager_apartment/apartment_screens.dart';
import '../../viewmodel/room_detail.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class CardRoomDetailWidget extends StatefulWidget {
  final RoomDetail initialData;

  const CardRoomDetailWidget({super.key, required this.initialData});

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
  late List<String> initialImages;

  List<String> selectedUtilities = [];
  String? selectedRoomType;
  String? selectedRoomState;

  List<String> allUtilities = [];
  late List<File> _images;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles.map((xfile) => File(xfile.path)));
      });
    }
  }

  final List<String> roomTypes = [
    '1 Phòng Ngủ',
    '2 Phòng Ngủ',
    'Studio',
    '3 Phòng Ngủ',
  ];

  final List<String> roomStates = [
    'Trống',
    'Đã thuê',
    'Đang sửa',
  ];
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
    depositPriceController = TextEditingController(text: widget.initialData.depositPrice);
    areaController = TextEditingController(text: widget.initialData.area);
    checkinController = TextEditingController(text: widget.initialData.checkin);
    checkoutController = TextEditingController(text: widget.initialData.checkout);
    capacityController = TextEditingController(text: widget.initialData.maxCapacity);
    statusController = TextEditingController(text: widget.initialData.room_status);
    priceController = TextEditingController(
      text: _formatCurrency(widget.initialData.price.replaceAll(RegExp(r'[^0-9]'), '')),
    );
    descriptionController = TextEditingController(text: widget.initialData.description);

    selectedUtilities = [...widget.initialData.utilities];
    selectedRoomType = widget.initialData.roomType;
    selectedRoomState = widget.initialData.roomState;
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
            _buildLabeledInput('Mã Phòng', roomCodeController),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const Text('Diện Tích'),
              const SizedBox(height: 8),
              TextFormField(
                controller: areaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFF4285F4)),
                ),
                filled: true,
                fillColor: Colors.white,
                suffix: const Text('m²', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              ],
            ),
            const SizedBox(height: 16),
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
                Expanded(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Giá Đặt Cọc'),
                    const SizedBox(height: 8),
                    TextFormField(
                    controller: depositPriceController,
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
                        depositPriceController.text = '';
                        depositPriceController.selection = TextSelection.collapsed(offset: 0);
                        return;
                      }
                      final formatted = _formatCurrency(digits);
                      if (depositPriceController.text != formatted) {
                        depositPriceController.text = formatted;
                        depositPriceController.selection = TextSelection.collapsed(offset: formatted.length);
                      }
                    },
                    ),
                  ],
                  ),
                ),
                ],
              ),
            const SizedBox(height: 16),
            _buildLabeledInput('Mô Tả Thêm', descriptionController, maxLines: 3),
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
                const Text('Hình Ảnh Phòng'),
                const SizedBox(height: 8),
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Hiển thị ảnh từ URL (initialImages)
                      ...initialImages.map((url) => Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    url,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image, color: Colors.grey),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        initialImages.remove(url);
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      // Hiển thị ảnh từ File (_images)
                      ..._images.map((img) => Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    img,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _images.remove(img);
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      // Nút thêm ảnh mới
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF4285F4)),
                          ),
                          child: const Icon(Icons.add_a_photo, size: 36, color: Color(0xFF4285F4)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                GestureDetector(
                  onTap: () {
                  Navigator.of(context).maybePop();
                  },
                  child: _buildActionButton('Hủy', color: Colors.white, textColor: Colors.black),
                ),
                GestureDetector(
                  onTap: () async {
                  final message = '''Mã Phòng: ${roomCodeController.text}\nDiện Tích: ${areaController.text}\nCheckin: ${checkinController.text}\nCheckout: ${checkoutController.text}\nSức Chứa Tối Đa: ${capacityController.text}\nTrạng Thái Phòng: ${statusController.text}\nGiá Phòng: ${priceController.text}\nMô Tả Thêm: ${descriptionController.text}\nTiện Ích: ${selectedUtilities.join(', ')}\nLoại Phòng: $selectedRoomType\nTrạng Thái Phòng: $selectedRoomState''';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                    content: Text(message, style: const TextStyle(fontSize: 14)),
                    duration: const Duration(seconds: 3),
                    ),
                  );
                  // Gọi service để cập nhật thông tin phòng
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
                      final success = await ApartmentController().updateApartment(createOrUpdateRoom);
                    } else {
                      final success = await ApartmentController().createApartment(createOrUpdateRoom);
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Tạo phòng thành công!')),
                      );
                      Navigator.of(context).pop();
                      if (success) {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const ApartmentScreen()));
                      }
                    }
                  },
                  child: _buildActionButton(
                  widget.initialData.roomCode.isNotEmpty ? 'Cập Nhật' : 'Tạo',
                  color: const Color(0xFF4285F4),
                  textColor: Colors.white,
                  width: 153,
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
        value: selectedRoomState!.isEmpty ? null : selectedRoomState,
        hint: const Text('Chọn trạng thái'),
        items: roomStates.map((state) => DropdownMenuItem(value: state, child: Text(state))).toList(),
        onChanged: (value) {
          setState(() {
            selectedRoomState = value;
          });
        },
      ),
    );
  }

  Widget _buildActionButton(String text, {required Color color, required Color textColor, double width = 74}) {
    return Container(
      width: width,
      height: 50.87,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(7),
        border: color == Colors.white ? Border.all(color: const Color(0xFF4285F4)) : null,
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 19, fontWeight: FontWeight.w600),
      ),
    );
  }
}
