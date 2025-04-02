import 'package:flutter/material.dart';
import 'package:myapp/screens/challenge/challenge_create_sceen.dart';
import 'package:myapp/screens/challenge/challenge_detail_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/challenge_provider.dart';
import '../../providers/auth_provider.dart';

class ChallengesScreen extends StatefulWidget {
  @override
  _ChallengesScreenState createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<ChallengeProvider>(
      context,
      listen: false,
    ).loadUserChallengeMemberships();
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = AuthProvider.currentRole == 'admin';
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = screenWidth * 9 / 16;
    double titleFontSize;

    if (screenWidth <= 320) {
      titleFontSize = 15;
    } else if (screenWidth <= 400) {
      titleFontSize = 17;
    } else if (screenWidth <= 600) {
      titleFontSize = 19;
    } else {
      titleFontSize = 21;
    }

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/title_logo.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      ),
      backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      body: Consumer<ChallengeProvider>(
        builder: (context, challengeProv, _) {
          if (challengeProv.challenges.isEmpty) {
            return Center(child: Text("등록된 챌린지가 없습니다."));
          }
          return ListView.builder(
            itemCount: challengeProv.challenges.length,
            itemBuilder: (context, index) {
              final chall = challengeProv.challenges[index];
              // 상태 뱃지 처리
              final now = DateTime.now();
              final startDate = chall.createdAt.toDate(); // 또는 chall.startTime
              final endDate = chall.endTime.toDate();
              final bool isMember = challengeProv.joinedChallenges.contains(
                chall.id,
              );

              String statusText;
              Color statusColor;

              if (now.isAfter(endDate)) {
                statusText = "챌린지 종료";
                statusColor = Colors.grey;
              } else if (now.isBefore(startDate)) {
                statusText = "시작 예정";
                statusColor = Colors.orange;
              } else {
                if (isMember) {
                  statusText = "참여중";
                  statusColor = Colors.cyanAccent;
                } else {
                  statusText = "참가 가능";
                  statusColor = Colors.greenAccent;
                }
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChallengeDetailScreen(challenge: chall),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 상단 이미지
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) =>
                                      ChallengeDetailScreen(challenge: chall),
                            ),
                          );
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // 이미지 + 회색 배경
                            Stack(
                              children: [
                                // 회색 배경
                                Container(
                                  height: imageHeight,
                                  width: double.infinity,
                                  color: Colors.grey[600],
                                ),
                                // 실제 이미지
                                Image.network(
                                  chall.logoUrl,
                                  height: imageHeight,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return const SizedBox(); // 로딩 중
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: imageHeight,
                                      width: double.infinity,
                                      color: Colors.grey[800],
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Colors.white38,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            // 상태 뱃지
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black45,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  statusText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 아래 텍스트 영역
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              chall.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              chall.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: titleFontSize * 0.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton:
          isAdmin
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CreateChallengePage()),
                  );
                },
                tooltip: "챌린지 생성",
                heroTag: 'Create Challenge',
                shape: const CircleBorder(),
                child: Icon(Icons.add),
              )
              : null,
    );
  }
}
