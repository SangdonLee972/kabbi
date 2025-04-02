import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'auth_provider.dart';

class Challenge {
  String id;
  String title;
  String description;
  String createdBy;
  String logoUrl;
  Timestamp createdAt;
  Timestamp endTime;
  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.logoUrl,
    required this.endTime,
    required this.createdBy,
    required this.createdAt,
  });
  factory Challenge.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Challenge(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      endTime: data['endTime'] ?? Timestamp.now()
    );
  }
}

class ChallengeProvider extends ChangeNotifier {
  List<Challenge> _challenges = [];
  Set<String> _joinedChallenges = {};
  late StreamSubscription _challengeSub;

  List<Challenge> get challenges => _challenges;
  Set<String> get joinedChallenges => _joinedChallenges;

  ChallengeProvider() {
    // Firestore 챌린지 컬렉션 실시간 구독
    _challengeSub = FirebaseFirestore.instance
        .collection('challenges')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _challenges =
              snapshot.docs.map((doc) => Challenge.fromDocument(doc)).toList();
          notifyListeners();
        });
  }

  Future<void> loadUserChallengeMemberships() async {
    if (AuthProvider.currentUserId == null) return;
    _joinedChallenges.clear();
    QuerySnapshot snap =
        await FirebaseFirestore.instance
            .collectionGroup('participants')
            .where('userId', isEqualTo: AuthProvider.currentUserId)
            .get();
    for (var doc in snap.docs) {
      String challengeId = doc.reference.parent.parent!.id;
      _joinedChallenges.add(challengeId);
    }
    notifyListeners();
  }

  Future<String?> createChallenge({
  required String title,
  required String description,
  required String logoUrl,
  required Timestamp endTime,
}) async {
  if (AuthProvider.currentUserId == null) return "Not authenticated";
  try {
    await FirebaseFirestore.instance.collection('challenges').add({
      'title': title,
      'description': description,
      'logoUrl': logoUrl,
      'endTime': endTime,
      'createdBy': AuthProvider.currentUserId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return null;
  } catch (e) {
    return e.toString();
  }
}

  Future<String?> joinChallenge(String challengeId) async {
    if (AuthProvider.currentUserId == null ||
        AuthProvider.currentNickname == null) {
      return "Not authenticated";
    }
    try {
      await FirebaseFirestore.instance
          .collection('challenges')
          .doc(challengeId)
          .collection('participants')
          .doc(AuthProvider.currentUserId)
          .set({
            'userId': AuthProvider.currentUserId,
            'userName': AuthProvider.currentNickname,
            'joinedAt': FieldValue.serverTimestamp(),
          });
      _joinedChallenges.add(challengeId);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> uploadProof(
    String challengeId,
    String challengeTitle, {
    String text = '',
    String? filePath,
    bool isVideo = false,
  }) async {
    if (AuthProvider.currentUserId == null ||
        AuthProvider.currentNickname == null) {
      return "Not authenticated";
    }
    try {
      String? downloadUrl;
      String mediaType = 'text';
      if (filePath != null) {
        final ext = filePath.split('.').last.toLowerCase();
        isVideo =
            (ext == 'mp4' || ext == 'mov' || ext == 'avi' || ext == 'm4v');
        mediaType = isVideo ? 'video' : 'image';
        final fileRef = FirebaseStorage.instance.ref(
          'submissions/${challengeId}_${AuthProvider.currentUserId}_${DateTime.now().millisecondsSinceEpoch}.$ext',
        );
        await fileRef.putFile(File(filePath));
        downloadUrl = await fileRef.getDownloadURL();
      }
      await FirebaseFirestore.instance.collection('submissions').add({
        'challengeId': challengeId,
        'challengeTitle': challengeTitle,
        'userId': AuthProvider.currentUserId,
        'userName': AuthProvider.currentNickname,
        'text': text,
        'mediaUrl': downloadUrl ?? '',
        'mediaType': mediaType,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> approveSubmission(String submissionId) async {
    try {
      DocumentReference subRef = FirebaseFirestore.instance
          .collection('submissions')
          .doc(submissionId);
      DocumentSnapshot subDoc = await subRef.get();
      if (!subDoc.exists) return "Submission not found";
      if ((subDoc.data() as Map<String, dynamic>)['status'] != 'pending') {
        return "Already processed";
      }
      String userId = (subDoc.data() as Map<String, dynamic>)['userId'];
      await subRef.update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
      });
      // 사용자 인증 횟수 및 등급 업데이트
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot userDoc = await transaction.get(userRef);
        int prevCount = 0;
        if (userDoc.exists) {
          prevCount =
              (userDoc.data() as Map<String, dynamic>)['completedCount'] ?? 0;
        }
        int newCount = prevCount + 1;
        String newRank;
        if (newCount >= 10)
          newRank = 'Gold';
        else if (newCount >= 5)
          newRank = 'Silver';
        else
          newRank = 'Bronze';
        transaction.update(userRef, {
          'completedCount': newCount,
          'rank': newRank,
        });
      });
      // 클래스 내 해당 사용자 등급 일괄 업데이트
      DocumentSnapshot updatedUser = await userRef.get();
      String newRank =
          (updatedUser.data() as Map<String, dynamic>)['rank'] ?? '';
      QuerySnapshot memberDocs =
          await FirebaseFirestore.instance
              .collectionGroup('members')
              .where('userId', isEqualTo: userId)
              .get();
      for (var doc in memberDocs.docs) {
        await doc.reference.update({'rank': newRank});
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> denySubmission(String submissionId) async {
    try {
      await FirebaseFirestore.instance
          .collection('submissions')
          .doc(submissionId)
          .update({'status': 'denied'});
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  void dispose() {
    _challengeSub.cancel();
    super.dispose();
  }
}
