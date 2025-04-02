import 'package:flutter/material.dart';
import 'package:myapp/providers/class_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart' as user_info;

class ClassDetailPage extends StatefulWidget {
  final String classId;
  const ClassDetailPage({Key? key, required this.classId}) : super(key: key);

  @override
  _ClassDetailPageState createState() => _ClassDetailPageState();
}

class _ClassDetailPageState extends State<ClassDetailPage> {
  final ClassProvider _classProvider = ClassProvider();
  late Future<ClassModel?> _classFuture;
  late Future<List<Member>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _classFuture = _classProvider.fetchClassById(widget.classId);
    _membersFuture = _classProvider.fetchMembersOfClass(widget.classId);
  }

  Widget _buildClassInfoSection(ClassModel classData) {
    double progress = (classData.exp % 100) / 100.0;

    return Card(
      color: Colors.black,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 33,
                  backgroundImage:
                      (classData.logoUrl.isNotEmpty)
                          ? NetworkImage(classData.logoUrl)
                          : const AssetImage('assets/images/default_logo.png')
                              as ImageProvider,
                  backgroundColor: Colors.grey[900],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classData.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '레벨 : ${classData.level}',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: progress.clamp(0.0, 1.0),
                              backgroundColor: Colors.grey.shade800,
                              color: Colors.tealAccent,
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(14),
              child: Text(
                classData.description,
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final Uri url = Uri.parse(classData.openChatUrl);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('채팅방을 열 수 없습니다.')));
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  //iconColor: Colors.black,
                  backgroundColor: Colors.yellow,
                  side: BorderSide(color: Colors.yellow),
                ),
                icon: Image.asset(
                  'assets/images/kakaotalk_logo.png',
                  width: 25,
                ),
                label: const Text('오픈채팅 열기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberListSection(List<Member> members) {
    if (members.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Text('아직 멤버가 없습니다.', style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    return Column(
      children:
          members.map((member) {
            return Card(
              color: Colors.black,
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: Text(
                  member.userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                trailing: Text(
                  '${member.score} 점',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildActionButton({required bool isMember, required bool isLeader}) {
    String buttonText;
    Color backgroundColor;
    Color textColor = Colors.white;
    VoidCallback? onPressed;

    if (isLeader) {
      buttonText = '삭제하기';
      backgroundColor = Colors.red.shade700;
      onPressed = () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: Text('클래스 삭제'),
                content: Text('정말 이 클래스를 삭제하시겠습니까?'),
                actions: [
                  TextButton(
                    child: Text('취소'),
                    onPressed: () => Navigator.pop(ctx, false),
                  ),
                  TextButton(
                    child: Text('삭제'),
                    onPressed: () => Navigator.pop(ctx, true),
                  ),
                ],
              ),
        );
        if (confirm != true) return;
        try {
          await _classProvider.deleteClass(widget.classId);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('클래스가 삭제되었습니다.')));
          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      };
    } else if (!isMember) {
      buttonText = '참여하기';
      backgroundColor = Colors.tealAccent;
      onPressed = () async {
        try {
          await _classProvider.joinClass(widget.classId);
          setState(() {
            _membersFuture = _classProvider.fetchMembersOfClass(widget.classId);
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('클래스에 참여했습니다!')));
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      };
    } else {
      buttonText = '탈퇴하기';
      backgroundColor = Colors.grey.shade700;
      onPressed = () async {
        try {
          await _classProvider.leaveClass(widget.classId);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('클래스를 탈퇴했습니다.')));
          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      };
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ClassModel?>(
      future: _classFuture,
      builder: (context, classSnap) {
        if (classSnap.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: const Color(0xFF141414),
            appBar: AppBar(
              backgroundColor: const Color(0xFF141414),
              title: Text('클래스 상세'),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (classSnap.hasError || classSnap.data == null) {
          return Scaffold(
            backgroundColor: const Color(0xFF141414),
            appBar: AppBar(
              backgroundColor: const Color(0xFF141414),
              title: Text('클래스 상세'),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: Text(
                '클래스 정보를 불러올 수 없습니다.',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }

        final classData = classSnap.data!;
        return FutureBuilder<List<Member>>(
          future: _membersFuture,
          builder: (context, membersSnap) {
            final currentUserId = user_info.AuthProvider.currentUserId;
            final members = membersSnap.data ?? [];
            final isMember = members.any((m) => m.userId == currentUserId);
            final isLeader = currentUserId == classData.leaderId;

            return Scaffold(
              backgroundColor: const Color(0xFF141414),
              appBar: AppBar(
                backgroundColor: const Color(0xFF141414),
                title: Text(classData.name),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildClassInfoSection(classData),
                    const SizedBox(height: 16),
                    Text(
                      '멤버 목록 (${members.length}명)',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    membersSnap.connectionState == ConnectionState.waiting
                        ? Center(child: CircularProgressIndicator())
                        : _buildMemberListSection(members),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildActionButton(
                  isMember: isMember,
                  isLeader: isLeader,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
