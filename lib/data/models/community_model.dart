class CommunityModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? url;
  final String? membersCount;

  const CommunityModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.url,
    this.membersCount,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) => CommunityModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        imageUrl: json['image_url'] as String?,
        url: json['url'] as String?,
        membersCount: json['member_c'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'image_url': imageUrl,
        'url': url,
        'member_c': membersCount,
      };

  CommunityModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? url,
    String? membersCount,
  }) =>
      CommunityModel(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        imageUrl: imageUrl ?? this.imageUrl,
        url: url ?? this.url,
        membersCount: membersCount ?? this.membersCount,
      );
}
