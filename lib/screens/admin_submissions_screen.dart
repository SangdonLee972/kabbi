import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/challenge_provider.dart';

class AdminSubmissionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final challengeProv = Provider.of<ChallengeProvider>(
      context,
      listen: false,
    );
    return Scaffold(
      appBar: AppBar(title: Text("인증 요청 승인")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('submissions')
                .where('status', isEqualTo: 'pending')
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(child: Text("대기 중인 인증 요청이 없습니다."));
          }
          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              String challengeTitle = data['challengeTitle'] ?? 'Challenge';
              String userName = data['userName'] ?? 'User';
              String text = data['text'] ?? '';
              String mediaType = data['mediaType'] ?? 'text';
              String mediaUrl = data['mediaUrl'] ?? '';
              return Card(
                color: Colors.grey[900],
                child: ListTile(
                  leading:
                      mediaType == 'image'
                          ? (mediaUrl.isNotEmpty
                              ? Image.network(
                                mediaUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                              : Icon(Icons.image, color: Colors.cyanAccent))
                          : mediaType == 'video'
                          ? Icon(Icons.videocam, color: Colors.cyanAccent)
                          : Icon(Icons.notes, color: Colors.cyanAccent),
                  title: Text(
                    "챌린지: $challengeTitle",
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    text.isNotEmpty ? "$userName: $text" : "$userName",
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.cyanAccent),
                          onPressed: () async {
                            String? err = await challengeProv.approveSubmission(
                              doc.id,
                            );
                            if (err != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $err")),
                              );
                            } else {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text("승인 완료")));
                            }
                          },
                          tooltip: "승인",
                        ),
                        IconButton(
                          icon: Icon(Icons.clear, color: Colors.redAccent),
                          onPressed: () async {
                            String? err = await challengeProv.denySubmission(
                              doc.id,
                            );
                            if (err != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $err")),
                              );
                            } else {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text("거절 완료")));
                            }
                          },
                          tooltip: "거절",
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
