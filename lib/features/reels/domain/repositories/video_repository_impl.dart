import 'package:reel_app/features/reels/data/datasources/video_remote_data_source.dart';
import 'package:reel_app/features/reels/domain/entities/video.dart';

import '../../domain/repositories/video_repository.dart';

class VideoRepositoryImpl implements VideoRepository {
  final VideoRemoteDataSource remoteDataSource;

  VideoRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Video>> getVideos() async {
    final models = await remoteDataSource.getVideos();
    return models
        .map(
          (model) => Video(
            id: model.id,
            title: model.title,
            videoUrl: model.videoUrl,
            thumbnailUrl: model.thumbnailUrl,
            userName: model.userName,
          ),
        )
        .toList();
  }
}
