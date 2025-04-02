import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'admin_submissions_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("프로필")),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!auth.isAuthenticated) {
            return Center(child: Text("로그인이 필요합니다."));
          }
          //일단 지금 너가 위에 짜준 코드를 확인해 봤는데 내가 원하는대로 틀은 완성됐는데 세세한 부분은 완성되지 못한것 같아.
          // 예를들면
          bool isAdmin = auth.role == 'admin';
          return ListView(
            children: [
              ListTile(
                title: Text("닉네임", style: TextStyle(color: Colors.white70)),
                subtitle: Text(auth.nickname ?? "", style: TextStyle(color: Colors.white)),
              ),
              ListTile(
                title: Text("이메일", style: TextStyle(color: Colors.white70)),
                subtitle: Text(auth.user!.email ?? "", style: TextStyle(color: Colors.white)),
              ),
              ListTile(
                title: Text("등급 (Rank)", style: TextStyle(color: Colors.white70)),
                subtitle: Text(auth.rank ?? "", style: TextStyle(color: Colors.white)),
              ),
              if (isAdmin)
                ListTile(
                  title: Text("역할", style: TextStyle(color: Colors.white70)),
                  subtitle: Text("관리자", style: TextStyle(color: Colors.white)),
                ),
              if (isAdmin)
                ListTile(
                  title: Text("인증 요청 관리", style: TextStyle(color: Colors.white)),
                  trailing: Icon(Icons.chevron_right, color: Colors.cyanAccent),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => AdminSubmissionsScreen()));
                  },
                ),
              ListTile(
                title: Text("로그아웃", style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Provider.of<AuthProvider>(context, listen: false).signOut();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
