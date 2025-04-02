import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/challenge_provider.dart';

class ChallengeProofScreen extends StatefulWidget {
  final String challengeId;
  final String challengeTitle;
  ChallengeProofScreen({required this.challengeId, required this.challengeTitle});

  @override
  _ChallengeProofScreenState createState() => _ChallengeProofScreenState();
}
class _ChallengeProofScreenState extends State<ChallengeProofScreen> {
  final _textCtrl = TextEditingController();
  File? _mediaFile;
  bool _isVideo = false;
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _mediaFile = File(picked.path);
        _isVideo = false;
      });
    }
  }

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _mediaFile = File(picked.path);
        _isVideo = true;
      });
    }
  }

  Future<void> _submitProof() async {
    if (_mediaFile == null && _textCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("사진/영상 또는 텍스트를 입력하세요.")));
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    String? error = await Provider.of<ChallengeProvider>(context, listen: false).uploadProof(
      widget.challengeId,
      widget.challengeTitle,
      text: _textCtrl.text.trim(),
      filePath: _mediaFile?.path,
      isVideo: _isVideo,
    );
    setState(() {
      _isSubmitting = false;
    });
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $error")));
    } else {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("챌린지 인증", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_mediaFile != null)
              _isVideo
                  ? Icon(Icons.videocam, size: 80, color: Colors.cyanAccent)
                  : Image.file(_mediaFile!, height: 150),
            if (_mediaFile != null) SizedBox(height: 10),
            TextField(
              controller: _textCtrl,
              decoration: InputDecoration(
                labelText: "인증 내용 (텍스트)",
                filled: true,
                fillColor: Colors.black,
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.image, color: Colors.cyanAccent),
                  label: Text("사진 선택", style: TextStyle(color: Colors.cyanAccent)),
                  onPressed: _pickImage,
                ),
                TextButton.icon(
                  icon: Icon(Icons.videocam, color: Colors.cyanAccent),
                  label: Text("영상 선택", style: TextStyle(color: Colors.cyanAccent)),
                  onPressed: _pickVideo,
                ),
              ],
            ),
            SizedBox(height: 20),
            _isSubmitting
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitProof,
                    child: Text("인증 제출"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
                  ),
          ],
        ),
      ),
    );
  }
}
