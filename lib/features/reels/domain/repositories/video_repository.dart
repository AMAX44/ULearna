import 'package:reel_app/features/reels/domain/entities/video.dart';

abstract class VideoRepository {
  Future<List<Video>> getVideos();
}
