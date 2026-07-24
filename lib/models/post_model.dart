class PostModel {
  final int id;
  final int userId;
  final String imageUrl;
  final String caption;
  final int likes;
  final int comments;
  final int shares;

  PostModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.caption,
    required this.likes,
    required this.comments,
    required this.shares,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      imageUrl: json['image_url'] ?? '',
      caption: json['caption'] ?? '',
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'image_url': imageUrl,
      'caption': caption,
      'likes': likes,
      'comments': comments,
      'shares': shares,
    };
  }
}
