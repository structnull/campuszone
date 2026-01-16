class LostAndFoundModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String imagePath;
  final DateTime createdAt;
  final String? authorName;

  const LostAndFoundModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.createdAt,
    this.authorName,
  });

  factory LostAndFoundModel.fromJson(Map<String, dynamic> json) {
    // Handle nested user data if available (Supabase join)
    final user = json['users'] as Map<String, dynamic>? ??
        json['user'] as Map<String, dynamic>?;

    return LostAndFoundModel(
      id: json['item_id'] ?? '',
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imagePath: json['image_path'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      authorName: user?['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
