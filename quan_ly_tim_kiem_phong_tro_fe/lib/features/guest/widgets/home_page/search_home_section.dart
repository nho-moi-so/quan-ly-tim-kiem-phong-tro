import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/search_criteria.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/screens/search_apartment_screens.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/controller/search_controller.dart'
    as guest;

class SearchHomeSection extends StatefulWidget {
  const SearchHomeSection({super.key});

  @override
  State<SearchHomeSection> createState() => _SearchHomeSectionState();
}

class _SearchHomeSectionState extends State<SearchHomeSection> {
  // controllers cho các input
  final addressController = TextEditingController();
  final priceController = TextEditingController();
  final occupancyController = TextEditingController();

  // dropdown loại căn hộ
  List<String> apartmentTypes = [];
  String? selectedType;

  // ngày nhận/trả
  DateTime? checkInDate;
  DateTime? checkOutDate;

  bool loadingTypes = false;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _fetchApartmentTypes();
  }

  @override
  void dispose() {
    addressController.dispose();
    priceController.dispose();
    occupancyController.dispose();
    super.dispose();
  }

  Future<void> _fetchApartmentTypes() async {
    setState(() => loadingTypes = true);
    final snap = await FirebaseFirestore.instance.collection('apartment').get();

    final setTypes = <String>{};
    for (final d in snap.docs) {
      final data = d.data();
      final t = (data['type'] ?? data['Type']);
      if (t is String && t.trim().isNotEmpty) setTypes.add(t.trim());
    }

    setState(() {
      apartmentTypes = setTypes.toList()..sort();
      loadingTypes = false;
    });
  }

  Future<void> _pickCheckIn() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => checkInDate = picked);
  }

  Future<void> _pickCheckOut() async {
    final base = checkInDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: base.add(const Duration(days: 1)),
      firstDate: base,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => checkOutDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width * 0.9,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputField(
            Icons.location_on,
            'Nhập địa chỉ & khu vực bạn cần tìm',
            controller: addressController,
          ),
          const SizedBox(height: 12),

          // DROPDOWN TYPE
          _buildTypeDropdown(),
          const SizedBox(height: 12),

          _buildInputField(
            Icons.attach_money,
            'Mức Giá tối đa',
            controller: priceController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),

          _buildInputField(
            Icons.group,
            'Số người ở tối thiểu',
            controller: occupancyController,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _dateButton('Checkin', checkInDate, _pickCheckIn),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dateButton('Checkout', checkOutDate, _pickCheckOut),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildSearchButton(),
        ],
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4285F4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.home, size: 20, color: Color(0xFF4285F4)),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedType,
                isExpanded: true,
                hint: Text(
                  loadingTypes ? 'Đang tải loại căn hộ...' : 'Chọn loại căn hộ',
                  style: const TextStyle(
                    color: Color(0xFFCCCCCC),
                    fontSize: 13,
                  ),
                ),
                items: apartmentTypes
                    .map(
                      (t) => DropdownMenuItem<String>(value: t, child: Text(t)),
                    )
                    .toList(),
                onChanged: loadingTypes
                    ? null
                    : (v) => setState(() => selectedType = v),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateButton(String label, DateTime? value, VoidCallback onTap) {
    final text = value == null
        ? label
        : '${value.day}/${value.month}/${value.year}';
    return SizedBox(
      height: 40,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.calendar_month),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildInputField(
    IconData icon,
    String hint, {
    TextEditingController? controller,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4285F4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4285F4)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFFCCCCCC),
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton.icon(
        onPressed: () async {
          final address = addressController.text.trim();
          final price = double.tryParse(priceController.text.trim());
          final occupancy = int.tryParse(occupancyController.text.trim());

          final criteria = SearchCriteria(
            address: address.isEmpty ? null : address,
            maxDailyRate: price,
            minOccupancy: occupancy,
            apartmentType: selectedType,
            checkIn: checkInDate,
            checkOut: checkOutDate,
          );

          final controller = guest.SearchController();
          final results = await controller.search(
            criteria,
          ); 

          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchApartmentScreens(
                  criteria: criteria, 
                  results: results,
                  
                ),
              ),
            );
          }
        },
        icon: isLoading
            ? CircularProgressIndicator()
            : Icon(Icons.search), 
        label: const Text("Tìm kiếm"), 
      ),
    );
  }
}
