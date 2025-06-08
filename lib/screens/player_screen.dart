import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../providers/video_provider.dart';
import '../providers/security_provider.dart';
import '../providers/screenshot_provider.dart';
import '../utils/constants.dart';
import '../utils/video_utils.dart';
import 'dart:async';

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
  bool _isInitialized = false;
  bool _showQualityMenu = false;
  bool _showSpeedMenu = false;
  Timer? _watermarkTimer;
  String _currentWatermark = '';

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _startWatermarkTimer();
    _setupScreenshotProtection();
  }

  void _setupScreenshotProtection() {
    final screenshotService = context.read<ScreenshotProvider>().screenshotService;
    screenshotService.enableScreenshotProtection(
      onScreenshotAttempt: _handleScreenshotAttempt,
    );
  }

  void _handleScreenshotAttempt() async {
    final videoProvider = context.read<VideoProvider>();
    final screenshotProvider = context.read<ScreenshotProvider>();
    
    // First pause the video
    await videoProvider.controller!.pause();
    
    // Then increment screenshot count
    await screenshotProvider.incrementScreenshotCount();
    
    // Finally show warning dialog
    _showScreenshotWarning();
  }

  void _showScreenshotWarning() {
    final screenshotCount = context.read<ScreenshotProvider>().screenshotCount;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Screenshot Blocked'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Screenshots are not allowed for private content.'),
            const SizedBox(height: 8),
            Text(
              'Screenshot attempts: $screenshotCount',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Resume video playback after dialog is dismissed
              final videoProvider = context.read<VideoProvider>();
              if (videoProvider.controller != null) {
                videoProvider.controller!.play();
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _watermarkTimer?.cancel();
    final screenshotService = context.read<ScreenshotProvider>().screenshotService;
    screenshotService.disableScreenshotProtection();
    context.read<VideoProvider>().stopAndDispose();
    super.dispose();
  }

  void _startWatermarkTimer() {
    _updateWatermark();
    _watermarkTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateWatermark();
    });
  }

  void _updateWatermark() {
    final now = DateTime.now();
    final watermark = context.read<SecurityProvider>().watermarkText;
    setState(() {
      _currentWatermark = '$watermark\n${now.toString().split('.')[0]}';
    });
  }

  Future<void> _initializeVideo() async {
    try {
      final videoProvider = context.read<VideoProvider>();
      final video = videoProvider.videos.firstWhere(
        (v) => v.id == widget.videoId,
        orElse: () => throw Exception('Video not found'),
      );
      await videoProvider.initializeVideo(video);
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _showQualityMenu = false;
      }
    });
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  void _toggleQualityMenu() {
    setState(() {
      _showQualityMenu = !_showQualityMenu;
    });
  }

  void _toggleSpeedMenu() {
    setState(() {
      _showSpeedMenu = !_showSpeedMenu;
    });
  }

  List<double> _getAvailableSpeeds(SecurityProvider securityProvider) {
    if (securityProvider.isSecureMode) {
      return [0.5, 1.0, 1.5, 2.0]; // Limited speeds in secure mode
    }
    return [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 4.0]; // Full range of speeds
  }

  Future<void> _rewindVideo() async {
    final videoProvider = context.read<VideoProvider>();
    if (videoProvider.controller == null) return;
    
    try {
      final newPosition = videoProvider.currentPosition - const Duration(seconds: 10);
      await videoProvider.seekTo(newPosition > Duration.zero ? newPosition : Duration.zero);
    } catch (e) {
      debugPrint('Error rewinding video: $e');
    }
  }

  Future<void> _forwardVideo() async {
    final videoProvider = context.read<VideoProvider>();
    if (videoProvider.controller == null) return;
    
    try {
      final newPosition = videoProvider.currentPosition + const Duration(seconds: 10);
      if (newPosition < videoProvider.totalDuration) {
        await videoProvider.seekTo(newPosition);
      }
    } catch (e) {
      debugPrint('Error forwarding video: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<VideoProvider, SecurityProvider>(
      builder: (context, videoProvider, securityProvider, child) {
        if (videoProvider.error != null) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  context.read<VideoProvider>().stopAndDispose();
                  GoRouter.of(context).pop();
                },
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${videoProvider.error}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _initializeVideo,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (!_isInitialized || videoProvider.controller == null) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Loading video...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        }

        final currentVideo = videoProvider.videos.firstWhere(
          (v) => v.id == widget.videoId,
          orElse: () => throw Exception('Video not found'),
        );

        return WillPopScope(
          onWillPop: () async {
            if (_isFullScreen) {
              setState(() {
                _isFullScreen = false;
              });
              return false;
            }
            return true;
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: videoProvider.aspectRatio,
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: _toggleControls,
                            child: VideoPlayer(videoProvider.controller!),
                          ),
                          if (securityProvider.watermarkText.isNotEmpty)
                            Positioned.fill(
                              child: Center(
                                child: Text(
                                  _currentWatermark,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.8),
                                        offset: const Offset(1, 1),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (_showControls)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () {
                                context.read<VideoProvider>().stopAndDispose();
                                GoRouter.of(context).pop();
                              },
                            ),
                            const Spacer(),
                            if (!securityProvider.isSecureMode) ...[
                              IconButton(
                                icon: const Icon(Icons.speed, color: Colors.white),
                                onPressed: _toggleSpeedMenu,
                              ),
                              if (currentVideo.qualities.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.high_quality, color: Colors.white),
                                  onPressed: _toggleQualityMenu,
                                ),
                              IconButton(
                                icon: Icon(
                                  _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                                  color: Colors.white,
                                ),
                                onPressed: _toggleFullScreen,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  if (_showSpeedMenu)
                    Positioned(
                      top: 60,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Playback Speed',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._getAvailableSpeeds(securityProvider).map((speed) {
                              final speedText = '${speed.toStringAsFixed(1)}x';
                              final isSelected = videoProvider.playbackSpeed == speed;
                              return InkWell(
                                onTap: () {
                                  videoProvider.setPlaybackSpeed(speed);
                                  _toggleSpeedMenu();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                                        color: isSelected ? AppConstants.primaryColor : Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        speedText,
                                        style: TextStyle(
                                          color: isSelected ? AppConstants.primaryColor : Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  if (_showQualityMenu)
                    Positioned(
                      top: 60,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quality',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...currentVideo.qualities.keys.map((quality) {
                              final isSelected = videoProvider.currentQuality == quality;
                              return InkWell(
                                onTap: () {
                                  videoProvider.changeQuality(quality);
                                  _toggleQualityMenu();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                                        color: isSelected ? AppConstants.primaryColor : Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        quality,
                                        style: TextStyle(
                                          color: isSelected ? AppConstants.primaryColor : Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  if (_showControls)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            VideoProgressIndicator(
                              videoProvider.controller!,
                              allowScrubbing: true,
                              colors: VideoProgressColors(
                                playedColor: AppConstants.primaryColor,
                                bufferedColor: Colors.grey[400]!,
                                backgroundColor: Colors.grey[600]!,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.replay_10, color: Colors.white),
                                  onPressed: _rewindVideo,
                                ),
                                IconButton(
                                  icon: Icon(
                                    videoProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => videoProvider.togglePlay(),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.forward_10, color: Colors.white),
                                  onPressed: _forwardVideo,
                                ),
                                Text(
                                  '${VideoUtils.formatDuration(videoProvider.currentPosition)} / ${VideoUtils.formatDuration(videoProvider.totalDuration)}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const Spacer(),
                                if (securityProvider.watermarkText.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(
                                      securityProvider.watermarkText,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
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