class UserModel {
  final String id;
  final String name;
  final String email;
  final String? collegeId;
  final String? bio;
  final String? profilePicPath;
  final DateTime createdAt;
  final SocialsModel? socials;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.collegeId,
    this.bio,
    this.profilePicPath,
    required this.createdAt,
    this.socials,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        collegeId: json['collegeid'] as String?,
        bio: json['bio'] as String?,
        profilePicPath: json['profile_pic_path'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        socials: _parseSocials(json['socials']),
      );

  static SocialsModel? _parseSocials(dynamic data) {
    if (data == null) return null;
    if (data is List && data.isNotEmpty) {
      return SocialsModel.fromJson(data.first as Map<String, dynamic>);
    }
    if (data is Map<String, dynamic>) {
      return SocialsModel.fromJson(data);
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'collegeid': collegeId,
        'bio': bio,
        'profile_pic_path': profilePicPath,
        'created_at': createdAt.toIso8601String(),
      };

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? collegeId,
    String? bio,
    String? profilePicPath,
    DateTime? createdAt,
    SocialsModel? socials,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        collegeId: collegeId ?? this.collegeId,
        bio: bio ?? this.bio,
        profilePicPath: profilePicPath ?? this.profilePicPath,
        createdAt: createdAt ?? this.createdAt,
        socials: socials ?? this.socials,
      );
}

class SocialsModel {
  final String? linkedin;
  final String? twitter;
  final String? instagram;

  const SocialsModel({this.linkedin, this.twitter, this.instagram});

  factory SocialsModel.fromJson(Map<String, dynamic> json) => SocialsModel(
        linkedin: json['linkedin'] as String?,
        twitter: json['twitter'] as String?,
        instagram: json['instagram'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'linkedin': linkedin,
        'twitter': twitter,
        'instagram': instagram,
      };
}
