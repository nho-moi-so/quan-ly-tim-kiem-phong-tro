import 'package:flutter/material.dart';

import '../../../features/owner/widgets/widgets.dart';
import '../../../features/common/widgets/widgets.dart';

class LoginScreens extends StatelessWidget {
  const LoginScreens({super.key});

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
              SizedBox(height: screenHeight * 0.03), // Giảm xuống
              Center(child: LogoWidget(scale: 1.5,)),
              Center(child: LogInForm()),
              SizedBox(height: screenHeight * 0.02), // Giảm xuống
              Center(
                child: AuthSwitchText(
                  isLogin: true, 
                ),
              ),
            ],
            
          ),
        ),
      ),
    );
  }
}