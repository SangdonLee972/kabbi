import 'package:flutter/material.dart';

class SignUpCompleteScreen extends StatelessWidget {
  final String nickname;

  SignUpCompleteScreen({required this.nickname});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 400;

    final titleFontSize = isSmall ? 20.0 : 24.0;
    final buttonFontSize = isSmall ? 16.0 : 18.0;
    final buttonHeight = isSmall ? 44.0 : 50.0;
    final verticalSpacing = isSmall ? 16.0 : 24.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(25),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 0, 0, 0),
              Color.fromARGB(255, 28, 30, 31),
              Color.fromARGB(255, 50, 58, 61),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/default_logo.png',
              width: verticalSpacing * 10,
              fit: BoxFit.contain,
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(color: Colors.white, fontSize: titleFontSize),
                children: [
                  TextSpan(
                    text: "$nickname",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 57, 252, 161),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: "님, 회원가입을 축하합니다!"),
                ],
              ),
            ),
            SizedBox(height: verticalSpacing * 2),
            SizedBox(
              height: buttonHeight,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "깨비허리 시작하기",
                  style: TextStyle(fontSize: buttonFontSize),
                ),
              ),
            ),
            SizedBox(height: verticalSpacing * 2),
          ],
        ),
      ),
    );
  }
}
