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
      children: [
        // Video
        Center(
          child: AspectRatio(
            aspectRatio: widget.controller.value.aspectRatio,
            child: VideoPlayer(widget.controller),
          ),
        ),

        // Watermark
        if (_showWatermark)
          Positioned(
            bottom: 16,
            right: 16,
            child: Consumer<SecurityProvider>(
              builder: (context, securityProvider, child) {
                return Text(
                  '${securityProvider.watermarkText}\n${_lastWatermarkUpdate.toString().split('.')[0]}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        // Controls
        if (widget.showControls)
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onTogglePlay,
              child: Container(
                color: Colors.black26,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
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

                    // Control buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Play/Pause button
                          IconButton(
                            icon: Icon(
                              widget.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: widget.onTogglePlay,
                          ),

                          // Time display
                          Text(
                            '${_formatDuration(widget.currentPosition)} / ${_formatDuration(widget.totalDuration)}',
                            style: const TextStyle(color: Colors.white),
                          ),

                          // Fullscreen button
                          IconButton(
                            icon: Icon(
                              widget.isFullScreen
                                  ? Icons.fullscreen_exit
                                  : Icons.fullscreen,
                              color: Colors.white,
                            ),
                            onPressed: widget.onToggleFullScreen,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
} 