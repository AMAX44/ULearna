import 'package:flutter_bloc/flutter_bloc.dart';
import 'video_event.dart';
import 'video_state.dart';
import '../../domain/usecases/get_videos.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final GetVideos getVideos;

  VideoBloc(this.getVideos) : super(VideoInitial()) {
    on<LoadVideos>((event, emit) async {
      emit(VideoLoading());
      try {
        final videos = await getVideos();
        emit(VideoLoaded(videos));
      } catch (e) {
        emit(VideoError('Failed to fetch videos'));
      }
    });
  }
}
