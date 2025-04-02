import 'package:flutter/material.dart';
import 'package:myapp/providers/class_provider.dart';
import 'package:myapp/screens/class/class_detail_screen.dart';
import 'package:myapp/screens/class/classcreatescreen.dart';
import 'package:provider/provider.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({Key? key}) : super(key: key);

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);
    final classes = classProvider.classes;
    final _isLoading = classProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TEAM'),
        backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      ),
      backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : (classes.isEmpty
                  ? const Center(
                    child: Text(
                      '현재 참여 가능한 클래스가 없습니다.',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      final classInfo = classes[index];
                      return Card(
                        //color: Theme.of(context).cardColor,
                        color: Colors.black,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                (classInfo.logoUrl.isNotEmpty)
                                    ? NetworkImage(classInfo.logoUrl)
                                    : const AssetImage(
                                          'assets/images/default_logo.png',
                                        )
                                        as ImageProvider,
                            backgroundColor: Colors.grey[800],
                          ),
                          title: Text(
                            classInfo.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  classInfo.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Level: ${classInfo.level}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.white70,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        ClassDetailPage(classId: classInfo.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateClassPage()),
          );
        },
        shape: const CircleBorder(),
        tooltip: 'Create Class',
        heroTag: 'Create Class',
        child: const Icon(Icons.add),
      ),
    );
  }
}
