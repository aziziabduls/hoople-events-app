class EventModel {
  final int id;
  final int userId;
  final String category;
  final String name;
  final String tagline;
  final String description;
  late String? announcement;
  final String imageUrl;
  final String location;
  final Map<String, dynamic> locationDetails;
  final DateTime startDate;
  final DateTime endDate;
  final String timezone;
  final bool isFree;
  late bool isFollowing;
  late bool isHosting;
  final double price;
  final int participantCapacity;
  final List<String> availableLanguages;

  EventModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.name,
    required this.tagline,
    required this.description,
    this.announcement,
    required this.imageUrl,
    required this.location,
    required this.locationDetails,
    required this.startDate,
    required this.endDate,
    required this.timezone,
    required this.isFree,
    required this.isFollowing,
    required this.isHosting,
    required this.price,
    required this.participantCapacity,
    required this.availableLanguages,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      category: json['category'] ?? 'event',
      name: json['name'] ?? '',
      tagline: json['tagline'] ?? '',
      description: json['description'] ?? '',
      announcement: json['announcement'],
      imageUrl: json['image_url'] ?? '',
      location: json['location'] ?? '',
      locationDetails: json['location_details'] ?? {},
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
      timezone: json['timezone'] ?? '',
      isFree: json['is_free'] ?? true,
      isFollowing: json['is_following'] ?? false,
      isHosting: json['is_hosting'] ?? false,
      price: (json['price'] ?? 0).toDouble(),
      participantCapacity: json['participant_capacity'] ?? 0,
      availableLanguages:
          (json['available_languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category': category,
      'name': name,
      'tagline': tagline,
      'description': description,
      'announcement': announcement,
      'image_url': imageUrl,
      'location': location,
      'location_details': locationDetails,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'timezone': timezone,
      'is_free': isFree,
      'is_following': isFollowing,
      'is_hosting': isHosting,
      'price': price,
      'participant_capacity': participantCapacity,
      'available_languages': availableLanguages,
    };
  }
}
