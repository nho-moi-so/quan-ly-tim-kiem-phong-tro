import 'package:flutter/material.dart';

class BookingScheduleWidget extends StatefulWidget {
  const BookingScheduleWidget({super.key});

  @override
  State<BookingScheduleWidget> createState() => _BookingScheduleWidgetState();
}

class _BookingScheduleWidgetState extends State<BookingScheduleWidget> {
  DateTime? startDate;
  DateTime? endDate;
  bool selectingStart = true;

  String get rangeText {
    if (startDate == null || endDate == null) return 'Chưa chọn';
    return '${startDate!.day}/${startDate!.month}/${startDate!.year} - '
        '${endDate!.day}/${endDate!.month}/${endDate!.year}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month - 3);
    final lastDate = DateTime(now.year + 2);

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            height: 56,
            color: const Color(0xFF4285F4),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'LỊCH ĐẶT PHÒNG',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Noto Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Xử lý lưu lịch ở đây
                  },
                  child: const Text(
                    'SAVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Selected Range
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF4285F4),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x33000000),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SELECTED RANGE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  rangeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.18,
                  ),
                ),
              ],
            ),
          ),
          // Calendar hiển thị luôn
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: CalendarDatePicker(
              initialDate: startDate ?? now,
              firstDate: firstDate,
              lastDate: lastDate,
              onDateChanged: (date) {
                setState(() {
                  if (selectingStart) {
                    startDate = date;
                    endDate = null;
                    selectingStart = false;
                  } else {
                    if (startDate != null && date.isAfter(startDate!)) {
                      endDate = date;
                      selectingStart = true;
                    } else {
                      // Nếu chọn ngày kết thúc trước ngày bắt đầu, thì reset
                      startDate = date;
                      endDate = null;
                      selectingStart = false;
                    }
                  }
                });
              },
            ),
          ),
          Text(
            selectingStart
                ? 'Chọn ngày bắt đầu'
                : 'Chọn ngày kết thúc',
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
