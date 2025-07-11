//apartment widgets
export 'apartment/card_customer_widget.dart';
export 'apartment/card_room_detail_widget.dart';
export 'apartment/card_room_widget.dart';
export 'apartment/label_status_widget.dart';
export 'logo_widget.dart';

export 'apartment/label_title_widget.dart';
export 'apartment/button_add_widget.dart';
export 'label_title_and_quaylai_widget.dart';

//booking request widgets
export 'booking_request/fliter_status_widget.dart';
export 'booking_request/search_by_date_widget.dart';
export 'booking_request/card_booking_request_widget.dart';
export 'booking_request/card_booking_request_detail_widget.dart';
export 'booking_request/booking_schedule_widget.dart';
export 'booking_request/note_booking_schedule_widget.dart';

//widgets
export 'menu_detail_widget.dart';
export 'tag_with_icon_widget.dart';
export 'bottom_nav_widget.dart';

//util
import 'package:flutter/material.dart';
Future<void> showDateTimePicker({
  required BuildContext context,
  required DateTime initialDateTime,
  required ValueChanged<DateTime> onDateTimeChanged,
}) async {
  final DateTime? date = await showDatePicker(
    context: context,
    initialDate: initialDateTime,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  if (date != null) {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
    );

    if (time != null) {
      final DateTime newDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      onDateTimeChanged(newDateTime);

      // Hiện thông báo (SnackBar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã chọn: ${_formatDateTime(newDateTime)}'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

String _formatDateTime(DateTime dt) {
  return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
         '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
