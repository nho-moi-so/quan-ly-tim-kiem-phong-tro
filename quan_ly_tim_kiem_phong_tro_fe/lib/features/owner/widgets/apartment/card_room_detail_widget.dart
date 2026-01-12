import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/apartment_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/helpers/status_constants.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/iot_device.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/iot_device_service.dart';

import '../../viewmodel/room_detail.dart';
import 'map_picker_dialog.dart';

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
  
  // Trạng thái check IOT device
  final Map<String, bool> _deviceCheckingMap = {}; // deviceId -> đang check hay không
  final Map<String, String> _deviceStatusMap = {}; // deviceId -> "online"/"offline"/""
  
  // Biến lưu tọa độ
  double? _selectedLatitude;
  double? _selectedLongitude;
  
  // Biến Future cho IOT devices
  Future<List<dynamic>>? _iotDevicesFuture;
  
  // Hàm khởi tạo Future
  void _initIotDevicesFuture() {
    final iotService = IotDeviceService();
    _iotDevicesFuture = Future.wait([
      iotService.getAllSupportedDevices(),
      iotService.getConnectedDevicesForRoom(roomCodeController.text),
    ]);
  }

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
  
  // Khởi tạo tọa độ từ dữ liệu ban đầu
  _selectedLatitude = widget.initialData.latitude;
  _selectedLongitude = widget.initialData.longitude;

  selectedUtilities = [...widget.initialData.utilities];
  selectedRoomType = widget.initialData.roomType.isNotEmpty ? widget.initialData.roomType : (widget.roomTypes.isNotEmpty ? widget.roomTypes.first : null);
    // selectedRoomState = widget.initialData.roomState;
    _images = [];
    
    // Khởi tạo Future cho IOT nếu đã có roomCode
    if (widget.initialData.roomCode.isNotEmpty) {
      _initIotDevicesFuture();
    }
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
                const Text(
                  'Mã Phòng',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: (isRoomCodeUnique == null 
                                ? const Color(0xFF4C6FFF)
                                : isRoomCodeUnique! 
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444)).withOpacity(0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: roomCodeController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isRoomCodeUnique == null 
                                  ? const Color(0xFFBFCDE6)
                                  : isRoomCodeUnique! 
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isRoomCodeUnique == null 
                                  ? const Color(0xFFBFCDE6)
                                  : isRoomCodeUnique! 
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: isRoomCodeUnique != null
                              ? Icon(
                                  isRoomCodeUnique! ? Icons.check_circle : Icons.error,
                                  color: isRoomCodeUnique! ? const Color(0xFF10B981) : const Color(0xFFEF4444),
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
                    ),
                    // Chỉ hiện nút check và random khi đang tạo mới (roomCode rỗng ban đầu)
                    if (widget.initialData.roomCode.isEmpty)
                      const SizedBox(width: 8),
                    if (widget.initialData.roomCode.isEmpty)
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
                    if (widget.initialData.roomCode.isEmpty)
                      const SizedBox(width: 8),
                    if (widget.initialData.roomCode.isEmpty)
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
                ),
                if (isRoomCodeUnique != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    isRoomCodeUnique! 
                      ? '✓ Mã phòng này có thể sử dụng'
                      : '✗ Mã phòng đã tồn tại, vui lòng chọn mã khác',
                    style: TextStyle(
                      fontSize: 12,
                      color: isRoomCodeUnique! ? const Color(0xFF10B981) : const Color(0xFFEF4444),
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
              const Text(
                'Sức Chứa Tối Đa',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4C6FFF).withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: capacityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFBFCDE6), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFBFCDE6), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4C6FFF), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  suffix: const Text('Người', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
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
                    const Text(
                      'Giá Phòng',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4C6FFF).withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFBFCDE6), width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFBFCDE6), width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF4C6FFF), width: 2),
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
            // Địa chỉ với nút mở bản đồ
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Địa chỉ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4C6FFF).withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: addressController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFBFCDE6), width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFBFCDE6), width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF4C6FFF), width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Nhập địa chỉ hoặc chọn trên bản đồ',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Nút mở bản đồ
                    Material(
                      color: const Color(0xFF4C6FFF),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          final result = await showDialog<LocationResult>(
                            context: context,
                            builder: (context) => MapPickerDialog(
                              initialAddress: addressController.text,
                              initialLatitude: _selectedLatitude,
                              initialLongitude: _selectedLongitude,
                            ),
                          );
                          
                          if (result != null) {
                            setState(() {
                              addressController.text = result.address;
                              _selectedLatitude = result.latitude;
                              _selectedLongitude = result.longitude;
                            });
                          }
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.map_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_selectedLatitude != null && _selectedLongitude != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Tọa độ: ${_selectedLatitude!.toStringAsFixed(6)}, ${_selectedLongitude!.toStringAsFixed(6)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            
            // Hiển thị bản đồ nếu có tọa độ
            if (_selectedLatitude != null && _selectedLongitude != null) ...[
              _buildMapPreview(),
              const SizedBox(height: 16),
            ],
            
            _buildLabeledInput('Yêu cầu', requirementController, maxLines: 2),
            const SizedBox(height: 16),
            const Text(
              'Loại phòng',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFBFCDE6), width: 2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4C6FFF).withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text(
                            'Thêm Tiện Ích',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1F36),
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                decoration: InputDecoration(
                                  hintText: 'Tìm kiếm tiện ích...',
                                  prefixIcon: const Icon(Icons.search, color: Color(0xFF4C6FFF)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE0E7FF), width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE0E7FF), width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF4C6FFF), width: 2),
                                  ),
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
                                      activeColor: const Color(0xFF4C6FFF),
                                      checkColor: Colors.white,
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
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF4C6FFF),
                              ),
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
            // Thiết bị IOT - Thiết kế tổng quát
            if (widget.initialData.roomCode.isNotEmpty) ...[
              _buildIotDevicesSection(),
              const SizedBox(height: 24),
            ],
            const Text(
              'Chọn Trạng Thái Phòng',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFBFCDE6), width: 2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4C6FFF).withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                    latitude: _selectedLatitude,
                    longitude: _selectedLongitude,
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
                    color: const Color(0xFF4C6FFF),
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
  
  Widget _buildLabeledInput(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4C6FFF).withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFBFCDE6), width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFBFCDE6), width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4C6FFF), width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionRow(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4C6FFF), Color(0xFF6B8AFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4C6FFF).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4C6FFF).withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF4C6FFF) : const Color(0xFFE0E7FF),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4C6FFF) : Colors.white,
                border: Border.all(
                  color: isSelected ? const Color(0xFF4C6FFF) : const Color(0xFFE0E7FF),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF4C6FFF) : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
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

  /// Widget hiển thị section Thiết bị IOT
  Widget _buildIotDevicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Thiết bị IOT',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Noto Sans',
                color: Color(0xFF1A1F36),
                letterSpacing: -0.3,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _initIotDevicesFuture(); // Tạo Future mới để reload lại từ đầu
                });
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Làm mới'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4C6FFF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Thống kê IOT - Hiển thị động dựa trên state
        FutureBuilder<List<dynamic>>(
          future: _iotDevicesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox.shrink();
            }
            
            if (snapshot.hasData) {
              final supportedDevices = snapshot.data![0] as List<IotDevice>;
              final connectedDevices = snapshot.data![1] as List<ConnectedIotDevice>;
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4C6FFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildIotStat(
                      'Hỗ trợ',
                      supportedDevices.length.toString(),
                      Icons.devices,
                      const Color(0xFF4C6FFF),
                    ),
                    Container(width: 1, height: 30, color: Colors.grey.shade300),
                    _buildIotStat(
                      'Đã kết nối',
                      connectedDevices.where((d) => d.isConnected).length.toString(),
                      Icons.link,
                      const Color(0xFF10B981),
                    ),
                    
                  ],
                ),
              );
            }
            
            return const SizedBox.shrink();
          },
        ),
        const SizedBox(height: 12),
        
        // Danh sách thiết bị hỗ trợ và trạng thái kết nối
        FutureBuilder<List<dynamic>>(
          future: _iotDevicesFuture, // Sử dụng biến đã lưu
          builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Column(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(height: 8),
                          Text('Đang tải thiết bị IOT...'),
                        ],
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: const Color(0xFFEF4444)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Không thể tải danh sách thiết bị',
                            style: TextStyle(color: const Color(0xFFEF4444)),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final List<IotDevice> supportedDevices = snapshot.data![0] as List<IotDevice>;
                final List<ConnectedIotDevice> connectedDevices = snapshot.data![1] as List<ConnectedIotDevice>;

                if (supportedDevices.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text('Hệ thống chưa có thiết bị IOT nào được hỗ trợ'),
                        ),
                      ],
                    ),
                  );
                }

                // Tạo map để tra cứu nhanh trạng thái kết nối
                final Map<String, ConnectedIotDevice> connectionMap = {};
                for (var connected in connectedDevices) {
                  connectionMap[connected.iotDeviceId] = connected;
                }

                // Tự động check trạng thái các thiết bị đã kết nối khi mới load trang
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _autoCheckConnectedDevices(connectedDevices);
                });

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Danh sách thiết bị
                    ...supportedDevices.map((device) {
                      final connected = connectionMap[device.deviceId];
                      return IotDeviceCard(
                        key: ValueKey(device.deviceId),
                        device: device,
                        connected: connected,
                        roomCode: roomCodeController.text,
                        deviceCheckingMap: _deviceCheckingMap,
                        deviceStatusMap: _deviceStatusMap,
                        onStatusUpdate: () => setState(() {}),
                      );
                    }).toList(),
                  ],
                );
              },
        ),
      ],
    );
  }

  /// Tự động check trạng thái các thiết bị đã kết nối
  Future<void> _autoCheckConnectedDevices(List<ConnectedIotDevice> connectedDevices) async {
    final iotService = IotDeviceService();
    
    for (var connected in connectedDevices) {
      // Chỉ check những thiết bị đã verified và chưa được check
      if (connected.isConnected && !_deviceStatusMap.containsKey(connected.iotDeviceId)) {
        try {
          _deviceCheckingMap[connected.iotDeviceId] = true;
          
          final status = await iotService.callAPICheckIOTDevice(connected.connectionId);
          print("status auto-check: $status for device ${connected.iotDeviceId}");
          
          if (mounted) {
            setState(() {
              _deviceStatusMap[connected.iotDeviceId] = status;
              _deviceCheckingMap[connected.iotDeviceId] = false;
            });
          }
        } catch (e) {
          print('❌ Error auto-checking device ${connected.iotDeviceId}: $e');
          if (mounted) {
            setState(() {
              _deviceStatusMap[connected.iotDeviceId] = 'offline';
              _deviceCheckingMap[connected.iotDeviceId] = false;
            });
          }
        }
        
        // Delay nhỏ giữa các request để tránh quá tải
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
  }

  /// Widget thống kê IOT
  Widget _buildIotStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, {required Color color, required Color textColor, double width = 74, bool isLoading = false}) {
    final isOutlined = color == Colors.white;
    return Container(
      width: width,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: isOutlined
            ? null
            : LinearGradient(
                colors: [color, color.withOpacity(0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isOutlined ? Colors.white : null,
        borderRadius: BorderRadius.circular(12),
        border: isOutlined
            ? Border.all(color: const Color(0xFFE0E7FF), width: 2)
            : null,
        boxShadow: isOutlined
            ? null
            : [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
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
              style: TextStyle(
                color: isOutlined ? const Color(0xFF1F2937) : textColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
    );
  }

  /// Widget hiển thị bản đồ xem trước vị trí
  Widget _buildMapPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.map_outlined,
              size: 20,
              color: Color(0xFF4C6FFF),
            ),
            const SizedBox(width: 8),
            const Text(
              'Vị trí trên bản đồ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 14,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Đã chọn vị trí',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF4C6FFF), width: 2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4C6FFF).withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(_selectedLatitude!, _selectedLongitude!),
                    initialZoom: 15,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.quan_ly_tim_kiem_phong_tro_fe',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(_selectedLatitude!, _selectedLongitude!),
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            color: Color(0xFFEF4444),
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Nút xem full map
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () async {
                        final result = await showDialog<LocationResult>(
                          context: context,
                          builder: (context) => MapPickerDialog(
                            initialAddress: addressController.text,
                            initialLatitude: _selectedLatitude,
                            initialLongitude: _selectedLongitude,
                          ),
                        );
                        
                        if (result != null) {
                          setState(() {
                            addressController.text = result.address;
                            _selectedLatitude = result.latitude;
                            _selectedLongitude = result.longitude;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.fullscreen,
                              size: 18,
                              color: Color(0xFF4C6FFF),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Xem đầy đủ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4C6FFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.my_location,
              size: 14,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Tọa độ: ${_selectedLatitude!.toStringAsFixed(6)}, ${_selectedLongitude!.toStringAsFixed(6)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ],
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
                  color: const Color(0xFFEF4444),
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

// Widget riêng cho IOT Device Card để tối ưu performance
class IotDeviceCard extends StatefulWidget {
  final IotDevice device;
  final ConnectedIotDevice? connected;
  final String roomCode;
  final Map<String, bool> deviceCheckingMap;
  final Map<String, String> deviceStatusMap;
  final VoidCallback onStatusUpdate;

  const IotDeviceCard({
    super.key,
    required this.device,
    required this.connected,
    required this.roomCode,
    required this.deviceCheckingMap,
    required this.deviceStatusMap,
    required this.onStatusUpdate,
  });

  @override
  State<IotDeviceCard> createState() => _IotDeviceCardState();
}

class _IotDeviceCardState extends State<IotDeviceCard> {
  bool get isChecking => widget.deviceCheckingMap[widget.device.deviceId] ?? false;
  String get deviceStatus => widget.deviceStatusMap[widget.device.deviceId] ?? '';

  IconData _getDeviceIcon(String deviceId) {
    switch (deviceId.toLowerCase()) {
      case 'smart_lock':
        return Icons.lock;
      case 'sensor_door':
        return Icons.sensor_door;
      case 'camera':
        return Icons.videocam;
      case 'thermostat':
        return Icons.thermostat;
      case 'light':
        return Icons.lightbulb;
      case 'fan':
        return Icons.air;
      case 'sensor_motion':
        return Icons.sensors;
      case 'alarm':
        return Icons.alarm;
      default:
        return Icons.device_hub;
    }
  }

  Future<void> _checkDeviceStatus() async {
    widget.deviceCheckingMap[widget.device.deviceId] = true;
    widget.onStatusUpdate();
    
    try {
      final iotService = IotDeviceService();
      final status = await iotService.callAPICheckIOTDevice(
        // widget.roomCode,
        widget.connected!.connectionId,
      );
      
      widget.deviceStatusMap[widget.device.deviceId] = status;
      widget.deviceCheckingMap[widget.device.deviceId] = false;
      widget.onStatusUpdate();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'online' 
                ? '✓ ${widget.device.name} đang hoạt động'
                : '✗ ${widget.device.name} không phản hồi',
            ),
            backgroundColor: status == 'online' 
              ? const Color(0xFF10B981) 
              : const Color(0xFFEF4444),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      widget.deviceStatusMap[widget.device.deviceId] = 'offline';
      widget.deviceCheckingMap[widget.device.deviceId] = false;
      widget.onStatusUpdate();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ ${widget.device.name} không thể kết nối'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isConnected = widget.connected?.isConnected ?? false;
    final bool isPending = widget.connected != null && !widget.connected!.isConnected;
    final bool isReady = deviceStatus == 'online';
    
    Color bg;
    Color borderColor;
    IconData statusIcon;
    String statusText;
    String statusSubtitle;

    // Chỉ màu xanh khi đã kết nối VÀ đã sẵn sàng (online)
    if (isConnected && isReady) {
      bg = const Color(0xFF10B981).withOpacity(0.05);
      borderColor = const Color(0xFF10B981);
      statusIcon = Icons.check_circle;
      statusText = 'Đã kết nối';
      statusSubtitle = 'Thiết bị sẵn sàng hoạt động';
    } else if (isConnected) {
      // Đã kết nối nhưng chưa sẵn sàng hoặc offline
      bg = const Color(0xFF6B7280).withOpacity(0.05);
      borderColor = const Color(0xFF6B7280);
      statusIcon = Icons.check_circle;
      statusText = 'Đã kết nối';
      if (deviceStatus == 'offline') {
        statusSubtitle = 'Thiết bị không phản hồi';
      } else {
        statusSubtitle = 'Đang kiểm tra trạng thái...';
      }
    } else if (isPending) {
      // Chờ xác nhận
      bg = const Color(0xFF6B7280).withOpacity(0.05);
      borderColor = const Color(0xFF6B7280);
      statusIcon = Icons.pending;
      statusText = 'Chờ xác nhận';
      statusSubtitle = 'Đang chờ thiết bị phản hồi';
    } else {
      // Chưa kết nối
      bg = const Color(0xFF6B7280).withOpacity(0.05);
      borderColor = const Color(0xFF6B7280);
      statusIcon = Icons.link_off;
      statusText = 'Chưa kết nối';
      statusSubtitle = 'Thiết bị chưa được liên kết';
    }

    IconData deviceIcon = _getDeviceIcon(widget.device.deviceId);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          // Icon thiết bị
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: borderColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(deviceIcon, color: borderColor, size: 24),
          ),
          const SizedBox(width: 12),
          
          // Thông tin thiết bị
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.device.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.device.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Status badges
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    // Badge trạng thái kết nối
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isConnected ? const Color(0xFF10B981).withOpacity(0.15) : borderColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14, color: isConnected ? const Color(0xFF10B981) : borderColor),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isConnected ? const Color(0xFF10B981) : borderColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Badge trạng thái sẵn sàng (chỉ hiển thị khi đã kết nối)
                    if (isConnected && deviceStatus.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: deviceStatus == 'online' 
                            ? const Color(0xFF10B981).withOpacity(0.15)
                            : const Color(0xFFEF4444).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              deviceStatus == 'online' 
                                ? Icons.check_circle_outline 
                                : Icons.warning_amber_rounded,
                              size: 14,
                              color: deviceStatus == 'online' 
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              deviceStatus == 'online' ? 'Đã sẵn sàng' : 'Chưa sẵn sàng',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: deviceStatus == 'online' 
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // Nút refresh trạng thái
          Tooltip(
            message: statusSubtitle,
            child: IconButton(
              onPressed: isChecking ? null : _checkDeviceStatus,
              icon: isChecking
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(borderColor),
                    ),
                  )
                : Icon(Icons.refresh, color: borderColor),
              tooltip: 'Kiểm tra trạng thái thiết bị',
            ),
          ),
        ],
      ),
    );
  }
}
