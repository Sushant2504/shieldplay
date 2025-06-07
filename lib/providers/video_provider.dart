import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/video_model.dart';
import '../services/video_service.dart';

class VideoProvider extends ChangeNotifier {
  final VideoService _videoService;
  List<VideoModel> _videos = [];
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  String? _error;
  bool _isLoading = false;
  bool _isInitialized = false;

  VideoProvider(this._videoService) {
    _initialize();
  }

  List<VideoModel> get videos => _videos;
  VideoPlayerController? get controller => _controller;
  bool get isPlaying => _isPlaying;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  Duration get currentPosition => _controller?.value.position ?? Duration.zero;
  Duration get totalDuration => _controller?.value.duration ?? Duration.zero;

  Future<void> _initialize() async {
    try {
      await loadVideos();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadVideos() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final videos = await _videoService.getAvailableVideos();
      _videos = videos;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> initializeVideo(String path) async {
    try {
      _error = null;
      notifyListeners();

      await _controller?.dispose();
      _controller = VideoPlayerController.network(path);
      await _controller!.initialize();
      _controller!.addListener(_videoListener);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _videoListener() {
    if (_controller != null) {
      _isPlaying = _controller!.value.isPlaying;
      notifyListeners();
    }
  }

  void togglePlay() {
    if (_controller != null) {
      if (_isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    }
  }

  void seekTo(Duration position) {
    _controller?.seekTo(position);
  }

  Future<void> toggleVideoCache(VideoModel video) async {
    if (!_isInitialized) return;

    try {
      _error = null;
      notifyListeners();

      if (video.isCached) {
        await _videoService.removeFromCache(video.path);
      } else {
        await _videoService.cacheVideo(video);
      }

      // Update video cache status
      final index = _videos.indexWhere((v) => v.id == video.id);
      if (index != -1) {
        _videos[index] = video.copyWith(isCached: !video.isCached);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearCache() async {
    if (!_isInitialized) return;

    try {
      _error = null;
      notifyListeners();

      await _videoService.clearCache();
      
      // Update all videos' cache status
      _videos = _videos.map((video) => video.copyWith(isCached: false)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }
} 