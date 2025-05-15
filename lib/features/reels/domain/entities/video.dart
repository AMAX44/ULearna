class Video {
  final int id;
  final String title;
  final String videoUrl;
  final String thumbnailUrl;
  final String? userName;

  Video({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.userName,
  });
}
