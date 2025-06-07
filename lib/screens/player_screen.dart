import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../providers/video_provider.dart';
import '../providers/security_provider.dart';
import '../widgets/custom_video_player.dart';

class PlayerScreen extends StatefulWidget {
  final String videoId;

  const PlayerScreen({
    super.key,
    required this.videoId,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _showControls = true;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final videoProvider = context.read<VideoProvider>();
    final video = videoProvider.videos.firstWhere(
      (v) => v.id == widget.videoId,
      orElse: () => throw Exception('Video not found'),
    );
    await videoProvider.initializeVideo(video.path);
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<VideoProvider, SecurityProvider>(
      builder: (context, videoProvider, securityProvider, child) {
        if (videoProvider.error != null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${videoProvider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => GoRouter.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: GestureDetector(
              onTap: _toggleControls,
              child: Stack(
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: videoProvider.controller?.value.aspectRatio ?? 16 / 9,
                      child: CustomVideoPlayer(
                        controller: videoProvider.controller!,
                        showControls: _showControls,
                        isFullScreen: _isFullScreen,
                        onToggleFullScreen: _toggleFullScreen,
                        onTogglePlay: videoProvider.togglePlay,
                        onSeek: videoProvider.seekTo,
                        currentPosition: videoProvider.currentPosition,
                        totalDuration: videoProvider.totalDuration,
                        isPlaying: videoProvider.isPlaying,
                      ),
                    ),
                  ),
                  if (_showControls)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.black54,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => GoRouter.of(context).pop(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 