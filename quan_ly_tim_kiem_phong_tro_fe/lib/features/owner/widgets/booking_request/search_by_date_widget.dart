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

  void _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        fromDate =
            "${picked.start.day}/${picked.start.month}/${picked.start.year}";
        toDate =
            "${picked.end.day}/${picked.end.month}/${picked.end.year}";
      });
      if (widget.onDateRangeChanged != null) {
        widget.onDateRangeChanged!(picked.start, picked.end); //== trả về start và end date
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 383,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ngày Đặt',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  height: 1.12,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4285F4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Noto Sans',
                      fontWeight: FontWeight.w400,
                      height: 1.29,
                    ),
                  ),
                  onPressed: () async {
                    _pickDateRange();
                    print('Start date: $fromDate');
                    print('End date: $toDate');
                    // List<BookingRequestSummary> bookingRequestSummaries = await _bookingRequestController.searchBookingRequestByStartDateAndEndDate("ownerId", DateTime.now(), DateTime.now()); //==ownerId đang cố định

                  },
                  child: const Text(
                    'Lịch Đặt Phòng',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Noto Sans',
                      fontWeight: FontWeight.w400,
                      height: 1.29,
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),

          // From and To Dates
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Từ Ngày',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildDateBox(fromDate),
                ],
              ),
              const SizedBox(width: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đến',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildDateBox(toDate),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateBox(String dateText) {
    return Container(
      width: 96,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF4285F4), width: 1),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        dateText,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
