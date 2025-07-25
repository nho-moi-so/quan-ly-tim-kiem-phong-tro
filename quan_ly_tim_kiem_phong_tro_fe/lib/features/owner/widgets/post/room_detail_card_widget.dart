import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';



class RoomDetailCardWidget extends StatefulWidget {
  const RoomDetailCardWidget({super.key});

  @override
  State<RoomDetailCardWidget> createState() => _RoomDetailCardWidgetState();
}

class _RoomDetailCardWidgetState extends State<RoomDetailCardWidget> {
  late TextEditingController roomController;
  late TextEditingController floorController;
  late TextEditingController areaController;
  late TextEditingController priceController;
  late TextEditingController addressController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    roomController = TextEditingController(text: '403');
    floorController = TextEditingController(text: 'Tầng 4');
    areaController = TextEditingController(text: '30m2');
    priceController = TextEditingController(text: '1.500.000');
    addressController = TextEditingController(text: 'Chung cư nam long, hưng thạnh, cái răng');
    descriptionController = TextEditingController(text: 'Phòng dành cho 4 người, có 2 phòng ngủ và 1 phòng khách, có phòng bếp và 3 wc');
  }

  @override
  void dispose() {
    roomController.dispose();
    floorController.dispose();
    areaController.dispose();
    priceController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          width: 378,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xD8756A6A),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _infoField(label: 'Phòng', controller: roomController),
                    const SizedBox(width: 12),
                    _infoField(label: 'Khu', controller: floorController),
                  ],
                ),
                const SizedBox(height: 12),
                _infoField(label: 'Diện Tích', controller: areaController, fullWidth: true),
                const SizedBox(height: 12),
                _infoField(label: 'Tiền Phòng', controller: priceController, fullWidth: true),
                const SizedBox(height: 12),
                _infoField(label: 'Địa Chỉ', controller: addressController, fullWidth: true),
                const SizedBox(height: 12),
                _infoField(
                  label: 'Mô Tả',
                  controller: descriptionController,
                  fullWidth: true,
                  multiline: true,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Upload Images',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      width: 157,
                      height: 118,
                      decoration: BoxDecoration(
                        image: imageFile != null
                            ? DecorationImage(image: FileImage(imageFile!), fit: BoxFit.cover)
                            : const DecorationImage(
                                image: NetworkImage("https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Image_created_with_a_mobile_phone.png/1200px-Image_created_with_a_mobile_phone.png"),
                                fit: BoxFit.cover,
                              ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: imageFile == null
                          ? const Center(child: Icon(Icons.add_a_photo, size: 32, color: Colors.white))
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0x354285F4),
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
                          final info = '''Phòng: ${roomController.text}\nKhu: ${floorController.text}\nDiện Tích: ${areaController.text}\nTiền Phòng: ${priceController.text}\nĐịa Chỉ: ${addressController.text}\nMô Tả: ${descriptionController.text}''';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(info, style: const TextStyle(fontSize: 14)),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4285F4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Cập Nhật'),
                      ),
                    ),
                  ],
                )
              ],
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black.withOpacity(0.6),
            fontSize: 14,
            fontFamily: 'Noto Sans',
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
            decoration: InputDecoration(
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
