class NoteModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String fileUrl;
  final String? subject;
  final String? semester;
  final DateTime createdAt;
  final String? authorName;

  const NoteModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.fileUrl,
    this.subject,
    this.semester,
    required this.createdAt,
    this.authorName,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return NoteModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      fileUrl: json['file_path'] as String,
      subject: json['subject'] as String?,
      semester: json['semester'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      authorName: user?['name'] as String? ?? json['author_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'description': description,
        'file_path': fileUrl,
        'subject': subject,
        'semester': semester,
        'created_at': createdAt.toIso8601String(),
      };

  NoteModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? fileUrl,
    String? subject,
    String? semester,
    DateTime? createdAt,
    String? authorName,
  }) =>
      NoteModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        description: description ?? this.description,
        fileUrl: fileUrl ?? this.fileUrl,
        subject: subject ?? this.subject,
        semester: semester ?? this.semester,
        createdAt: createdAt ?? this.createdAt,
        authorName: authorName ?? this.authorName,
      );
}
