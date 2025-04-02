import 'package:flutter/material.dart';
import 'package:myapp/screens/community/post_create_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/community_provider.dart';
import 'post_detail_screen.dart';
import 'package:intl/intl.dart'; // 날짜 포맷용

class CommunityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("커뮤니티")),
      body: Consumer<CommunityProvider>(
        builder: (context, communityProv, _) {
          return Column(
            children: [
              // 카테고리 선택 Chip
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Wrap(
                  spacing: 8,
                  children: communityProv.categories.map((cat) {
                    bool selected = (cat == communityProv.selectedCategory);
                    return ChoiceChip(
                      label: Text(cat),
                      selected: selected,
                      selectedColor: Colors.cyanAccent,
                      labelStyle: TextStyle(
                        color: selected ? Colors.black : Colors.white70,
                      ),
                      onSelected: (sel) {
                        if (sel) {
                          communityProv.setCategory(cat);
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
              Divider(color: Colors.white12, height: 1),
              Expanded(
                child: communityProv.posts.isEmpty
                    ? Center(
                        child: Text(
                          "해당 카테고리에 게시글이 없습니다.",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        itemCount: communityProv.posts.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.white12,
                          height: 1,
                          thickness: 0.5,
                        ),
                        itemBuilder: (context, index) {
                          final post = communityProv.posts[index];
                          final formattedDate = DateFormat('yyyy-MM-dd HH:mm')
                              .format(post.timestamp.toDate());

                          return ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            title: Text(
                              post.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                children: [
                                  Text(
                                    post.authorName,
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    "조회수 ${post.views}",
                                    style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PostDetailScreen(post: post),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PostCreateScreen()),
          );
        },
        shape: const CircleBorder(),
        tooltip: "새 게시물 작성",
        heroTag: 'Create Post',
        child: Icon(Icons.edit),
      ),
    );
  }
}
