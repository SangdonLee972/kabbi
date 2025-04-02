import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/firebase_options.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/challenge_provider.dart';
import 'providers/class_provider.dart';
import 'providers/community_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChallengeProvider()),
        ChangeNotifierProvider(create: (_) => ClassProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return MaterialApp(
          title: 'Challenge & Class App',
          theme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.white, // 흰색
            colorScheme: ColorScheme.dark(primary: Colors.black),
            scaffoldBackgroundColor: Colors.black, // 배경색 검정
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Colors.white, // 흰색으로 변경
              foregroundColor: Colors.black, // FAB 아이콘 색상
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // 버튼 배경 흰색
                foregroundColor: Colors.black, // 버튼 텍스트 검정
              ),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.black,
              selectedItemColor: Colors.white, // 선택된 아이템 색상 흰색
              unselectedItemColor: Colors.grey, // 선택되지 않은 아이템 색상 회색
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white), // 흰색 테두리
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white), // 흰색 테두리
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white,
                  width: 2,
                ), // 흰색 강조 테두리
              ),
              labelStyle: TextStyle(color: Colors.white), // 텍스트 색상 흰색
            ),
          ),
          home: auth.user != null ? HomeScreen() : LoginScreen(),
        );
      },
    );
  }
}
