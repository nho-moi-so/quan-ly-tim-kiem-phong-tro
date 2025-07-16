import 'package:flutter/material.dart';
import '../../viewmodel/room_detail.dart';
import '../../../../service/owner/apartment_service.dart';


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
  late TextEditingController descriptionController;

  List<String> selectedUtilities = [];
  String? selectedRoomType;
  String? selectedRoomState;

  final List<String> allUtilities = ApartmentService().getUtilities();

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

  @override
  void initState() {
    super.initState();
    roomCodeController = TextEditingController(text: widget.initialData.roomCode);
    areaController = TextEditingController(text: widget.initialData.area);
    checkinController = TextEditingController(text: widget.initialData.checkin);
    checkoutController = TextEditingController(text: widget.initialData.checkout);
    capacityController = TextEditingController(text: widget.initialData.maxCapacity);
    statusController = TextEditingController(text: widget.initialData.room_status);
    priceController = TextEditingController(text: widget.initialData.price);
    descriptionController = TextEditingController(text: widget.initialData.description);

    selectedUtilities = [...widget.initialData.utilities];
    selectedRoomType = widget.initialData.roomType;
    selectedRoomState = widget.initialData.roomState;
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
            _buildLabeledInput('Diện Tích', areaController),
            const SizedBox(height: 16),
            Row(
              children: [
              Expanded(
                child: _buildDateTimePicker(
                label: 'Checkin',
                controller: checkinController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateTimePicker(
                label: 'Checkout',
                controller: checkoutController,
                ),
              ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLabeledInput('Sức Chứa Tối Đa', capacityController),
            const SizedBox(height: 16),
            _buildLabeledInput('Trạng Thái Phòng', statusController),
            const SizedBox(height: 16),
            _buildLabeledInput('Giá Phòng', priceController),
            const SizedBox(height: 16),
            _buildLabeledInput('Mô Tả Thêm', descriptionController, maxLines: 3),
            const SizedBox(height: 24),
            _buildOptionRow('+ Thêm Tiện Ích'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: allUtilities.map((u) => _buildCheckboxOption(u)).toList(),
            ),
            const SizedBox(height: 24),
            _buildOptionRow('+ Loại Phòng'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              children: roomTypes.map((t) => _buildRadioOption(t)).toList(),
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
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton('Hủy', color: Colors.white, textColor: Colors.black),
                _buildActionButton('Cập Nhật', color: const Color(0xFF4285F4), textColor: Colors.white, width: 153),
              ],
            ),
          ],
        ),
      ),
    );
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
