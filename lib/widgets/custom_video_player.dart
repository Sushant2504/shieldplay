import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';

class CustomVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final bool showControls;
  final bool isFullScreen;
  final VoidCallback onToggleFullScreen;
  final VoidCallback onTogglePlay;
  final Function(Duration) onSeek;
  final Duration currentPosition;
  final Duration totalDuration;
  final bool isPlaying;

  const CustomVideoPlayer({
    super.key,
    required this.controller,
    required this.showControls,
    required this.isFullScreen,
    required this.onToggleFullScreen,
    required this.onTogglePlay,
    required this.onSeek,
    required this.currentPosition,
    required this.totalDuration,
    required this.isPlaying,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  bool _showWatermark = true;
  DateTime _lastWatermarkUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startWatermarkUpdate();
  }

  void _startWatermarkUpdate() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _showWatermark = !_showWatermark;
          _lastWatermarkUpdate = DateTime.now();
        });
        _startWatermarkUpdate();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video
        VideoPlayer(widget.controller),
        
        // Watermark
        Positioned(
          bottom: 16,
          right: 16,
          child: Consumer<SecurityProvider>(
            builder: (context, securityProvider, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  securityProvider.watermarkText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),

        // Controls
        if (widget.showControls)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        widget.isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                        color: Colors.white,
                      ),
                      onPressed: widget.onToggleFullScreen,
                    ),
                  ],
                ),
                // Bottom controls
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Progress bar
                      Slider(
                        value: widget.currentPosition.inSeconds.toDouble(),
                        min: 0,
                        max: widget.totalDuration.inSeconds.toDouble(),
                        onChanged: (value) {
                          widget.onSeek(Duration(seconds: value.toInt()));
                        },
                      ),
                      // Playback controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(widget.currentPosition),
                            style: const TextStyle(color: Colors.white),
                          ),
                          IconButton(
                            icon: Icon(
                              widget.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed: widget.onTogglePlay,
                          ),
                          Text(
                            _formatDuration(widget.totalDuration),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
} 