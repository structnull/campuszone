class EventModel {
  final String id;
  final String title;
  final String? description;
  final String? date; // Legacy: e.g. "12th Oct"
  final String? time; // Legacy: e.g. "10:00 AM"
  final String? location;
  final String? registerUrl;
  final List<String> organizers;
  final List<String> tags;
  final DateTime? createdAt; // might be missing in legacy

  const EventModel({
    required this.id,
    required this.title,
    this.description,
    this.date,
    this.time,
    this.location,
    this.registerUrl,
    this.organizers = const [],
    this.tags = const [],
    this.createdAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id: json['id'].toString(),
        title: json['title'] as String,
        description: json['description'] as String?,
        date: json['date'] as String?,
        time: json['time'] as String?,
        location: json['location'] as String?,
        registerUrl: json['register_url'] as String?,
        organizers: (json['organizers'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        tags: (json['tags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'date': date,
        'time': time,
        'location': location,
        'register_url': registerUrl,
        'organizers': organizers,
        'tags': tags,
      };
}
