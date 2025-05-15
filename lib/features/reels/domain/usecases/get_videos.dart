import '../entities/video.dart';
import '../repositories/video_repository.dart';

class GetVideos {
  final VideoRepository repository;

  GetVideos(this.repository);

  Future<List<Video>> call() async {
    return await repository.getVideos();
  }
}
