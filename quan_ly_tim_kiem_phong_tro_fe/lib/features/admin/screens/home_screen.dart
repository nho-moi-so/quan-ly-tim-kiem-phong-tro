import 'package:flutter/material.dart';
import '/features/admin/widgets/widgets.dart';


class HomeScreen extends StatelessWidget {
 @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
              child: Container(
                width: screenWidth,
          padding: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //wiget trong đây
              TopBar(), 
            ],
          )
        ),
      ),
    );
  }

}


