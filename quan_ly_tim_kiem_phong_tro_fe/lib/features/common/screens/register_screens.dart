import 'package:flutter/material.dart';

import '../../../features/common/widgets/widgets.dart';
import '../../../features/owner/widgets/widgets.dart';

class RegisterScreens extends StatelessWidget {
  const RegisterScreens({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F7FA),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.02),
                
                // Logo
                LogoWidget(scale: 1.2),
                
                SizedBox(height: screenHeight * 0.015),
                
                // Signup Form Card
                SignupForm(),
                
                SizedBox(height: screenHeight * 0.02),
                
                // Auth Switch
                Center(
                  child: AuthSwitchText(
                    isLogin: false, 
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}