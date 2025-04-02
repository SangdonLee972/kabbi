import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/community_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PostCreateScreen extends StatefulWidget {
  @override
  _PostCreateScreenState createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<PostCreateScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = "General";
  List<String> _categories = ["General", "QnA", "Notice"];
  List<File> _mediaFiles = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  Future<void> _pickMedia(ImageSource source, {bool isVideo = false}) async {
    // 단일 파일 선택; 필요시 multi_image_picker 등으로 확장 가능
    final picked =
        isVideo
            ? await _picker.pickVideo(source: source)
            : await _picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _mediaFiles.add(File(picked.path));
      });
    }
  }

  // Firebase Storage에 파일 업로드 후 다운로드 URL 반환
  Future<String> _uploadFile(File file) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance.ref().child(
      'post_media/$fileName',
    );
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _submitPost() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("제목과 내용을 입력해주세요.")));
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    List<String> mediaUrls = [];
    // 모든 미디어 파일 업로드
    for (File file in _mediaFiles) {
      try {
        String url = await _uploadFile(file);
        mediaUrls.add(url);
      } catch (e) {
        print("Upload error: $e");
      }
    }
    String? error = await Provider.of<CommunityProvider>(
      context,
      listen: false,
    ).createPost(
      _selectedCategory,
      _titleController.text.trim(),
      _contentController.text.trim(),
      mediaUrls: mediaUrls,
    );
    setState(() {
      _isSubmitting = false;
    });
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $error")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("게시글이 등록되었습니다.")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 작성자 정보는 AuthProvider에서 자동으로 사용
    return Scaffold(
      appBar: AppBar(title: Text("게시글 작성")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 선택 Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(labelText: "카테고리"),
              items:
                  _categories
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedCategory = val;
                  });
                }
              },
            ),
            SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "제목"),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: "내용"),
              maxLines: 5,
            ),
            SizedBox(height: 12),
            Text(
              "첨부 미디어 (사진/영상)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            // 미리보기 영역
            _mediaFiles.isEmpty
                ? Text("첨부된 파일이 없습니다.")
                : Container(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _mediaFiles.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(right: 8),
                        child: Image.file(
                          _mediaFiles[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.image),
                  label: Text("사진"),
                  onPressed: () => _pickMedia(ImageSource.gallery),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.videocam),
                  label: Text("영상"),
                  onPressed:
                      () => _pickMedia(ImageSource.gallery, isVideo: true),
                ),
              ],
            ),
            SizedBox(height: 20),
            _isSubmitting
                ? Center(child: CircularProgressIndicator())
                : Center(
                  child: ElevatedButton(
                    onPressed: _submitPost,
                    child: Text("등록"),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
