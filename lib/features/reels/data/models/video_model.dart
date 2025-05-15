class VideoModel {
  final int id;
  final String title;
  final String videoUrl;
  final String thumbnailUrl;
  final String? description;
  final int duration;
  final String? location;
  final String orientation;
  final String language;
  final String? aspectRatio;
  final String? categoryTitle;
  final String? userName;
  final String? userProfilePic;

  VideoModel({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.description,
    required this.duration,
    this.location,
    required this.orientation,
    required this.language,
    this.aspectRatio,
    this.categoryTitle,
    this.userName,
    this.userProfilePic,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'],
      title: json['title'],
      videoUrl: json['cdn_url'],
      thumbnailUrl: json['thumb_cdn_url'],
      description: json['description'],
      duration: json['duration'],
      location: json['location'],
      orientation: json['orientation'],
      language: json['language'],
      aspectRatio: json['video_aspect_ratio'],
      categoryTitle: json['category']?['title'],
      userName: json['user']?['fullname'],
      userProfilePic: json['user']?['profile_picture_cdn'],
    );
  }
}
