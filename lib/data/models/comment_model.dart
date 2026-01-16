class CommentModel {
  final String id;
  final String userId;
  final String itemId;
  final String commentText;
  final DateTime createdAt;
  final String? authorName;

  const CommentModel({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.commentText,
    required this.createdAt,
    this.authorName,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final user = json['users'] as Map<String, dynamic>? ??
        json['user'] as Map<String, dynamic>?;
    return CommentModel(
      id: json['id'] as String,
      userId: json['user_id'] ?? '',
      itemId: json['item_id'] ?? '',
      commentText: json['comment_text'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      authorName: user?['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'item_id': itemId,
      'comment_text': commentText,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
