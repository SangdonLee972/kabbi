import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  PostDetailScreen({required this.post});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 게시글 상세 진입 시 조회수 증가
    Provider.of<CommunityProvider>(
      context,
      listen: false,
    ).incrementViews(widget.post.id);
  }

  Future<void> _addComment() async {
    String content = _commentCtrl.text.trim();
    if (content.isEmpty) return;
    String? error = await Provider.of<CommunityProvider>(
      context,
      listen: false,
    ).addComment(widget.post.id, content);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $error")));
    } else {
      _commentCtrl.clear();
    }
  }

  Future<void> _deletePost() async {
    // 삭제 권한: 글 작성자 본인 또는 관리자만 삭제 가능
    bool canDelete =
        (AuthProvider.currentUserId == widget.post.authorId) ||
        (AuthProvider.currentRole == 'admin');
    if (!canDelete) return;

    String? error = await Provider.of<CommunityProvider>(
      context,
      listen: false,
    ).deletePost(widget.post.id);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $error")));
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("게시글이 삭제되었습니다.")));
    }
  }

  // 첨부 미디어 미리보기 (가로 스크롤)
  Widget _buildMediaPreview() {
    if (widget.post.mediaUrls.isEmpty) return SizedBox.shrink();
    return Container(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.post.mediaUrls.length,
        itemBuilder: (context, index) {
          String url = widget.post.mediaUrls[index];
          // 영상은 간단히 아이콘 표시, 이미지면 미리보기
          if (url.endsWith('.mp4') || url.endsWith('.mov')) {
            return Container(
              width: 150,
              margin: EdgeInsets.only(right: 8),
              color: Colors.black26,
              child: Center(
                child: Icon(Icons.videocam, size: 50, color: Colors.cyanAccent),
              ),
            );
          } else {
            return Container(
              width: 150,
              margin: EdgeInsets.only(right: 8),
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) =>
                        Center(child: CircularProgressIndicator()),
                errorWidget:
                    (context, url, error) =>
                        Icon(Icons.error, color: Colors.redAccent),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = AuthProvider.currentRole == 'admin';
    bool isAuthor = AuthProvider.currentUserId == widget.post.authorId;
    return Scaffold(
      appBar: AppBar(
        title: Text("게시글"),
        actions: [
          if (isAdmin || isAuthor)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deletePost,
              tooltip: "게시글 삭제",
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.post.title,
              style: TextStyle(
                fontSize: 20,
                color: Colors.cyanAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "by ${widget.post.authorName}",
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 8),
            Text(
              "조회수: ${widget.post.views + 1}",
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 12),
            _buildMediaPreview(),
            SizedBox(height: 12),
            Text(
              widget.post.content,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            Divider(color: Colors.white54, height: 32),
            Text(
              "댓글",
              style: TextStyle(fontSize: 16, color: Colors.cyanAccent),
            ),
            SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('posts')
                        .doc(widget.post.id)
                        .collection('comments')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final comments = snapshot.data!.docs;
                  if (comments.isEmpty) {
                    return Center(
                      child: Text(
                        "댓글이 없습니다.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final data =
                          comments[index].data() as Map<String, dynamic>;
                      String author = data['authorName'] ?? 'User';
                      String content = data['content'] ?? '';
                      return ListTile(
                        title: Text(
                          author,
                          style: TextStyle(color: Colors.cyanAccent),
                        ),
                        subtitle: Text(
                          content,
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentCtrl,
                    decoration: InputDecoration(labelText: "댓글 입력"),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.cyanAccent),
                  onPressed: _addComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
