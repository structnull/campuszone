enum PostType { lost, found }

class PostModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final PostType type;
  final String? imageUrl;
  final DateTime createdAt;
  final String? authorName;
  final String? location; // Added location as per lost_and_found.dart usage

  const PostModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    this.imageUrl,
    required this.createdAt,
    this.authorName,
    this.location,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return PostModel(
      id: json['id'] as String? ??
          json['item_id'].toString(), // Handle item_id from legacy schema
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: json['type'] == 'lost' ? PostType.lost : PostType.found,
      imageUrl: json['image_url'] as String? ??
          json['image_path'] as String?, // Handle image_path
      createdAt: DateTime.parse(json['created_at'] as String),
      authorName: user?['name'] as String? ?? json['author_name'] as String?,
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'title': title,
        'description': description,
        'type': type == PostType.lost ? 'lost' : 'found',
        'image_path':
            imageUrl, // Mapping back to image_path for legacy compatibility if needed
        'location': location,
      };
}
