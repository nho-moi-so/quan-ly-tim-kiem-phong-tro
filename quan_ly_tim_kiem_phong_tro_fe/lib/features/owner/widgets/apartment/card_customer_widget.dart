//done
import 'package:flutter/material.dart';

class CardCustomerWidget extends StatefulWidget {
  const CardCustomerWidget({super.key});

  @override
  State<CardCustomerWidget> createState() => _CardCustomerWidgetState();
}

class _CardCustomerWidgetState extends State<CardCustomerWidget> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController idCardController;
  late TextEditingController addressController;
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    idCardController = TextEditingController();
    addressController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    idCardController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        return Center(
          child: Container(
            width: screenWidth * 0.9, // responsive width
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  // child: Text(
                  //   'Thêm Khách Thuê Mới',
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(
                  //     color: const Color(0xFF4B5563),
                  //     fontSize: 23,
                  //     fontFamily: 'Inter',
                  //     fontWeight: FontWeight.w500,
                  //   ),
                  // ),
                ),
                const SizedBox(height: 24),
                _buildLabeledInput('Tên Khách Trọ', nameController),
                const SizedBox(height: 24),
                _buildLabeledInput('Số Điện Thoại', phoneController),
                const SizedBox(height: 24),
                _buildLabeledInput('CCCD & Hộ Chiếu', idCardController, inputHeight: 80),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  _buildLabel('Giới Tính'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                    filled: true,
                    fillColor: Colors.white,
                    ),
                    items: const [
                    DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                    DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                    DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                    value: selectedGender,
                  ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildLabeledInput('Địa Chỉ Thường Chú', addressController, inputHeight: 63),
                const SizedBox(height: 32),
                // Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Xử lý khi bấm nút Hủy
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFF4285F4), width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          foregroundColor: Colors.black, // màu chữ
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: xử lý thêm dữ liệu
                          print('=== THÔNG TIN KHÁCH THUÊ MỚI ===');
                          print('Tên Khách Trọ: ${nameController.text}');
                          print('Số Điện Thoại: ${phoneController.text}');
                          print('CCCD & Hộ Chiếu: ${idCardController.text}');
                          print('Giới Tính: $selectedGender');
                          print('Địa Chỉ Thường Chú: ${addressController.text}');
                          print('=====================================');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4285F4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Thêm',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),



                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.black.withOpacity(0.8),
        fontSize: 15,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
      ),
    );
  }

Widget _buildInputBox({double height = 45, TextEditingController? controller}) {
  return Container(
    margin: const EdgeInsets.only(top: 6),
    height: height,
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
        filled: true,
        fillColor: Colors.white,
      ),
    ),
  );
}


  Widget _buildLabeledInput(String label, TextEditingController controller, {double inputHeight = 45}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        _buildInputBox(height: inputHeight, controller: controller),
      ],
    );
  }
}
