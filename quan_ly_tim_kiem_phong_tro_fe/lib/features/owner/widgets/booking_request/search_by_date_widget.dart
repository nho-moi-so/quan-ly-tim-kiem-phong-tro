import 'package:flutter/material.dart';

class SearchByDateWidget extends StatefulWidget {
  final void Function(DateTime? from, DateTime? to)? onDateRangeChanged;
  const SearchByDateWidget({super.key, this.onDateRangeChanged});

  @override
  State<SearchByDateWidget> createState() => _SearchByDateWidgetState();
}

class _SearchByDateWidgetState extends State<SearchByDateWidget> {
  String fromDate = '--/--/----';
  String toDate = '--/--/----';
  DateTime? fromDateTime;
  DateTime? toDateTime;

  void _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Chọn ngày bắt đầu',
    );

    if (picked != null) {
      setState(() {
        fromDateTime = picked;
        fromDate = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
      _triggerCallback();
    }
  }

  void _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: toDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Chọn ngày kết thúc',
    );

    if (picked != null) {
      setState(() {
        toDateTime = picked;
        toDate = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
      _triggerCallback();
    }
  }

  void _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: (fromDateTime != null && toDateTime != null)
          ? DateTimeRange(start: fromDateTime!, end: toDateTime!)
          : null,
    );

    if (picked != null) {
      setState(() {
        fromDateTime = picked.start;
        toDateTime = picked.end;
        fromDate = "${picked.start.day.toString().padLeft(2, '0')}/${picked.start.month.toString().padLeft(2, '0')}/${picked.start.year}";
        toDate = "${picked.end.day.toString().padLeft(2, '0')}/${picked.end.month.toString().padLeft(2, '0')}/${picked.end.year}";
      });
      _triggerCallback();
    }
  }

  void _triggerCallback() {
    if (widget.onDateRangeChanged != null) {
      widget.onDateRangeChanged!(fromDateTime, toDateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      width: screenWidth - 32,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với title và button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4285F4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.date_range,
                      color: Color(0xFF4285F4),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Lọc theo ngày đặt',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    _pickDateRange();
                    print('Start date: $fromDate');
                    print('End date: $toDate');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4285F4), Color(0xFF0D47A1)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4285F4).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.calendar_today, size: 16, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Chọn ngày',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Date range display
          Row(
            children: [
              Expanded(
                child: _buildDateCard('Từ ngày', fromDate, Icons.login, _pickFromDate),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Color(0xFF4285F4),
                  size: 24,
                ),
              ),
              Expanded(
                child: _buildDateCard('Đến ngày', toDate, Icons.logout, _pickToDate),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(String label, String dateText, IconData icon, VoidCallback onTap) {
    final hasDate = dateText != '--/--/----';
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasDate ? const Color(0xFF4285F4) : Colors.grey.shade300,
            width: hasDate ? 2.5 : 2,
          ),
          boxShadow: hasDate
              ? [
                  BoxShadow(
                    color: const Color(0xFF4285F4).withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: hasDate ? const Color(0xFF4285F4) : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: hasDate ? const Color(0xFF4285F4) : Colors.grey.shade600,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              dateText,
              style: TextStyle(
                color: hasDate ? Colors.black87 : Colors.grey.shade400,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: hasDate ? FontWeight.w700 : FontWeight.w400,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
