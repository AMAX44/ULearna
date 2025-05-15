import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reel_app/features/reels/presentation/bloc/video_bloc.dart';
import 'package:reel_app/features/reels/presentation/bloc/video_event.dart';
import 'package:reel_app/features/reels/presentation/pages/video_feed_page.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Video Feed App',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: BlocProvider(
        create: (_) => di.sl<VideoBloc>()..add(LoadVideos()),
        child: const VideoFeedPage(),
      ),
    );
  }
}
