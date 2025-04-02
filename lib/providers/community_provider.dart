import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../providers/auth_provider.dart';

class Post {
  String id;
  String title;
  String content;
  String category;
  String authorName;
  String authorId;
  Timestamp timestamp;
  List<dynamic> mediaUrls; // 이미지/영상 URL 리스트
  int views;
  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.authorName,
    required this.authorId,
    required this.timestamp,
    required this.mediaUrls,
    required this.views,
  });
  factory Post.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      category: data['category'] ?? 'General',
      authorName: data['authorName'] ?? '',
      authorId: data['authorId'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      mediaUrls: data['mediaUrls'] ?? [],
      views: data['views'] ?? 0,
    );
  }
}

class CommunityProvider extends ChangeNotifier {
  List<String> categories = ["General", "QnA", "Notice"];
  String _selectedCategory = "General";
  List<Post> _posts = [];
  StreamSubscription? _postSub;

  String get selectedCategory => _selectedCategory;
  List<Post> get posts => _posts;

  CommunityProvider() {
    try {
      _postSub = FirebaseFirestore.instance
          .collection('posts')
          .where('category', isEqualTo: _selectedCategory)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
            _posts =
                snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
            notifyListeners();
          });
    } catch (e) {
      print(e);
    }
  }

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    print(_selectedCategory);
    _postSub?.cancel();
    try {
      _postSub = FirebaseFirestore.instance
          .collection('posts')
          .where('category', isEqualTo: category)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
            _posts =
                snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
            notifyListeners();
          });
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  // 글 작성: mediaUrls (첨부 미디어 URL 리스트)를 함께 저장하며 조회수는 0으로 초기화.
  Future<String?> createPost(
    String category,
    String title,
    String content, {
    List<String>? mediaUrls,
  }) async {
    if (AuthProvider.currentUserId == null ||
        AuthProvider.currentNickname == null) {
      return "Not authenticated";
    }
    try {
      await FirebaseFirestore.instance.collection('posts').add({
        'category': category,
        'title': title,
        'content': content,
        'mediaUrls': mediaUrls ?? [],
        'views': 0,
        'authorId': AuthProvider.currentUserId,
        'authorName': AuthProvider.currentNickname,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deletePost(String postId) async {
    try {
      DocumentReference postRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(postId);
      QuerySnapshot commentsSnap = await postRef.collection('comments').get();
      for (var doc in commentsSnap.docs) {
        await doc.reference.delete();
      }
      await postRef.delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> addComment(String postId, String content) async {
    if (AuthProvider.currentUserId == null ||
        AuthProvider.currentNickname == null) {
      return "Not authenticated";
    }
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
            'content': content,
            'authorId': AuthProvider.currentUserId,
            'authorName': AuthProvider.currentNickname,
            'timestamp': FieldValue.serverTimestamp(),
          });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // 게시글 상세 진입 시 조회수 증가
  Future<void> incrementViews(String postId) async {
    await FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'views': FieldValue.increment(1),
    });
  }

  @override
  void dispose() {
    _postSub?.cancel();
    super.dispose();
  }
}
