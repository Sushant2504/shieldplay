import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../providers/video_provider.dart';
import '../providers/security_provider.dart';
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
  bool _isMuted = false;
  double _volume = 1.0;
  Timer? _watermarkTimer;
  String _currentWatermark = '';

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _startWatermarkTimer();
  }

  @override
  void dispose() {
    _watermarkTimer?.cancel();
    super.dispose();
  }

  void _startWatermarkTimer() {
    _updateWatermark();
    _watermarkTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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

  Future<void> _toggleMute() async {
    final videoProvider = context.read<VideoProvider>();
    if (videoProvider.controller == null) return;
    
    try {
      setState(() {
        _isMuted = !_isMuted;
        _volume = _isMuted ? 0.0 : 1.0;
      });
      await videoProvider.controller!.setVolume(_volume);
    } catch (e) {
      debugPrint('Error toggling mute: $e');
    }
  }

  Future<void> _setVolume(double value) async {
    final videoProvider = context.read<VideoProvider>();
    if (videoProvider.controller == null) return;
    
    try {
      setState(() {
        _volume = value;
        _isMuted = value == 0.0;
      });
      await videoProvider.controller!.setVolume(value);
    } catch (e) {
      debugPrint('Error setting volume: $e');
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
                onPressed: () => GoRouter.of(context).pop(),
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
                              onPressed: () => GoRouter.of(context).pop(),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.speed, color: Colors.white),
                              onPressed: _toggleSpeedMenu,
                            ),
                            if (currentVideo.qualities.length > 1)
                              IconButton(
                                icon: const Icon(Icons.settings, color: Colors.white),
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
                            ...['0.5x', '1.0x', '1.5x', '2.0x'].map((speed) {
                              final speedValue = double.parse(speed.replaceAll('x', ''));
                              final isSelected = videoProvider.playbackSpeed == speedValue;
                              return InkWell(
                                onTap: () {
                                  videoProvider.setPlaybackSpeed(speedValue);
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
                                        speed,
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
                                  icon: Icon(
                                    videoProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => videoProvider.togglePlay(),
                                ),
                                Text(
                                  '${VideoUtils.formatDuration(videoProvider.currentPosition)} / ${VideoUtils.formatDuration(videoProvider.totalDuration)}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: Icon(
                                    _isMuted ? Icons.volume_off : Icons.volume_up,
                                    color: Colors.white,
                                  ),
                                  onPressed: _toggleMute,
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Slider(
                                    value: _volume,
                                    onChanged: _setVolume,
                                    activeColor: AppConstants.primaryColor,
                                    inactiveColor: Colors.grey[400],
                                  ),
                                ),
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