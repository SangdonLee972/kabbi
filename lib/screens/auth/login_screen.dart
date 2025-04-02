import 'package:flutter/material.dart';
import 'package:myapp/screens/auth/signUp/signup_nickname.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showError = false;

  Future<void> _performLogin() async {
    setState(() => _isLoading = true);
    String? error = await Provider.of<AuthProvider>(
      context,
      listen: false,
    ).signIn(_emailController.text.trim(), _passwordController.text);
    setState(() {
      _isLoading = false;
      _showError = error != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 400;

    final logoWidth = screenWidth * 0.6;
    final inputFontSize = isSmall ? 14.0 : 16.0;
    final buttonFontSize = isSmall ? 16.0 : 18.0;
    final buttonHeight = isSmall ? 44.0 : 50.0;
    final verticalPadding = isSmall ? 12.0 : 20.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  child: Image.asset(
                    'assets/images/main_logo2.png',
                    width: logoWidth,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: verticalPadding * 2),
                _buildTextField(
                  controller: _emailController,
                  label: "이메일",
                  icon: Icons.email,
                  fontSize: inputFontSize,
                ),
                SizedBox(height: verticalPadding),
                _buildTextField(
                  controller: _passwordController,
                  label: "비밀번호",
                  icon: Icons.lock,
                  obscureText: true,
                  fontSize: inputFontSize,
                ),
                SizedBox(height: verticalPadding * 1.5),

                SizedBox(
                  width: double.infinity,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: _performLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isLoading
                            ? CircularProgressIndicator(color: Colors.black)
                            : Text(
                              "로그인",
                              style: TextStyle(fontSize: buttonFontSize),
                            ),
                  ),
                ),
                if (_showError) SizedBox(height: 12),
                if (_showError)
                  Text(
                    "이메일 또는 비밀번호가 일치하지 않습니다.",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: inputFontSize,
                    ),
                  ),
                SizedBox(height: verticalPadding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SignUpNicknameScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "계정이 아직 없으신가요?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: inputFontSize,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    double fontSize = 16,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        //prefixIcon: Icon(icon, color: Colors.white),
        labelText: label,
        labelStyle: TextStyle(color: Colors.white, fontSize: fontSize),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
      ),
      style: TextStyle(color: Colors.white, fontSize: fontSize),
    );
  }
}
