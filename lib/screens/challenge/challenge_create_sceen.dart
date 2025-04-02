import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:myapp/providers/challenge_provider.dart';
import 'package:provider/provider.dart';

class CreateChallengePage extends StatefulWidget {
  @override
  _CreateChallengePageState createState() => _CreateChallengePageState();
}

class _CreateChallengePageState extends State<CreateChallengePage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final now = DateTime.now();
      final fileName = 'challenge_${now.microsecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child(
        'challenge_logos/$fileName',
      );
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> _submitChallenge(BuildContext context) async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedImage == null ||
        _endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('모든 항목을 입력해주세요.')));
      return;
    }

    if (!_endDate!.isAfter(_startDate!)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('종료 날짜는 시작 날짜보다 늦어야 합니다.')));
      return;
    }

    final logoUrl = await _uploadImage(_selectedImage!);
    if (logoUrl == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('이미지 업로드 실패')));
      return;
    }

    final challengeProvider = Provider.of<ChallengeProvider>(
      context,
      listen: false,
    );
    final result = await challengeProvider.createChallenge(
      title: _titleController.text,
      description: _descriptionController.text,
      logoUrl: logoUrl,
      endTime: Timestamp.fromDate(_endDate!),
    );

    if (result == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('챌린지 생성 완료!')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('에러: $result')));
    }
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initialDate =
        isStart
            ? (_startDate ?? now)
            : (_endDate ??
                (_startDate != null
                    ? _startDate!.add(Duration(days: 1))
                    : now.add(Duration(days: 1))));

    final firstDate =
        isStart
            ? now
            : _startDate != null
            ? _startDate!.add(Duration(days: 1))
            : now.add(Duration(days: 1));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;

          // 종료 날짜가 설정되어 있고, 시작 날짜보다 같거나 이전이면 → 자동 조정
          if (_endDate != null && !_endDate!.isAfter(_startDate!)) {
            _endDate = _startDate!.add(Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("챌린지 생성")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 이미지 업로드 영역
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(12),
                    image:
                        _selectedImage != null
                            ? DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                  alignment: Alignment.center,
                  child:
                      _selectedImage == null
                          ? Text(
                            "이미지를 삽입해주세요",
                            style: TextStyle(color: Colors.white),
                          )
                          : null,
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.image, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            // 챌린지명
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "챌린지명",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // 챌린지 설명
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "챌린지 설명",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // 날짜 선택
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _pickDate(isStart: true),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: '시작 날짜',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _startDate != null
                            ? DateFormat('yyyy-MM-dd').format(_startDate!)
                            : '날짜 선택',
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap:
                        _startDate == null
                            ? null
                            : () => _pickDate(isStart: false),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: '종료 날짜',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                _startDate == null ? Colors.grey : Colors.white,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                _startDate == null ? Colors.grey : Colors.white,
                          ),
                        ),
                      ),
                      child: Text(
                        _endDate != null
                            ? DateFormat('yyyy-MM-dd').format(_endDate!)
                            : ('날짜 선택'),
                        style: TextStyle(
                          color: _startDate == null ? Colors.grey : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // 여기에 생성 로직 넣기
                _submitChallenge(context);
              },
              style: ElevatedButton.styleFrom(minimumSize: Size(400, 60)),
              child: Text("챌린지 생성하기"),
            ),
          ],
        ),
      ),
    );
  }
}
