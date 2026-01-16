class LinkModel {
  final String name;
  final String link;

  const LinkModel({required this.name, required this.link});

  factory LinkModel.fromJson(Map<String, dynamic> json) => LinkModel(
        name: json['name'] as String,
        link: json['link'] as String,
      );

  Map<String, dynamic> toJson() => {'name': name, 'link': link};
}
