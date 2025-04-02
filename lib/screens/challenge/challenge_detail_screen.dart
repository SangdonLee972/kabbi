import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/providers/challenge_provider.dart';
import 'package:myapp/screens/challenge/challenge_proof_screen.dart';
import 'package:provider/provider.dart';

class ChallengeDetailScreen extends StatelessWidget {
  final Challenge challenge;
  ChallengeDetailScreen({required this.challenge});

  final Color backgroundColor = const Color(0xFF141414);

  @override
  Widget build(BuildContext context) {
    final joined = Provider.of<ChallengeProvider>(
      context,
    ).joinedChallenges.contains(challenge.id);
    final now = DateTime.now();
    final start = challenge.createdAt.toDate();
    final end = challenge.endTime.toDate();
    final isJoinable = now.isAfter(start) && now.isBefore(end);
    final createdAtFormatted = DateFormat(
      'yyyy-MM-dd',
    ).format(challenge.createdAt.toDate());
    final endDateFormatted = DateFormat(
      'yyyy-MM-dd',
    ).format(challenge.endTime.toDate());

    final imageHeight = MediaQuery.of(context).size.width * 9 / 16;

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset('assets/images/main_logo2.png', height: 60),
        centerTitle: true,
        toolbarHeight: 80,
      ),
      body: Stack(
        children: [
          // 콘텐츠
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100), // 버튼 공간 확보
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height - 100, // 화면 최소 높이로 고정
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이미지
                  Image.network(
                    challenge.logoUrl,
                    width: double.infinity,
                    height: imageHeight,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        width: double.infinity,
                        height: imageHeight,
                        color: Colors.grey[700],
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: imageHeight,
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

                  // 콘텐츠
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // 날짜 정보
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 17,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '기간 : $createdAtFormatted ~ $endDateFormatted',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Divider(color: Colors.grey[800]),
                        const SizedBox(height: 6),
                        Text(
                          ' 챌린지 설명',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.all(16),
                          child: Text(
                            challenge.description,
                            style: TextStyle(
                              color: const Color.fromARGB(255, 233, 233, 233),
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 하단 고정 버튼
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child:
                joined
                    ? ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ChallengeProofScreen(
                                  challengeId: challenge.id,
                                  challengeTitle: challenge.title,
                                ),
                          ),
                        );
                        if (result == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("인증이 제출되었습니다. (검토 대기)")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(Icons.camera_alt, color: Colors.white),
                      label: Text(
                        "인증하기",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    )
                    : isJoinable
                    ? ElevatedButton.icon(
                      onPressed: () async {
                        String? error = await Provider.of<ChallengeProvider>(
                          context,
                          listen: false,
                        ).joinChallenge(challenge.id);

                        if (error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: $error")),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("챌린지에 참여했습니다!")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(Icons.how_to_reg, color: Colors.white),
                      label: Text(
                        "챌린지 참가",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    )
                    : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
