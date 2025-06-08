import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/video_model.dart';
import '../services/video_service.dart';
import '../utils/video_utils.dart';
import 'dart:io';

class VideoProvider extends ChangeNotifier {
  final VideoService _videoService;
  List<VideoModel> _videos = [];
  bool _isLoading = false;
  String? _error;
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _isBuffering = false;
  String _currentQuality = 'auto';
  double _playbackSpeed = 1.0;

  VideoProvider(this._videoService);

  List<VideoModel> get videos => _videos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  VideoPlayerController? get controller => _controller;
  Duration get currentPosition => _controller?.value.position ?? Duration.zero;
  Duration get totalDuration => _controller?.value.duration ?? Duration.zero;
  double get aspectRatio => _controller?.value.aspectRatio ?? 16 / 9;
  String get currentQuality => _currentQuality;
  double get playbackSpeed => _playbackSpeed;

  Future<void> loadVideos() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Load local videos
      final localVideos = await _videoService.getVideos();
      
      // Add network videos with different quality options
      final networkVideos = await _getNetworkVideos();
      
      _videos = [...localVideos, ...networkVideos];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<List<VideoModel>> _getNetworkVideos() async {
    final List<VideoModel> videoModels = [];
    
    try {
      final videoList = [
        {
          'id': 'video1',
          'title': 'Big Buck Bunny',
          'duration': const Duration(minutes: 9, seconds: 56),
          'qualities': {
            '1080p': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
            '720p': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny_720p.mp4',
          },
          'thumbnail': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg',
        },
        {
          'id': 'video2',
          'title': 'Elephant Dream',
          'duration': const Duration(minutes: 10, seconds: 53),
          'qualities': {
            '1080p': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
            '720p': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream_720p.mp4',
          },
          'thumbnail': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg',
        },
        {
          'id': 'video3',
          'title': 'Sintel',
          'duration': const Duration(minutes: 14, seconds: 48),
          'qualities': {
            '1080p': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
            '720p': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel_720p.mp4',
          },
          'thumbnail': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/Sintel.jpg',
        },
      ];

      for (final video in videoList) {
        videoModels.add(VideoModel(
          id: video['id'] as String,
          title: video['title'] as String,
          path: (video['qualities'] as Map<String, String>)['1080p']!,
          duration: video['duration'] as Duration,
          thumbnail: video['thumbnail'] as String,
          source: VideoSource.network,
          isCached: false,
          qualities: video['qualities'] as Map<String, String>,
        ));
      }
    } catch (e) {
      debugPrint('Error fetching videos: $e');
    }

    return videoModels;
  }

  Future<void> initializeVideo(VideoModel video) async {
    try {
      await _controller?.dispose();
      _controller = null;
      _isPlaying = false;
      _isBuffering = true;
      notifyListeners();

      if (video.source == VideoSource.network) {
        final url = video.qualities[_currentQuality] ?? video.qualities['1080p']!;
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(url),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      } else {
        _controller = VideoPlayerController.file(
          File(video.path),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      }

      await _controller!.initialize();
      _controller!.addListener(_videoListener);
      await _controller!.setPlaybackSpeed(_playbackSpeed);
      await _controller!.setVolume(1.0);
      await _controller!.play();
      
      _isBuffering = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isBuffering = false;
      notifyListeners();
      debugPrint('Error initializing video: $e');
    }
  }

  Future<void> changeQuality(String quality) async {
    if (_currentQuality == quality) return;
    
    final currentVideo = _videos.firstWhere(
      (v) => v.path == _controller?.dataSource,
      orElse: () => throw Exception('Current video not found'),
    );

    _currentQuality = quality;
    await initializeVideo(currentVideo);
  }

  void _videoListener() {
    if (_controller != null) {
      final wasPlaying = _isPlaying;
      final wasBuffering = _isBuffering;
      
      _isPlaying = _controller!.value.isPlaying;
      _isBuffering = _controller!.value.isBuffering;
      
      if (wasPlaying != _isPlaying || wasBuffering != _isBuffering) {
        notifyListeners();
      }
    }
  }

  Future<void> togglePlay() async {
    if (_controller == null) return;

    try {
      if (_isPlaying) {
        await _controller!.pause();
      } else {
        await _controller!.setVolume(1.0);
        await _controller!.play();
      }
    } catch (e) {
      debugPrint('Error toggling play state: $e');
    }
  }

  Future<void> seekTo(Duration position) async {
    if (_controller == null) return;
    
    try {
      await _controller!.seekTo(position);
    } catch (e) {
      debugPrint('Error seeking video: $e');
    }
  }

  Future<void> toggleVideoCache(VideoModel video) async {
    if (video.source != VideoSource.network) return;

    try {
      final index = _videos.indexWhere((v) => v.id == video.id);
      if (index == -1) return;

      if (video.isCached) {
        await _videoService.removeFromCache(video);
        _videos[index] = video.copyWith(isCached: false);
      } else {
        await _videoService.cacheVideo(video);
        _videos[index] = video.copyWith(isCached: true);
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearCache() async {
    try {
      await _videoService.clearCache();
      _videos = _videos.map((video) {
        if (video.source == VideoSource.network) {
          return video.copyWith(isCached: false);
        }
        return video;
      }).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> setPlaybackSpeed(double speed) async {
    if (_controller == null) return;
    
    try {
      _playbackSpeed = speed;
      await _controller!.setPlaybackSpeed(speed);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting playback speed: $e');
    }
  }

  Future<void> addLocalVideo(String filePath) async {
    try {
      if (!VideoUtils.isVideoFile(filePath)) {
        throw Exception('Unsupported video format');
      }

      final video = await VideoUtils.createVideoModel(filePath);
      _videos.add(video);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('Error adding local video: $e');
    }
  }

  Future<void> stopAndDispose() async {
    if (_controller != null) {
      await _controller!.pause();
      await _controller!.dispose();
      _controller = null;
      _isPlaying = false;
      _isBuffering = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopAndDispose();
    super.dispose();
  }
} 