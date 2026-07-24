class UserModel {
  final String fullName;
  final String userName;
  final String imageUrl;
  final int followers;
  final int following;
  final int postCount;
  final int eventCount;

  UserModel({
    required this.fullName,
    required this.userName,
    required this.imageUrl,
    required this.followers,
    required this.following,
    required this.postCount,
    required this.eventCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['full_name'] ?? '',
      userName: json['user_name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      postCount: json['post'] ?? 0,
      eventCount: json['events'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'user_name': userName,
      'image_url': imageUrl,
      'followers': followers,
      'following': following,
      'post': postCount,
      'events': eventCount,
    };
  }
}
