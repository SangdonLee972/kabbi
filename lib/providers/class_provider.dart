import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/providers/auth_provider.dart';

class ClassProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String get currentUserId => AuthProvider.currentUserId ?? '';
  String get currentUserName => AuthProvider.currentNickname ?? '';

  List<ClassModel> _classes = [];
  List<ClassModel> get classes => _classes;
  bool isLoading = false;

  ClassProvider() {
    fetchAllClasses();
  }

  /// 전체 클래스 조회 및 저장
  Future<void> fetchAllClasses() async {
    try {
      isLoading = true;
      notifyListeners();
      final snapshot = await _firestore.collection('classes').get();
      _classes =
          snapshot.docs
              .map((doc) => ClassModel.fromMap(doc.id, doc.data()))
              .toList();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('fetchAllClasses error: $e');
    }
  }

  // 현재 사용자가 이미 클래스를 생성했는지 확인
  Future<bool> hasCreatedClass() async {
    final query =
        await _firestore
            .collection('classes')
            .where('ownerId', isEqualTo: currentUserId)
            .limit(1)
            .get();
    return query.docs.isNotEmpty;
  }

  // 새 클래스 생성
  Future<String?> createClass({
    required String name,
    required String description,
    XFile? logoImage,
    required String openChatUrl,
  }) async {
    if (await hasCreatedClass()) {
      return '이미 본인이 만든 클래스가 존재합니다.';
    }
    if (name.isEmpty || openChatUrl.isEmpty) {
      return '클래스 이름과 오픈채팅 링크는 필수 입력입니다.';
    }
    try {
      DocumentReference classRef = _firestore.collection('classes').doc();
      String classId = classRef.id;
      String logoUrl;
      if (logoImage != null) {
        // 로고 이미지가 있을 경우 Firebase Storage에 업로드
        Reference storageRef = _storage.ref().child('class_logos/$classId.png');
        await storageRef.putData(await logoImage.readAsBytes());
        logoUrl = await storageRef.getDownloadURL();
      } else {
        // 기본 이미지 사용
        logoUrl = 'https://example.com/default_class_logo.png';
      }
      Timestamp now = Timestamp.now();
      Map<String, dynamic> classData = {
        'name': name,
        'description': description,
        'leaderId': currentUserId,
        'leaderName': currentUserName,
        'logoUrl': logoUrl,
        'openChatUrl': openChatUrl,
        'level': 1,
        'exp': 0,
        'createdAt': now,
      };
      // Firestore에 클래스 생성
      await classRef.set(classData);
      // 생성자를 멤버로 추가
      DocumentReference memberRef = classRef
          .collection('members')
          .doc(currentUserId);
      Map<String, dynamic> memberData = {
        'userId': currentUserId,
        'userName': currentUserName,
        'rank': 1,
        'joinDate': now,
        'score': 0,
        'classId': classId,
      };
      await memberRef.set(memberData);
      notifyListeners();
      return null;
    } catch (e) {
      print('createClass error: $e');
      return '클래스 생성 중 오류가 발생했습니다.';
    }
  }

  Future<ClassModel?> fetchClassById(String classId) async {
    try {
      final doc = await _firestore.collection('classes').doc(classId).get();
      if (!doc.exists) return null;
      return ClassModel.fromDocument(doc.id, doc.data()!);
    } catch (e) {
      // 에러 발생 시 throw하여 상위에서 처리
      throw Exception('클래스 정보를 불러오지 못했습니다: $e');
    }
  }

  Future<List<Member>> fetchMembersOfClass(String classId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('classes')
              .doc(classId)
              .collection('members')
              .get();
      return querySnapshot.docs
          .map((doc) => Member.fromDocument(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('멤버 목록을 불러오지 못했습니다: $e');
    }
  }
Future<void> joinClass(String classId) async {
  final currentUserId = AuthProvider.currentUserId;
  final currentUserName = AuthProvider.currentNickname;

  if (currentUserId == null) throw Exception('로그인된 사용자가 없습니다.');

  try {
    // `members` 서브컬렉션에 현재 사용자 추가
    await _firestore
        .collection('classes')
        .doc(classId)
        .collection('members')
        .doc(currentUserId)  // AuthProvider에서 가져온 currentUserId 사용
        .set({
      'userName': currentUserName ?? 'User',  // AuthProvider에서 가져온 currentNickname 사용
      'score': 0,  // 새로 참여시 기본 점수 0
    });
  } catch (e) {
    throw Exception('클래스 참여에 실패했습니다: $e');
  }
}


Future<void> leaveClass(String classId) async {
  final currentUserId = AuthProvider.currentUserId;

  if (currentUserId == null) throw Exception('로그인된 사용자가 없습니다.');

  try {
    await _firestore
        .collection('classes')
        .doc(classId)
        .collection('members')
        .doc(currentUserId)  // AuthProvider에서 가져온 currentUserId 사용
        .delete();
  } catch (e) {
    throw Exception('클래스 탈퇴에 실패했습니다: $e');
  }
}

  Future<void> deleteClass(String classId) async {
    try {
      // 멤버 전체 삭제
      final membersRef = _firestore.collection('classes').doc(classId).collection('members');
      final members = await membersRef.get();
      for (var doc in members.docs) {
        await doc.reference.delete();
      }
      // 클래스 문서 삭제
      await _firestore.collection('classes').doc(classId).delete();
    } catch (e) {
      throw Exception('클래스를 삭제하지 못했습니다: $e');
    }
  }

  // 챌린지 승인 처리 (트랜잭션 이용)
  Future<bool> approveChallenge(String challengeId) async {
    final challengeRef = _firestore
        .collection('class_challenges')
        .doc(challengeId);
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot challengeSnap = await transaction.get(challengeRef);
        if (!challengeSnap.exists) throw Exception('챌린지 없음');
        Map<String, dynamic> challengeData =
            challengeSnap.data() as Map<String, dynamic>;
        if (challengeData['status'] == 'approved') throw Exception('이미 승인됨');

        String classId = challengeData['classId'];
        int classExpReward = challengeData['expReward'] ?? 50;
        int memberPointReward = challengeData['pointReward'] ?? 10;

        DocumentReference classRef = _firestore
            .collection('classes')
            .doc(classId);
        DocumentSnapshot classSnap = await transaction.get(classRef);
        if (!classSnap.exists) throw Exception('클래스 없음');
        Map<String, dynamic> classData =
            classSnap.data() as Map<String, dynamic>;
        int currentLevel = classData['level'] ?? 1;
        int currentExp = classData['exp'] ?? 0;

        // 클래스 경험치 및 레벨 계산
        int newExp = currentExp + classExpReward;
        int newLevel = currentLevel;
        int threshold = currentLevel * 100;
        if (newExp >= threshold) {
          newLevel += 1;
          newExp = newExp - threshold;
        }
        transaction.update(classRef, {'exp': newExp, 'level': newLevel});

        // 멤버들 점수 업데이트
        CollectionReference membersRef = classRef.collection('members');
        QuerySnapshot membersSnap = await membersRef.get();
        for (DocumentSnapshot memberDoc in membersSnap.docs) {
          DocumentReference memberRef = memberDoc.reference;
          int currentScore =
              (memberDoc.data() as Map<String, dynamic>)['score'] ?? 0;
          int updatedScore = currentScore + memberPointReward;
          transaction.update(memberRef, {
            'score': updatedScore,
            // 'rank': ... 필요 시 개인 랭크 업데이트
          });
        }

        // 챌린지 상태 갱신
        transaction.update(challengeRef, {
          'status': 'approved',
          'approvedBy': currentUserId,
          'approvedAt': Timestamp.now(),
        });
      });
      return true;
    } catch (e) {
      print('approveChallenge error: $e');
      return false;
    }
  }
}

