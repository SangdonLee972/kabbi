import 'package:flutter/material.dart';
import 'package:myapp/screens/challenge/challenges_screen.dart';
import 'class/classes_screen.dart';
import 'community/community_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = [
    ChallengesScreen(),
    ClassesScreen(),
    CommunityScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border(
            top: BorderSide(color: Colors.grey.shade800, width: 1),
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent, // Container 배경색 보이게 transparent로
          elevation: 0, // 그림자 없애기
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.flag), label: "챌린지"),
            BottomNavigationBarItem(icon: Icon(Icons.group), label: "클래스"),
            BottomNavigationBarItem(icon: Icon(Icons.forum), label: "커뮤니티"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "프로필"),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
