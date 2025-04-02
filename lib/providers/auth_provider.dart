import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _nickname;
  String? _role;
  String? _rank;

  // 다른 Provider에서 접근할 수 있도록 static으로 현재 사용자 정보 유지
  static String? currentUserId;
  static String? currentNickname;
  static String? currentRole;
  static String? currentRank;

  AuthProvider() {
    // Firebase Auth 로그인 상태 변화 리스너
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      _user = firebaseUser;
      if (_user != null) {
        currentUserId = _user!.uid;
        // Firestore에서 사용자 정보 가져오기
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(_user!.uid)
                .get();
        if (userDoc.exists) {
          _nickname = userDoc['nickname'];
          _role = userDoc['role'];
          _rank = userDoc['rank'];
        } else {
          _nickname = null;
          _role = null;
          _rank = null;
        }
        currentNickname = _nickname;
        currentRole = _role;
        currentRank = _rank;
      } else {
        _nickname = null;
        _role = null;
        _rank = null;
        currentUserId = null;
        currentNickname = null;
        currentRole = null;
        currentRank = null;
      }
      notifyListeners();
    });
  }

  User? get user => _user;
  String? get nickname => _nickname;
  String? get role => _role;
  String? get rank => _rank;
  bool get isAuthenticated => _user != null;

  Future<String?> signUp(String email, String password, String nickname) async {
    try {
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      User newUser = cred.user!;
      // Firestore에 신규 유저 정보 저장
      await FirebaseFirestore.instance.collection('users').doc(newUser.uid).set(
        {
          'nickname': nickname,
          'role': 'user',
          'completedCount': 0,
          'rank': 'Bronze',
          'email' : email
        },
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    // 상태 변화 리스너가 _user 등을 null로 처리함
  }
}
