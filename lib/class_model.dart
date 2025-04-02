class ClassModel {
  String id;
  String name;
  String intro;
  String logoUrl;
  String openChatLink;
  String grade;   // 등급 (Bronze/Silver/Gold...)
  int xp;         // 누적 경험치
  String ownerId;
  List<String> members;

  ClassModel({
    required this.id,
    required this.name,
    required this.intro,
    required this.logoUrl,
    required this.openChatLink,
    required this.grade,
    required this.xp,
    required this.ownerId,
    required this.members,
  });

  // Firestore 문서로부터 ClassModel 생성
  factory ClassModel.fromMap(String id, Map<String, dynamic> data) {
    return ClassModel(
      id: id,
      name: data['name'] ?? '',
      intro: data['intro'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
      openChatLink: data['openChatLink'] ?? '',
      grade: data['grade'] ?? 'Bronze',
      xp: data['xp'] ?? 0,
      ownerId: data['ownerId'] ?? '',
      members: List<String>.from(data['members'] ?? []),
    );
  }

  // Firestore 저장용 맵 변환
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'intro': intro,
      'logoUrl': logoUrl,
      'openChatLink': openChatLink,
      'grade': grade,
      'xp': xp,
      'ownerId': ownerId,
      'members': members,
    };
  }
}
