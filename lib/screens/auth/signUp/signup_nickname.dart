import 'package:flutter/material.dart';
import 'package:myapp/screens/auth/signUp/signup_emailNpw.dart';

class SignUpNicknameScreen extends StatefulWidget {
  @override
  _SignUpNicknameScreenState createState() => _SignUpNicknameScreenState();
}

class _SignUpNicknameScreenState extends State<SignUpNicknameScreen> {
  final _nicknameCtrl = TextEditingController();
  bool _isFilled = false;

  @override
  void initState() {
    super.initState();
    _nicknameCtrl.addListener(() {
      setState(() {
        _isFilled = _nicknameCtrl.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 400;

    final inputFontSize = isSmall ? 14.0 : 16.0;
    final buttonFontSize = isSmall ? 16.0 : 18.0;
    final buttonHeight = isSmall ? 44.0 : 50.0;
    final verticalPadding = isSmall ? 12.0 : 20.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: verticalPadding),
              Text(
                "닉네임을 입력해주세요!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: inputFontSize * 1.4,
                ),
              ),
              SizedBox(height: verticalPadding * 2),
              TextField(
                controller: _nicknameCtrl,
                style: TextStyle(color: Colors.white, fontSize: inputFontSize),
                decoration: InputDecoration(
                  hintText: "닉네임",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: verticalPadding * 2),
              SizedBox(
                width: double.infinity,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed:
                      _isFilled
                          ? () {
                            final nickname = _nicknameCtrl.text.trim();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        SignUpEmailScreen(nickname: nickname),
                              ),
                            );
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isFilled
                            ? Colors.white
                            : const Color.fromARGB(190, 158, 158, 158),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("다음", style: TextStyle(fontSize: buttonFontSize)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
