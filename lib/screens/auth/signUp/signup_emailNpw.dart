import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/providers/auth_provider.dart';
import 'package:myapp/screens/auth/signUp/signup_complete_screen.dart';
import 'package:provider/provider.dart';

class SignUpEmailScreen extends StatefulWidget {
  final String nickname;
  SignUpEmailScreen({required this.nickname});

  @override
  State<SignUpEmailScreen> createState() => _SignUpEmailScreenState();
}

class _SignUpEmailScreenState extends State<SignUpEmailScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _emailChecked = false;
  bool _emailValid = false;
  bool _isLoading = false;
  bool _isPasswordFilled = false;
  bool _isEmailFormatValid = false;
  bool _obscurePassword = true;

  final RegExp _emailRegExp = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

  @override
  void initState() {
    super.initState();

    _emailCtrl.addListener(() {
      setState(() {
        _isEmailFormatValid = _emailRegExp.hasMatch(_emailCtrl.text.trim());
      });
    });

    _passwordCtrl.addListener(() {
      setState(() {
        _isPasswordFilled = _passwordCtrl.text.length >= 6;
      });
    });
  }

  Future<void> _checkEmailDuplicate() async {
    setState(() => _isLoading = true);
    final email = _emailCtrl.text.trim();

    final emailValid = await isEmailAvailable(email);

    setState(() {
      _emailChecked = true;
      _emailValid = emailValid;
      _isLoading = false;
    });
  }

  Future<bool> isEmailAvailable(String email) async {
    final query =
        await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
    return query.docs.isEmpty;
  }

  Future<void> _submitSignup() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final error = await auth.signUp(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
      widget.nickname,
    );

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SignUpCompleteScreen(nickname: widget.nickname),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 400;

    final inputFontSize = isSmall ? 14.0 : 16.0;
    final titleFontSize = isSmall ? 20.0 : 23.0;
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(fontSize: titleFontSize, color: Colors.white),
                children: [
                  TextSpan(
                    text: "${widget.nickname}",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 57, 252, 161),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: "님! 반갑습니다 👋"),
                ],
              ),
            ),
            SizedBox(height: verticalPadding * 2),

            /// 이메일 입력
            TextField(
              controller: _emailCtrl,
              onChanged: (e) {
                setState(() {
                  _emailValid = false;
                  _emailChecked = false;
                });
              },
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.white, fontSize: inputFontSize),
              decoration: InputDecoration(
                labelText: "이메일",
                labelStyle: TextStyle(color: Colors.white),
                hintText: "example@email.com",
                hintStyle: TextStyle(color: Colors.white38),
                border: OutlineInputBorder(),
              ),
            ),
            if (!_isEmailFormatValid && _emailCtrl.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "올바른 이메일 형식을 입력해주세요",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: inputFontSize - 1,
                  ),
                ),
              ),

            if (!_emailValid) ...[
              SizedBox(height: verticalPadding),

              /// 이메일 중복 검사 버튼
              SizedBox(
                height: buttonHeight,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      !_isEmailFormatValid || _isLoading
                          ? null
                          : _checkEmailDuplicate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isEmailFormatValid ? Colors.white : Colors.grey,
                    foregroundColor: Colors.black,
                  ),
                  child:
                      _isLoading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(
                            "이메일 중복 검사",
                            style: TextStyle(fontSize: buttonFontSize),
                          ),
                ),
              ),
            ],
            if (_emailChecked)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  _emailValid ? "사용 가능한 이메일입니다" : "이미 사용 중인 이메일입니다",
                  style: TextStyle(
                    color: _emailValid ? Colors.green : Colors.red,
                    fontSize: inputFontSize,
                  ),
                ),
              ),

            /// 비밀번호 입력 + 버튼
            if (_emailValid) ...[
              SizedBox(height: verticalPadding),
              TextField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                style: TextStyle(color: Colors.white, fontSize: inputFontSize),
                decoration: InputDecoration(
                  labelText: "비밀번호 (6자 이상)",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white54,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              if (_passwordCtrl.text.isNotEmpty && !_isPasswordFilled)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "비밀번호는 6자 이상이어야 합니다",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: inputFontSize - 1,
                    ),
                  ),
                ),
              SizedBox(height: verticalPadding),
              SizedBox(
                height: buttonHeight,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPasswordFilled ? _submitSignup : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isPasswordFilled
                            ? Colors.white
                            : const Color.fromARGB(190, 158, 158, 158),
                    foregroundColor: Colors.black,
                  ),
                  child: Text(
                    "회원가입 완료",
                    style: TextStyle(fontSize: buttonFontSize),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