class Member {
  final String userId;
  final String userName;
  final int score;

  Member({required this.userId, required this.userName, required this.score});

  factory Member.fromDocument(String docId, Map<String, dynamic> data) {
    return Member(
      userId: docId,
      userName: data['userName'] ?? '',
      score: data['score'] ?? 0,
    );
  }
}

// 데이터 모델 정의
class ClassModel {
  final String id;
  final String logoUrl;
  final String name;
  final String description;
  final int level;
  final int exp;
  final String openChatUrl;
  final String leaderId; // 클래스장의 사용자 ID

  ClassModel({
    required this.id,
    required this.logoUrl,
    required this.name,
    required this.description,
    required this.level,
    required this.exp,
    required this.openChatUrl,
    required this.leaderId,
  });


    // Firestore 문서로부터 ClassModel 생성
  factory ClassModel.fromMap(String id, Map<String, dynamic> data) {
    return ClassModel(
      id: id,
      logoUrl: data['logoUrl'] ?? '',  // 기본값 처리
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      level: data['level'] ?? 1,
      exp: data['exp'] ?? 0,
      openChatUrl: data['openChatUrl'] ?? '',
      leaderId: data['leaderId'] ?? '',  // 클래스장의 ID 필드
    );
  }

  // Firestore 문서로부터 ClassModel 생성 (필요에 따라 수정)
  factory ClassModel.fromDocument(String docId, Map<String, dynamic> data) {
    return ClassModel(
      id: docId,
      logoUrl: data['logoUrl'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      level: data['level'] ?? 1,
      exp: data['exp'] ?? 0,
      openChatUrl: data['openChatUrl'] ?? '',
      leaderId: data['leaderId'] ?? '', // 클래스장의 ID 필드
    );
  }
}

/// 클래스 생성 페이지 (위에 이미 ClassProvider와 CreateClassPage 구현되어 있음)
/// -- 생략 (위 코드에서 CreateClassPage 클래스 참조) --

/// 클래스 상세 페이지 (위 UI 예시 코드 ClassDetailPage 구현)
/// -- 위에서 ClassDetailPage StatelessWidget 예시를 이미 제공하였음 --
