import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/providers/class_provider.dart';
import 'package:provider/provider.dart';

/// 클래스 생성 화면 위젯
class CreateClassPage extends StatefulWidget {
  const CreateClassPage({Key? key}) : super(key: key);

  @override
  _CreateClassPageState createState() => _CreateClassPageState();
}

class _CreateClassPageState extends State<CreateClassPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  String _openChatUrl = '';
  XFile? _selectedImage; // 선택된 로고 이미지 파일 (ImagePicker의 XFile 사용)

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyLarge?.copyWith(color: Colors.white);
    final classProvider = Provider.of<ClassProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('새 클래스 만들기', style: TextStyle(fontSize: 22)),
        backgroundColor: const Color(0xFF141414),
      ),
      backgroundColor: const Color(0xFF141414),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // 로고 업로드 섹션
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[700],
                    backgroundImage:
                        _selectedImage != null
                            ? FileImage(File(_selectedImage!.path))
                            : AssetImage('assets/images/default_logo.png')
                                as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          setState(() {
                            _selectedImage = image;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 클래스 이름
            _buildInputField(
              label: '클래스 이름',
              onSaved: (value) => _name = value ?? '',
              validator:
                  (value) =>
                      value == null || value.isEmpty ? '클래스 이름을 입력하세요.' : null,
              textStyle: textStyle,
            ),
            const SizedBox(height: 12),

            // 클래스 소개
            _buildInputField(
              label: '클래스 소개',
              maxLines: 3,
              onSaved: (value) => _description = value ?? '',
              textStyle: textStyle,
            ),
            const SizedBox(height: 12),

            // 오픈채팅 링크
            _buildInputField(
              label: '카카오톡 오픈채팅 링크 (필수)',
              onSaved: (value) => _openChatUrl = value ?? '',
              validator:
                  (value) =>
                      value == null || value.isEmpty ? '오픈채팅 링크를 입력하세요.' : null,
              textStyle: textStyle,
            ),
            const SizedBox(height: 24),

            // 클래스 생성 버튼
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final error = await classProvider.createClass(
                    name: _name,
                    description: _description,
                    logoImage: _selectedImage,
                    openChatUrl: _openChatUrl,
                  );
                  if (error != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(error)));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('클래스가 성공적으로 생성되었습니다!')),
                    );
                    Navigator.pop(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '클래스 만들기',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
    TextStyle? textStyle,
    int maxLines = 1,
  }) {
    return TextFormField(
      style: textStyle,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: const Color(0xFF141414),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[500]!),
        ),
        border: OutlineInputBorder(),
      ),
      maxLines: maxLines,
      validator: validator,
      onSaved: onSaved,
    );
  }
}
