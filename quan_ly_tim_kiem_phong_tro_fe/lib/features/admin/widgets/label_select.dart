import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class LabelSelect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Select',
      style: AppTextStyles.hintText,
    );
  }
}
