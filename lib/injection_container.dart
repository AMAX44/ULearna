import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:reel_app/features/reels/domain/repositories/video_repository_impl.dart';
import 'features/reels/data/datasources/video_remote_data_source.dart';
import 'features/reels/domain/repositories/video_repository.dart';
import 'features/reels/domain/usecases/get_videos.dart';
import 'features/reels/presentation/bloc/video_bloc.dart';

final sl = GetIt.instance;

void init() {
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton<VideoRemoteDataSource>(
    () => VideoRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<VideoRepository>(() => VideoRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetVideos(sl()));
  sl.registerFactory(() => VideoBloc(sl()));
}
