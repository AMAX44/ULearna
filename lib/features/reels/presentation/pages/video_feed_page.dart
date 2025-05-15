import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:vibration/vibration.dart';

import 'package:reel_app/features/reels/presentation/bloc/video_bloc.dart';
import 'package:reel_app/features/reels/presentation/bloc/video_event.dart';
import 'package:reel_app/features/reels/presentation/bloc/video_state.dart';
import 'package:reel_app/injection_container.dart';

class VideoFeedPage extends StatefulWidget {
  const VideoFeedPage({super.key});

  @override
  State<VideoFeedPage> createState() => _VideoFeedPageState();
}

class _VideoFeedPageState extends State<VideoFeedPage> {
  final PageController _pageController = PageController();

  // Track current page index to control videos accordingly
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();

    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (_currentPageIndex != page) {
        setState(() {
          _currentPageIndex = page;
        });
      }
    });
  }

  void _scrollToTop() {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const appBarColor = Color(0xFF5385C7);

    return Scaffold(
      backgroundColor: appBarColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 4,
        centerTitle: true,
        title: GestureDetector(
          onTap: _scrollToTop,
          child: const Text(
            'Ulearna',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
      body: BlocProvider(
        create: (context) => sl<VideoBloc>()..add(LoadVideos()),
        child: BlocBuilder<VideoBloc, VideoState>(
          builder: (context, state) {
            if (state is VideoLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is VideoLoaded) {
              return GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity == null) return;

                  if (details.primaryVelocity! < -500) {
                    if (_currentPageIndex < state.videos.length - 1) {
                      _pageController.animateToPage(
                        _currentPageIndex + 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  } else if (details.primaryVelocity! > 500) {
                    if (_currentPageIndex > 0) {
                      _pageController.animateToPage(
                        _currentPageIndex - 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  }
                },
                child: PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: state.videos.length,
                  itemBuilder: (context, index) {
                    final video = state.videos[index];
                    return Column(
                      children: [
                        Expanded(
                          child: VideoPlayerItem(
                            videoUrl: video.videoUrl,
                            thumbnailUrl: video.thumbnailUrl,
                            isActive: _currentPageIndex == index,
                            videoTitle: video.title,
                            userName: video.userName,
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          decoration: const BoxDecoration(
                            color: appBarColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(0, -2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                video.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'By ${video.userName ?? "Anonymous"}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            } else if (state is VideoError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  final String thumbnailUrl;
  final bool isActive;
  final String videoTitle;
  final String? userName;

  const VideoPlayerItem({
    Key? key,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.isActive,
    required this.videoTitle,
    this.userName,
  }) : super(key: key);

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem>
    with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isLiked = false;
  bool _isMuted = false;
  bool _showPauseIcon = false;
  bool _showMuteIcon = false;
  bool _showLikeIcon = false;
  IconData _centerVolumeIcon = Icons.volume_off;

  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;

  bool _hasError = false;

  // For scrubbing
  double? _dragStartPosition;
  Duration? _dragStartVideoPosition;

  // For progress bar animation update
  late VoidCallback _videoListener;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(widget.videoUrl);

    _videoListener = () {
      if (mounted) {
        setState(() {}); // to update progress bar & UI
      }
    };

    _initializeVideo();

    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _likeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  Future<void> _initializeVideo() async {
    try {
      await _controller.initialize();
      _controller.setLooping(true);
      _controller.addListener(_videoListener);
      setState(() {
        _isInitialized = true;
      });
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
      if (widget.isActive) {
        _controller.play();
      }
    } catch (e) {
      setState(() {
        _hasError = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.white70),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Can't play this video, scroll to the next please.",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
          elevation: 8,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(covariant VideoPlayerItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !_controller.value.isPlaying && !_hasError) {
      _controller.play();
    } else if (!widget.isActive && _controller.value.isPlaying) {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    setState(() {
      _isLiked = !_isLiked;
      _showLikeIcon = true;
    });

    _likeAnimationController.forward(from: 0.0);

    // Vibration & sound feedback on like
    _vibrateFeedback();

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() => _showLikeIcon = false);
      }
    });
  }

  void _onTap() {
    setState(() {
      _isMuted = !_isMuted;
      _centerVolumeIcon = _isMuted ? Icons.volume_off : Icons.volume_up;
      _showMuteIcon = true;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });

    // Vibration & sound feedback on mute/unmute
    _vibrateFeedback();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _showMuteIcon = false);
      }
    });
  }

  void _vibrateFeedback() async {
    // Use vibration package or fallback to light haptic feedback
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    } else {
      HapticFeedback.lightImpact();
    }
  }

  void _onLongPress() {
    setState(() => _showPauseIcon = true);
    _controller.pause();
  }

  void _onLongPressUp() {
    setState(() => _showPauseIcon = false);
    if (widget.isActive) {
      _controller.play();
    }
  }

  // Handle horizontal drag for scrubbing video timeline
  void _onHorizontalDragStart(DragStartDetails details) {
    if (!_isInitialized) return;
    _dragStartPosition = details.globalPosition.dx;
    _dragStartVideoPosition = _controller.value.position;
    _controller.pause();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_isInitialized ||
        _dragStartPosition == null ||
        _dragStartVideoPosition == null)
      return;

    final dragDelta = details.globalPosition.dx - _dragStartPosition!;
    final videoDuration = _controller.value.duration;

    // Calculate scrub seconds (drag 100 px = ~5 seconds)
    final secondsPerPixel = 5 / 100;
    final scrubSeconds = dragDelta * secondsPerPixel;

    var newPosition =
        _dragStartVideoPosition! + Duration(seconds: scrubSeconds.round());
    if (newPosition < Duration.zero) newPosition = Duration.zero;
    if (newPosition > videoDuration) newPosition = videoDuration;

    _controller.seekTo(newPosition);
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!_isInitialized) return;
    if (widget.isActive) {
      _controller.play();
    }
    _dragStartPosition = null;
    _dragStartVideoPosition = null;
  }

  void _onCommentPressed() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Sample static comments
        final comments = [
          'Awesome video! 🔥',
          'Loved the part at 0:45',
          'Can you share more like this?',
          'Great content, keep it up!',
          'Where was this shot?',
        ];

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Comments',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: comments.length,
                  separatorBuilder:
                      (context, index) => const Divider(color: Colors.white24),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blueGrey,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        comments[index],
                        style: const TextStyle(color: Colors.white70),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _onSharePressed() {
    // Vibrate feedback on share
    _vibrateFeedback();

    // Use share_plus package for platform share sheet
    Share.share(
      'Check out this video: ${widget.videoUrl}',
      subject: widget.videoTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoDuration = _controller.value.duration;
    final videoPosition = _controller.value.position;
    final progressPercent =
        videoDuration.inMilliseconds > 0
            ? videoPosition.inMilliseconds / videoDuration.inMilliseconds
            : 0.0;

    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      onTap: _onTap,
      onLongPress: _onLongPress,
      onLongPressUp: _onLongPressUp,

      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,

      child: Stack(
        fit: StackFit.expand,
        children: [
          // Show thumbnail if not initialized or error
          if (!_isInitialized || _hasError)
            Image.network(widget.thumbnailUrl, fit: BoxFit.cover),

          // Show video if initialized and not error
          if (_isInitialized && !_hasError)
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),

          // Spinner while loading
          if (!_isInitialized && !_hasError)
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // Heart animation
          if (_showLikeIcon)
            Center(
              child: ScaleTransition(
                scale: _likeAnimation,
                child: Icon(
                  Icons.favorite,
                  size: 100,
                  color: Colors.red.withOpacity(0.85),
                ),
              ),
            ),

          // Mute/unmute icon at center with circular progress indicator around it
          if (_showMuteIcon)
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: progressPercent,
                      color: Colors.white70,
                      backgroundColor: Colors.white12,
                      strokeWidth: 4,
                    ),
                  ),
                  Icon(_centerVolumeIcon, size: 50, color: Colors.white70),
                ],
              ),
            ),

          // Pause icon on hold with circular progress indicator around it
          if (_showPauseIcon)
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: progressPercent,
                      color: Colors.white70,
                      backgroundColor: Colors.white12,
                      strokeWidth: 4,
                    ),
                  ),
                  const Icon(
                    Icons.pause_circle_filled,
                    size: 60,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),

          // Subtle progress bar at bottom of video (height 4)
          if (_isInitialized && !_hasError)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LinearProgressIndicator(
                value: progressPercent,
                minHeight: 4,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            ),

          // Right-side UI
          Positioned(
            right: 10,
            bottom: 150,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.white,
                    size: 35,
                  ),
                  onPressed: _onDoubleTap,
                ),
                const SizedBox(height: 20),
                IconButton(
                  icon: const Icon(
                    Icons.comment,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: _onCommentPressed,
                ),
                const SizedBox(height: 20),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white, size: 30),
                  onPressed: _onSharePressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
